
// updatevalues.js
'use strict';

// SDK Library to asset with writing the logic
const { Contract } = require('fabric-contract-api');

class Chaincode extends Contract {
    async Init(stub) {
        console.info('Init contract');
        return shim.success();
    }
}