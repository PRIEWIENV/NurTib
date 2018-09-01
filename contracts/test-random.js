// import sha3 from 'solidity-sha3';
const nervos = require('../nervos');
const { abi  } = require('./compiled');
// const { contractAddress } = require('../config')
// sha3_256 = require('js-sha3').sha3_256;
// const sha3 = require('solidity-sha3');
var Web3Utils = require('web3-utils');

const tx0 = {
  from: '0x17f3487df9f9331969602bf203165abf886a0ed1',
  privateKey: '0xea6b3d6d8792ab5519d89ebf54afbc906e67bf5757b717e69e1925a1d1b42154',
  nonce: 999999,
  quota: 1000000000,
  chainId: 2,
  version: 0,
  validUntilBlock: 999999,
  value: '0x0',
};

const tx1 = {
  from: '0xd4329b280baaa5e2de19d7b5cf6ecf9a0c78651d',
  privateKey: '0x53bcd05b80d1337f680077c3401c5084bb134a90ef3d0c73c9527a2ed9c60087',
  nonce: 999999,
  quota: 1000000000,
  chainId: 2,
  version: 0,
  validUntilBlock: 999999,
  value: '0x0',
};

const tx2 = {
  from: '0x08104eee6c240b856de260dba89ee313aba41b0c',
  privateKey: '0x6ef0ed0a091efb35009f7205f67fe314948f412eb8f2033a6b52193649b987ca',
  nonce: 999999,
  quota: 1000000000,
  chainId: 2,
  version: 0,
  validUntilBlock: 999999,
  value: '0x0',
};

const tx3 = {
  from: '0x674a3efc9ef5725ed9d5fc47aba5bca1c70161d7',
  privateKey: '0x3863a8ecb70afe112d9f1363cb2b8ac987cbc3c5faa1c1471761513901620e9b',
  nonce: 999999,
  quota: 1000000000,
  chainId: 2,
  version: 0,
  validUntilBlock: 999999,
  value: '0x0',
};



const account0 = nervos.appchain.accounts.privateKeyToAccount(tx0.privateKey);
const account1 = nervos.appchain.accounts.privateKeyToAccount(tx1.privateKey);
const account2 = nervos.appchain.accounts.privateKeyToAccount(tx2.privateKey);
const account3 = nervos.appchain.accounts.privateKeyToAccount(tx3.privateKey);

nervos.appchain.accounts.wallet.add(account0)
nervos.appchain.accounts.wallet.add(account1)
nervos.appchain.accounts.wallet.add(account2)
nervos.appchain.accounts.wallet.add(account3)


const randomContract = new nervos.appchain.Contract(abi, "0xD95F50bCB6CA37D74356172cfcD9e7feA94dA5C8");

// nervos.appchain.getBalance(nervos.appchain.accounts.wallet[0].address).then(console.log);
// console.log(`Interact with contract at ${contractAddress}`);
// nervos.appchain.getAccounts().then(console.log);
// console.log(nervos.appchain.accounts.wallet)

nervos.appchain.getMetaData().then(console.log);

const current_time = new Date().getTime();
const random_str = current_time.toString() + Math.floor((Math.random() * (1000 - 100) + 100)).toString() ;
const input = Web3Utils.soliditySha3(random_str)
// console.log(typeof(input))

let counter = 0;

while (counter<1){

    nervos.appchain
        .getBlockNumber()
        .then(current => {
            console.log('Get current: ' + current)
            tx0.validUntilBlock = +current + 88
            console.log(JSON.stringify(randomContract, null, 2))
            return randomContract.methods.userCommit(input).send(tx0)
        })
        .then(res => {
            if(res){
                return nervos.listeners.listenToTransactionReceipt(res)
            } else {
                throw new Error('No Transaction Hash Received')
            }
        })
        .then(receipt => {
            if (!receipt.errorMessage) {
                console.log(receipt)
            } else {
                throw new Error(receipt.errorMessage)
            }
        })
        .catch(err => {
            console.log(err)
        })
    //randomContract.methods.userReveal(random_str).send(tx0);


    //randomContract.methods.userCommit(input).send(tx1);
    //randomContract.methods.userReveal(random_str).send(tx1);

    //randomContract.methods.userCommit(input).send(tx2);
    //randomContract.methods.userReveal(random_str).send(tx2);

    //randomContract.methods.userCommit(input).send(tx3);
    //randomContract.methods.userReveal(random_str).send(tx3);

    console.log('Current round: ' + counter)
    counter++;

}
