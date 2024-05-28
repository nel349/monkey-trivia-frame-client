// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {SourceMinter} from "../contracts/ccip/SourceMinter.sol";
import {console} from "forge-std/console.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract DeploySourceMinter is Script {
    uint256 public DEFAULT_ANVIL_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 public deployerKey;

    function run() external returns (SourceMinter) {
        HelperConfig helperConfig = new HelperConfig();

        if (block.chainid == 31337) {
            deployerKey = DEFAULT_ANVIL_PRIVATE_KEY;
        } else {
            deployerKey = vm.envUint("PRIVATE_KEY");
        }

        address mostRecentlyDestinationMinter = DevOpsTools
            .get_most_recent_deployment("DestinationMinter", block.chainid);
        console.log("Most recendly deployed DestinationMinter: %s", mostRecentlyDestinationMinter);

        vm.startBroadcast(deployerKey);

        HelperConfig.NetworkConfig memory networkConfig = helperConfig.getActiveNetworkConfig();
        HelperConfig.RouterConfig memory routerConfig = helperConfig.getActiveRouterConfig();

        SourceMinter sourceMinter = new SourceMinter(routerConfig.address_, networkConfig.link);
        vm.stopBroadcast();

        console.log("SourceMinter address: %s", address(sourceMinter));
        return sourceMinter;
    }
}
