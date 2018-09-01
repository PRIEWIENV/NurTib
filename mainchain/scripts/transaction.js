const nervos = require('../nervos')
const transaction = {
  from: nervos.appchain.accounts.wallet[0].address,
  privateKey: nervos.appchain.accounts.wallet[0].privateKey,
  nonce: 999999,
  quota: 1000000000,
  chainId: 3,
  version: 0,
  validUntilBlock: 999999,
  value: '0x0',
};

module.exports = transaction
