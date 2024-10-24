// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import './Token.sol';

contract PropertyToken is Token {
    
    event UserBoughtTokens(address, uint256);
    event UserDepositedTokens(address, uint256);
    event UserWithdrewTokens(address, uint256);

    error InsufficientUserBalance();

    mapping(address => uint256) private _depositedTokens;

    constructor(
        string memory name,
        string memory symbol,
        uint256 premint
    ) 
    Token(name, symbol, premint){}

    function userBuysTokens(address userAddress, uint256 amount) public onlyOwner {
        if(balanceOf(address(this)) < amount)
            revert InsufficientTokenSupply();

        _transfer(address(this), userAddress, amount);
        emit UserBoughtTokens(userAddress, amount);
    }

    function userDepositsTokens(address userAddress, uint256 amount) public onlyOwner {
        if(balanceOf(userAddress) - _depositedTokens[userAddress] < amount)
            revert InsufficientUserBalance();

        _depositedTokens[userAddress] += amount;
        emit UserDepositedTokens(userAddress, amount);
    }

    function userRefundsTokens(address userAddress, uint256 amount) public onlyOwner {
        if(_depositedTokens[userAddress] < amount)
            revert InsufficientUserBalance();

        _depositedTokens[userAddress] -= amount;
        _transfer(userAddress, address(this), amount);

        emit UserWithdrewTokens(userAddress, amount);
    }

    function getDepositedTokensForUser(address userAddress) public view returns (uint256) {
        return _depositedTokens[userAddress];
    }
}