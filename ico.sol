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
    function getReferrer(address user) external  view returns(address);

    function getAllRefrees(address user) external  view returns(address[] memory);
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
    address[] public investors;

    uint256  public phase1Supply = 60000000000000000000000000;
    uint256  public phase2Supply = 120000000000000000000000000;
    uint256  public phase3Supply = 180000000000000000000000000;
    uint256  public phase4Supply = 330000000000000000000000000;
    uint256  public phase5Supply = 502900000000000000000000000;

    mapping(address => uint256) public tokenBoughtUser;
    mapping(address => uint256) public usdInvestedByUser;
    mapping(address => bool) isWhitelisted;
    mapping(address => bool) public phase1Bought;

    uint256 public firstBuyAmount = 5000000000;
    uint256 public firstBuyTime = 259200;
    uint256 public phase1Price = 1000000; //0.01
    uint256 public phase2Price = 2000000; 
    uint256 public phase3Price = 2500000;
    uint256 public phase4Price = 3000000;
    uint256 public phase5Price = 3500000;
    uint256 public poolAmount;
    uint256 public poolAmountDistributed;

    mapping(uint256 => uint256) public levelToCommision;
    mapping(uint256 => uint256) public poolToSale;
    mapping(address => bool) public added;
    uint256 public boardCommision = 800;
    address public boardWallet;
    uint256 public referalPool = 400; 

    struct Refer{
    address user;                                                                                                           
    uint256 amount; 
    
    }
 
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
        levelToCommision[1] = 1000;
        levelToCommision[2] = 700;
        levelToCommision[3] = 500;
        levelToCommision[4]= 400;
        levelToCommision[5]= 300;
        levelToCommision[6] = 200;
        levelToCommision[7] = 100;
        poolToSale[1] = 1000000000000000000000000;
        poolToSale[2] = 2000000000000000000000000;
        poolToSale[3] = 5000000000000000000000000;
        poolToSale[4] = 10000000000000000000000000;


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

    function buyToken(address token, uint256 amount, address user) external payable {
        if(!added[user]){
            investors.push(user);
        }
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
                require(isWhitelisted[user] ||
                Referal(referalContract).getReferrer(user) != address(0),"Not Eligible, try later");
                require(phase1Bought[user] == false,"Already Bought Tokens");
                phase1Bought[user] = true;
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
            uint256 pool = (amount*referalPool)/10000;
            poolAmount += pool;
            IERC20(busd).transferFrom(msg.sender, address(this), pool); 
            uint256 board = (amount* boardCommision)/10000;
            IERC20(busd).transferFrom(msg.sender, boardWallet, board); 
            uint256 referalAmount = distributeWbnb(user, amount);
            IERC20(busd).transferFrom(msg.sender, treasury, (amount -(referalAmount + board + pool)));    
        }
        else if(token == wbnb){
            uint256 pool = (amount*referalPool)/10000;
            poolAmount += pool;
            uint256 board = (amount* boardCommision)/10000;
            payable(boardWallet).transfer(board); 
            uint256 referalAmount = distributeWbnb(user, amount);
            payable(treasury).transfer((amount -(referalAmount + board + pool)));    
            refundIfOver(amount);
        }
        usdInvestedByUser[user] += usdAmount;
        // Referal(referalContract).updateReward(user, usdAmount);
        Vesting(vestingContract).vestTokens(user, tokenAmount, stage);
        emit TokensBought(user, usdAmount, tokenAmount);

    }

    function getStagePrice(uint256 stage) public view returns(uint256 price){
        if(stage == 1){
            price = phase1Price;
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
    }

    function getPrice(address token) public view returns(uint256 price){
        if(token == busd){
            price = uint256(IBUSDPrice(busdPriceOracle).getLatestPrice());     
        }
        else if(token == wbnb){
            price = uint256(IBNBPrice(bnbPriceOracle).getLatestPrice());
        }
    }

    function getPriceForTokens(address currency, uint256 tokenAmount)
     public view returns(uint256 amount){
        uint256 stage = getStage();
        uint256 tokenPrice = getStagePrice(stage);
        uint256 currencyPrice = getPrice(currency);
        return(tokenAmount*((tokenPrice*10**18)/currencyPrice));
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


    function getIcoReferalTrail(address user, uint256 amount) public view returns(Refer[] memory trail) {
        uint totalItemCount = 7;
        uint itemCount = 0;
        uint currentIndex = 0;
        address _user = user;

        for (uint i = 1; i <= totalItemCount; i++) {
            if (Referal(referalContract).getReferrer(_user)!= address(0)) {
                _user = Referal(referalContract).getReferrer(user);
                itemCount = itemCount+(1) ;
            }
        }
         _user = user;
        Refer[] memory items = new Refer[](itemCount);
        for (uint i = 1; i <= totalItemCount; i++) {
            if (Referal(referalContract).getReferrer(user)!= address(0)) {
                Refer memory currentItem = Refer({
                    user : _user,
                    amount : (amount*(levelToCommision[i]))/10000
                });
                _user = Referal(referalContract).getReferrer(user);
                items[currentIndex] = currentItem;
                currentIndex = currentIndex+(1);
            }
        }
        return items; 
    }
    


    function distributeWbnb(address user, uint256 amount) private returns(uint256 total){
     uint totalItemCount = 7;
     address _user = user;
        for (uint i = 1; i <= totalItemCount; i++) {
            if (Referal(referalContract).getReferrer(user)!= address(0)) {
                IERC20(busd).transferFrom(msg.sender, Referal(referalContract).getReferrer(user), amount*(levelToCommision[i])/10000);
                 total += (levelToCommision[i])/10000;
                _user = Referal(referalContract).getReferrer(user);
            }
        }
    }

    function distributeBnb(address user, uint256 amount) private returns(uint256 total){
    uint totalItemCount = 7;
     address _user = user;
        for (uint i = 1; i <= totalItemCount; i++) {
            if (Referal(referalContract).getReferrer(user)!= address(0)) {
                payable(Referal(referalContract).getReferrer(user)).transfer(amount*(levelToCommision[i])/10000);
                total += (levelToCommision[i])/10000;
                _user = Referal(referalContract).getReferrer(user);
            }
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

    function getEligibleAmount(address user) public view returns(uint256 amount, address highest, uint256 otherAmount,
        uint256 highestAmount){
        address[] memory getRefrees = Referal(referalContract).getAllRefrees(user);
        uint256 total = getRefrees.length;
        for(uint256 i = 0; i< total ; i++){
           if(usdInvestedByUser[getRefrees[i]] > usdInvestedByUser[highest]){
              highest = getRefrees[i];
              otherAmount += highestAmount;
              highestAmount = usdInvestedByUser[getRefrees[i]];
           }
           else{
               otherAmount += usdInvestedByUser[getRefrees[i]];
           }

        }

    if(otherAmount < highestAmount){
        amount = 2*otherAmount;
    }
    else{
        amount = otherAmount + highestAmount;
    }

    }

    function distributePoolAmount() external onlyOwner{
        uint256 totalUsers = investors.length;
        for(uint256 i = 0; i< totalUsers; i++){
            uint256 userAmount = ((usdInvestedByUser[investors[i]])*poolAmount)/amountRaised;
            IERC20(astor).transfer(investors[i], userAmount);
        }
    }
                                                                                                             

 }
