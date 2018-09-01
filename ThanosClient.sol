pragma solidity ^0.4.4;

contract RockScissorsPaper {

    address owner;

    event Round(address sender, uint rand);

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }

    function RockScissorsPaper() {
        owner = msg.sender;
    }

    //the user plays one roll of the machine putting in money for the win
    function oneRound(uint sendNumber) {
        uint rand = randomGen(sendNumber%3);

        Round(msg.sender, rand);
        
    }
    
    function contractBalance() constant returns(uint) {
        return this.balance;
    }

    function() onlyOwner payable {
    }

    function cashout(uint _amount) onlyOwner {
        msg.sender.transfer(_amount);
    }

    function randomGen(uint seed) private constant returns (uint randomNumber) {
        uint nonce = uint(sha3(block.blockhash(block.number-1), msg.sender, seed));
        return nonce;
    }

}