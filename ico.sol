// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBNBPrice{
   function getLatestPrice() external view returns(int);
}

interface IBUSDPrice{
   function getLatestPrice() external view returns(int);
}

interface Referal{
    function isReferred(address user) external view returns(bool);
    function updateReward(address user, uint256 amount) external ;
}

interface Vesting{
    function vestTokens(address user, uint256 amount, uint256 phase) external;
}

contract AstorTokenICO is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IERC20 private astor;

    uint256 public startTime;
    uint256 public amountRaised;
    address private treasury;
    address public referalContract;
    address public vestingContract;
    uint256 private tokensSold;
    address public busd;
    address public wbnb;
    address public bnbPriceOracle;
    address public busdPriceOracle;

    uint256  private phase1Supply = 60000000000000000000000000;
    uint256  private phase2Supply = 120000000000000000000000000;
    uint256  private phase3Supply = 180000000000000000000000000;
    uint256  private phase4Supply = 330000000000000000000000000;
    uint256  private phase5Supply = 502900000000000000000000000;

    mapping(address => uint256) public tokenBoughtUser;
    mapping(address => bool) isWhitelisted;
    mapping(address => bool) public phase1Bought;

    uint256 public firstBuyAmount = 5000000000;
    uint256 public firstBuyTime = 259200;
    uint256 public phase1Price = 1000000;
    uint256 public phase2Price = 2000000; 
    uint256 public phase3Price = 2500000;
    uint256 public phase4Price = 3000000;
    uint256 public phase5Price = 3500000;


    event TokensBought(address indexed investor, uint256 indexed usdAmount,
    uint256 indexed tokenAmount);

    event SupplyEdited(uint256 phase1Supply ,uint256 phase2Supply,
    uint256 phase3Supply, uint256 phase4Supply, uint256 phase5Supply);

    event PriceUpdated(uint256 phase1Price ,uint256 phase2Price,
    uint256 phase3Price, uint256 phase4Price, uint256 phase5Price);

    event TreasuryUpdated(address treasury);

    event FirstBuyUpdated(uint256 amount, uint256 time);

    event ContractsUpdated(address referalContract, address vestingContract,
    address bnbPriceOracle, address busdPriceOracle);

  
    constructor(
        address astorToken,
        uint256 _start, address _treasury

    ) {
      
        astor = IERC20(astorToken);
        startTime = _start;
        treasury = _treasury;
    }

    function updateSupply(uint256 _phase1Supply ,uint256 _phase2Supply,
    uint256 _phase3Supply, uint256 _phase4Supply, uint256 _phase5Supply) external onlyOwner{
        phase1Supply = _phase1Supply;
        phase2Supply = _phase2Supply;
        phase3Supply = _phase3Supply;
        phase4Supply = _phase4Supply;
        phase5Supply = _phase5Supply;
        
        emit SupplyEdited(_phase1Supply , _phase2Supply,
        _phase3Supply, _phase4Supply, _phase5Supply);

    }

    function editPrice(uint256 _phase1Price ,uint256 _phase2Price,
    uint256 _phase3Price, uint256 _phase4Price, uint256 _phase5Price) external onlyOwner{
        phase1Price = _phase1Price;
        phase2Price = _phase2Price;
        phase3Price = _phase3Price;
        phase4Price = _phase4Price;
        phase5Price = _phase5Price;

        emit PriceUpdated(_phase1Price ,_phase2Price,
        _phase3Price, _phase4Price, _phase5Price);
    }

    function updateTreasury(address _treasury) external onlyOwner{
        treasury = _treasury;

        emit TreasuryUpdated( _treasury);
    }

    function updateFirstBuy(uint256 amount, uint256 time) external onlyOwner{
        firstBuyAmount = amount;
        firstBuyTime = time;

        emit FirstBuyUpdated(amount, time);
    }

    function updateContracts(address _referalContract, address _vestingContract,
    address _bnbPriceOracle, address _busdPriceOracle) external onlyOwner{
        referalContract = _referalContract;
        vestingContract =_vestingContract;
        bnbPriceOracle = _bnbPriceOracle;
        busdPriceOracle = _busdPriceOracle;

        emit ContractsUpdated(_referalContract,  _vestingContract,
     _bnbPriceOracle,  _busdPriceOracle);

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

    function buyToken(address token, uint256 amount) external payable {
        require(token == wbnb || token == busd,"Invalid currency");
        uint256 stage = getStage();
        require(stage > 0, "ICO has not started yet");
        uint256 price;
        if(stage == 1){
            price = phase1Price;
            if(startTime + firstBuyTime > block.timestamp){
                require(isWhitelisted[msg.sender] ||
                 Referal(referalContract).isReferred(msg.sender),"Not Eligible, try later");
                require(phase1Bought[msg.sender] == false,"Already Bought Tokens");
                phase1Bought[msg.sender] == true;
                uint256 currencyPrice = getPrice(token);
                amount = (firstBuyAmount*10**18/currencyPrice);               
            }
        }
        else if(stage == 2){
            price = phase2Price;
        }
        else if(stage == 3){
            price = phase3Price;
        }
        else if(stage == 5){
            price = phase4Price;
        }
        else if(stage == 5){
            price = phase5Price;
        }
        (uint256 tokenAmount, uint256 usdAmount) = getTokensForPrice( token,  amount,  price);
        tokensSold += tokenAmount;
        amountRaised += usdAmount;
        if(token == busd){
            IERC20(busd).transferFrom(msg.sender, treasury, amount);    
        }
        else if(token == wbnb){
            payable(treasury).transfer(amount); 
        }
        Referal(referalContract).updateReward(msg.sender, usdAmount);
        Vesting(vestingContract).vestTokens(msg.sender, tokenAmount, stage);
        emit TokensBought(msg.sender, usdAmount, tokenAmount);

    }

    function getPrice(address token) public view returns(uint256 price){
        if(token == busd){
            price = uint256(IBUSDPrice(busdPriceOracle).getLatestPrice());     
        }
        else if(token == wbnb){
            price = uint256(IBNBPrice(bnbPriceOracle).getLatestPrice());
        }
    }

    function getTokensForPrice(address token, uint256 amount, uint256 price)
     public view returns(uint256 tokenAmount, uint256 usdPrice){
        uint256 currencyPrice = getPrice(token);
        tokenAmount == (currencyPrice*amount)/price;
        usdPrice = currencyPrice*amount;
    }                                                                                                                   

}
