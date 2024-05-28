// SPDX-License-Identifier: MIT
// An example of a consumer contract that relies on a subscription for funding.
pragma solidity ^0.8.0;

import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract TriviaGameVrf is VRFConsumerBaseV2Plus {
    event VrfRequestSent(uint256 requestId, uint32 numWords);
    event VrfRequestFulfilled(uint256 requestId, uint256 gameId);

    struct VrfRequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
        uint256 gameId;
    }
    mapping(uint256 => VrfRequestStatus) public s_vrfRequests; /* requestId --> VrfRequestStatus */
    IVRFCoordinatorV2Plus COORDINATOR;

    // Your subscription ID.
    uint256 s_vrfSubscription;

    // past requests Id.
    uint256[] public vrfRequestIds;
    uint256 public vrfLastRequestId;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf/v2-5/supported-networks
    bytes32 keyHash =
        0x1770bdc7eec7771f7ba4ffd640f34260d7f095b79c92d34a5b2551d6f6cfd2be;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 2_500_000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2_5.MAX_NUM_WORDS.
    uint32 numWords = 2;

    /**
     * HARDCODED FOR Arbitrum SEPOLIA
     * COORDINATOR: 0x5CE8D5A2BC84beb22a398CCA51996F7930313D61
     */
    constructor(
        uint256 subscriptionId,
        address vrfCoordinatorV2
    ) VRFConsumerBaseV2Plus(vrfCoordinatorV2) {
        COORDINATOR = IVRFCoordinatorV2Plus(
            vrfCoordinatorV2
        );
        s_vrfSubscription = subscriptionId;

    }

    // Assumes the subscription is funded sufficiently.
    function requestRandomWords(uint256 _gameId)
        external
        onlyOwner
        returns (uint256 requestId)
    {
        // Will revert if subscription is not set and funded.
        // To enable payment in native tokens, set nativePayment to true.
        requestId = COORDINATOR.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: s_vrfSubscription,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
        s_vrfRequests[requestId] = VrfRequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false,
            gameId: _gameId
        });
        vrfRequestIds.push(requestId);
        vrfLastRequestId = requestId;
        emit VrfRequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] calldata _randomWords
    ) internal override virtual {
        // require(s_vrfRequests[_requestId].exists, "request not found");
        // s_vrfRequests[_requestId].fulfilled = true;
        // s_vrfRequests[_requestId].randomWords = _randomWords;
        // emit VrfRequestFulfilled(_requestId, _randomWords);
        // fulfillWinners(_randomWords);
    }

    function getVrfRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_vrfRequests[_requestId].exists, "request not found");
        VrfRequestStatus memory request = s_vrfRequests[_requestId];
        return (request.fulfilled, request.randomWords);
    }

    // get the last ramdom words
    function getLastRandomWords() external view returns (uint256[] memory) {
        return s_vrfRequests[vrfLastRequestId].randomWords;
    }
}
