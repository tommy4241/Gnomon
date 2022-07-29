// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Gnomon is Ownable, IERC721Receiver {

    using SafeMath for uint256;
    using Address for address;
    struct WheelRound {
        uint256 lastTimePlayed;
        uint256 totalPlayed;
    }

    // reward tokens
    IERC20 private cell;
    IERC20 private buildingMat;
    IERC20 private aurorium;
    IERC20 private persidian;
    IERC20 private floxium;
    IERC20 private deeds;
    IERC20 private dataSheets;
    IERC20 private  food;
    IERC20 private mindMilk;
    IERC20 private cookies;
    IERC721 private mystBox;

    // reward token addresses
    address private cellAddr;
    address private buildingMatAddr;
    address private auroriumAddr;
    address private persidianAddr;
    address private floxiumAddr;
    address private deedsAddr;
    address private dataSheetsAddr;
    address private  foodAddr;
    address private mindMilkAddr;
    address private cookiesAddr;
    address private mystBoxAddr;

    // reward token balance mapping : token addr - token contract
    mapping ( address => uint256 ) public balances;
    
    // rewards earned : user - token -reward
    mapping ( address => mapping ( address => uint256 ) ) public rewards;
    
    // last time user earned an nft
    mapping ( address => uint256 ) public lastNFTEarned;

    // user - {lastPlayed, lastPlayedTime}
    mapping ( address => WheelRound ) private playedRounds;

    // top 5 wallets
    address[5] public topWallets;

    constructor (address [] memory _tokens, uint256 [] memory ratios) {
        updateRewardTokens(_tokens);
    }

    // update reward token addresses
    function updateRewardTokens (address[] memory _tokens) public onlyOwner {
        bool areAllContracts = true;
        for(uint8 i = 0; i < _tokens.length ; ++i){
            address _token = _tokens[i];
            areAllContracts = areAllContracts && _token.isContract();
        }
        require(areAllContracts, "Gnomon/Update-Reward-Token-Failed");

    }

    function _updateRewardTokens (address [] memory _tokens) internal {

        cellAddr = _tokens[0];
        cell = IERC20(cellAddr);

        buildingMatAddr = _tokens[1];
        buildingMat = IERC20(buildingMatAddr);

        auroriumAddr = _tokens[2];
        aurorium = IERC20(aurorium);

        persidianAddr = _tokens[3];
        persidian = IERC20(persidianAddr);

        floxiumAddr = _tokens[4];
        floxium = IERC20(floxiumAddr);

        deedsAddr = _tokens[5];
        deeds = IERC20(deeds);

        dataSheetsAddr = _tokens[6];
        dataSheets = IERC20(dataSheetsAddr);

        foodAddr = _tokens[7];
        food = IERC20(foodAddr);

        mindMilkAddr = _tokens[8];
        mindMilk = IERC20(mindMilkAddr);

        cookiesAddr = _tokens[9];
        cookies = IERC20(cookiesAddr);

        mystBoxAddr = _tokens[10];
        mystBox = IERC721(mystBoxAddr);
        // check if mystBox is erc721
        bytes4 interfaceID = type(IERC721).interfaceId;
        require(mystBox.supportsInterface(interfaceID), "Gnomon/Invalid-nft-contract");
    }
    // overrid onERC721Received to get nfts from safeTransfer
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) external override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}



