pragma solidity ^0.4.24;

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
      uint32    bnum;
      uint96    deposit;
      uint16    commitBalkline;
      uint16    commitDeadline;
      
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
    
    uint16 commitThreshold;
    uint16 revealThreshold;
    uint256 numCampaigns;
    LogItem[] logs;
    Campaign[] campaigns;
    address public founder;
    
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
      require(block.number < _bnum - _commitBalkline);
      _;
    }
    
    modifier CheckThreshold(uint16 _commitThreshold,uint16 _revealThreshold){
        assert(_commitThreshold>0);
        assert(_revealThreshold>0);
        require(_revealThreshold<=_commitThreshold);
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
    
    modifier BountyPhase(uint256 _bnum){ require(block.number >= _bnum); _; }
    
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
                         uint96 deposit,
                         uint16 commitBalkline,
                         uint16 commitDeadline,
                         uint256 bountypot);
                         
    event LogFollow(uint256 indexed CampaignId, address indexed from, uint256 bountypot);
    event LogCommit(uint256 indexed CampaignId, address indexed from, bytes32 commitment);
    event LogReveal(uint256 indexed CampaignId, address indexed from, uint256 secret);
    event LogSetThreshold(uint16 _commitThreshold,uint16 _revealThreshold);
    
    function Random(){
        founder=msg.sender;
    }
    
    function setThreshold(
        uint16 _commitThreshold,
        uint16 _revealThreshold
        ) CheckThreshold(_commitThreshold,_revealThreshold) external{
            commitThreshold=_commitThreshold;
            revealThreshold=_revealThreshold;
            LogSetThreshold(_commitThreshold,_revealThreshold);
        }
    
    function newCampaign(
      uint32 _bnum,
      uint96 _deposit,
      uint16 _commitBalkline,
      uint16 _commitDeadline
      ) payable
        TimeLineCheck(_bnum, _commitBalkline, _commitDeadline)
         external returns (uint256 _campaignID) {
          
          _campaignID = campaigns.length++;
          Campaign c = campaigns[_campaignID];
          numCampaigns++;
          c.bnum = _bnum;
          c.deposit = _deposit;
          c.commitBalkline = _commitBalkline;
          c.commitDeadline = _commitDeadline;
          c.bountypot = msg.value;
          c.consumers[msg.sender] = Consumer(msg.sender, msg.value);
          LogCampaignAdded(_campaignID, msg.sender, _bnum, _deposit, _commitBalkline, _commitDeadline, msg.value);
    }
    
    function follow(uint256 _campaignID)external payable returns (bool) {
          Campaign c = campaigns[_campaignID];
          Consumer consumer = c.consumers[msg.sender];
          return followCampaign(_campaignID, c, consumer);
    }
    
    function followCampaign(
      uint256 _campaignID,
      Campaign storage c,
      Consumer storage consumer
      ) CheckFollowPhase(c.bnum, c.commitDeadline)
        IsBlankAddress(consumer.caddr) internal returns (bool) {
          c.bountypot += msg.value;
          c.consumers[msg.sender] = Consumer(msg.sender, msg.value);
          LogFollow(_campaignID, msg.sender, msg.value);
          return true;
    }
    
    function commit(uint256 _campaignID, bytes32 _hs) NotBlank(_hs) external payable {
      Campaign c = campaigns[_campaignID];
      commitmentCampaign(_campaignID, _hs, c);
    }
    
    function commitmentCampaign(
      uint256 _campaignID,
      bytes32 _hs,
      Campaign storage c
      ) CheckDeposit(c.deposit)
        CheckCommitPhase(c.bnum, c.commitBalkline, c.commitDeadline)
        IsBlank(c.participants[msg.sender].commitment) internal {
          c.participants[msg.sender] = Participant(0, _hs, 0, false, false);
          c.commitNum++;
          LogCommit(_campaignID, msg.sender, _hs);
    }
    
    function reveal(uint256 _campaignID, uint256 _s) external {
      Campaign c = campaigns[_campaignID];
      Participant p = c.participants[msg.sender];
      revealCampaign(_campaignID, _s, c, p);
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
    
    function getRandom(uint256 _campaignID) external returns (uint256) {
        Campaign c = campaigns[_campaignID];
        return returnRandom(_campaignID,c);
    }

    function returnRandom(uint256 _campaignID,Campaign storage c) BountyPhase(c.bnum) internal returns (uint256) {
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
    
    function getLogsList(address account) returns(uint){
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
    
    function getMyBounty(uint256 _campaignID) external {
      Campaign c = campaigns[_campaignID];
      Participant p = c.participants[msg.sender];
      transferBounty(c, p);
    }

    function transferBounty(
      Campaign storage c,
      Participant storage p
    ) BountyPhase(c.bnum)
      IsFalse(p.rewarded) internal {
      if (c.revealsNum > 0) {
          if (p.revealed) {
              uint256 share = calculateShare(c);
              returnReward(share, c, p);
          }
      } else {
          returnReward(0, c, p);
      }
    }

    function calculateShare(Campaign c) internal returns (uint256 _share) {
      if (c.commitNum > c.revealsNum) {
          _share = fines(c) / c.revealsNum;
      } else {
          _share = c.bountypot / c.revealsNum;
      }
    }

    function returnReward(
      uint256 _share,
      Campaign storage c,
      Participant storage p ) internal {
          p.reward = _share;
          p.rewarded = true;
          if (!msg.sender.send(_share + c.deposit)) {
              p.reward = 0;
              p.rewarded = false;
          }
    }

    function fines(Campaign c) internal returns (uint256) {
        return (c.commitNum - c.revealsNum) * c.deposit;
    }

    function refundBounty(uint256 _campaignID) external {
          Campaign c = campaigns[_campaignID];
          returnBounty(_campaignID, c);
    }
    
    function returnBounty(uint256 _campaignID, Campaign storage c)
        BountyPhase(c.bnum)
        CampaignFailed(c.commitNum, c.revealsNum)
        IsConsumer(c.consumers[msg.sender].caddr) internal {
          uint256 bountypot = c.consumers[msg.sender].bountypot;
          c.consumers[msg.sender].bountypot = 0;
          if (!msg.sender.send(bountypot)) {
              c.consumers[msg.sender].bountypot = bountypot;
          }
    }
    
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