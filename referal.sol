// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";


contract Referal is Ownable {
   

    mapping(address => address) public referedBy;
    mapping(address => address[]) public getRefrees;
    

    event Registered(address indexed user, address indexed referrer);

  
    constructor(
       

    ) {}
      
  
    function refer(address referrer) external{
    require(referedBy[msg.sender] == address(0),"Already registered");
    referedBy[msg.sender] = referrer;
    getRefrees[referrer].push(msg.sender);
    emit Registered(msg.sender, referrer);
    }

    function getReferrer(address user) external  view returns(address){
        return(referedBy[user]);
    }

    function getAllRefrees(address user) external  view returns(address[] memory){
        return(getRefrees[user]);
    }

                                                                                                     

}
