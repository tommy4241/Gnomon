// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockERC721Token is ERC721 {

    constructor (string memory name, string memory symbol) ERC721(name, symbol){}

}