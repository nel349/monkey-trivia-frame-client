// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {GameSessionNft} from "../contracts/GameSessionNft.sol";
import {SourceMinter} from "../contracts/ccip/SourceMinter.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {MockLinkToken} from "@chainlink/contracts/src/v0.8/mocks/MockLinkToken.sol";
import { TriviaGameHubTest } from "../contracts/test/harnes/TriviaGameHubTest.sol";
import {DeployTriviaGameHub} from "../script/DeployTriviaGameHub.s.sol";

contract DeployGameSessionNft is Script {
    string public constant ACTIVE_URI =
        "https://bafkreiapzeyrdkua4x7fkzfcdnbxro5bh2kzqqfta5knstzo54ittisbga.ipfs.nftstorage.link/";
    uint256 deployerKey;

    function run() external {
        address mostRecentlyDeployedBasicNft = DevOpsTools
            .get_most_recent_deployment("GameSessionNft", block.chainid);
        mintNftOnContract(mostRecentlyDeployedBasicNft);
    }

    function mintNftOnContract(address basicNftAddress) public {
        vm.startBroadcast();
        GameSessionNft(basicNftAddress).mintNftActive(ACTIVE_URI);
        vm.stopBroadcast();
    }
}

contract MintGameSessionNft is Script {
    string public constant ACTIVE_URL =
        "https://bafkreiapzeyrdkua4x7fkzfcdnbxro5bh2kzqqfta5knstzo54ittisbga.ipfs.nftstorage.link/";

    uint256 deployerKey;

    function run() external {
        address mostRecentlyDeployedBasicNft = DevOpsTools
            .get_most_recent_deployment("GameSessionNft", block.chainid);
        mintNftActiveSessionOnContract(mostRecentlyDeployedBasicNft);
    }

    function mintNftActiveSessionOnContract(address nftAddress) public {
        vm.startBroadcast();
        GameSessionNft(nftAddress).mintNftActive(ACTIVE_URL);
        vm.stopBroadcast();
    }
}

contract MintCompleteGameSessionNftBase64 is Script {
    string public constant COMPLETE_URL =
        "data:application/json;base64,ewogICAgIm5hbWUiOiAiTW9ua2V5IFRyaXZpYSBTZXNzaW9uIENvbXBsZXRlZCIsCiAgICAiZGVzY3JpcHRpb24iOiAiR2FtZSBzZXNzaWlvbiBjb21wbGV0ZWQuICBZb3UgYXJlIGEgd2lubmVyISIsCiAgICAiaW1hZ2UiOiAiaHR0cHM6Ly9iYWZ5YmVpZXh4eTd2cHRwdGo2eXg2cmVodjV4cDRnYTd6enRiZTJ1ZHUyZDNnYTNiZTRnc243bmt4NC5pcGZzLm5mdHN0b3JhZ2UubGluay8iLAogICAgImF0dHJpYnV0ZXMiOiBbCiAgICAgICAgewogICAgICAgICAgICAidHJhaXRfdHlwZSI6ICJwbGFjZSIsCiAgICAgICAgICAgICJ2YWx1ZSI6ICIxc3QiCiAgICAgICAgfQogICAgXQp9";

    uint256 deployerKey;

    function run() external {
        address mostRecentlyDeployedBasicNft = DevOpsTools
            .get_most_recent_deployment("GameSessionNft", block.chainid);
        mintNftCompletedSessionOnContract(mostRecentlyDeployedBasicNft);
    }

    function mintNftCompletedSessionOnContract(address nftAddress) public {
        vm.startBroadcast();
        GameSessionNft(nftAddress).mintNftComplete(COMPLETE_URL);
        vm.stopBroadcast();
    }
}

// contract MintCompleteXChainSepoliaToPolygon is Script {
//     string public constant COMPLETE_URL =
//         "data:application/json;base64,ewogICAgIm5hbWUiOiAiTW9ua2V5IFRyaXZpYSBTZXNzaW9uIENvbXBsZXRlZCIsCiAgICAiZGVzY3JpcHRpb24iOiAiR2FtZSBzZXNzaWlvbiBjb21wbGV0ZWQuICBZb3UgYXJlIGEgd2lubmVyISIsCiAgICAiaW1hZ2UiOiAiaHR0cHM6Ly9iYWZ5YmVpZXh4eTd2cHRwdGo2eXg2cmVodjV4cDRnYTd6enRiZTJ1ZHUyZDNnYTNiZTRnc243bmt4NC5pcGZzLm5mdHN0b3JhZ2UubGluay8iLAogICAgImF0dHJpYnV0ZXMiOiBbCiAgICAgICAgewogICAgICAgICAgICAidHJhaXRfdHlwZSI6ICJwbGFjZSIsCiAgICAgICAgICAgICJ2YWx1ZSI6ICIxc3QiCiAgICAgICAgfQogICAgXQp9";

