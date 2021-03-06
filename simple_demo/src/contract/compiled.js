const bytecode = '608060405234801561001057600080fd5b50336000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff16021790555061032f806100606000396000f300608060405260043610610057576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806376911357146100b45780638b7afe2e146100f5578063a9e732bb14610120575b3373ffffffffffffffffffffffffffffffffffffffff166000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff161415156100b257600080fd5b005b3480156100c057600080fd5b506100df6004803603810190808035906020019092919050505061014d565b6040518082815260200191505060405180910390f35b34801561010157600080fd5b5061010a6101c0565b6040518082815260200191505060405180910390f35b34801561012c57600080fd5b5061014b600480360381019080803590602001909291905050506101df565b005b600080600361016760038581151561016157fe5b06610284565b81151561017057fe5b069050803373ffffffffffffffffffffffffffffffffffffffff167f3915e4f072718b808de1d573f6f881b1d613f58d9ed6b54da0f60ef661cf5da260405160405180910390a380915050919050565b60003073ffffffffffffffffffffffffffffffffffffffff1631905090565b3373ffffffffffffffffffffffffffffffffffffffff166000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1614151561023a57600080fd5b3373ffffffffffffffffffffffffffffffffffffffff166108fc829081150290604051600060405180830381858888f19350505050158015610280573d6000803e3d6000fd5b5050565b600080600143034033846040518084600019166000191681526020018373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff166c0100000000000000000000000002815260140182815260200193505050506040518091039020600190049050809150509190505600a165627a7a7230582005be136508157f85bd5e2b4fde354b384df5ff687720fec31699829611a45a720029';

const abi = [{
  "constant": false,
  "inputs": [{"name": "sendNumber", "type": "uint256"}],
  "name": "oneRound",
  "outputs": [{"name": "", "type": "uint256"}],
  "payable": false,
  "stateMutability": "nonpayable",
  "type": "function"
}, {
  "constant": true,
  "inputs": [],
  "name": "contractBalance",
  "outputs": [{"name": "", "type": "uint256"}],
  "payable": false,
  "stateMutability": "view",
  "type": "function"
}, {
  "constant": false,
  "inputs": [{"name": "_amount", "type": "uint256"}],
  "name": "cashout",
  "outputs": [],
  "payable": false,
  "stateMutability": "nonpayable",
  "type": "function"
}, {"inputs": [], "payable": false, "stateMutability": "nonpayable", "type": "constructor"}, {
  "payable": true,
  "stateMutability": "payable",
  "type": "fallback"
}, {
  "anonymous": false,
  "inputs": [{"indexed": true, "name": "sender", "type": "address"}, {
    "indexed": true,
    "name": "rand",
    "type": "uint256"
  }],
  "name": "Round",
  "type": "event"
}];

module.exports = {
  abi,
  bytecode
};
