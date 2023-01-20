// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ClaimToken is Ownable {
    
    IERC20 private acceptedToken;

    struct Royalti {
        uint256 tokenAmount;
        bool isClaim;
    }

    //mapping of struct
    mapping(address => mapping(uint256 => Royalti)) public RoyaltiMapping;
    mapping(address => bool) public addressStaked;

    constructor(address accepted_token){
        acceptedToken = IERC20(accepted_token);
    }

    function storeRoyaltiData(uint256 month, address[] memory participant, uint256[] calldata amount)
    public onlyOwner returns(bool) {
        for (uint256 i = 0; i < participant.length; i++) {
            RoyaltiMapping[participant[i]][month].tokenAmount = amount[i];
            RoyaltiMapping[participant[i]][month].isClaim = false;
            
            addressStaked[participant[i]] = true;
        }
        return true;
    }


    function getRoyaltiData(address user, uint256 month) public view returns(uint, bool) {
        uint amount = RoyaltiMapping[user][month].tokenAmount;
        bool isClaim = RoyaltiMapping[user][month].isClaim;
        return (amount, isClaim);
    }

    // uint256 month, address claim_user
    function claimRoyalti(address user, uint256 month)  
    public returns(bool) {
        require(addressStaked[_msgSender()] == true, "You are not participated");
        require(RoyaltiMapping[user][month].isClaim == false, "already claim");
        uint amount = RoyaltiMapping[user][month].tokenAmount;
        acceptedToken.transfer(user, amount);
        RoyaltiMapping[user][month].isClaim = true;

        return true;
    }
}