//     uint256 deployerKey;

//     function run() external {
//         address mostRecentlyDeployedSourceMinter = DevOpsTools
//             .get_most_recent_deployment("SourceMinter", block.chainid);
//         mintNftCompletedSessionOnContract(mostRecentlyDeployedSourceMinter);
//         console.log("SourceMinter address: %s", mostRecentlyDeployedSourceMinter);
//     }

//     function mintNftCompletedSessionOnContract(address sourceMinterAddress) public {
//         HelperConfig helperConfig = new HelperConfig();
//         (,HelperConfig.RouterConfig memory routerConfig) = helperConfig.getMumbaiPolygonConfig();
//         vm.startBroadcast();
//         /*
//             Fees LINK:1, NATIVE:0
//         */

//        // get latest sourceMinterAddress mint(chainSelector, destinationMinter, PayFeesInLinkOrNative)
//         SourceMinter(payable(0x9041b59b5CCC47EFA7dfBF1497bC8bAD7AD5ad1E)).mint(routerConfig.chainSelector, address(0xBC4cF7731Dd2c8C5fed08F21E7cFc4c292D4C8a7), SourceMinter.PayFeesIn.Native,"");
//         vm.stopBroadcast();
//     }
// }

contract MintNftCompletedSessionPolygonToFuji is Script {
    string public constant COMPLETE_URL =
        "data:application/json;base64,ewogICAgIm5hbWUiOiAiTW9ua2V5IFRyaXZpYSBTZXNzaW9uIENvbXBsZXRlZCIsCiAgICAiZGVzY3JpcHRpb24iOiAiR2FtZSBzZXNzaWlvbiBjb21wbGV0ZWQuICBZb3UgYXJlIGEgd2lubmVyISIsCiAgICAiaW1hZ2UiOiAiaHR0cHM6Ly9iYWZ5YmVpZXh4eTd2cHRwdGo2eXg2cmVodjV4cDRnYTd6enRiZTJ1ZHUyZDNnYTNiZTRnc243bmt4NC5pcGZzLm5mdHN0b3JhZ2UubGluay8iLAogICAgImF0dHJpYnV0ZXMiOiBbCiAgICAgICAgewogICAgICAgICAgICAidHJhaXRfdHlwZSI6ICJwbGFjZSIsCiAgICAgICAgICAgICJ2YWx1ZSI6ICIxc3QiCiAgICAgICAgfQogICAgXQp9";

    uint256 deployerKey;

    function run() external {
        // address mostRecentlyDeployedSourceMinter = DevOpsTools
        //     .get_most_recent_deployment("SourceMinter", block.chainid);
        mintNftCompletedSessionPolygonToFuji();
        // console.log("SourceMinter address: %s", mostRecentlyDeployedSourceMinter);
    }

    function mintNftCompletedSessionPolygonToFuji() public {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory mumbaiNetworkConfig = helperConfig.getMumbaiPolygonConfig();
        HelperConfig.NetworkConfig memory fujiNetworkConfig = helperConfig.getFujiAvalancheConfig();
        // (, HelperConfig.RouterConfig memory destinationRouterConfig) = helperConfig.getFujiAvalancheConfig();
        vm.startBroadcast();

        address mostRecentlyDeployedSourceMinter = DevOpsTools 
            .get_most_recent_deployment("SourceMinter", 80001);

        address mostRecentlyDeployedDestinationMinter = DevOpsTools
            .get_most_recent_deployment("DestinationMinter", 43113);

        console.log("Link address: %s", mumbaiNetworkConfig.link);

        uint balance = LinkTokenInterface(mumbaiNetworkConfig.link).balanceOf(mostRecentlyDeployedSourceMinter);

        console.log("Link balance: %s", balance);
        //if link balance is less than 0.4, send 0.4 link to SourceMinter
        if(balance < 400000000000000000){            
            // LinkTokenInterface(networkConfig.link).transferFrom(msg.sender, mostRecentlyDeployedSourceMinter, 400000000000000000);
        //     //print tx hash
            console.log ("SourceMinter address: %s", mostRecentlyDeployedSourceMinter);
            console.log("Not enough link! 0.4 Link needed by SourceMinter, Try again!"); return;
        }

        // send 0.4 link to SourceMinter
        // LinkTokenInterface(networkConfig.link).transferFrom(msg.sender, mostRecentlyDeployedSourceMinter, 400000000000000000);
        // console.log("Link balance: %s", LinkTokenInterface(networkConfig.link).balanceOf(mostRecentlyDeployedSourceMinter));

       // get latest sourceMinterAddress mint(chainSelector, destinationMinter, PayFeesInLinkOrNative)
        SourceMinter(payable(mostRecentlyDeployedSourceMinter)).mint(
            fujiNetworkConfig.ccipChainSelector,
            address(mostRecentlyDeployedDestinationMinter), 
            SourceMinter.PayFeesIn.LINK,
            COMPLETE_URL
        );
        vm.stopBroadcast();
    }
}


