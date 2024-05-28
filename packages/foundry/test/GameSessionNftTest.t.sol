// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {DeployGameSessionNft} from "../script/DeployGameSessionNft.s.sol";
import {GameSessionNft} from "../contracts/GameSessionNft.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {MintGameSessionNft, MintCompleteGameSessionNftBase64} from "../script/Interactions.s.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract GameSessionNftTest is StdCheats, Test {
    string constant NFT_NAME = "MonkeyTrivia NFT";
    string constant NFT_SYMBOL = "MTSession";
    GameSessionNft public gameSessionNft;
    DeployGameSessionNft public deployer;
    address public deployerAddress;

    string public constant ACTIVE_URI =
        "https://bafkreiapzeyrdkua4x7fkzfcdnbxro5bh2kzqqfta5knstzo54ittisbga.ipfs.nftstorage.link";

    string public constant COMPLETE_URI =
        "https://bafkreih3uethjok3wtnyyg6knpc3oyko4lc5cehs4nx6qvmmsgnu6qebgm.ipfs.nftstorage.link/";

    address public constant USER = address(1);

    function setUp() public {
        deployer = new DeployGameSessionNft();
        gameSessionNft = deployer.run();
    }

    function testInitializedCorrectly() public view {
        assert(
            keccak256(abi.encodePacked(gameSessionNft.name()))
                == keccak256(abi.encodePacked((NFT_NAME)))
        );
        assert(
            keccak256(abi.encodePacked(gameSessionNft.symbol()))
                == keccak256(abi.encodePacked((NFT_SYMBOL)))
        );
    }

    function testCanMintAndHaveABalance() public {
        vm.prank(USER);
        gameSessionNft.mintNftActive(ACTIVE_URI);

        assert(gameSessionNft.balanceOf(USER) == 1);
    }

    function testTokenActiveURIIsCorrect() public {
        vm.prank(USER);
        gameSessionNft.mintNftActive(ACTIVE_URI);

        assert(
            keccak256(abi.encodePacked(gameSessionNft.tokenURI(0)))
                == keccak256(abi.encodePacked(ACTIVE_URI))
        );
    }

    function testTokenCompleteURIIsCorrect() public {
        vm.prank(USER);
        gameSessionNft.mintNftComplete(COMPLETE_URI);

        assert(
            keccak256(abi.encodePacked(gameSessionNft.tokenURI(0)))
                == keccak256(abi.encodePacked(COMPLETE_URI))
        );
    }

    function testMintWithActiveSessionScript() public {
        uint256 startingTokenCount = gameSessionNft.getTokenCounter();
        MintGameSessionNft mintGameSessionNft = new MintGameSessionNft();
        mintGameSessionNft.mintNftActiveSessionOnContract(
            address(gameSessionNft)
        );
        assert(gameSessionNft.getTokenCounter() == startingTokenCount + 1);
        assert(
            gameSessionNft.getTokenIdToState(0)
                == GameSessionNft.NFTState.ACTIVE
        );
    }

    function testMintWithCompleteSessionScript() public {
        uint256 startingTokenCount = gameSessionNft.getTokenCounter();
        MintCompleteGameSessionNftBase64 mintGameSessionNft = new MintCompleteGameSessionNftBase64();
        mintGameSessionNft.mintNftCompletedSessionOnContract(
            address(gameSessionNft)
        );
        assert(gameSessionNft.getTokenCounter() == startingTokenCount + 1);
        assert(
            gameSessionNft.getTokenIdToState(0)
                == GameSessionNft.NFTState.COMPLETE
        );
    }

    function testJsonToUriActive() public pure {
        string memory json =
            '{"name":"Monkey NFT", "description":"An NFT that reflects the mood of the owner, 100% on Chain!", "attributes": [{"trait_type": "moodiness", "value": 100}], "image":"https://bafybeiho6hqlwn5t5al4puie4wvae5atjph4h2pmanegfyk2plb4r4sjbu.ipfs.nftstorage.link/"}';
        string memory uri = jsonToURI(json);
        // console.log("uri: %s", uri);
        assert(
            keccak256(abi.encodePacked(uri))
                == keccak256(
                    abi.encodePacked(
                        "data:application/json;base64,eyJuYW1lIjoiTW9ua2V5IE5GVCIsICJkZXNjcmlwdGlvbiI6IkFuIE5GVCB0aGF0IHJlZmxlY3RzIHRoZSBtb29kIG9mIHRoZSBvd25lciwgMTAwJSBvbiBDaGFpbiEiLCAiYXR0cmlidXRlcyI6IFt7InRyYWl0X3R5cGUiOiAibW9vZGluZXNzIiwgInZhbHVlIjogMTAwfV0sICJpbWFnZSI6Imh0dHBzOi8vYmFmeWJlaWhvNmhxbHduNXQ1YWw0cHVpZTR3dmFlNWF0anBoNGgycG1hbmVnZnlrMnBsYjRyNHNqYnUuaXBmcy5uZnRzdG9yYWdlLmxpbmsvIn0="
                    )
                )
        );
    }

    function testJsonToUriComplete() public view {
        string memory json =
            vm.readFile("./images/monkey-trivia/monkey-trivia-session-winner.json");
        string memory uri = jsonToURI(json);
        // console.log("uri: %s", uri);
        assert(
            keccak256(abi.encodePacked(uri))
                == keccak256(
                    abi.encodePacked(
                        "data:application/json;base64,ewogICAgIm5hbWUiOiAiTW9ua2V5IFRyaXZpYSBTZXNzaW9uIENvbXBsZXRlZCIsCiAgICAiZGVzY3JpcHRpb24iOiAiR2FtZSBzZXNzaWlvbiBjb21wbGV0ZWQuICBZb3UgYXJlIGEgd2lubmVyISIsCiAgICAiaW1hZ2UiOiAiaHR0cHM6Ly9iYWZ5YmVpZXh4eTd2cHRwdGo2eXg2cmVodjV4cDRnYTd6enRiZTJ1ZHUyZDNnYTNiZTRnc243bmt4NC5pcGZzLm5mdHN0b3JhZ2UubGluay8iLAogICAgImF0dHJpYnV0ZXMiOiBbCiAgICAgICAgewogICAgICAgICAgICAidHJhaXRfdHlwZSI6ICJwbGFjZSIsCiAgICAgICAgICAgICJ2YWx1ZSI6ICIxc3QiCiAgICAgICAgfQogICAgXQp9"
                    )
                )
        );
    }

    // function to convert Json to URI using base64 encoding
    function jsonToURI(string memory json)
        public
        pure
        returns (string memory)
    {
        string memory baseURI = "data:application/json;base64,";
        string memory jsonBase64Encoded =
            Base64.encode(bytes(string(abi.encodePacked(json))));
        return string(abi.encodePacked(baseURI, jsonBase64Encoded));
    }
}
