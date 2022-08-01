// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IMystery.sol";

contract MysteryBox is ERC721, Ownable, IMystery {

    address public gnomon;
    uint256 [] public gnomonOwnedIDs;
    mapping (uint256 => uint256) public gnomonIDMap;

    constructor(string memory name, string memory symbol) ERC721(name, symbol){

    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenID
    ) internal override {
        require(gnomon != address(0), "gnomon contract is not set");
        if(from == gnomon) {
            _updateGnomonNFTs(tokenID, false);
        }
        else if (to == gnomon){
            _updateGnomonNFTs(tokenID, true);
        }
    }

    function _updateGnomonNFTs (uint256 tokenID, bool isAdded) internal {
        // if it's a send tx to gnomon, then add
        if(isAdded){
            gnomonOwnedIDs.push(tokenID);
            uint256 arrLen = gnomonOwnedIDs.length;
            gnomonIDMap[tokenID] = arrLen - 1;
        }
        // if it's a send tx from gnomon, then remove
        else{
            uint256 tokenIdx = gnomonIDMap[tokenID];
            // if tokenIdx is 0, can be really the first token or removed token
            if(tokenIdx == 0){
                if(tokenID != gnomonOwnedIDs[0])
                    revert("gnomon doesn't have such id");
            }
            uint256 gnomonHoldings = gnomonOwnedIDs.length;
            gnomonOwnedIDs[tokenIdx] = gnomonOwnedIDs[gnomonHoldings-1];
            delete gnomonIDMap[tokenID];
        }
    }

    function getRewardTokenID () external view returns (uint256 id) {
        id = gnomonOwnedIDs[0];
    }

    function setGnomon (address _gnomon) external onlyOwner {
        gnomon = _gnomon;
    }

}