contract MintNftCompletedSessionEthSepoliaToBase is Script {
    string public constant COMPLETE_URL =
        "data:application/json;base64,ewogICAgIm5hbWUiOiAiTW9ua2V5IFRyaXZpYSBTZXNzaW9uIENvbXBsZXRlZCIsCiAgICAiZGVzY3JpcHRpb24iOiAiR2FtZSBzZXNzaWlvbiBjb21wbGV0ZWQuICBZb3UgYXJlIGEgd2lubmVyISIsCiAgICAiaW1hZ2UiOiAiaHR0cHM6Ly9iYWZ5YmVpZXh4eTd2cHRwdGo2eXg2cmVodjV4cDRnYTd6enRiZTJ1ZHUyZDNnYTNiZTRnc243bmt4NC5pcGZzLm5mdHN0b3JhZ2UubGluay8iLAogICAgImF0dHJpYnV0ZXMiOiBbCiAgICAgICAgewogICAgICAgICAgICAidHJhaXRfdHlwZSI6ICJwbGFjZSIsCiAgICAgICAgICAgICJ2YWx1ZSI6ICIxc3QiCiAgICAgICAgfQogICAgXQp9";

    uint256 deployerKey;

    function run() external {
        // address mostRecentlyDeployedSourceMinter = DevOpsTools
        //     .get_most_recent_deployment("SourceMinter", block.chainid);
        mintNftCompletedSessionEthSepoliaToBase();
        // console.log("SourceMinter address: %s", mostRecentlyDeployedSourceMinter);
    }

    function mintNftCompletedSessionEthSepoliaToBase() public {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory ethSepoliaNetworkConfig = helperConfig.getSepoliaEthConfig();
        HelperConfig.NetworkConfig memory baseNetworkConfig = helperConfig.getBaseTestnetConfig();
        vm.startBroadcast();

        address mostRecentlyDeployedSourceMinter = DevOpsTools 
            .get_most_recent_deployment("SourceMinter", 11155111);

        // address mostRecentlyDeployedDestinationMinter = DevOpsTools
        //     .get_most_recent_deployment("DestinationMinter", 84532);

        // console.log("Link address: %s", ethSepoliaNetworkConfig.link);

        uint balance = LinkTokenInterface(ethSepoliaNetworkConfig.link).balanceOf(mostRecentlyDeployedSourceMinter);

        console.log("Link balance: %s", balance);
        //if link balance is less than 0.4, send 0.4 link to SourceMinter
        if(balance < (0.4 * 10**18)){            
            // LinkTokenInterface(ethSepoliaNetworkConfig.link).transferFrom(msg.sender, mostRecentlyDeployedSourceMinter, 400000000000000000);
        //     //print tx hash
            console.log ("SourceMinter address: %s", mostRecentlyDeployedSourceMinter);
            console.log("Not enough link! 0.4 Link needed by SourceMinter, Try again!"); return;
        }

        // send 0.4 link to SourceMinter
        // LinkTokenInterface(networkConfig.link).transferFrom(msg.sender, mostRecentlyDeployedSourceMinter, 400000000000000000);
        // console.log("Link balance: %s", LinkTokenInterface(networkConfig.link).balanceOf(mostRecentlyDeployedSourceMinter));

       // get latest sourceMinterAddress mint(chainSelector, destinationMinter, PayFeesInLinkOrNative)
        SourceMinter(payable(mostRecentlyDeployedSourceMinter)).mint(
            baseNetworkConfig.ccipChainSelector,
            address(0xA75b12AEE788814e3AdA413EB58b7a844f0D75A3), 
            SourceMinter.PayFeesIn.LINK,
            COMPLETE_URL
        );
        vm.stopBroadcast();
    }
}

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns (uint256, address) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory networkConfig = helperConfig.getActiveNetworkConfig();
        return createSubscription(networkConfig.vrfCoordinator, networkConfig.deployerKey);
    }

    function createSubscription(
        address vrfCoordinatorV2,
        uint256 deployerKey
    ) public returns (uint256, address) {
        console.log("Creating subscription on chainId: ", block.chainid);
        vm.startBroadcast(deployerKey);
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinatorV2).createSubscription();
        vm.stopBroadcast();
        console.log("Your subscription Id is: ", subId);
        console.log("Please update the subscriptionId in HelperConfig.s.sol");
        return (subId, vrfCoordinatorV2);
    }

    function run() external returns (uint256, address) {
        return createSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    function addConsumer(
        address contractToAddToVrf,
        address vrfCoordinator,
        uint256 subId,
        uint256 deployerKey
    ) public {
        console.log("Adding consumer contract: ", contractToAddToVrf);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On ChainID: ", block.chainid);
        vm.startBroadcast(deployerKey);
        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(
            subId,
            contractToAddToVrf
        );
        vm.stopBroadcast();
    }

    function addConsumerUsingConfig(address mostRecentlyDeployed) public {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory networkConfig = helperConfig.getActiveNetworkConfig();
        addConsumer(mostRecentlyDeployed, networkConfig.vrfCoordinator, networkConfig.vrfSubscription, networkConfig.deployerKey);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );
        addConsumerUsingConfig(mostRecentlyDeployed);
    }
}

