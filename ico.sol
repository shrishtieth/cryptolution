// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBNBPrice{
   function getLatestPrice() external view returns(int);
}

interface Referal{
    function isReferred(address user) external view returns(bool);
    function updateReward(address user, uint256 amount) external ;
}

interface Vesting{
    function vestTokens(address user, uint256 amount) external;
}

contract AstorTokenICO is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IERC20 private astor;

    uint256 public startTime;
    uint256 public endTime;
    uint256 public amountRaised;
    address private treasury;
    address public referalContract;
    address public vestingContract;

    uint256  private phase1Supply = 60000000000000000000000000;
    uint256  private phase2Supply = 120000000000000000000000000;
    uint256  private phase3Supply = 180000000000000000000000000;
    uint256  private phase4Supply = 330000000000000000000000000;
    uint256  private phase5Supply = 502900000000000000000000000;
    uint256 private tokensSold;
    mapping(address => uint256) public tokenBoughtUser;
    mapping(address => bool) isWhitelisted;
    uint256 public phase1BuyAmount;
    uint256 public phase1BuyTime;
    uint256 public phase1Price = 1000000;
    uint256 public phase2Price = 2000000; 
    uint256 public phase3Price = 2500000;
    uint256 public phase4Price = 3000000;
    uint256 public phase5Price = 3500000;


    event BuyToken(address indexed investor, uint256 indexed bnbAmount,
     uint256 indexed tokenAmount);

  
    constructor(
        address astorToken,
        uint256 _start, uint256 _duration, address _treasury

    ) {
      
        astor = IERC20(astorToken);
        startTime = _start;
        endTime = _start + _duration * 1 days ;
        treasury = _treasury;
    }

    function getStage() public view returns(uint256 stage){
        if(block.timestamp > startTime && tokensSold < phase1Supply){
            return(1);
        }
        else if(tokensSold >= phase1Supply && tokensSold < phase2Supply){
            return(2);
        }
        else if(tokensSold >= phase2Supply && tokensSold < phase3Supply){
            return(3);
        }
        else if(tokensSold >= phase3Supply && tokensSold < phase4Supply){
            return(4);
        }
        else if(tokensSold >= phase4Supply && tokensSold < phase5Supply){
            return(5);
        }
        else{
            return(0);
        }
    }

}
