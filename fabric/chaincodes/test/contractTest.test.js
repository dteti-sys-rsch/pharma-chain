const assert = require('assert');
const { ChaincodeStub } = require('fabric-shim');
const { MyContract } = require('../lib/contract');

describe('MyContract', () => {
  let stub;

  beforeEach(() => {
    stub = sinon.createStubInstance(ChaincodeStub);
  });

  describe('#init', () => {
    it('should initialize the chaincode', async () => {
      const contract = new MyContract();
      await contract.Init(stub);
      sinon.assert.calledOnce(stub.putState);
    });
  });

  describe('#invoke', () => {
    it('should invoke the chaincode', async () => {
      const contract = new MyContract();
      await contract.Invoke(stub);
      sinon.assert.calledOnce(stub.getState);
    });
  });
});