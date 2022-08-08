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

    address public astor;
    uint256 public startTime;
    uint256 public amountRaised;
    address public treasury ;
    address public referalContract = 0xBE10B136177E9f1a5B29fBE3a4Ce467C31f88540;
    address public vestingContract = 0xC300Ee0Ea14A43977234C75659562A1e52a127f5;
    uint256 public tokensSold;
    address public busd = 0xf906D9c24e98c8CAf3aF6b8a52C03D94DEF3499F;
    address public wbnb = 0x9CfCD3D329549D9A327114F5ABf73637d13eFD07;
    address public bnbPriceOracle = 0x6A761b152d85F4889c778CDe69ACe2209F34cA7E;
    address public busdPriceOracle = 0xAC3d690Fd663db40d8A23e6eEE316b4e252BF542;

    uint256  public phase1Supply = 60000000000000000000000000;
    uint256  public phase2Supply = 120000000000000000000000000;
    uint256  public phase3Supply = 180000000000000000000000000;
    uint256  public phase4Supply = 330000000000000000000000000;
    uint256  public phase5Supply = 502900000000000000000000000;

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

    event WhitelistUpdated(address user, bool isWhitelisted);

  
    constructor(
        address astorToken,
        uint256 _start, address _treasury

    ) {
      
        astor = (astorToken);
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

    function updateWhitelist(address user, bool _isWhitelisted) external onlyOwner{
        isWhitelisted[user] = _isWhitelisted;
        emit WhitelistUpdated(user, _isWhitelisted);
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
        if(token == wbnb){
            amount = msg.value;
        }
        uint256 stage = getStage();
        require(stage > 0, "ICO has not started yet");
        uint256 price;
        if(stage == 1){
            price = phase1Price;
            if(startTime + firstBuyTime > block.timestamp){
                require(isWhitelisted[msg.sender] ||
                 Referal(referalContract).isReferred(msg.sender),"Not Eligible, try later");
                require(phase1Bought[msg.sender] == false,"Already Bought Tokens");
                phase1Bought[msg.sender] = true;
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
        else if(stage == 4){
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
            refundIfOver(amount);
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
        tokenAmount = (currencyPrice*amount)/price;
        usdPrice = currencyPrice*amount;
    } 

    function refundIfOver(uint256 price) private {
    if (msg.value > price) {
      payable(msg.sender).transfer(msg.value - price);
    }
    }  

    receive() external payable {}

    /*
    @param token address of token to be withdrawn
    @param wallet wallet that gets the token
    */

    function withdrawTokens(IERC20 token, address wallet) external onlyOwner{
        uint256 balanceOfContract = token.balanceOf(address(this));
        token.transfer(wallet,balanceOfContract);
    }

     /*
    @param wallet address that gets the Eth
     */
    
    function withdrawFunds(address wallet) external onlyOwner{
        uint256 balanceOfContract = address(this).balance;
        payable(wallet).transfer(balanceOfContract);
    }                                                                                                                

}
