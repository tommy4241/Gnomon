// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../src/Gnomon.sol";
import "../src/Heart.sol";
import "../src/IHeart.sol";
import "../src/Mystery.sol";
import "../src/IMystery.sol";
import "../src/TierDetails.sol";

import "./lib/MockUser.sol";
import "./lib/MockERC20Token.sol";

contract GnomonTest is Test {
    using SafeMath for uint256;

    Gnomon public gnomon;
    MysteryBox public mysteryBox;
    Heart public heart;

    string[] public tokens = [
        "Cell",
        "BuildingMaterials",
        "Aurorium",
        "Persidian",
        "Floxium",
        "Deeds",
        "DataSheets",
        "Food",
        "ConsolationCookies",
        "MindtrapMilk"
    ];
    MockERC20Token[] public rewardTokens;

    TierDetails[] public _commonTier;
    TierDetails[] public _rareTier;
    TierDetails[] public _legendaryTier;

    MockUser public player1;
    MockUser public player2;

    

    function setUp() public {
        // deploy gnomon
        gnomon = new Gnomon();

        // deploy heart
        heart = new Heart();

        // deploy mystery box & set gnomon
        mysteryBox = new MysteryBox("MysteryBox", "MBOX");
        mysteryBox.setGnomon(address(gnomon));
        // mint 10k nfts to the gnomon for testing
        mysteryBox.preMintForTest();

        // deploy reward tokens
        for(uint256 i = 0; i < 10; ++i){
            MockERC20Token _temp = new MockERC20Token(tokens[i], tokens[i]);
            _temp.setGnomon(address(gnomon));
            _temp.preMint();
            rewardTokens.push(_temp);
        }

        // update common tier
        _commonTier.push( TierDetails({token : address(rewardTokens[0]), amount : 1000, dropRate : 259}));
        _commonTier.push( TierDetails({token : address(rewardTokens[0]),amount : 200,dropRate : 431}));
        _commonTier.push( TierDetails({token : address(rewardTokens[1]),amount : 1,dropRate : 690}));
        _commonTier.push( TierDetails({token : address(rewardTokens[2]),amount : 5,dropRate : 517}));
        _commonTier.push( TierDetails({token : address(rewardTokens[3]),amount : 1,dropRate : 431}));
        _commonTier.push( TierDetails({token : address(rewardTokens[4]),amount : 1,dropRate : 345}));
        _commonTier.push( TierDetails({token : address(rewardTokens[5]),amount : 1,dropRate : 517}));
        _commonTier.push( TierDetails({token : address(rewardTokens[6]),amount : 1,dropRate : 690}));
        _commonTier.push( TierDetails({token : address(rewardTokens[7]),amount : 1,dropRate : 1724}));
        _commonTier.push( TierDetails({token : address(rewardTokens[8]),amount : 1,dropRate : 86}));
        _commonTier.push( TierDetails({token : address(rewardTokens[9]),amount : 1,dropRate : 1724}));
        _commonTier.push( TierDetails({token : address(mysteryBox),amount : 1,dropRate : 87}));

        gnomon.updateCommonTier( _commonTier );

        // update rare tier
        _rareTier.push( TierDetails({token : address(rewardTokens[0]), amount : 5000, dropRate : 174}));
        _rareTier.push( TierDetails({token : address(rewardTokens[0]),amount : 1000,dropRate : 435}));
        _rareTier.push( TierDetails({token : address(rewardTokens[1]),amount : 5,dropRate : 696}));
        _rareTier.push( TierDetails({token : address(rewardTokens[2]),amount : 10,dropRate : 522}));
        _rareTier.push( TierDetails({token : address(rewardTokens[3]),amount : 2,dropRate : 435}));
        _rareTier.push( TierDetails({token : address(rewardTokens[4]),amount : 2,dropRate : 348}));
        _rareTier.push( TierDetails({token : address(rewardTokens[5]),amount : 2,dropRate : 522}));
        _rareTier.push( TierDetails({token : address(rewardTokens[6]),amount : 2,dropRate : 696}));
        _rareTier.push( TierDetails({token : address(rewardTokens[7]),amount : 5,dropRate : 1739}));
        _rareTier.push( TierDetails({token : address(rewardTokens[8]),amount : 5,dropRate : 2609}));
        _rareTier.push( TierDetails({token : address(rewardTokens[9]),amount : 5,dropRate : 1739}));
        _rareTier.push( TierDetails({token : address(mysteryBox),amount : 1,dropRate : 87}));

        gnomon.updateRareTier(_rareTier);

        // update common tier
        _legendaryTier.push( TierDetails({token : address(rewardTokens[0]), amount : 1000, dropRate : 131}));
        _legendaryTier.push( TierDetails({token : address(rewardTokens[0]),amount : 200,dropRate : 437}));
        _legendaryTier.push( TierDetails({token : address(rewardTokens[1]),amount : 1,dropRate : 699}));
        _legendaryTier.push( TierDetails({token : address(rewardTokens[2]),amount : 5,dropRate : 524}));
        _legendaryTier.push( TierDetails({token : address(rewardTokens[3]),amount : 1,dropRate : 437}));
        _legendaryTier.push( TierDetails({token : address(rewardTokens[4]),amount : 1,dropRate : 349}));
        _legendaryTier.push( TierDetails({token : address(rewardTokens[5]),amount : 1,dropRate : 524}));
        _legendaryTier.push( TierDetails({token : address(rewardTokens[6]),amount : 1,dropRate : 699}));
        _legendaryTier.push( TierDetails({token : address(rewardTokens[7]),amount : 1,dropRate : 1747}));
        _legendaryTier.push( TierDetails({token : address(rewardTokens[8]),amount : 1,dropRate : 2620}));
        _legendaryTier.push( TierDetails({token : address(rewardTokens[9]),amount : 1,dropRate : 1747}));
        _legendaryTier.push( TierDetails({token : address(mysteryBox),amount : 1,dropRate : 87}));

        gnomon.updateLegendaryTier(_legendaryTier);

        // now people can spin?

    }

    function testSpin() {
        
    }


}