contract FundSubscription is Script {
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory networkConfig = helperConfig.getActiveNetworkConfig();

        if (networkConfig.vrfSubscription == 0) {
            CreateSubscription createSub = new CreateSubscription();
            (uint256 updatedSubId, address updatedVRFv2) = createSub.run();
            networkConfig.vrfSubscription = updatedSubId;
            networkConfig.vrfCoordinator = updatedVRFv2;
            console.log("New SubId Created! ", networkConfig.vrfSubscription, "VRF Address: ", networkConfig.vrfCoordinator);
        }

        fundSubscription(networkConfig.vrfCoordinator, networkConfig.vrfSubscription, networkConfig.link, networkConfig.deployerKey);
    }

    function fundSubscription(
        address vrfCoordinatorV2,
        uint256 subId,
        address link,
        uint256 deployerKey
    ) public {
        console.log("Funding subscription: ", subId);
        console.log("Using vrfCoordinator: ", vrfCoordinatorV2);
        console.log("On ChainID: ", block.chainid);
        if (block.chainid == 31337) {
            vm.startBroadcast(deployerKey);
            VRFCoordinatorV2_5Mock(vrfCoordinatorV2).fundSubscription(
                subId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            console.log(MockLinkToken(link).balanceOf(msg.sender));
            console.log(msg.sender);
            console.log(MockLinkToken(link).balanceOf(address(this)));
            console.log(address(this));
            vm.startBroadcast(deployerKey);
            MockLinkToken(link).transferAndCall(
                vrfCoordinatorV2,
                FUND_AMOUNT,
                abi.encode(subId)
            );
            vm.stopBroadcast();
        }
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}

contract PrepareForTesting is Script {
    DeployTriviaGameHub public deployer;
    TriviaGameHubTest public triviaGameHub;

    function run() external {
        deployer = new DeployTriviaGameHub();
        triviaGameHub = deployer.run();

        console.log("Deployed TriviaGameHub at: ", address(triviaGameHub));
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 3600;

        triviaGameHub.createGame(startTime, endTime);
    }
}
