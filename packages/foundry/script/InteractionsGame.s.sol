// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
// import {GameSessionNft} from "../contracts/GameSessionNft.sol";
// import {SourceMinter} from "../contracts/ccip/SourceMinter.sol";
// import {HelperConfig} from "./HelperConfig.s.sol";
// import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
// import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
// import {MockLinkToken} from "@chainlink/contracts/src/v0.8/mocks/MockLinkToken.sol";
// import { TriviaGameHubTest } from "../contracts/test/harnes/TriviaGameHubTest.sol";
// import {DeployTriviaGameHub} from "../script/DeployTriviaGameHub.s.sol";
import {TriviaGameHub} from "../contracts/TriviaGameHub.sol";


contract CreateGame is Script {
    function run() public {
        console.log("Creating game");
        address mostRecentlyDeployedTriviaGameHub = DevOpsTools
            .get_most_recent_deployment("TriviaGameHubTest", block.chainid);
        createGame(mostRecentlyDeployedTriviaGameHub);
    }

    function createGame(address _triviaGameHub) internal {
        vm.startBroadcast();
        TriviaGameHub triviaGameHub = TriviaGameHub(_triviaGameHub);
        uint256 gameId = triviaGameHub.createGame(block.timestamp, block.timestamp + 3600);
        vm.stopBroadcast();
        console.log("Game created with id: ", gameId);
    }
}

contract JoinGame is Script {
    uint256 gameId = vm.envUint("GAME_ID");
    uint256 score = vm.envUint("SCORE");
    
    function run() public {
        console.log("Joining game with id: ", gameId);
        // console.log("Join game with user:", user);
        
        address mostRecentlyDeployedTriviaGameHub = DevOpsTools
            .get_most_recent_deployment("TriviaGameHubTest", block.chainid);
        console.log("contract address: ", mostRecentlyDeployedTriviaGameHub);
        joinGame(mostRecentlyDeployedTriviaGameHub);
    }

    function joinGame(address _triviaGameHub) internal {
        vm.startBroadcast();
        TriviaGameHub triviaGameHub = TriviaGameHub(_triviaGameHub);
        triviaGameHub.joinGame(gameId, score);
        vm.stopBroadcast();
    }
}