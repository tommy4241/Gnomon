// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IHeart.sol";

contract Heart is IHeart, Ownable, ReentrancyGuard {
    
    address private gnomon;
    uint256 private seed = 97;

    modifier onlyGnomon () {
        require(msg.sender == gnomon, "unauthorised");
        _;
    }

    constructor (address _gnomon) {
        gnomon = _gnomon;
    }

    function updateGnomon (address _gnomon) external onlyOwner {
        gnomon = _gnomon;
    }

    // get heart rate
    function heartRate() override virtual external onlyGnomon returns (uint256) {
        return uint256(
            keccak256(
                abi.encodePacked(
                    block.gaslimit,
                    block.timestamp,
                    block.difficulty,
                    _updatePressure()
                )
            )
        );
    }

    // update blood pressure
    function _updatePressure () nonReentrant internal returns (uint256) {
        seed = seed * 499;
        seed = seed % 10000;
        return seed;
    }

    function updateSeed (uint256 _seed) nonReentrant external onlyOwner {
        seed = _seed;
    }
}