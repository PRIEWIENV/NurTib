const nervos = require('./nervos')

const transaction = require('./contracts/transaction')

nervos.system.chainManager.options.address = "0xffffffffffffffffffffffffffffffffff020002"

nervos.appchain
  .getBlockNumber()
  .then(current => {
    transaction.validUntilBlock = +current + 88
    return nervos.system.chainManager.methods.enableSideChain(3).send(transaction)
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
      if (receipt.logs.length === 0) {
        console.log(receipt)
      } else {
        var result = nervos.eth.abi.decodeLog([
            { "indexed": true, "name": "errorType", "type": "uint8" },
            { "indexed": false, "name": "msg", "type": "string" }
          ],
          receipt.logs[0].data,
          receipt.logs[0].topics
        )
        console.log(result)
      }
    } else {
    throw new Error(receipt.errorMessage)
    }
  })
  .catch(err => {
    console.log(err)
  })