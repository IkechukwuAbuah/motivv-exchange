// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Exchange {
    address public feeAccount; //account that receives exchange fees
    uint256 public feePercent; //% charge on transactions

    constructor (address _feeAccount, uint256 _feePercent){
        feeAccount = _feeAccount;
        feePercent = _feePercent;
    }

}
