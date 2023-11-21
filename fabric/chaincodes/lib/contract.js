// updatevalues.js
'use strict';

// SDK Library to asset with writing the logic
const { Contract } = require('fabric-contract-api');
const { Client } = require('pg');
const { MongoClient } = require('mongodb');

class PharmaChaincode extends Contract {
  async UploadIdentity(ctx, pubkey) {
    const mspid = ctx.clientIdentity.getMSPID();
    await ctx.stub.putState(mspid, pubkey);
  }
  async GetKey(ctx, mspid) {
    const pubkey = await ctx.stub.getState(mspid);
    return pubkey.toString();
  }
  async UploadTxn(ctx, txn, keys) {
    const { createHash } = require('crypto');
    const hashfunc = createHash('sha256');

    var prev = ctx.stub.getState("statehash").toString();
    if (!prev || prev.length === 0) {
        prev = hashfunc.update("0").digest('hex');
    }

    const statehash = hashfunc.update(prev + txn).digest('hex');
    await ctx.stub.putState("statehash", statehash);

    return statehash;
  }
/*   async initLedger(ctx) {
    // Initialize the ledger with any necessary data
  }

  async createData(ctx, key, value) {
    // Create a new data object on the blockchain
  }

  async readData(ctx, key) {
    // Read an existing data object from the blockchain
  }

  async updateData(ctx, key, newValue) {
    // Update an existing data object on the blockchain
  }

  async deleteData(ctx, key) {
    // Delete an existing data object from the blockchain
  } */

  async sendDataToSQL(ctx, key) {
    // Send data from the blockchain to an off-chain SQL database
    const client = new Client({
      user: 'username',
      host: 'localhost',
      database: 'mydatabase',
      password: 'mypassword',
      port: 5432,
    });
    await client.connect();
    const result = await client.query(`INSERT INTO mytable (key, value) VALUES ('${key}', '${value}')`);
    await client.end();
    return result;
  }

  async receiveDataFromSQL(ctx, key) {
    // Receive data from an off-chain SQL database and store it on the blockchain
    const client = new Client({
      user: 'username',
      host: 'localhost',
      database: 'mydatabase',
      password: 'mypassword',
      port: 5432,
    });
    await client.connect();
    const result = await client.query(`SELECT * FROM mytable WHERE key = '${key}'`);
    await client.end();
    return result.rows[0];
  }

  async sendDataToNoSQL(ctx, key) {
    // Send data from the blockchain to an off-chain NoSQL database
    const client = new MongoClient('mongodb://localhost:27017');
    await client.connect();
    const db = client.db('mydatabase');
    const collection = db.collection('mycollection');
    const result = await collection.insertOne({ key, value });
    await client.close();
    return result;
  }

  async receiveDataFromNoSQL(ctx, key) {
    // Receive data from an off-chain NoSQL database and store it on the blockchain
    const client = new MongoClient('mongodb://localhost:27017');
    await client.connect();
    const db = client.db('mydatabase');
    const collection = db.collection('mycollection');
    const result = await collection.findOne({ key });
    await client.close();
    return result;
  }
}

module.exports = PharmaChaincode;
