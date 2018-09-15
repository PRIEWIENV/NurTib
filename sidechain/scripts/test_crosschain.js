const nervos = require('../nervos')
const { abi } = require('./compiled_cross_chain_demo.js')

const tx0 = {
  from: '0x4b5ae4567ad5d9fb92bc9afd6a657e6fa13a2523',
  privateKey: '0x5f0258a4778057a8a7d97809bd209055b2fbafa654ce7d31ec7191066b9225e6',
  nonce: 999999,
  quota: 1000000000,
  chainId: 2,
  version: 0,
  validUntilBlock: 999999,
  value: '0x0',
};

// contract contract instance
const crossTokenContract = new nervos.appchain.Contract(abi, "0x10bDd1684100bbcE6C17E97DB9a3779A000b350B")

function sendToSideChain() {
  nervos.appchain
  .getBlockNumber()
  .then(current => {
    tx0.validUntilBlock = +current + 88 // update transaction.validUntilBlock
    // deploy contract
    return crossTokenContract
      .methods
      .sendToSideChain(
        3,
        "0x27Ec3678e4d61534AB8A87cF8FEB8aC110dDeda5",
        "0x" + "7".padStart(64, "0")
        )
      .send(tx0)
  })
  .then(txRes => {
    if (txRes.hash) {
      // get transaction receipt
      return nervos.listeners.listenToTransactionReceipt(txRes.hash)
    } else {
      throw new Error('No Transaction Hash Received')
    }
  })
  .then(receipt => {
    // console.log(receipt)
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
}

function recvFromSideChain(proof) {
  nervos.appchain
  .getBlockNumber()
  .then(current => {
    tx0.validUntilBlock = +current + 88 // update transaction.validUntilBlock
    // deploy contract
    return crossTokenContract
      .methods
      .recvFromSideChain(proof)
      .send(tx0)
  })
  .then(txRes => {
    if (txRes.hash) {
      // get transaction receipt
      return nervos.listeners.listenToTransactionReceipt(txRes.hash)
    } else {
      throw new Error('No Transaction Hash Received')
    }
  })
  .then(receipt => {
    // console.log(receipt)
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
}

recvFromSideChain()
