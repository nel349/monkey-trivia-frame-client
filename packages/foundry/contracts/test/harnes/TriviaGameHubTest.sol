// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { TriviaGameHub } from "../../TriviaGameHub.sol";

contract TriviaGameHubTest is TriviaGameHub {

    constructor(
        address _functionsRouter,
        bytes32 _donId,
        uint64 _secretVersion,
        uint8 _secretSlot,
        string memory _source,
        uint64 _subscriptionId,
        uint256 _vrfSubscription,
        address _vrfCoordinator
    ) TriviaGameHub(_functionsRouter, _donId, _secretVersion, 
        _secretSlot, _source, _subscriptionId, _vrfSubscription,
        _vrfCoordinator
    ) {}

    function testFulfillRequest(bytes32 requestId, bytes memory response) public {
        fulfillRequest(requestId, response, hex"");
    }

    function testFulfillRandomWords(uint256 _requestId,
        uint256[] calldata _randomWords) public {
        fulfillRandomWords(_requestId, _randomWords);
    }
}