// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PropertyToken is ERC20 {
    
    constructor(
        string memory name,
        string memory symbol,
        uint premint
    ) ERC20 (name, symbol) {
        _mint(address(this), premint);
    }

    
}