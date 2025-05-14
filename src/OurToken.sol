// SPDX-License-Identifier: MIT

//Powered by OpenZepplin - ERC-20 Standard Token

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

pragma solidity ^0.8.19;

contract OurToken is ERC20 {

    constructor(uint256 _intialSupply) ERC20("OurToken", "OT") {
        _mint(msg.sender, _intialSupply);
    }

}