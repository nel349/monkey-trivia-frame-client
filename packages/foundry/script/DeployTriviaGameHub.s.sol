// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {TriviaGameHub} from "../contracts/TriviaGameHub.sol";
import {console} from "forge-std/console.sol";
import { HelperConfig } from "./HelperConfig.s.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import { TriviaGameHubTest } from "../contracts/test/harnes/TriviaGameHubTest.sol";
import {AddConsumer, CreateSubscription, FundSubscription} from "./Interactions.s.sol";


contract DeployTriviaGameHub is Script {

    using Strings for uint256;

    uint256 public DEFAULT_ANVIL_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 public deployerKey;

    uint64 public constant subscriptionId = 39;

    function run() external returns (TriviaGameHubTest) {
        if (block.chainid == 31337) {
            deployerKey = DEFAULT_ANVIL_PRIVATE_KEY;
        } else {
            deployerKey = vm.envUint("PRIVATE_KEY");
        }

        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory networkConfig = helperConfig.getActiveNetworkConfig();
        string memory source = vm.readFile("./functions/sources/getScores.js");
        
        // console.log("Deploying TriviaGameHub with deployer public key: ", vm.addr(deployerKey));
        // console.log("Chain ID: ", block.chainid);

        // console.log("Deploying TriviaGameHub with networkConfig.functionsRouter: ", networkConfig.functionsRouter);
        // console.log("Deploying TriviaGameHub with networkConfig.donId: ", bytes32ToHex(networkConfig.donId));
        // console.log("Deploying TriviaGameHub with networkConfig.secretVersion: ", networkConfig.secretVersion);
        // console.log("Deploying TriviaGameHub with networkConfig.secretSlot: ", networkConfig.secretSlot);
        // console.log("Deploying TriviaGameHub with source: ", source);
        // console.log("Deploying TriviaGameHub with subscriptionId: ", subscriptionId);

        // uint256 vrf_subId = 39;
        // address vrfCoordinator = networkConfig.vrfCoordinator;
        
        AddConsumer addConsumer = new AddConsumer();
        
        if (networkConfig.vrfSubscription == 0) {
            CreateSubscription createSubscription = new CreateSubscription();

            (networkConfig.vrfSubscription, networkConfig.vrfCoordinator) = createSubscription.createSubscription(
                networkConfig.vrfCoordinator,
                deployerKey
            );

            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                networkConfig.vrfCoordinator,
                networkConfig.vrfSubscription,
                networkConfig.link,
                deployerKey
            );
        }

        vm.startBroadcast(deployerKey);
        TriviaGameHubTest _contract = new TriviaGameHubTest(
            networkConfig.functionsRouter,
            networkConfig.donId,
            networkConfig.secretVersion,
            networkConfig.secretSlot,
            source,
            subscriptionId,
            networkConfig.vrfSubscription,
            networkConfig.vrfCoordinator
        );
        vm.stopBroadcast();

                // We already have a broadcast in here
        addConsumer.addConsumer(
            address(_contract),
            networkConfig.vrfCoordinator,
            networkConfig.vrfSubscription,
            deployerKey
        );
        return _contract;
    }

    // get the address of the deployer public key
    function getDeployerPubKey() external view returns (address) {
        return vm.addr(deployerKey);
    }

    function bytes32ToHex(bytes32 _bytes) public pure returns (string memory) {
        return Strings.toHexString(uint256(_bytes));
    }
}


// VRF subscription id
// 5066633046379740931671515134021046474345982068868745947742250283067159237818