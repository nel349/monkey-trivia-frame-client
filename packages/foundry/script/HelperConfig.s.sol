// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import {VRFCoordinatorV2Mock} from "../test/mocks/VRFCoordinatorV2Mock.sol";
import { MockLinkToken } from "../contracts/test/mocks/MockLinkToken.sol";
import { MockFunctionsRouter } from "../contracts/test/mocks/MockFunctionsRouter.sol";
import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;
    RouterConfig public activeRouterConfig;

    struct NetworkConfig {
        address link;
        // address usdcPriceFeed;
        // address ethUsdPriceFeed;
        address functionsRouter;
        bytes32 donId;
        uint64 subId;
        // address redemptionCoin;
        address ccipRouter;
        uint64 ccipChainSelector;
        uint64 secretVersion;
        uint8 secretSlot;
        address vrfCoordinator;
        uint256 vrfSubscription;
        uint256 deployerKey;
    }

    struct RouterConfig {
        address address_;
        uint64 chainSelector;
    }

    // Mocks
    MockLinkToken public linkTokenMock;
    MockFunctionsRouter public functionsRouterMock;

    uint256 public DEFAULT_ANVIL_PRIVATE_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    // event HelperConfig__CreatedMockVRFCoordinator(address vrfCoordinator);

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 43113) {
            activeNetworkConfig = getFujiAvalancheConfig();
        } else if (block.chainid == 80001) {
            activeNetworkConfig = getMumbaiPolygonConfig();
        } else if (block.chainid == 84532) {
            activeNetworkConfig = getBaseTestnetConfig();
        } else if (block.chainid == 421614) {
            activeNetworkConfig = getArbitrumSepoliaConfig();
        } else if (block.chainid == 8453) {
            activeNetworkConfig = getBaseMainnetConfig();
        }
        else {
            _setupAnvilConfig();
            // activeNetworkConfig = getOrCreateAnvilEthConfig();
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getActiveNetworkConfig() public view returns (NetworkConfig memory) {
        return activeNetworkConfig;
    }

    function getActiveRouterConfig() public view returns (RouterConfig memory) {
        return activeRouterConfig;
    }

    function getSepoliaEthConfig()
        public
        view
        returns (NetworkConfig memory sepoliaNetworkConfig)
    {
        sepoliaNetworkConfig = NetworkConfig({
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            // usdcPriceFeed: 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E,
            // ethUsdPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
            functionsRouter: 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0,
            donId: 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000,
            subId: 39,
            // redemptionCoin: 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238,
            ccipRouter: 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59,
            ccipChainSelector: 16015286601757825753,
            secretVersion: 0, // fill in!
            secretSlot: 0, // fill in!
            vrfCoordinator: address(0),
            vrfSubscription: 0,
            deployerKey: vm.envUint("PRIVATE_KEY")
        });

        // sepoliaRouterConfig =
        //     RouterConfig({address_: 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59, chainSelector: 16015286601757825753});
    }

    function getFujiAvalancheConfig()
        public
        view
        returns (NetworkConfig memory avalancheFujiNetworkConfig)
    {
        avalancheFujiNetworkConfig = NetworkConfig({
            link: 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846,
            // usdcPriceFeed: 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E,
            // ethUsdPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
            functionsRouter: 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0,
            donId: 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000,
            subId: 0, // fill in!
            // redemptionCoin: 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238,
            ccipRouter: 0xF694E193200268f9a4868e4Aa017A0118C9a8177,
            ccipChainSelector: 14767482510784806043,
            secretVersion: 0, // fill in!
            secretSlot: 0, // fill in!
            vrfCoordinator: address(0),
            vrfSubscription: 0,
            deployerKey: vm.envUint("PRIVATE_KEY")
        });

        // avalancheRouterConfig =
        //     RouterConfig({address_: 0xF694E193200268f9a4868e4Aa017A0118C9a8177, chainSelector: 14767482510784806043});
    }

    function getMumbaiPolygonConfig()
        public
        view
        returns (NetworkConfig memory polygonMumbaiNetworkConfig)
    {
        polygonMumbaiNetworkConfig = NetworkConfig({
            link: 0x326C977E6efc84E512bB9C30f76E30c160eD06FB,
            // usdcPriceFeed: 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E,
            // ethUsdPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
            functionsRouter: 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0,
            donId: 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000,
            subId: 0, // fill in!
            // redemptionCoin: 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238,
            ccipRouter: 0x1035CabC275068e0F4b745A29CEDf38E13aF41b1,
            ccipChainSelector: 12532609583862916517,
            secretVersion: 0, // fill in!
            secretSlot: 0, // fill in!
            vrfCoordinator: address(0),
            vrfSubscription: 0,
            deployerKey: vm.envUint("PRIVATE_KEY")
        });

        // polygonMumbaiRouterConfig =
        //     RouterConfig({address_: 0x1035CabC275068e0F4b745A29CEDf38E13aF41b1, chainSelector: 12532609583862916517});
    }

    function getBaseTestnetConfig()
        public
        view
        returns (NetworkConfig memory baseTestnetNetworkConfig)
    {
        baseTestnetNetworkConfig = NetworkConfig({
            link: 0xE4aB69C077896252FAFBD49EFD26B5D171A32410,
            // usdcPriceFeed: 0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165,
            // ethUsdPriceFeed: 0x4aDC67696bA383F43DD60A9e78F2C97Fbbfc7cb1,
            functionsRouter: 0xf9B8fc078197181C841c296C876945aaa425B278,
            donId: 0x66756e2d626173652d7365706f6c69612d310000000000000000000000000000,
            subId: 39,
            // redemptionCoin: 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238,
            ccipRouter: 0xD3b06cEbF099CE7DA4AcCf578aaebFDBd6e88a93,
            ccipChainSelector: 10344971235874465080,
            secretVersion: 0, // fill in!
            secretSlot: 0, // fill in!
            vrfCoordinator: address(0),
            vrfSubscription: 0,
            deployerKey: vm.envUint("PRIVATE_KEY")
        });

        // baseTestnetRouterConfig =
        //     RouterConfig({address_: 0xD3b06cEbF099CE7DA4AcCf578aaebFDBd6e88a93, chainSelector: 10344971235874465080});
    }

    function getArbitrumSepoliaConfig()
        public
        view
        returns (NetworkConfig memory arbitrumSepoliaNetworkConfig)
    {
        arbitrumSepoliaNetworkConfig = NetworkConfig({
            link: 0xb1D4538B4571d411F07960EF2838Ce337FE1E80E,
            // usdcPriceFeed: 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E, // fill in!
            // ethUsdPriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306, // fill in!
            functionsRouter: 0x234a5fb5Bd614a7AA2FfAB244D603abFA0Ac5C5C,
            donId: 0x66756e2d617262697472756d2d7365706f6c69612d3100000000000000000000,
            subId: 0, // fill in!
            // redemptionCoin: 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238, // fill in!
            ccipRouter: 0x2a9C5afB0d0e4BAb2BCdaE109EC4b0c4Be15a165,
            ccipChainSelector: 3478487238524512106,
            secretVersion: 0, // fill in!
            secretSlot: 0, // fill in!
            vrfCoordinator: 0x5CE8D5A2BC84beb22a398CCA51996F7930313D61,
            vrfSubscription: 5066633046379740931671515134021046474345982068868745947742250283067159237818,
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
    }

    function getAnvilEthConfig() internal returns (NetworkConfig memory anvilNetworkConfig) {

        uint96 baseFee = 0.25 ether;
        uint96 gasPriceLink = 1e9;
        int256 weiPerUnitLink = 1000000000000000000; // 1 LINK in Wei

        // vm.startBroadcast(DEFAULT_ANVIL_PRIVATE_KEY);
        VRFCoordinatorV2_5Mock vrfCoordinatorMock = 
        new VRFCoordinatorV2_5Mock(
            baseFee,
            gasPriceLink,
            weiPerUnitLink
        );

        anvilNetworkConfig = NetworkConfig({
            functionsRouter: address(functionsRouterMock),
            donId: 0x66756e2d706f6c79676f6e2d6d756d6261692d31000000000000000000000000, // Dummy
            subId: 39, // Dummy non-zero
            link: address(linkTokenMock),
            ccipChainSelector: 1, // This is a dummy non-zero value
            secretVersion: 0,
            secretSlot: 0,
            // redemptionCoin: address(0), // Please see your brokerage for redemption coin
            // usdcPriceFeed: address(0), // Please see your brokerage for price feeds
            // ethUsdPriceFeed: address(0), // Please see your brokerage for price feeds
            ccipRouter: address(0), // Please see your brokerage for CCIP router,
            vrfCoordinator: address(vrfCoordinatorMock),
            // vrfCoordinator: address(0),
            vrfSubscription: 0,
            deployerKey: DEFAULT_ANVIL_PRIVATE_KEY
        });
        // minimumRedemptionAmount: 30e6 // Please see your brokerage for min redemption amounts
        // https://alpaca.markets/support/crypto-wallet-faq
    }

    function _setupAnvilConfig() internal returns (NetworkConfig memory) {
        // usdcMock = new MockUSDC();
        // tslaFeedMock = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        // ethUsdFeedMock = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        // usdcFeedMock = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER_USD);
        functionsRouterMock = new MockFunctionsRouter();
        // ccipRouterMock = new MockCCIPRouter();
        linkTokenMock = new MockLinkToken();
        return getAnvilEthConfig();
    }

    function getBaseMainnetConfig() internal returns (NetworkConfig memory) {
        return NetworkConfig({
            link: 0x88Fb150BDc53A65fe94Dea0c9BA0a6dAf8C6e196,
            functionsRouter: 0xf9B8fc078197181C841c296C876945aaa425B278,
            donId: 0x66756e2d626173652d6d61696e6e65742d310000000000000000000000000000,
            subId: 17,
            ccipRouter: 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846,
            ccipChainSelector: 1,
            secretVersion: 0,
            secretSlot: 0,
            vrfCoordinator: 0x5CE8D5A2BC84beb22a398CCA51996F7930313D61,
            vrfSubscription: 0,
            deployerKey: vm.envUint("PRIVATE_KEY")
        });
    }

}
