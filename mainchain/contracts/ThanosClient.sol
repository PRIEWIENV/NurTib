pragma solidity ^0.4.4;

contract ThanosClient is CrossChain {

    address owner;

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }

    function ThanosClient() {
        owner = msg.sender;
    }

    function randomGen(uint seed) private constant returns (uint randomNumber) {
        uint nonce = uint(sha3(block.blockhash(block.number-1), msg.sender, seed));
        return nonce;
    }

    function sendToSideChain(
        uint32 toChainId,
        address destContract,
        bytes txData
    ) public {
        require(txData.length == txDataSize);
        uint256 value;
        uint nonce;
        assembly {
            value := mload(add(txData, 0x20))
        }
        require(balanceOf[msg.sender] >= value);
        bytes4 destFuncHasher = bytes4(keccak256("recvFromSideChain(bytes)"));
        sendTransaction(toChainId, destContract, destFuncHasher);
        balanceOf[msg.sender] -= value;
    }

}