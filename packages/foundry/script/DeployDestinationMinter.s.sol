// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {DestinationMinter} from "../contracts/ccip/DestinationMinter.sol";
import {console} from "forge-std/console.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {GameSessionNft} from "../contracts/GameSessionNft.sol";

contract DeployDestinationMinter is Script {
    uint256 public DEFAULT_ANVIL_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 public deployerKey;

    function run() external returns (DestinationMinter) {
        if (block.chainid == 31337) {
            deployerKey = DEFAULT_ANVIL_PRIVATE_KEY;
        } else {
            deployerKey = vm.envUint("PRIVATE_KEY");
            console.log("deployerKey: %s", deployerKey);
        }


        address mostRecentlyDeployedBasicNft = DevOpsTools
            .get_most_recent_deployment("GameSessionNft", block.chainid);

        // if (mostRecentlyDeployedBasicNft == address(0)) {
        //     console.log("No GameSessionNft deployed on this chain. Attempting to deploy one now.");
        //     // deploy GameSessionNft
        //     vm.startBroadcast(deployerKey);
        //     GameSessionNft basicNft = new GameSessionNft();
        //     mostRecentlyDeployedBasicNft = address(basicNft);
        //     vm.stopBroadcast();
        // }

        // print most recently deployed basic nft
        console.log("Most recendly deployed GameSessionNft: %s", mostRecentlyDeployedBasicNft);
        
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.RouterConfig memory routerConfig = helperConfig.getActiveRouterConfig();
        vm.startBroadcast(deployerKey);
        DestinationMinter destinationMinter =
            new DestinationMinter(routerConfig.address_, mostRecentlyDeployedBasicNft);
        vm.stopBroadcast();

        console.log("DestinationMinter address: %s", address(destinationMinter));
        return destinationMinter;
    }
}
