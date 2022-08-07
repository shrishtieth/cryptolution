    // SPDX-License-Identifier: MIT
    pragma solidity 0.8.9;

    import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
    import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
    import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";



    contract Vesting is  Ownable {
    using Counters for Counters.Counter;
    Counters.Counter public vestingID;
    mapping(uint256 => VestingDetails) public idToVesting;
    mapping(address => uint256[]) public userVests;
    mapping(address => uint256) public userTgeAmount;
    mapping(address => uint256) public tgeAmountReleased;
    mapping(address => bool) public allowedToCall;
    address public astorToken;
    uint256 public totalTokensVested;
    uint256 public totalTokensUnvested;
    uint256 public totalTgeAmount;
    uint256 public totalTgeAmountReleased;
    uint256 public cliff = 7890000;
    uint256 public teamCliff = 15780000;
    uint256 public advisorCliff = 7890000;
    uint256 public phase2TgeAmount = 500;
    uint256 public phase3TgeAmount = 750;
    uint256 public phase4TgeAmount = 1000;
    uint256 public phase5TgeAmount = 1250;
    uint256 public phase1VestTime = 12;
    uint256 public phase2VestTime = 10;
    uint256 public phase3VestTime = 8;
    uint256 public phase4VestTime = 6;
    uint256 public phase5VestTime = 5;
    uint256 public advisorVestTime = 24;
    uint256 public teamVestTime = 48;
    address[] public allUsers;
    mapping(address => bool) public added;



    struct VestingDetails{

        uint256 tokensDeposited;
        uint256 tokensWithdrawn;
        uint256 startTime;
        uint256 endTime;
        uint256 releasePerEpoch;
        uint256 epoch;
        address owner;
        uint256 phase;
        uint256 lockId;
        bool isActive;
    }
    
    event Vested(uint256 indexed id, address indexed user);
    event Unvested(uint256 indexed id, uint256 amount);
    // constructor() {}


    function vestTokenIco(address user, uint256 amount, uint256 phase) public returns(uint256 id){
        require(allowedToCall[msg.sender],"Access Denied");
        if(added[msg.sender] == false){
           allUsers.push(msg.sender);
        }
        id = vestingID.current();
        (uint256 tgeAmount, uint256 vestAmount, uint256 releasePerEpoch, uint256 endTime) = getAmounts(amount, phase);
        userTgeAmount[user] += tgeAmount;
        totalTgeAmount += tgeAmount;
        totalTokensVested += vestAmount;
        idToVesting[id] = VestingDetails({
        tokensDeposited : vestAmount,
        tokensWithdrawn: 0,
        startTime : cliff + block.timestamp,
        endTime : endTime,
        releasePerEpoch : releasePerEpoch,
        epoch : 2630000,
        owner : user,
        phase : phase,
        lockId : id,
        isActive : true
        });
        userVests[user].push(id);
        vestingID.increment();
        emit Vested(id, user);
        return(id);
    }

    function getAmounts(uint256 totalAmount, uint256 phase) public view returns
    (uint256 tgeAmount, uint256 vestAmount, uint256 releasePerEpoch, uint256 endTime){
       if(phase == 1){

          tgeAmount = 0;
          vestAmount = totalAmount-tgeAmount;
          releasePerEpoch = (totalAmount-tgeAmount)/phase1VestTime;
          endTime = cliff + block.timestamp + phase1VestTime * 2630000;
                
       }
       else if(phase == 2){

          tgeAmount = (totalAmount*phase2TgeAmount)/10000;
          vestAmount = totalAmount-tgeAmount;
          releasePerEpoch = (totalAmount-tgeAmount)/phase2VestTime;
          endTime = cliff + block.timestamp + phase2VestTime * 2630000;
           
       }
       else if(phase == 3){
          tgeAmount = (totalAmount*phase3TgeAmount)/10000;
          tgeAmount = 0;
          vestAmount = totalAmount-tgeAmount;
          releasePerEpoch = (totalAmount-tgeAmount)/phase3VestTime;
          endTime = cliff + block.timestamp + phase3VestTime * 2630000;
       }
       else if(phase == 4){
           
          tgeAmount = (totalAmount*phase4TgeAmount)/10000;
          vestAmount = totalAmount-tgeAmount;
          releasePerEpoch = (totalAmount-tgeAmount)/phase4VestTime;
          endTime = cliff + block.timestamp + phase4VestTime * 2630000;
       }
       else if(phase == 5){
          tgeAmount = (totalAmount*phase5TgeAmount)/10000;
          vestAmount = totalAmount-tgeAmount;
          releasePerEpoch = (totalAmount-tgeAmount)/phase5VestTime;
          endTime = block.timestamp + phase5VestTime * 2630000;
       }
   }

    function unvestAllTokens(address user) external {
       require(msg.sender == user|| msg.sender == owner(),"Not allowed to unvest"); 
       uint256 totalVests = userVests[user].length;
       for(uint256 i =0; i< totalVests;i++){
          if(idToVesting[userVests[user][i]].isActive){
            unvestToken(userVests[user][i], user);
          }
       }
    }

    function unvestToken(uint256 id, address user) public returns(uint256 amountUnvested){
        require(msg.sender == user || msg.sender == address(this) || msg.sender == owner(),"Not allowed to unvest");
        require(block.timestamp > idToVesting[id].startTime + idToVesting[id].epoch, "WindowClosed");
        uint256 endTimestamp;
        if(block.timestamp > idToVesting[id].endTime){
           endTimestamp = idToVesting[id].endTime;
        }
        else{
           endTimestamp = block.timestamp;
        }
        uint256 eligibleEpoch = (endTimestamp - idToVesting[id].startTime)/ idToVesting[id].epoch;
        uint256 calculatedAmount = (eligibleEpoch * idToVesting[id].releasePerEpoch) - 
        idToVesting[id].tokensWithdrawn;
        IERC20(astorToken).transfer(idToVesting[id].owner, calculatedAmount); 
        idToVesting[id].tokensWithdrawn += calculatedAmount; 
        totalTokensUnvested += calculatedAmount;
        if(idToVesting[id].tokensDeposited == idToVesting[id].tokensWithdrawn){
           idToVesting[id].isActive == false;
        } 
   
        emit Unvested(id, calculatedAmount);
        return(calculatedAmount);
    }

    function updateAllowed(address user, bool allowed) external onlyOwner{
        allowedToCall[user] = allowed;
    }



}
