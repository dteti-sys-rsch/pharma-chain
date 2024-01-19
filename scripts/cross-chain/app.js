/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Gateway, Wallets } = require('fabric-network');
const FabricCAServices = require('fabric-ca-client');
const path = require('path');
const { buildCAClient, registerAndEnrollUser, enrollAdmin } = require('./CAUtil.js');
const { buildCCPOrg1, buildCCPOrg4, buildWallet } = require('./AppUtil.js');

const channelHospital = 'hospital';
const channelInsurance = 'insurance';
const chaincodeHospital = 'hospital-cc';
const chaincodeInsurance = 'insurance-cc';
const mspOrg1 = 'Org1MSP';
const mspOrg4 = 'Org4MSP';
const org1UserId = 'appUser5';
const org4UserId = 'appUser6';

function prettyJSONString(inputString) {
	return JSON.stringify(JSON.parse(inputString), null, 2);
}

async function initContractFromOrg1Identity() {
	console.log('\n--> Fabric client user & Gateway init: Using Org1 identity to Org1 Peer');
	// build an in memory object with the network configuration (also known as a connection profile)
	const ccpOrg1 = buildCCPOrg1();

	// build an instance of the fabric ca services client based on
	// the information in the network configuration
	const caOrg1Client = buildCAClient(FabricCAServices, ccpOrg1, 'ca.org1.hospital.com');

	// setup the wallet to cache the credentials of the application user, on the app server locally
	const walletPathOrg1 = path.join(__dirname, 'wallet/org1');
	const walletOrg1 = await buildWallet(Wallets, walletPathOrg1);

	// in a real application this would be done on an administrative flow, and only once
	// stores admin identity in local wallet, if needed
	await enrollAdmin(caOrg1Client, walletOrg1, mspOrg1);
	// register & enroll application user with CA, which is used as client identify to make chaincode calls
	// and stores app user identity in local wallet
	// In a real application this would be done only when a new user was required to be added
	// and would be part of an administrative flow
	await registerAndEnrollUser(caOrg1Client, walletOrg1, mspOrg1, org1UserId, 'org1.department1');
	try {
		// Create a new gateway for connecting to Org's peer node.
		const gatewayOrg1 = new Gateway();
		//connect using Discovery enabled
		await gatewayOrg1.connect(ccpOrg1,
			{ wallet: walletOrg1, identity: org1UserId, discovery: { enabled: true, asLocalhost: true } });

		return gatewayOrg1;
	} catch (error) {
		console.error(`Error in connecting to gateway: ${error}`);
		process.exit(1);
	}
}

async function initContractFromOrg4Identity() {
	console.log('\n--> Fabric client user & Gateway init: Using Org4 identity to Org4 Peer');
	const ccpOrg4 = buildCCPOrg4();
	const caOrg4Client = buildCAClient(FabricCAServices, ccpOrg4, 'ca.org4.insurance.com');

	const walletPathOrg4 = path.join(__dirname, 'wallet/org4');
	const walletOrg4 = await buildWallet(Wallets, walletPathOrg4);

	await enrollAdmin(caOrg4Client, walletOrg4, mspOrg4);
	await registerAndEnrollUser(caOrg4Client, walletOrg4, mspOrg4, org4UserId, 'org4.department1');

	try {
		// Create a new gateway for connecting to Org's peer node.
		const gatewayOrg4 = new Gateway();
		await gatewayOrg4.connect(ccpOrg4,
			{ wallet: walletOrg4, identity: org4UserId, discovery: { enabled: true, asLocalhost: true } });

		return gatewayOrg4;
	} catch (error) {
		console.error(`Error in connecting to gateway: ${error}`);
		process.exit(1);
	}
}

async function main() {
	try {
		const gatewayOrg1 = await initContractFromOrg1Identity();
		const networkOrg1 = await gatewayOrg1.getNetwork(channelHospital);
		const contractOrg1 = networkOrg1.getContract(chaincodeHospital);

		const gatewayOrg4 = await initContractFromOrg4Identity();
		const networkOrg4 = await gatewayOrg4.getNetwork(channelInsurance);
		const contractOrg4 = networkOrg4.getContract(chaincodeInsurance);
		try {
			console.log('\n--> Submit Transaction: GetKey');
			let result = await contractOrg1.submitTransaction('GetKey', mspOrg1);
			console.log(`*** Result: ${result}`);

			console.log('\n--> Submit Transaction: UploadIdentity');
			result = await contractOrg4.submitTransaction('UploadIdentity', result);
			console.log(`*** Result: ${result}`);

		} finally {
			// Disconnect from the gateway when the application is closing
			// This will close all connections to the network
			gatewayOrg1.disconnect();
			gatewayOrg4.disconnect();
		}
	} catch (error) {
		console.error(`******** FAILED to run the application: ${error}`);
		if (error instanceof AggregateError) {
			// Iterate over the errors in the AggregateError
			for (const subError of error.errors) {
				console.error('Sub-error:', subError);
			}
		} else {
			console.error('Enrollment failed:', error);
		}
	}
}

main();