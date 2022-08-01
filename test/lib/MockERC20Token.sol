// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockERC20Token is ERC20, Ownable {

    address public gnonmon;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address _a, uint256 _b) public {
        _mint(_a, _b);
    }

    // preMint 1000 tokens
    function preMint () public onlyOwner {
        _mint(gnonmon, 1000 * 1e18);
    }

    function setGnomon (address _gnomon) external onlyOwner {
        gnonmon = _gnomon;
    }
}
