// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

abstract contract Token is ERC20, Ownable {

    event TokenTotalAmountIncreased(uint256);
    event TokenTotalAmountDecreased(uint256);
    error InsufficientTokenSupply();

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
}