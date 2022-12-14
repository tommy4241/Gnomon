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
        // mysteryBox.preMintForTest();

        // deploy reward tokens
        for(uint256 i = 0; i < 10; ++i){
            MockERC20Token _temp = new MockERC20Token(tokens[i], tokens[i]);
            _temp.setGnomon(address(gnomon));
            _temp.preMint();
            rewardTokens.push(_temp);
        }
        
        // set the cell token address to gnomon
        gnomon.updateCell(address(rewardTokens[0]));
        
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
        _commonTier.push( TierDetails({token : address(rewardTokens[0]), amount : 100, dropRate : 259}));
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
        _rareTier.push( TierDetails({token : address(rewardTokens[0]), amount : 500, dropRate : 174}));
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
        _legendaryTier.push( TierDetails({token : address(rewardTokens[0]), amount : 2000, dropRate : 131}));
        _legendaryTier.push( TierDetails({token : address(rewardTokens[0]),amount : 4000,dropRate : 437}));
        _legendaryTier.push( TierDetails({token : address(rewardTokens[1]),amount : 10,dropRate : 699}));
        _legendaryTier.push( TierDetails({token : address(rewardTokens[2]),amount : 20,dropRate : 524}));
        _legendaryTier.push( TierDetails({token : address(rewardTokens[3]),amount : 3,dropRate : 437}));
        _legendaryTier.push( TierDetails({token : address(rewardTokens[4]),amount : 3,dropRate : 349}));
        _legendaryTier.push( TierDetails({token : address(rewardTokens[5]),amount : 3,dropRate : 524}));
        _legendaryTier.push( TierDetails({token : address(rewardTokens[6]),amount : 3,dropRate : 699}));
        _legendaryTier.push( TierDetails({token : address(rewardTokens[7]),amount : 10,dropRate : 1747}));
        _legendaryTier.push( TierDetails({token : address(rewardTokens[8]),amount : 10,dropRate : 2620}));
        _legendaryTier.push( TierDetails({token : address(rewardTokens[9]),amount : 10,dropRate : 1747}));
        _legendaryTier.push( TierDetails({token : address(mysteryBox),amount : 1,dropRate : 87}));

        gnomon.updateLegendaryTier(_legendaryTier);

        // now update gnomon logics
        gnomon.updateGnomon();

        // now people can spin?
        gnomon.assignTickets(0, 5, address(player1));
        gnomon.assignTickets(1, 5, address(player1));
        gnomon.assignTickets(2, 33, address(player1));
        gnomon.assignTickets(0, 7, address(player2));
        gnomon.assignTickets(1, 8, address(player2));
        gnomon.assignTickets(2, 9, address(player2));

    }

    // function testHeartRate () public {
    //     console.logString("Heart Rates before updating seed");
    //     for (uint256 i = 0; i < 5; ++i){
    //         uint256 heartRate = heart.heartRate();
    //         console.logUint(heartRate);
    //     }
    //     console.logString("update seed");
    //     heart.updateSeed(323421);
    //     console.logString("Heart Rates after updating seed");
    //     for (uint256 i = 0; i < 5; ++i){
    //         uint256 heartRate = heart.heartRate();
    //         console.logUint(heartRate);
    //     }
    // }

    // function testBuyTicket () public {
    //     cheats.startPrank(address(player1));
        
    //     // now log counts
    //     console.logUint(
    //         gnomon.getTicketBalance(address(player1),0)
    //     );
    //     console.logUint(
    //         gnomon.getTicketBalance(address(player1),1)
    //     );
    //     console.logUint(
    //         gnomon.getTicketBalance(address(player1),2)
    //     );

    //     // log original cell amount
    //     console.logString("reward token balances before play");
        
    //     for(uint256 i = 0; i < 10; ++i){
    //         console.logUint(
    //             rewardTokens[i].balanceOf(address(player1))
    //         );
    //     }
    //     console.logString("nft balance before play");

    //     console.logUint(
    //         mysteryBox.balanceOf(address(player1))
    //     );
    //     // spin 5 times
    //     for(uint256 i = 0; i < 33; ++i){
    //         gnomon.spin(2);
    //     }
    //     // log potential balances
    //     console.logString("reward balances after 5 spins");
    //     for(uint256 i = 0; i < 10; ++i){
    //         console.logUint(
    //             rewardTokens[i].balanceOf(address(player1))
    //         );
    //     }
    //     console.logString("nft balance after play");

    //     console.logUint(
    //         mysteryBox.balanceOf(address(player1))
    //     );
        
    //     cheats.stopPrank();

    //     console.logString("ticket balances after play");
    //     console.logUint(
    //         gnomon.getTicketBalance(address(player1),0)
    //     );
    //     console.logUint(
    //         gnomon.getTicketBalance(address(player1),1)
    //     );
    //     console.logUint(
    //         gnomon.getTicketBalance(address(player1),2)
    //     );
    //     console.logString("total spin counts");
    //     console.logUint(gnomon.getTotalSpinCounts(address(player1), 2));
    //     console.logString("player rewards");
    //     address _token;
    //     uint256 amount;
    //     (_token, amount) = gnomon.seeWinnings(address(player1), 0, 5);
    //     console.log(_token);
    //     console.logUint(amount);
    //     // 
    //     for(uint256 i = 0; i < 33 ; ++ i){
    //         (,uint256 amount )= gnomon.seeWinnings(address(player1), 2, i);
    //         console.logUint(amount);
    //     }
    // }

    // function testFailBuyTicket () public {
    //     cheats.startPrank(address(player1));
    //     gnomon.buyTickets(3, 2);
    //     cheats.stopPrank();
    // }

    // function testWithdrawNFTs () public {
    //     uint256[] memory ids = new uint[](3);
    //     ids[0] = 44;
    //     ids[1] = 45;
    //     ids[2] = 46;
    //     console.log(mysteryBox.ownerOf(44));
    //     console.log(mysteryBox.ownerOf(45));
    //     console.log(mysteryBox.ownerOf(46));
    //     gnomon.withdrawNFTsBatch(address(mysteryBox), address(player1), ids);
    //     console.log(mysteryBox.ownerOf(44));
    //     console.log(mysteryBox.ownerOf(45));
    //     console.log(mysteryBox.ownerOf(46));
    // }

    // function testWithdrawTokens () public {
    //     console.logUint(IERC20(rewardTokens[2]).balanceOf(address(player1)));
    //     gnomon.withdrawTokens(address(rewardTokens[2]), address(player1), 10000000000);
    //     console.logUint(IERC20(rewardTokens[2]).balanceOf(address(player1)));
    // }

    // function testReadBalance () public {
    //     uint256[] memory balances = gnomon.getBalances(address(player2));
    //     console.logString("read balances");
    //     for(uint256 i = 0 ;i < 15; ++i)
    //         console.logUint(balances[i]);
    // }


    function testBatchMint () public {
        mysteryBox.batchMint(100, address(this));
        console.logUint(mysteryBox.balanceOf(address(this)));
    }

}
