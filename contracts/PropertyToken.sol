// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract PropertyToken is ERC20, Ownable {
    
    event UserBoughtTokens(address, uint256);
    event UserDepositedTokens(address, uint256);
    event UserWithdrewTokens(address, uint256);
    event TokenTotalAmountIncreased(uint256);
    event TokenTotalAmountDecreased(uint256);

    error InsufficientTokenSupply();
    error InsufficientUserBalance();

    mapping(address => uint256) private _depositedTokens;

    constructor(
        string memory name,
        string memory symbol,
        uint256 premint
    ) 
    Ownable(msg.sender)
    ERC20(name, symbol)
    {
        _mint(address(this), premint);
    }

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

    function increaseTokenCirculation(uint256 amount) public onlyOwner {
        _mint(address(this), amount);
        emit TokenTotalAmountIncreased(amount);
    }

    function decreaseTokenCirculation(uint256 amount) public onlyOwner {
        if(balanceOf(address(this)) < amount)
            revert InsufficientTokenSupply();

        _burn(address(this), amount);
        emit TokenTotalAmountDecreased(amount);
    }

    function getDepositedTokensForUser(address userAddress) public view returns (uint256) {
        return _depositedTokens[userAddress];
    }
}