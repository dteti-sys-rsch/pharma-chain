'use strict';

const Chaincode = require('./lib/contract');

module.exports.contracts = [Chaincode];

const pharmaChaincode = new Chaincode();

pharmaChaincode.Init();
pharmaChaincode.Invoke();