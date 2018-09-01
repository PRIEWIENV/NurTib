pragma solidity ^0.4.24;

/* contractAddress is: 0x130449c688a58cdEFB2Bc8AB631479B34eED3d1B  */
contract Random{
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
      uint startBlock;
      uint endBlock;
      
      uint256   random;
      bool      settled;
      uint256   bountypot;
      uint32    commitNum;
      uint32    revealsNum;

      mapping (address => Consumer) consumers;
      mapping (address => Participant) participants;
    }
    
    struct LogItem{
        address account;
        uint id;
        uint timestamp;
        uint256 random;
        bool beSuccess;
    }
    
    uint16 revealThreshold;
    uint256 numCampaigns;
    LogItem[] logs;
    Campaign[] campaigns;
    address public founder;

    modifier OnlyOwner(){ require(founder==msg.sender);_;}
    modifier IsBlankAddress(address _n){assert(_n==0);_;}
    modifier IsPositive(uint256 _deposit){assert(_deposit>0);_;}
    modifier NotBlank(bytes32 _s){require(_s!="");_;}
    modifier IsBlank(bytes32 _s){require(_s=="");_;}
    modifier IsFalse(bool _b){assert(!_b);_;}
    
    modifier CheckThreshold(uint16 _revealThreshold){
        assert(_revealThreshold>0);
        _;
    }
    
    modifier CheckFollowPhase(uint256 _bnum, uint16 _commitDeadline) {
      require(block.number <= _bnum - _commitDeadline);
      _;
    }
    
    modifier CheckSecret(uint256 _s, bytes32 _commitment) {
      require(sha3(_s) == _commitment);
      _;
    }
    
    modifier BountyPhase(uint256 _bnum){ require(block.number >= _bnum); _; }
    
    modifier CampaignFailed(uint32 _commitNum, uint32 _revealsNum) {
      require(_commitNum != _revealsNum || _commitNum == 0);
      _;
    }

    modifier IsConsumer(address _caddr) {
      require(_caddr == msg.sender);
      _;
    }
    
    event LogCampaignAdded(uint256 indexed campaignID,address indexed from,uint256 bountypot);
    event LogFollow(uint256 indexed CampaignId, address indexed from, uint256 bountypot);
    event LogCommit(uint256 indexed CampaignId, address indexed from, bytes32 commitment);
    event LogReveal(uint256 indexed CampaignId, address indexed from, uint256 secret);
    event LogSetThreshold(uint16 _revealThreshold);
    
    function Random(){
        founder=msg.sender;
        revealThreshold=2;
    }
    
    function setThreshold (uint16 _revealThreshold) OnlyOwner CheckThreshold(_revealThreshold) external{
            revealThreshold=_revealThreshold;
            LogSetThreshold(_revealThreshold);
    }
    
    function newCampaign() payable returns (uint256 _campaignID) {
          _campaignID = campaigns.length++;
          Campaign c = campaigns[_campaignID];
          numCampaigns++;
          c.startBlock=block.number;
          c.endBlock=c.startBlock;
          c.bountypot = msg.value;
          c.consumers[msg.sender] = Consumer(msg.sender, msg.value);
          LogCampaignAdded(_campaignID, msg.sender, msg.value);
    }
    
    function commit(uint256 _campaignID, bytes32 _hs) NotBlank(_hs) external payable{
      uint campaignsLen=campaigns.length;
      if(_campaignID+1>campaignsLen) newCampaign();
      Campaign c = campaigns[_campaignID];
      require(!c.settled);
      commitmentCampaign(_campaignID, _hs, c);
    }
    
    function commitmentCampaign(
      uint256 _campaignID,
      bytes32 _hs,
      Campaign storage c
      ) IsBlank(c.participants[msg.sender].commitment) internal {
          c.participants[msg.sender] = Participant(0, _hs, 0, false, false);
          c.commitNum++;
          LogCommit(_campaignID, msg.sender, _hs);
    }
    
    function reveal(uint256 _campaignID, uint256 _s) external {
      Campaign c = campaigns[_campaignID];
      Participant p = c.participants[msg.sender];
      require(!c.settled);
      require(block.number-c.startBlock<12);
      revealCampaign(_campaignID, _s, c, p);
    }
    
    function revealCampaign(
        uint256 _campaignID,
        uint256 _s,
        Campaign storage c,
        Participant storage p) CheckSecret(_s, p.commitment) IsFalse(p.revealed) internal {
              p.secret = _s;
              p.revealed = true;
              c.revealsNum++;
              c.random ^= p.secret;
              if(c.revealsNum>=revealThreshold&&c.commitNum==c.revealsNum){
                  c.endBlock=block.number;
                  c.settled=true;
              } 
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
        if (c.settled) {
            logCall(_campaignID,_random,true);
            return _random;
        }
        if ((!c.settled)&&(block.number-c.startBlock>=12)&&(c.revealsNum >= revealThreshold)) {
            c.settled = true;
            c.endBlock=block.number;
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
