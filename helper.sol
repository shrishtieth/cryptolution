// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceConsumerV3 {

    AggregatorV3Interface internal priceFeed;
    // busd 0x9331b55D9830EF609A2aBCfAc0FBCE050A52fdEa
    // bnb 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
    constructor() {
        priceFeed = AggregatorV3Interface(0x9331b55D9830EF609A2aBCfAc0FBCE050A52fdEa);
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }
}

contract Vesting{
    function vestTokens(address user, uint256 amount, uint256 phase) public{

    }
}

contract Referal{
    mapping(address => bool) isRef;

    function isReferred(address user) public view returns(bool){
      return(isRef[user]);
    }
    function updateReward(address user, uint256 amount) public{
    }
    function update(address user, bool isref) public{
        isRef[user] = isref;
    }
}
