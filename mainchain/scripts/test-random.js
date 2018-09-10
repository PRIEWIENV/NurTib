const nervos = require('../nervos');
const Web3Utils = require('web3-utils');

const abi = [{"constant":false,"inputs":[],"name":"getBlockNumber","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"founder","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_id","type":"uint256"}],"name":"getLogItem","outputs":[{"name":"","type":"address"},{"name":"","type":"uint256"},{"name":"","type":"uint256"},{"name":"","type":"uint256"},{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"_campaignID","type":"uint256"}],"name":"getCommitment","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_revealThreshold","type":"uint16"}],"name":"setThreshold","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_s","type":"uint256"}],"name":"shaCommit","outputs":[{"name":"","type":"bytes32"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_campaignID","type":"uint256"},{"name":"_s","type":"uint256"}],"name":"reveal","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"account","type":"address"}],"name":"getLogsList","outputs":[{"name":"","type":"uint256[]"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"getLogsCount","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"getCurrentRandom","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_campaignID","type":"uint256"},{"name":"_hs","type":"bytes32"}],"name":"commit","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"payable":true,"stateMutability":"payable","type":"fallback"},{"anonymous":false,"inputs":[{"indexed":true,"name":"campaignID","type":"uint256"},{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"bnum","type":"uint32"},{"indexed":false,"name":"commitBalkline","type":"uint16"},{"indexed":false,"name":"commitDeadline","type":"uint16"}],"name":"LogCampaignAdded","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"CampaignId","type":"uint256"},{"indexed":true,"name":"from","type":"address"},{"indexed":false,"name":"bountypot","type":"uint256"}],"name":"LogFollow","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"CampaignId","type":"uint256"},{"indexed":true,"name":"from","type":"address"},{"indexed":false,"name":"commitment","type":"bytes32"}],"name":"LogCommit","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"CampaignId","type":"uint256"},{"indexed":true,"name":"from","type":"address"},{"indexed":false,"name":"secret","type":"uint256"}],"name":"LogReveal","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"_revealThreshold","type":"uint16"}],"name":"LogSetThreshold","type":"event"}]

const tx = {
  from: nervos.appchain.accounts.wallet[0].address,
  privateKey: nervos.appchain.accounts.wallet[0].privateKey,
  nonce: 999999,
  quota: 1000000000,
  chainId: 2,
  version: 0,
  validUntilBlock: 999999,
  value: '0x0',
};

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


const randomContract = new nervos.appchain.Contract(abi, "0x97e5Cd9642ba9765518b9BF2E2c0245fE239270a");

// nervos.appchain.getBalance(nervos.appchain.accounts.wallet[0].address).then(console.log);
// console.log(`Interact with contract at ${contractAddress}`);
// nervos.appchain.getAccounts().then(console.log);
// console.log(nervos.appchain.accounts.wallet)

// nervos.appchain.getMetaData().then(console.log);

const current_time = new Date().getTime();
// node on appchain generates a random string
const random_str = current_time.toString() + Math.floor((Math.random() * (1000 - 100) + 100)).toString() ;
// hash the random string and input to the smart contracts
const input = Web3Utils.soliditySha3(random_str)
// console.log(input);
// console.log(typeof(input))

let counter = 1;
// console.log('counter type: ' + typeof(counter));
// console.log('counter type: ' + typeof(counter>>>0));



nervos.appchain
    .getBlockNumber()
    .then(current => {
        console.log('Get current height: ' + current)
        tx0.validUntilBlock = +current + 88
        //console.log(JSON.stringify(randomContract, null, 2))
        // >>> converts number to 32-bit unsigned int
        /* counter <uint256>, input <bytes32> */
        return randomContract.methods.commit(1, input).send(tx0)
    })
    .then(res => {
        if(res.hash){
            return nervos.listeners.listenToTransactionReceipt(res.hash)
        } else {
            throw new Error('No Transaction Hash Received')
        }
    })
    .then(receipt => {
        if (!receipt.errorMessage) {
            console.log('Success')
            console.log(receipt)
        } else {
            throw new Error(receipt.errorMessage)
        }
    })
    .catch(err => {
        console.log(err)
    })

// async () => {
//     const current = await nervos.appchain.getBlockNumber()
//     tx0.validUntilBlock = +current + 88 // update transaction.validUntilBlock
//     const txResult = await randomContract.methods.commit(counter, input).send(tx0) // sendTransaction to the contract
//     const receipt = await nervos.listeners.listenToTransactionReceipt(txResult.hash) // listen to the receipt
//     expect(receipt.errorMessage).toBeNull()
//     await console.log('Result: \n' + txResult.hash)
//     await console.log('Receipt: \n '+ receipt)
// }

//randomContract.methods.reveal(counter, random_str).send(tx0);


//randomContract.methods.commit(input).send(tx1);
//randomContract.methods.reveal(random_str).send(tx1);

//randomContract.methods.commit(input).send(tx2);
//randomContract.methods.reveal(random_str).send(tx2);

//randomContract.methods.commit(input).send(tx3);
//randomContract.methods.reveal(random_str).send(tx3);

console.log('Current round: ' + counter)
counter++;

