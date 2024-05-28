// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract GameSessionNft is ERC721, Ownable {
    // error ERC721Metadata__URI_QueryFor_NonExistentToken();
    // error GameSessionNft__TokenUriNotFound();

    enum NFTState {
        ACTIVE,
        COMPLETE
    }

    uint256 private s_tokenCounter;
    mapping(uint256 tokenId => string tokenUri) private s_tokenIdToUri;
    mapping(uint256 => NFTState) private s_tokenIdToState;

    event CreatedNFT(uint256 indexed tokenId);

    constructor() ERC721("MonkeyTrivia NFT", "MTSession") Ownable(msg.sender) {
        s_tokenCounter = 0;
    }

    function mintNft(string memory tokenUri) private {
        s_tokenIdToUri[s_tokenCounter] = tokenUri;
        _safeMint(msg.sender, s_tokenCounter);
    }

    function mintNftActive(string memory tokenUri) external {
        mintNft(tokenUri);
        s_tokenIdToState[s_tokenCounter] = NFTState.ACTIVE;
        s_tokenCounter = s_tokenCounter + 1;
    }

    function mintNftComplete(string memory tokenUri) external {
        mintNft(tokenUri);
        s_tokenIdToState[s_tokenCounter] = NFTState.COMPLETE;
        s_tokenCounter = s_tokenCounter + 1;
    }

    function mintWithTokenUri(address to, string memory tokenUri) external {
        _safeMint(to, s_tokenCounter);
        s_tokenIdToState[s_tokenCounter] = NFTState.COMPLETE;
        s_tokenIdToUri[s_tokenCounter] = tokenUri;
        s_tokenCounter = s_tokenCounter + 1;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }
    
   function mint(address to, string memory sessionId) external {
        string memory COMPLETE_URL =string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes( // bytes casting actually unnecessary as 'abi.encodePacked()' returns a bytes
                        abi.encodePacked(
                            '{"name":"',
                            'Monkey Trivia Session Completed',
                            '", "description":"Game sessiion completed.  You are a winner!"',
                            ', "attributes": [{"trait_type": "place", "value": "1st"}, {"trait_type": "sessionId", "value":"',
                            sessionId,
                             '"}], "image":"',
                            'https://bafybeiexxy7vptptj6yx6rehv5xp4ga7zztbe2udu2d3ga3be4gsn7nkx4.ipfs.nftstorage.link/',
                            '"}'
                        )
                    )
                )
            )
        );
        
        _safeMint(to, s_tokenCounter);
        s_tokenIdToState[s_tokenCounter] = NFTState.COMPLETE;
        s_tokenIdToUri[s_tokenCounter] = COMPLETE_URL;
        s_tokenCounter = s_tokenCounter + 1;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return s_tokenIdToUri[tokenId];
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

    function getTokenIdToState(uint256 tokenId)
        public
        view
        returns (NFTState)
    {
        return s_tokenIdToState[tokenId];
    }
}
