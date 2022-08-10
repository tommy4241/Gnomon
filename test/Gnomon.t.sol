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
import "../src/Structs.sol";

import "./lib/MockUser.sol";
import "./lib/MockERC20Token.sol";
import "./lib/CheatCodes.sol";

contract GnomonTest is Test {

    using SafeMath for uint256;

    CheatCodes cheats = CheatCodes(HEVM_ADDRESS);

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
        // init dummy users
        player1 = new MockUser();
        player2 = new MockUser();
        // deploy gnomon
        gnomon = new Gnomon();

        // deploy heart
        heart = new Heart();

        // set heart address to gnomon
        gnomon.giveHeart(address(heart));

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
        
        // set the cell token address to gnomon
        gnomon.updateCell(address(rewardTokens[0]));

        // users need to have some cell tokens to play
        deal(address(rewardTokens[0]), address(player1), 10000e18);
        deal(address(rewardTokens[0]), address(player2), 10000e18);
        
        // increase allowances
        cheats.startPrank(address(player1));
        for(uint256 i = 0; i < 10; ++i)
            rewardTokens[i].approve(address(gnomon), type(uint256).max);
        cheats.stopPrank();
        cheats.startPrank(address(player2));
        for(uint256 i = 0; i < 10; ++i)
            rewardTokens[i].approve(address(gnomon), type(uint256).max);
        cheats.stopPrank();

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

        // now update gnomon logics
        gnomon.updateGnomon();

        // now people can spin?

    }

    function testHeartRate () public {
        console.logString("Heart Rates before updating seed");
        for (uint256 i = 0; i < 5; ++i){
            uint256 heartRate = heart.heartRate();
            console.logUint(heartRate);
        }
        console.logString("update seed");
        heart.updateSeed(323421);
        console.logString("Heart Rates after updating seed");
        for (uint256 i = 0; i < 5; ++i){
            uint256 heartRate = heart.heartRate();
            console.logUint(heartRate);
        }
    }

    function testBuyTicket () public {
        cheats.startPrank(address(player1));
        gnomon.buyTickets(0, 5);
        gnomon.buyTickets(1, 3);
        gnomon.buyTickets(2, 6);
        
        // now log counts
        console.logUint(
            gnomon.getTicketBalance(address(player1),0)
        );
        console.logUint(
            gnomon.getTicketBalance(address(player1),1)
        );
        console.logUint(
            gnomon.getTicketBalance(address(player1),2)
        );

        // log original cell amount
        console.logString("reward token balances before play");
        
        for(uint256 i = 0; i < 10; ++i){
            console.logUint(
                rewardTokens[i].balanceOf(address(player1))
            );
        }
        console.logString("nft balance before play");

        console.logUint(
            mysteryBox.balanceOf(address(player1))
        );
        // spin 5 times
        for(uint256 i = 0; i < 5; ++i){
            gnomon.spin(0);
        }
        // log potential balances
        console.logString("reward balances after 5 spins");
        for(uint256 i = 0; i < 10; ++i){
            console.logUint(
                rewardTokens[i].balanceOf(address(player1))
            );
        }
        console.logString("nft balance after play");

        console.logUint(
            mysteryBox.balanceOf(address(player1))
        );
        
        cheats.stopPrank();

        console.logString("ticket balances after play");
        console.logUint(
            gnomon.getTicketBalance(address(player1),0)
        );
        console.logUint(
            gnomon.getTicketBalance(address(player1),1)
        );
        console.logUint(
            gnomon.getTicketBalance(address(player1),2)
        );
        console.logString("total spin counts");
        console.logUint(gnomon.getTotalSpinCounts(address(player1), 0));
        console.logString("player rewards");
        address _token;
        uint256 amount;
        (_token, amount) = gnomon.seeWinnings(address(player1), 0, 5);
        console.log(_token);
        console.logUint(amount);
    }

    function testFailBuyTicket () public {
        cheats.startPrank(address(player1));
        gnomon.buyTickets(3, 2);
        cheats.stopPrank();
    }

}
