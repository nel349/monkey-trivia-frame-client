// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {GameSessionNft} from "../contracts/GameSessionNft.sol";
import {console} from "forge-std/console.sol";

contract DeployGameSessionNft is Script {
    uint256 public DEFAULT_ANVIL_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 public deployerKey;

    function run() external returns (GameSessionNft) {
        if (block.chainid == 31337) {
            deployerKey = DEFAULT_ANVIL_PRIVATE_KEY;
        } else {
            deployerKey = vm.envUint("PRIVATE_KEY");
        }
        vm.startBroadcast(deployerKey);
        GameSessionNft basicNft = new GameSessionNft();
        vm.stopBroadcast();
        // console.log("GameSessionNft address: %s", address(basicNft));
        return basicNft;
    }
}
