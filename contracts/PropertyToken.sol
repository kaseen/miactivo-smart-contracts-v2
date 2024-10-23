// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract PropertyToken is ERC20 {
    
    error InsufficientTokenSupply();
    error InsufficientUserBalance();

    event UserBoughtTokens(address, uint256);
    event UserDepositedTokens(address, uint256);

    mapping(address => uint256) public depositedTokens;

    constructor(
        string memory name,
        string memory symbol,
        uint256 premint
    ) ERC20 (name, symbol) {
        _mint(address(this), premint);
    }

    function userBuysTokens(address userAddress, uint256 amount) public {
        if(balanceOf(address(this)) < amount)
            revert InsufficientTokenSupply();

        _transfer(address(this), userAddress, amount);
        emit UserBoughtTokens(userAddress, amount);
    }

    function userDepositsTokens(address userAddress, uint256 amount) public {
        if(balanceOf(userAddress) - depositedTokens[userAddress] < amount)
            revert InsufficientUserBalance();

        depositedTokens[userAddress] += amount;
        emit UserDepositedTokens(userAddress, amount);
    }
}