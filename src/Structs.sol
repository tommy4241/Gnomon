// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;


struct TierDetails {
    address token;
    uint256 amount;
    uint256 dropRate; //1e4
}

struct UserWinnings {
    address token;
    uint256 amount;
}