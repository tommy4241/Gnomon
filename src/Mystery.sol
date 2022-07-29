// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MysteryBox is ERC721, Ownable {
    address public gnomon;

    constructor(string memory name, string memory symbol) ERC721(name, symbol){

    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        if(from == gnomon) {

        }
        else if (to == gnomon){
            
        }
    }

}