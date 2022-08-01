// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

import "./IHeart.sol";
import "./IMystery.sol";
import "./TierDetails.sol";

contract Gnomon is Ownable, IERC721Receiver {

    using SafeMath for uint256;
    using Address for address;
    using ERC165Checker for address;

    event RewardedFromGnomon (
        address indexed winner,
        address indexed token,
        uint256 tier,
        uint256 value
    );

    uint256 public constant COMMON = 0;
    uint256 public constant RARE = 1;
    uint256 public constant LEGENDARY = 2;

    uint256[3] public buyinCosts;

    TierDetails private UNLUCKYTIER = TierDetails(
        address(0),0,0
    );

    TierDetails[12] public commonTiers;
    TierDetails[12] public rareTiers;
    TierDetails[12] public legendaryTiers;

    mapping (uint256 => TierDetails[]) public gnomon;

    // user - tier - last reward timestamp
    mapping (address => mapping(uint256 => uint256)) public playerNFTRewarded;

    // heart
    IHeart private heart;

    // Mystery
    address public mystery;

    uint256 public constant DENOMINATOR = 10000;

    bytes4 private constant InterfaceId_ERC721 = 0x80ac58cd;

    modifier onlyMystery () {
        require(msg.sender == mystery, "unauthorised");
        _;
    }

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

    function discoverMystery (address _mystery) external onlyOwner {
        // only erc-721 standard
        require(_mystery.supportsInterface(InterfaceId_ERC721), "invalid mystery address");
        mystery = _mystery;
    }

    function updateCommonTier(TierDetails[] memory _common) external onlyOwner {
        _updateCommonTier(_common);
    }

    // internal
    function _updateCommonTier(TierDetails[] memory _common) internal {
        for(uint256 i = 0; i < _common.length; ++i){
            commonTiers[i] = _common[i];
        }
    }

    function updateRareTier(TierDetails[] memory _rare) external onlyOwner {
        _updateRareTier(_rare);
    }
    // internal
    function _updateRareTier(TierDetails[] memory _rare) internal {
        for (uint256 i = 0; i < _rare.length; ++i) {
            rareTiers[i] = _rare[i];
        }
    }

    function updateLegendaryTier(TierDetails[] memory _legendary) external onlyOwner {
        _updateLegendaryTier(_legendary);
    }

    // internal
    function _updateLegendaryTier(TierDetails[] memory _legendary) internal {
        for(uint256 i = 0 ; i < _legendary.length ; ++i){
            legendaryTiers[i] = _legendary[i];
        }
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

    // user pays token, wishes for a luck
    function spin(uint256 tier) external {
        require(tier > 2, "tier not supported");
        TierDetails memory _tierDetails = _spin(tier);
        if(_tierDetails.token == address(0))
            emit RewardedFromGnomon(msg.sender, address(0), 0, 0);
        // check if it is an nft
        uint256 tierSize = gnomon[tier].length;
        address nftToken = gnomon[tier][tierSize-1].token;
        if(_tierDetails.token == nftToken){
            if(block.timestamp - playerNFTRewarded[msg.sender][tier] <= 7 days){
                emit RewardedFromGnomon(msg.sender, address(0), 0, 0);
            }else{
                require( IERC721(mystery).balanceOf(address(this)) > 0, "insufficient nft balance" );
                // send an nft to the user
                uint256 tokenIDToSend = IMystery(mystery).getRewardTokenID();
                IERC721(mystery).transferFrom(
                    address(this),
                    msg.sender,
                    tokenIDToSend
                );
                // update last reward time
                playerNFTRewarded[msg.sender][tier] = block.timestamp;
                emit RewardedFromGnomon (msg.sender, _tierDetails.token, tier, tokenIDToSend);
            }
        }
        else{
            // transfer erc20 tokens
            require(IERC20(_tierDetails.token).balanceOf(address(this)) >= _tierDetails.amount,
            string(abi.encode("insufficient ", _tierDetails.token, " balance"))
            );
            IERC20(_tierDetails.token).transfer(msg.sender, _tierDetails.amount);
            emit RewardedFromGnomon(msg.sender, _tierDetails.token, tier, _tierDetails.amount);
        }
    }

    function _spin (uint256 tier) internal returns (TierDetails memory _tierDetails) {
        uint256 pressure = heart.heartRate();
        uint256 point = 0;
        for(uint256 i = 0; i < gnomon[tier].length ; ++i) {
            point+= gnomon[tier][i].dropRate;
            if(point > pressure)
                return gnomon[tier][i];
        }
        return UNLUCKYTIER;
    }

    // overrid onERC721Received to get nfts from safeTransfer
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) external override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}



