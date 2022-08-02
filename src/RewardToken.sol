// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RewardToken is ERC20, Ownable {

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address _a, uint256 _b) external onlyOwner {
        _mint(_a, _b);
    }
}
