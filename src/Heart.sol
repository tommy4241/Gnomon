// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "./IHeart.sol";

contract Heart is IHeart {
    
    address private gnomon;

    modifier onlyGnomon () {
        require(msg.sender == gnomon, "unauthorised");
        _;
    }

    constructor (address _gnomon) {
        gnomon = _gnomon;
    }

    function heartRate() override virtual external onlyGnomon returns (uint256) {
        return 0;
    }
}