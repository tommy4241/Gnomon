// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./IHeart.sol";

contract Gnomon is Ownable, IERC721Receiver {

    using SafeMath for uint256;
    using Address for address;

    uint256 public constant COMMON = 0;
    uint256 public constant RARE = 1;
    uint256 public constant LEGENDARY = 2;

    uint256[3] public buyinCosts;

    struct TierDetails {
        address token;
        uint256 amount;
        uint256 dropRate; //10000
    }

    TierDetails[] public commonTiers;
    TierDetails[] public rareTiers;
    TierDetails[] public legendaryTiers;

    mapping (uint256 => TierDetails[]) public gnomon;

    // heart
    IHeart private heart;

    uint256 public constant DENOMINATOR = 10000;

    constructor() {
        _initBuyInCosts();
    }

    // internal
    function _initBuyInCosts() internal {
        buyinCosts[COMMON] = 100;
        buyinCosts[RARE] = 500;
        buyinCosts[LEGENDARY] = 1000;
    }

    function giveHeart (address _heart) external onlyOwner {
        heart = IHeart(_heart);
    }

    function updateCommonTier(TierDetails[] memory _common) external onlyOwner {
        _updateCommonTier(_common);
    }

    // internal
    function _updateCommonTier(TierDetails[] memory _common) internal {
        commonTiers = _common;
    }

    function updateRareTier(TierDetails[] memory _rare) external onlyOwner {
        _updateRareTier(_rare);
    }
    // internal
    function _updateRareTier(TierDetails[] memory _rare) internal {
        rareTiers = _rare;
    }

    function updateLegendaryTier(TierDetails[] memory _legendary) external onlyOwner {
        _updateLegendaryTier(_legendary);
    }

    // internal
    function _updateLegendaryTier(TierDetails[] memory _legendary) internal {
        legendaryTiers = _legendary;
    }
    function updateTiers (
        TierDetails[] memory _common,
        TierDetails[] memory _rare,
        TierDetails[] memory _legendary
    ) external onlyOwner {
        _updateCommonTier(_common);
        _updateRareTier(_rare);  
        _updateLegendaryTier(_legendary);
    }

    function updateBuyInCosts (uint256[3] memory _costs) external onlyOwner {
        buyinCosts = _costs;
    }

    function updateGnomon() external onlyOwner {
        gnomon[COMMON] = commonTiers;
        gnomon[RARE] = rareTiers;
        gnomon[LEGENDARY] = legendaryTiers;
    }

    // overrid onERC721Received to get nfts from safeTransfer
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) external override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}



