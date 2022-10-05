// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";


contract Referal is Ownable {
   

    mapping(address => address) public referedBy;
    mapping(address => address[]) public getRefrees;
    mapping(address => bool) public isWhitelisted;
    mapping(address => uint256) public referredTime;
    

    event Registered(address indexed user, address indexed referrer);

  
    constructor(
       

    ) {}
      
  
    function register(address referrer) external{
    require(referrer!= msg.sender,"User can't refer himself");
    require(isWhitelisted[referrer] == true || referedBy[referrer]!= address(0),"Enter a valid address" );
    require(referedBy[msg.sender] == address(0),"Already registered");
    referedBy[msg.sender] = referrer;
    getRefrees[referrer].push(msg.sender);
    referredTime[msg.sender] = block.timestamp;
    emit Registered(msg.sender, referrer);
    }

    function whitelist(address[] memory users, bool whitelisted) public onlyOwner{
        for(uint256 i =0; i< users.length; i++){
            isWhitelisted[users[i]] = whitelisted;
        }
    }

    function getReferrer(address user) external  view returns(address){
        return(referedBy[user]);
    }

    function getAllRefrees(address user) external  view returns(address[] memory){
        return(getRefrees[user]);
    }

                                                                                                     

}
