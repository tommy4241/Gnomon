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
import "./Structs.sol";

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
    // user - tier - ticket amount
    mapping (address => mapping (uint256 => uint256)) public tickets;
    // user-tier-number of spins
    mapping (address => mapping (uint256 => uint256)) public numberOfSpins;
    // user - tier - sping number - winning
    mapping (address => mapping (uint256 => mapping (uint256 => UserWinnings))) public winnings;

    // heart
    IHeart private heart;

    // Mystery
    address public mystery;

    uint256 public constant DENOMINATOR = 10000;

    bytes4 private constant InterfaceId_ERC721 = 0x80ac58cd;

    // cell token
    IERC20 cell;

    modifier onlyMystery () {
        require(msg.sender == mystery, "unauthorised");
        _;
    }

    modifier onlyTickets (uint256 tier) {
        require(tickets[msg.sender][tier] > 0, "don't have any ticket");
        _;
    }

    constructor() {
        _initBuyInCosts();
    }

    // internal
    function _initBuyInCosts() internal {
        buyinCosts[COMMON] = 100 * 1e18;
        buyinCosts[RARE] = 500 * 1e18;
        buyinCosts[LEGENDARY] = 1000 * 1e18;
    }

    function getTicketBalance (address player, uint256 tier) external view returns(uint256 balance) {
        balance = tickets[player][tier];
    }

    function getTotalSpinCounts (address player, uint256 tier) external view returns (uint256){
        return numberOfSpins[player][tier];
    }

    function seeWinnings (address player, uint256 tier, uint256 spinHeight) external view returns (
        address token, uint256 amount
    ) {
        UserWinnings memory _winning = winnings[player][tier][spinHeight];
        token = _winning.token;
        amount = _winning.amount;
    }

    // set the rng address
    function giveHeart (address _heart) external onlyOwner {
        heart = IHeart(_heart);
    }
    // set the reward nft addr
    function discoverMystery (address _mystery) external onlyOwner {
        // only erc-721 standard
        require(_mystery.supportsInterface(InterfaceId_ERC721), "invalid mystery address");
        mystery = _mystery;
    }
    // common tier gnomon logics
    function updateCommonTier(TierDetails[] memory _common) external onlyOwner {
        _updateCommonTier(_common);
    }

    // internal
    function _updateCommonTier(TierDetails[] memory _common) internal {
        for(uint256 i = 0; i < _common.length; ++i){
            commonTiers[i] = _common[i];
        }
    }
    // update rare tier gnomon logics
    function updateRareTier(TierDetails[] memory _rare) external onlyOwner {
        _updateRareTier(_rare);
    }
    // internal
    function _updateRareTier(TierDetails[] memory _rare) internal {
        for (uint256 i = 0; i < _rare.length; ++i) {
            rareTiers[i] = _rare[i];
        }
    }
    // update legendary tier gnomon logics
    function updateLegendaryTier(TierDetails[] memory _legendary) external onlyOwner {
        _updateLegendaryTier(_legendary);
    }

    // internal
    function _updateLegendaryTier(TierDetails[] memory _legendary) internal {
        for(uint256 i = 0 ; i < _legendary.length ; ++i){
            legendaryTiers[i] = _legendary[i];
        }
    }
    // update all 3 tiers
    function updateTiers (
        TierDetails[] memory _common,
        TierDetails[] memory _rare,
        TierDetails[] memory _legendary
    ) external onlyOwner {
        _updateCommonTier(_common);
        _updateRareTier(_rare);  
        _updateLegendaryTier(_legendary);
    }
    // update cell token address
    function updateCell (address _cell) external onlyOwner {
        cell = IERC20(_cell);
    }
    // update buy in costs of 3 tiers
    function updateBuyInCosts (uint256[3] memory _costs) external onlyOwner {
        buyinCosts = _costs;
    }
    // update gnomon stored on chain, mapping of tier -> tier math
    function updateGnomon() external onlyOwner {
        gnomon[COMMON] = commonTiers;
        gnomon[RARE] = rareTiers;
        gnomon[LEGENDARY] = legendaryTiers;
    }

    function assignTickets (uint256 tier, uint256 amount, address receiver) external onlyOwner {
        uint256 originalTicket = tickets[receiver][tier];
        tickets[receiver][tier] = originalTicket + amount;
    }

    // buys amount of tickets for the tier, amount * buy in cost of the tier
    function buyTickets (uint256 tier, uint256 amount) external {
        require(tier < 3, "tier not supported");
        cell.transferFrom(msg.sender, address(this), amount.mul(buyinCosts[tier]));
        uint256 originalAmount = tickets[msg.sender][tier];
        tickets[msg.sender][tier] = (originalAmount + amount);
    }

    // user pays token, wishes for a luck
    function spin(uint256 tier)  external onlyTickets(tier) {
        require(tier < 3, "tier not supported");
        TierDetails memory _tierDetails = _spin(tier, msg.sender);
        if(_tierDetails.token == address(0)){
            _storeReward(msg.sender, tier, address(0),0);
            emit RewardedFromGnomon(msg.sender, address(0), 0, 0);
            }
        // check if it is an nft
        uint256 tierSize = gnomon[tier].length;
        address nftToken = gnomon[tier][tierSize-1].token;
        if(_tierDetails.token == nftToken){
            if(block.timestamp - playerNFTRewarded[msg.sender][tier] <= 7 days){
                uint256 originalTicket = tickets[msg.sender][tier];
                // we give 2 more tickets since user can't get any reward
                tickets[msg.sender][tier] = originalTicket + 2;
                _storeReward(msg.sender, tier, address(0),2);
                emit RewardedFromGnomon(msg.sender, address(0), 2, 2);
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
                _storeReward(msg.sender,tier,_tierDetails.token, tokenIDToSend);
                emit RewardedFromGnomon (msg.sender, _tierDetails.token, tier, tokenIDToSend);
            }
        }
        else{
            // transfer erc20 tokens
            require(IERC20(_tierDetails.token).balanceOf(address(this)) >= _tierDetails.amount,
            string(abi.encode("insufficient ", _tierDetails.token, " balance"))
            );
            IERC20(_tierDetails.token).transfer(msg.sender, _tierDetails.amount);
            _storeReward(msg.sender,tier,_tierDetails.token, _tierDetails.amount);
            emit RewardedFromGnomon(msg.sender, _tierDetails.token, tier, _tierDetails.amount);
        }
    }

    function _spin (uint256 tier, address sender) internal returns (TierDetails memory _tierDetails) {
        
        _increaseTotalSpins(tier,sender);
        _decreaseTickets(tier,sender);

        uint256 pressure = heart.heartRate();
        uint256 point = 0;
        for(uint256 i = 0; i < gnomon[tier].length ; ++i) {
            point+= gnomon[tier][i].dropRate;
            if(point > pressure)
                return gnomon[tier][i];
        }
        return UNLUCKYTIER;
    }

    function _increaseTotalSpins (uint256 tier, address sender) internal {
        uint256 original = numberOfSpins[sender][tier];
        numberOfSpins[sender][tier] = original + 1;
    }
    
    function _decreaseTickets ( uint256 tier, address sender) internal {
        uint256 originalTicket = tickets[sender][tier];
        // since user used up 1 ticket to play, we remove 1
        tickets[sender][tier] = originalTicket - 1;
    }

    function _storeReward (address winner, uint256 tier, address token, uint256 amount) internal {
        uint256 highestSpin = numberOfSpins[winner][tier];
        winnings[winner][tier][highestSpin] = UserWinnings (token, amount);
    }

    function withdrawTokens (address token, address to, uint256 amount) external onlyOwner {
        IERC20(token).transferFrom(address(this), to, amount);
    }
    
    function withdrawNFT (address token, address to, uint256 tokenID) external onlyOwner {
        IERC721(token).transferFrom(address(this), to, tokenID);
    }
    
    function withdrawNFTsBatch (address token, address to, uint256[] memory tokenIDs) external onlyOwner {
        for(uint256 i = 0; i <  tokenIDs.length; ++i)
            IERC721(token).transferFrom(address(this), to, tokenIDs[i]);
    }
    
    function withdraw (address payable to, uint256 amount) external onlyOwner {
        (bool success,) = to.call{value : amount}("");
        require(success, "ether transfer failed");
    }

    // overrid onERC721Received to get nfts from safeTransfer
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) external override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}



