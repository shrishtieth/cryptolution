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

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    // function setFeeTo(address) external;
    // function setFeeToSetter(address) external;
}



interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}



interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}



interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract AstorTokenICO is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public astor;
    uint256 public startTime;
    uint256 public amountRaised;
    address public treasury ;
    address public referalContract = 0x25140D81fc1EDeCB91F246813454627088fa229B;
    address public vestingContract = 0xC300Ee0Ea14A43977234C75659562A1e52a127f5;
    uint256 public tokensSold;
    address public busd = 0x5995b7192867f6F53C17392E67b168459017C820;
    address public wbnb = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address public bnbPriceOracle = 0xAC3d690Fd663db40d8A23e6eEE316b4e252BF542;
    address public busdPriceOracle = 0x6A761b152d85F4889c778CDe69ACe2209F34cA7E ;
    address[] public investors;
    IUniswapV2Router02 public uniswapV2Router; // uniswap dex router

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
    mapping(address => uint256) public poolReward;
    mapping(address => uint256) public referalIncome;
    uint256 public boardCommision = 800;
    address public boardWallet = 0x7d22e6144931687AF80b38d2C9b7F9F3f7a43291;
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
        poolToSale[1] = 100000000000000;
        poolToSale[2] = 200000000000000;
        poolToSale[3] = 500000000000000;
        poolToSale[4] = 1000000000000000;
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        );
        uniswapV2Router = _uniswapV2Router;


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
        uint256 currencyPrice = getPrice(token);
        require(amount >= (firstBuyAmount*10**18/currencyPrice),"User should invest atleast 50$");
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
            uint256 poolBusd = swapEthForTokens(pool);
            poolAmount += poolBusd;
            uint256 board = (amount* boardCommision)/10000;
            payable(boardWallet).transfer(board); 
            uint256 referalAmount = distributeBnb(user, amount);
            payable(treasury).transfer((amount -(referalAmount + board + pool)));    
            refundIfOver(amount);
        }
        usdInvestedByUser[user] += usdAmount;
        tokenBoughtUser[user] += tokenAmount;
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
        usdPrice = (currencyPrice*amount)/10**18;
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
                _user = Referal(referalContract).getReferrer(_user);
                itemCount = itemCount+(1) ;
            }
        }
         _user = user;
        Refer[] memory items = new Refer[](itemCount);
        for (uint i = 1; i <= totalItemCount; i++) {
            if (Referal(referalContract).getReferrer(_user)!= address(0)) {
                Refer memory currentItem = Refer({
                    user : _user,
                    amount : (amount*(levelToCommision[i]))/10000
                });
                _user = Referal(referalContract).getReferrer(_user);
                items[currentIndex] = currentItem;
                currentIndex = currentIndex+(1);
            }
        }
        return items; 
    }
    


    function distributeWbnb(address user, uint256 amount) public returns(uint256 total){
     uint totalItemCount = 7;
     address _user = user;
        for (uint i = 1; i <= totalItemCount; i++) {
            if (Referal(referalContract).getReferrer(_user)!= address(0)) {
                IERC20(busd).transferFrom(msg.sender, Referal(referalContract).getReferrer(_user), amount*(levelToCommision[i])/10000);
                 referalIncome[Referal(referalContract).getReferrer(_user)] += (getPrice(busd)*amount*(levelToCommision[i])/10000)/10**8;
                 total += amount*(levelToCommision[i])/10000;
                _user = Referal(referalContract).getReferrer(_user);
            }
        }
    }

    function distributeBnb(address user, uint256 amount) public payable returns(uint256 total){
    uint totalItemCount = 7;
     address _user = user;
        for (uint i = 1; i <= totalItemCount; i++) {
            if (Referal(referalContract).getReferrer(_user)!= address(0)) {
                payable(Referal(referalContract).getReferrer(_user)).transfer(amount*(levelToCommision[i])/10000);
                referalIncome[Referal(referalContract).getReferrer(_user)] += (getPrice(wbnb)*amount*(levelToCommision[i])/10000)/10**8;
                total += amount*(levelToCommision[i])/10000;
                _user = Referal(referalContract).getReferrer(_user);
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

    function getPoolAndAmount(address user) external view returns(uint256 pool, uint256 amountRemaining){
        (uint256 amount,,,) = getEligibleAmount(user);
        if(amount < poolToSale[1]){
            pool = 1;
            amountRemaining = poolToSale[1] - amount;
        }
        if(amount >= poolToSale[1] && amount < poolToSale[2]){
            pool = 2;
            amountRemaining = poolToSale[2] - amount;
        }
        if(amount >= poolToSale[2] && amount < poolToSale[3]){
            pool = 3;
            amountRemaining = poolToSale[3] - amount;
        }
        if(amount >= poolToSale[3] && amount <= poolToSale[4]){
            pool = 4;
            amountRemaining = poolToSale[4] - amount;
        }
    } 

    function distributePoolAmount() external onlyOwner{
        uint256 totalUsers = investors.length;
        uint256 poolShare = (poolAmount - poolAmountDistributed)/4;
        for(uint256 i=0; i<4; i++){
            for(uint256 j = 0; j< totalUsers; j++){
            (uint256 amount,,,) = getEligibleAmount(investors[i]);
            if(amount >= poolToSale[i+1]){
            uint256 userAmount = ((usdInvestedByUser[investors[j]])*poolShare)/amountRaised;
            IERC20(busd).transfer(investors[j], userAmount);
            poolAmountDistributed += userAmount;
            poolReward[investors[j]] += userAmount;
            }
            
        }
        }
    }

    function swapEthForTokens(uint256 tokenAmount) public payable returns(uint256 busdAmount){
       
        address[] memory path = new address[](2);
        path[0] = uniswapV2Router.WETH();
        path[1] = busd;
        uint[] memory amounts = new uint[](2);
        amounts = uniswapV2Router.swapExactETHForTokens{value:tokenAmount}(
            0,
            path,
            address(this),
            block.timestamp + 1000
        );
        return(amounts[1]);
    }
                                                                                                             

 }
