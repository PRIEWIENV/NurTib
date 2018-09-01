pragma solidity ^0.4.4;

contract RockScissorsPaper {

    address owner;

    event Round(address indexed sender, uint256 indexed rand);

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }

    function RockScissorsPaper() {
        owner = msg.sender;
    }

    //the user plays one roll of the machine putting in money for the win
    function oneRound(uint256 sendNumber) returns(uint256){
        uint256 rand = randomGen(sendNumber%3)%3;
        Round(msg.sender, rand);
        return rand;
    }
    
    function contractBalance() constant returns(uint256) {
        return this.balance;
    }

    function() onlyOwner payable {
    }

    function cashout(uint256 _amount) onlyOwner {
        msg.sender.transfer(_amount);
    }

    function randomGen(uint256 seed) private constant returns (uint randomNumber) {
        uint256 nonce = uint(sha3(block.blockhash(block.number-1), msg.sender, seed));
        return nonce;
    }

}
