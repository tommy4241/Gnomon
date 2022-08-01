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

    struct TierDetails {
        address token;
        uint256 amount;
        uint256 dropRate; //1e4
    }

    TierDetails private UNLUCKYTIER = TierDetails(
        address(0),0,0
    );

    TierDetails[] public commonTiers;
    TierDetails[] public rareTiers;
    TierDetails[] public legendaryTiers;

    mapping (uint256 => TierDetails[]) public gnomon;

    // last time user rewarded an nft
    mapping (address => uint256) public playerNFTRewarded;

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

    // user pays token, wish for a chance
    function spin(uint256 tier) external {
        require(tier <= 2, "tier not supported");
        TierDetails memory _tierDetails = _spin(tier);
        if(_tierDetails.token == address(0))
            emit RewardedFromGnomon(msg.sender, address(0), 0, 0);
        // check if it is an nft
        uint256 tierSize = gnomon[tier].length;
        address nftToken = gnomon[tier][tierSize-1].token;
        if(_tierDetails.token == nftToken){
            if(block.timestamp - playerNFTRewarded[msg.sender] <= 7 days){
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
                playerNFTRewarded[msg.sender] = block.timestamp;
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



