// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { FunctionsClient } from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import { ConfirmedOwner } from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import { FunctionsRequest } from "@chainlink/contracts/src/v0.8/functions/dev/v1_X/libraries/FunctionsRequest.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";
// import {console} from "forge-std/Test.sol";
import { TriviaGameVrf } from "./vrf/TriviaGameVrf.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";

contract TriviaGameHub is FunctionsClient, TriviaGameVrf, AutomationCompatibleInterface, Pausable {
    using FunctionsRequest for FunctionsRequest.Request;
    using Strings for uint256;
    using Address for address;

    error UnexpectedRequestID(bytes32 requestId);
    error GameDoesNotExist(uint256 gameId);
    error Raffle__UpkeepNotNeeded();
    event Response(bytes32 indexed requestId, bytes response, bytes err);
    event CheckedUpkeep(
        bool activeGame, 
        bool hasPassed, 
        bool hasPlayers, 
        uint256 blockTimestamp 
    );

    struct Game {
        address creator;
        uint256 startTime;
        uint256 endTime;
        bool isActive;
        address[] participants;
        mapping(address => bool) s_isParticipant;
        mapping(address => string) scores;
        address[] winners;
    }

    struct ScoreRequest {
        uint256 gameId;
        address participant;
    }
    struct ScoreResponse {
        uint256 gameId;
        string score;
        address participant;
    }

    mapping(uint256 => Game) public games;
    uint256 public nextGameId = 0;
    uint256 private i_interval;

    /// Chainlink Functions
    uint32 private constant GAS_LIMIT = 300_000;
    uint64 immutable i_subId;
    bytes32 public s_lastRequestId;
    bytes public s_lastResponse;
    bytes public s_lastError;

    // Check to get the router address for your supported network
    // https://docs.chain.link/chainlink-functions/supported-networks
    address s_functionsRouter;
    string s_source;

    // Check to get the donID for your supported network https://docs.chain.link/chainlink-functions/supported-networks
    bytes32 s_donID;
    string s_result;
    uint64 s_secretVersion;
    uint8 s_secretSlot;

    mapping(bytes32 requestId => ScoreRequest request) private s_requestIdToRequest;
    mapping(bytes32 requestId => ScoreResponse response) private s_requestIdToResponse;

    constructor(
        address functionsRouter,
        bytes32 donId,
        uint64 secretVersion,
        uint8 secretSlot,
        string memory source,
        uint64 subscriptionId, 
        uint256 _vrfSubscription,
        address _vrfCoordinator
    ) 
        FunctionsClient(functionsRouter)
        TriviaGameVrf(_vrfSubscription, _vrfCoordinator)
    {
        // console.log("TriviaGameHub deployed by", msg.sender);
        s_functionsRouter = functionsRouter;
        s_donID = donId;
        s_secretVersion = secretVersion;
        s_secretSlot = secretSlot;
        s_source = source;
        i_subId = subscriptionId;
    }

    modifier isParticipant(uint256 _gameId, address participant) {
        require(games[_gameId].s_isParticipant[participant], "Given address is not a participant in this game.");
        _;
    }

    function requestScoreForParticipant(
        uint256 _gameId, 
        address participant
    ) public isParticipant(_gameId, participant) returns (bytes32 requestId) {
        require(games[_gameId].isActive, "Game is not active.");
        require(block.timestamp >= games[_gameId].startTime && block.timestamp <= games[_gameId].endTime, "Game is not within active period.");
        require(games[_gameId].creator == msg.sender, "Only the game creator can request the score.");

        FunctionsRequest.Request memory req;
        req._initializeRequestForInlineJavaScript(s_source);
        string[] memory args = new string[](2);
        args[0] = Strings.toString(_gameId);
        args[1] = convertAddressToString(participant);
        req._setArgs(args);
        
        s_lastRequestId = _sendRequest(
            req._encodeCBOR(),
            i_subId,
            GAS_LIMIT,
            s_donID
        );
        s_requestIdToRequest[s_lastRequestId] = ScoreRequest(_gameId, participant);

        // console.log("Requesting score for participant: ", participant, "in game: ", _gameId);
        return s_lastRequestId;
    }

    /**
     * @notice Callback function for fulfilling a request
     * @param requestId The ID of the request to fulfill
     * @param response The HTTP response data
     */
    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory /* err */
    )
        internal
        override
        whenNotPaused
    {
               
        // if (s_lastRequestId != requestId) {
        //     revert UnexpectedRequestID(requestId);
        // }
        address participant = s_requestIdToRequest[requestId].participant;
        uint256 _gameId = s_requestIdToRequest[requestId].gameId;

        s_lastResponse = response;

        // uint256 requestIdAsUint = uint256(requestId);
        // console.log("Fulfilling request: ", Strings.toHexString(requestIdAsUint, 32) );
        // console.log(" for participant: ", participant, "in game: ", _gameId);
        s_requestIdToResponse[requestId] = ScoreResponse(_gameId, string(response), participant);
        games[_gameId].scores[participant] = string(s_lastResponse);
        
        emit Response(requestId, s_lastResponse, s_lastError);
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] calldata _randomWords
    ) internal override {
        require(s_vrfRequests[_requestId].exists, "request not found");
        require(!s_vrfRequests[_requestId].fulfilled, "Request already fulfilled");

        s_vrfRequests[_requestId].fulfilled = true;
        s_vrfRequests[_requestId].randomWords = _randomWords;

        uint256 _gameId = s_vrfRequests[_requestId].gameId;
        emit VrfRequestFulfilled(_requestId, _gameId);
    }

    function fulfillWinners(
        uint256 _requestId
    ) external onlyOwner {
        /* Set the winners addresses from the random words
            1. We are going to get the winners indexes from the random words
            2. We are going to get the winners addresses from the indexes
        */


        uint256[] memory _randomWords = s_vrfRequests[_requestId].randomWords;
        uint256 _gameId = s_vrfRequests[_requestId].gameId;

        for (uint256 i = 0; i < _randomWords.length; i++) {
            // console.log("Random word: ", _randomWords[i]);
            uint256 winnerIndex = _randomWords[i] % games[_gameId].participants.length;
            games[_gameId].winners.push(games[_gameId].participants[winnerIndex]);
        }

        // Emit the winners
        // emit Winners(winnersAddresses);
    }

    /**
     * @dev This is the function that the Chainlink Keeper nodes call
     * they look for `upkeepNeeded` to return True.
     * the following should be true for this to return true:
     * 1. Game is active
     * 2. Game has reached end time
     * 3. Game has participant
     */
    function checkUpkeep(
        bytes memory /* checkData */
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData )
    {
        upkeepNeeded = false;

        // check for all the games
        for (uint256 i = 0; i < nextGameId; i++) {
            bool isActive = games[i].isActive;
            bool timePassed = ((block.timestamp - games[i].startTime) > i_interval);
            bool hasPlayers = games[i].participants.length > 0;
            // upkeepNeeded = (timePassed && isActive && hasPlayers);
            if (isActive && hasPlayers) {
                performData = abi.encode(isActive, timePassed, hasPlayers, block.timestamp);
                upkeepNeeded = true;
                
            }
            
        }

        

        return (upkeepNeeded, performData); // can we comment this out?
    }

    function performUpkeep(bytes calldata performData)
        external
        override 
    {

        (bool isActive, bool timePassed, bool hasPlayers, uint256 block_t) = abi.decode(
            performData,
            (bool, bool, bool, uint256)
        );

        emit CheckedUpkeep(isActive, timePassed, hasPlayers, block_t);
        // (bool upkeepNeeded, ) = checkUpkeep("");
        // require(upkeepNeeded, "Upkeep not needed");
        // if (!upkeepNeeded) {
        //     revert Raffle__UpkeepNotNeeded();
        // }
        // for (uint256 i = 0; i < nextGameId; i++) {
        //     if (games[i].isActive && block.timestamp > games[i].endTime && games[i].participants.length > 0) {
        //         endGame(i);
        //     }
        // }
    }

    function createGame(uint256 _startTime, uint256 _endTime) public {
        require(_endTime > _startTime, "End time must be after start time.");
        

        Game storage newGame = games[nextGameId];
        newGame.creator = msg.sender;
        newGame.startTime = _startTime;
        newGame.endTime = _endTime;
        newGame.isActive = true;
        newGame.participants = new address[](0);
        newGame.winners = new address[](0);
        nextGameId++;
    }

    function createGameWithInterval(uint256 _interval) public {
        createGame(block.timestamp, block.timestamp + _interval);
        i_interval = _interval;
    }

    function createGameDefault() public {
        createGame(block.timestamp, block.timestamp + 3600);
    }

    function joinGame(uint256 _gameId) public {
        require(games[_gameId].isActive, "Game is not active.");
        require(block.timestamp >= games[_gameId].startTime, "Game has not started yet.");
        require(block.timestamp <= games[_gameId].endTime, "Game has already ended.");

        // Check if the participant is already in the game
        if (games[_gameId].s_isParticipant[msg.sender] == true) {
            revert GameDoesNotExist(_gameId);
        } 
        games[_gameId].participants.push(msg.sender);
        games[_gameId].s_isParticipant[msg.sender] = true;
    }

    function endGame(uint256 _gameId) public {
        require(msg.sender == games[_gameId].creator
         || msg.sender == owner(),
         "Only the game creator can end the game.");
        require(games[_gameId].isActive, "Game is already inactive.");
        games[_gameId].isActive = false;
        // Further logic to handle score calculation and rewards can be added here.

        // rewardWinners(_gameId);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    // Get game creator of a game
    function getGameCreator(uint256 gameId) public view returns (address) {
        return games[gameId].creator;
    }

    // Get game start time
    function getGameStartTime(uint256 gameId) public view returns (uint256) {
        return games[gameId].startTime;
    }

    // Get game end time
    function getGameEndTime(uint256 gameId) public view returns (uint256) {
        return games[gameId].endTime;
    }

    // Check if a game is active
    function getGameIsActive(uint256 gameId) public view returns (bool) {
        return games[gameId].isActive;
    }

    // Get game score for a participant
    function getGameParticipantScore(uint256 gameId, address participant) public view returns (string memory) {
        return games[gameId].scores[participant];
    }

    // Get participants of a game
    function getGameParticipants(uint256 gameId) public view returns (address[] memory) {
        return games[gameId].participants;
    }

    // Get all game scores for a scores nested mapping,
    // return array of tuples where tuple is (address, score)
    function getGameScores(uint256 gameId) public view returns (address[] memory, string[] memory) {
        address[] memory participants = games[gameId].participants;
        string[] memory scores = new string[](participants.length);

        for (uint i = 0; i < participants.length; i++) {
            scores[i] = games[gameId].scores[participants[i]];
        }
        return (participants, scores);
    }

    // Get the last ScoreRequest as a tuple of (string score, address participant)
    function getLastScoreRequest() public view returns (uint256, address) {
        return (s_requestIdToRequest[s_lastRequestId].gameId, s_requestIdToRequest[s_lastRequestId].participant);
    }

    // Get the last response in text format
    function getLastResponse() public view returns (string memory) {
        return string(s_lastResponse);
    }

    function convertAddressToString(address _address) public pure returns (string memory) {
        // convert string hex to bytes
        return Strings.toHexString(_address);
    }

    function getScoreResponse(bytes32 requestId) public view returns (uint256, string memory, address) {
        return (s_requestIdToResponse[requestId].gameId, s_requestIdToResponse[requestId].score, s_requestIdToResponse[requestId].participant);
    }

    function getLastRequestId() public view returns (bytes32) {
        return s_lastRequestId;
    }

    // get winners
    function getWinners(uint256 gameId) public view returns (address[] memory) {
        return games[gameId].winners;
    }
}