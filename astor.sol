// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

}

interface IUniswapV2Router02 is IUniswapV2Router01 {

}

interface IUniswapV2Factory {
    
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

}

contract Astor is ERC20, Ownable {
    uint256 public fees = 1000;
    address public farmReserve ;
    address public cryptolutionTreasury ;
    uint256 public launchBlock;
    uint256 public launchTime;
    mapping(address => bool) public excludedFromTax; //Address excluded from tax free 
    uint256 public maxBuySellPercentage = 50; // maximum amount that can be bought or sold
    mapping(address => bool) public pair; 
    mapping(address => bool) public isBlacklisted; // checks if an address is blacklisted

    // events
    event TokenBurnt(address wallet, uint256 amount);
    event WalletFeeUpdated(address wallet , bool isExcluded);
    event BlacklistAddressUpdated(address wallet, bool isBlacklisted);
    event MaxBuySellUpdated(uint256 maxSell);
    event FeesUpdated(uint256 fees);
    event TreasuryUpdated(address treasury);
    event FarmReserveUpdated(address farmReserve);
    event TokenAirDropped(address user, uint256 amount);
    event Launched(uint256 blockNumber, uint256 launchTime);
    event PairUpdated(address pairAddress, bool isPair);

    constructor()  ERC20("Astor", "Astor") {
        _mint(msg.sender, 1000000000000000000000000000);

        excludedFromTax[msg.sender] = true;

          IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D 
        );
        address automatedMarketMakerPairsContract = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        pair[automatedMarketMakerPairsContract] = true;
        

    }

    // launches the token, sets the launchTime and launchBlock
    function launch() external onlyOwner{
        launchBlock = block.number;
        launchTime = block.timestamp;
        emit Launched(launchBlock, launchTime);
    }

    // update automated market makers pair 
    function updatePair(address _pair, bool isPair) external onlyOwner{
        pair[_pair] = isPair;
        emit PairUpdated(_pair, isPair);
    }


    // burn the tokens from a wallet
    
    function burn(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
        emit TokenBurnt(account, amount);
    }

    // update excluded from Tax for a wallet

    function updateWalletFee(address wallet, bool isExcluded) external onlyOwner{
        excludedFromTax[wallet] = isExcluded;
        emit WalletFeeUpdated(wallet, isExcluded);
    }

    // updated blacklisted condition of a wallet

    function updateBlacklist(address wallet, bool _isBlacklisted) external onlyOwner{
        isBlacklisted[wallet] = _isBlacklisted;
        emit BlacklistAddressUpdated(wallet, _isBlacklisted);
    }

    // Update maximum amount that can be bought

    function updateMaxBuy(uint256 _max) external onlyOwner{
        maxBuySellPercentage = _max;
        emit MaxBuySellUpdated(_max);
    }

    // Update maximum amount that can be sold

    function updateFees(uint256 _fees) external onlyOwner{
        fees = _fees;
        emit FeesUpdated(_fees);
    }

    
    // update tax Distribution address

    function updateFarmReserve(address _farmReserve) external onlyOwner{
        farmReserve = _farmReserve;
        emit FarmReserveUpdated(_farmReserve);
    }

    function updateTreasury(address _treasury) external onlyOwner{
         cryptolutionTreasury = _treasury;
         emit TreasuryUpdated(_treasury);
    }

    // airdrop tokens

    function airdropTokens(address[] memory users, uint256[] memory amount) external onlyOwner{
        require(users.length == amount.length,"Invalid input");
        uint256 total = users.length;
        for(uint256 i=0; i< total ; i++){
            _transfer(msg.sender, users[i], amount[i]);
            emit TokenAirDropped(users[i], amount[i]);
        }
 
    }

    function getFees() public view returns(uint256 _fees){
        if(block.number - launchBlock < 3){
            return(99000);
        }
        else if((block.timestamp - launchTime) < 1728000){
            uint256 difference = (block.timestamp - launchTime)/86400;
            return(21- difference);
        }
        else{
            return fees;
        }
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override{   
        require(isBlacklisted[sender]!= true && isBlacklisted[recipient]!= true,"Address Blacklisted");
        if(excludedFromTax[sender]==false && excludedFromTax[recipient] == false){   
                if(pair[sender] || pair[recipient]){
                  require(amount <= (totalSupply()*maxBuySellPercentage)/100000, 
                  "Cannot buy or sell more than");
                 }
                uint256 feeAmount = getFees();
                _burn(msg.sender, (amount*feeAmount)/200000);
                super._transfer(sender,farmReserve,amount*feeAmount/400000); 
                super._transfer(sender,cryptolutionTreasury,amount*feeAmount/400000);
                uint256 totalFees = amount*feeAmount/100000;
                super._transfer(sender,recipient,amount-totalFees);   
        }
        else{
            super._transfer(sender,recipient,amount); 
        } 
        
    }
}
