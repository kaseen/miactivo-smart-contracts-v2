// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract PropertyToken is ERC20 {
    
    error InsufficientTokenSupply();
    event UserBoughtToken(address, uint256);
    error Test1();

    mapping(address => uint256) public depositedTokens;

    constructor(
        string memory name,
        string memory symbol,
        uint256 premint
    ) ERC20 (name, symbol) {
        _mint(address(this), premint);
    }

    function userBuysTokens(address recepient, uint256 amount) public {
        if(balanceOf(address(this)) < amount)
            revert InsufficientTokenSupply();

        _transfer(address(this), recepient, amount);
        emit UserBoughtToken(recepient, amount);
    }
}