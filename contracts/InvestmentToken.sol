// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import './Token.sol';

contract InvestmentToken is Token {

    constructor(
        string memory name,
        string memory symbol,
        uint256 premint
    ) 
    Token(name, symbol, premint){}

}