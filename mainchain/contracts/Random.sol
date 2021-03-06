pragma solidity ^0.4.24;

/* contractAddress is: 0x97e5Cd9642ba9765518b9BF2E2c0245fE239270a*/

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


/**
 * @title Owned
 */
contract Owned {
    address public owner;
    address public newOwner;
    mapping (address => bool) public admins;

    event OwnershipTransferred(
        address indexed _from, 
        address indexed _to
    );

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyAdmins {
        require(admins[msg.sender]);
        _;
    }

    function transferOwnership(address _newOwner) 
        public 
        onlyOwner 
    {
        newOwner = _newOwner;
    }

    function acceptOwnership() 
        public 
    {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }

    function addAdmin(address _admin) 
        onlyOwner 
        public 
    {
        admins[_admin] = true;
    }

    function removeAdmin(address _admin) 
        onlyOwner 
        public 
    {
        delete admins[_admin];
    }

}


contract Random{
    using SafeMath for uint256;
    struct Participant{
        uint256 secret;                       
        bytes32 commitment;
        uint256 reward;
        bool revealed;
        bool rewarded;
    }
    
    struct Consumer{
        address caddr;
        uint256 bountypot;
    }
    
    struct Campaign {
      uint32    bnum;
      uint16    commitBalkline;
      uint16    commitDeadline;
      
      uint256   random;
      bool      settled;
      uint32    commitNum;
      uint32    revealsNum;

      mapping (address => Participant) participants;
    }
    
    struct LogItem{
        address account;
        uint id;
        uint timestamp;
        uint256 random;
        bool beSuccess;
    }
    
    uint16 revealRate;
    uint16 revealThreshold;
    uint16 commitBalkline;
    uint16 commitDeadline;
    uint256 numCampaigns;
    LogItem[] logs;
    Campaign[] campaigns;
    address public founder;
    address[] contracts;
    
    modifier OnlyOwner(){ require(founder==msg.sender);_;}
    modifier IsBlankAddress(address _n){assert(_n==0);_;}
    modifier IsPositive(uint256 _deposit){assert(_deposit>0);_;}
    modifier NotBlank(bytes32 _s){require(_s!="");_;}
    modifier IsBlank(bytes32 _s){require(_s=="");_;}
    modifier IsFalse(bool _b){assert(!_b);_;}
    modifier TimeLineCheck(uint32 _bnum, uint16 _commitBalkline, uint16 _commitDeadline) {
      require(block.number < _bnum);
      assert(_commitBalkline > 0);
      assert(_commitDeadline > 0);
      require(_commitDeadline < _commitBalkline);
      require(block.number <= _bnum - _commitBalkline);
      _;
    }
    
    modifier CheckThreshold(uint16 _revealThreshold){
        assert(_revealThreshold>0);
        _;
    }
    
    modifier CheckFollowPhase(uint256 _bnum, uint16 _commitDeadline) {
      require(block.number <= _bnum - _commitDeadline);
      _;
    }
    
    modifier CheckDeposit(uint256 _deposit) { require(msg.value == _deposit) ; _; }
    modifier CheckCommitPhase(uint256 _bnum, uint16 _commitBalkline, uint16 _commitDeadline) {
      require(block.number >= _bnum - _commitBalkline);
      require(block.number <= _bnum - _commitDeadline);
      _;
    }
    
    modifier CheckRevealPhase(uint256 _bnum, uint16 _commitDeadline) {
      require(block.number > _bnum - _commitDeadline);
      require(block.number < _bnum);
      _;
    }
    
    modifier CheckSecret(uint256 _s, bytes32 _commitment) {
      require(sha3(_s) == _commitment);
      _;
    }
    
    modifier CampaignFailed(uint32 _commitNum, uint32 _revealsNum) {
      require(_commitNum != _revealsNum || _commitNum == 0);
      _;
    }

    modifier IsConsumer(address _caddr) {
      require(_caddr == msg.sender);
      _;
    }
    
    event LogCampaignAdded(uint256 indexed campaignID,
                         address indexed from,
                         uint32 indexed bnum,
                         uint16 commitBalkline,
                         uint16 commitDeadline);
                         
    event LogFollow(uint256 indexed CampaignId, address indexed from, uint256 bountypot);
    event LogCommit(uint256 indexed CampaignId, address indexed from, bytes32 commitment);
    event LogReveal(uint256 indexed CampaignId, address indexed from, uint256 secret);
    event LogSetParams(uint16 _revealThreshold,uint16 _commitBalkline,uint16 _commitDeadline);
    
    function Random(){
        founder=msg.sender;
        revealThreshold=1;
        commitDeadline=4;
        commitBalkline=8;
    }
    
    function setParams (uint16 _revealThreshold,
                        uint16 _commitBalkline,
                        uint16 _commitDeadline) OnlyOwner CheckThreshold(_revealThreshold) external{
            revealThreshold=_revealThreshold;
            commitBalkline=_commitBalkline;
            commitDeadline=_commitDeadline;
            LogSetParams(_revealThreshold,_commitBalkline,_commitDeadline);
    }
    
    
    function newCampaign(
      uint32 _bnum,
      uint16 _commitBalkline,
      uint16 _commitDeadline
      ) TimeLineCheck(_bnum, _commitBalkline, _commitDeadline)
         internal returns (uint256 _campaignID) {
          
          _campaignID = campaigns.length++;
          Campaign c = campaigns[_campaignID];
          numCampaigns++;
          c.bnum = _bnum;
          c.commitBalkline = _commitBalkline;
          c.commitDeadline = _commitDeadline;
          LogCampaignAdded(_campaignID, msg.sender, _bnum, _commitBalkline, _commitDeadline);
    }
    
    function commit(uint256 _campaignID, bytes32 _hs) NotBlank(_hs) payable returns(uint256){
      if(_campaignID+1>=campaigns.length) {
          newCampaign(uint32(block.number)+commitBalkline,commitBalkline,commitDeadline);
      }
      require(campaigns[_campaignID].bnum>0);
      Campaign c = campaigns[_campaignID];
      commitmentCampaign(_campaignID, _hs, c);
      return _campaignID;
    }
    
    function commitmentCampaign(
      uint256 _campaignID,
      bytes32 _hs,
      Campaign storage c
      )CheckCommitPhase(c.bnum, c.commitBalkline, c.commitDeadline)
        IsBlank(c.participants[msg.sender].commitment) internal {
          c.participants[msg.sender] = Participant(0, _hs, 0, false, false);
          c.commitNum++;
          LogCommit(_campaignID, msg.sender, _hs);
    }
    
    function reveal(uint256 _campaignID, uint256 _s)public returns(uint256){
      Campaign c = campaigns[_campaignID];
      Participant p = c.participants[msg.sender];
      revealCampaign(_campaignID, _s, c, p);
      return _campaignID;
    }
    
    function revealCampaign(
        uint256 _campaignID,
        uint256 _s,
        Campaign storage c,
        Participant storage p) CheckRevealPhase(c.bnum, c.commitDeadline)
            CheckSecret(_s, p.commitment)
            IsFalse(p.revealed) internal {
              p.secret = _s;
              p.revealed = true;
              c.revealsNum++;
              c.random ^= p.secret;
              LogReveal(_campaignID, msg.sender, _s);
    }
    
    function getCurrentRandom() public returns (uint256){
        uint256 campaignsLen=campaigns.length;
        require(campaignsLen>0);
        return getRandom(campaigns.length-1);
    }
    
    function getRandom(uint256 _campaignID) internal returns (uint256) {
        Campaign c = campaigns[_campaignID];
        return returnRandom(_campaignID,c);
    }

    function returnRandom(uint256 _campaignID,Campaign storage c) internal returns (uint256) {
        uint256 _random=c.random;
        if (c.revealsNum >= revealThreshold) {
            c.settled = true;
            logCall(_campaignID,_random,true);
            return _random;
        }
        logCall(_campaignID,_random,false);
    }
    
    function logCall(uint256 id,uint256 _random,bool beSuccess)internal {
        uint logTotal=logs.length++;
        logs[logTotal]=LogItem(msg.sender,id,now,_random,beSuccess);
    }
    
    function getLogsList(address account) returns(uint256[]){
        uint[] ids;
        uint idLen=0;
        uint logLen=logs.length;
        for(uint i=0;i<logLen;i++){
            if(logs[i].account==account){
                ids[idLen]=i;
                idLen++;
            }
        }
        return ids;
    }
    
    function getLogsCount() returns(uint){
        return logs.length;
    }
    
    function getLogItem(uint _id) returns(address,uint,uint,uint256,bool){
        LogItem item=logs[_id];
        return (item.account,item.id,item.timestamp,item.random,item.beSuccess);
    }
    
    
    function () payable{}
    
    //test
    function getBlockNumber() external returns(uint256){return block.number;}
    
    function getCommitment(uint256 _campaignID) external constant returns (bytes32) {
      Campaign c = campaigns[_campaignID];
      Participant p = c.participants[msg.sender];
      return p.commitment;
    }
    
    function shaCommit(uint256 _s) returns (bytes32) {
          return sha3(_s);
    }
}
