pragma solidity ^0.4.24;

/* contractAddress is: 0xb29C8b489A5Bc6eD0b0561Cbb1d5e91465017FE9  */
contract CrossChain {

    event SendCrossChain(uint32 fromChainId, uint32 toChainId,
                         address destContract, bytes4 destFuncSig,
                         uint64 sendNonce);
    event RecvCrossChain(address indexed sender, bytes txData);

    address crossChainVerifyAddr = 0xffFfffFfFFFfFFfffFFFffffFfFfffFfFF030002;
    address chainManagerAddr = 0xffFFFfffFFfFFfFFFFffFFFfFfFFffFFfF020002;

    uint64 crossChainSendNonce;
    uint64 crossChainRecvNonce;

    function getCrossChainSendNonce() public view returns (uint64) {
        return crossChainSendNonce;
    }

    function getCrossChainRecvNonce() public view returns (uint64) {
        return crossChainRecvNonce;
    }

    function getFromChainId() public view returns (uint32) {
        address contractAddr = chainManagerAddr;
        bytes4 funcSig = bytes4(keccak256("getChainId()"));
        uint256 chainId;
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, funcSig)
            let result := call(20000, contractAddr, 0, ptr, 0x4, ptr, 0x20)
            if eq(result, 0) { revert(ptr, 0) }
            chainId := mload(ptr)
        }
        return uint32(chainId);
    }

    function sendTransaction(
        uint32 toChainId,
        address destContract,
        bytes4 destFuncSig
    ) internal {
        uint32 fromChainId = getFromChainId();
        emit SendCrossChain(fromChainId, toChainId, destContract, destFuncSig, crossChainSendNonce);
        crossChainSendNonce += 1;
    }

    function verifyTransaction(
        bytes memory txProof,
        uint256 txDataSize
    ) internal returns (
        address sender,
        bytes memory txData
    ) {
        address recvContAddr = address(this);
        bytes4 recvFuncSig;
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0x0, 0x4)
            recvFuncSig := mload(ptr)
        }
        address contractAddr = crossChainVerifyAddr;
        bytes4 nativeFunc = bytes4(keccak256("verifyTransaction(address,bytes4,uint64,bytes)"));
        uint64 recvNonce = crossChainRecvNonce;
        // bytes len + bytes
        uint txProofSize = 0x20 + txProof.length / 0x20 * 0x20;
        if (txProof.length % 0x20 != 0) {
            txProofSize += 0x20;
        }
        // address + bytes pos + bytes len + bytes
        uint outSize = 0x60 + txDataSize / 0x20 * 0x20;
        if (txDataSize % 0x20 != 0) {
            outSize += 0x20;
        }
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, nativeFunc)
            mstore(add(ptr, 0x04), recvContAddr)
            mstore(add(ptr, 0x24), recvFuncSig)
            mstore(add(ptr, 0x44), recvNonce)
            mstore(add(ptr, 0x64), 0x80)
            // copy txproof bytes
            let ptrL := add(ptr, 0x84)
            for {
                    let txProofL := txProof
                    let txProofR := add(txProof, txProofSize)
                }
                lt(txProofL, txProofR)
                {
                    txProofL := add(txProofL, 0x20)
                    ptrL := add(ptrL, 0x20)
                }
                {
                mstore(ptrL, mload(txProofL))
            }
            let inSize := sub(ptrL, ptr)
            switch call(100000, contractAddr, 0, ptr, inSize, ptr, outSize)
            case 0 { revert(0, 0) }
            default {
                // return(ptr, outSize)
                sender := mload(ptr)
                txData := add(ptr, 0x40)
            }
        }
        emit RecvCrossChain(sender, txData);
        crossChainRecvNonce += 1;
    }
}

contract RSP is CrossChain {
    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;

    /* Initializes contract */
    function RSP(uint256 _balance) public {
        balanceOf[msg.sender] = _balance;
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) public {
        require(balanceOf[msg.sender] >= _value);
        // Check if the sender has enough
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        // Check for overflows
        balanceOf[msg.sender] -= _value;
        // Subtract from the sender
        balanceOf[_to] += _value;
        // Add the same to the recipient
    }

    function getBalance(address addr) public view returns (uint256) {
        return balanceOf[addr];
    }

    uint256 txDataSize = 0x20;

    function sendToSideChain(
        uint32 toChainId,
        address destContract,
        bytes txData
    ) public {
        require(txData.length == txDataSize);
        uint256 value;
        assembly {
            value := mload(add(txData, 0x20))
        }
        require(balanceOf[msg.sender] >= value);
        bytes4 destFuncHasher = bytes4(keccak256("recvFromSideChain(bytes)"));
        sendTransaction(toChainId, destContract, destFuncHasher);
        balanceOf[msg.sender] -= value;
    }

    // verify_proof need:
    // check from_chain_id in ChainManager.sideChains
    // check to_chain_id == my chain_id
    // check dest_contract == this
    // check hasher == RECV_FUNC_HASHER
    // check cross_chain_nonce == cross_chain_nonce
    // extract origin tx sender and origin tx data
    function recvFromSideChain(bytes txProof) public {
        address sender;
        bytes memory txData;
        (sender, txData) = verifyTransaction(txProof, txDataSize);
        uint256 value;
        assembly {
            value := mload(add(txData, 0x20))
        }
        balanceOf[sender] += value;
    }
}
