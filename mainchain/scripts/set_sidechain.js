const nervos = require('../nervos')

const transaction = require('./transaction')

nervos.system.chainManager.options.address = "0xffffffffffffffffffffffffffffffffff020002"

nervos.appchain
  .getBlockNumber()
  .then(current => {
    transaction.validUntilBlock = +current + 88
    return nervos.system.chainManager.methods.newSideChain(3, ["0x17f3487df9f9331969602bf203165abf886a0ed1"]).send(transaction)
  })
  .then(res => {
    if (res.hash) {
    return nervos.listeners.listenToTransactionReceipt(res.hash)
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