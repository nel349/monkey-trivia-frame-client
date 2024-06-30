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
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";


contract TriviaGameHub is FunctionsClient, TriviaGameVrf, AutomationCompatibleInterface, Pausable {
    using FunctionsRequest for FunctionsRequest.Request;
    using Strings for uint256;
    using Address for address;

    error UnexpectedRequestID(bytes32 requestId);
    error GameDoesNotExist(uint256 gameId);
    error ParticipantAlreadyInGame(uint256 gameId, address participant);
    error Raffle__UpkeepNotNeeded();
    event Response(bytes32 indexed requestId, bytes response, bytes err);
    event CheckedUpkeep(
        bool activeGame, 
        bool hasPassed, 
        bool hasPlayers, 
        uint256 blockTimestamp 
    );
    event GameCreated(uint256 indexed gameId, uint256 startTime, uint256 endTime);
    event ParticipantJoinedGame(uint256 indexed gameId, address indexed participant);
    event GameEnded(uint256 indexed gameId);
    event WinnerFulfilled(uint256 indexed gameId, address indexed winnerIndex);
    event NFTClaimed(uint256 indexed gameId, address indexed winner);
    event NFTReclaimed(uint256 indexed gameId, address indexed winner);
    event NFTDeposited(
        uint256 indexed gameId, 
        address indexed nftContract, 
        uint256 tokenId, 
        address indexed depositor
    );
    event Score(uint256 indexed gameId, address indexed participant, uint256 score);

    struct Game {
        address creator;
        uint256 startTime;
        uint256 endTime;
        bool isActive;
        address[] participants;
        mapping(address => bool) s_isParticipant;
        mapping(address => string) scores;
        address[] winners;
        address nftContract;
        uint256 nftTokenId;
        bool nftClaimed;
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

    function depositNFT(uint256 _gameId, address _nftContract, uint256 _tokenId) external {
        require(games[_gameId].creator == msg.sender, "Only the game creator can deposit the NFT.");
        require(games[_gameId].isActive, "Game is not active.");

        // check game is not expired
        require(block.timestamp < games[_gameId].endTime, "Game has expired.");

        IERC721(_nftContract).transferFrom(msg.sender, address(this), _tokenId);
        games[_gameId].nftContract = _nftContract;
        games[_gameId].nftTokenId = _tokenId;
        games[_gameId].nftClaimed = false;
        emit NFTDeposited(_gameId, _nftContract, _tokenId, msg.sender);
    }


    function claimNFT(uint256 _gameId) external {
        require(block.timestamp > games[_gameId].endTime || games[_gameId].isActive == false, "Game should be active or expired.");
        require(games[_gameId].nftClaimed == false, "NFT already claimed.");
        require(games[_gameId].winners.length > 0, "No winners found.");
        
        // check if the winner is the sender. iterate through the winners array
        bool isWinner = false;
        for (uint256 i = 0; i < games[_gameId].winners.length; i++) {
            if (games[_gameId].winners[i] == msg.sender) {
                isWinner = true;
                break;
            }
        }

        require(isWinner, "You are not a winner.");

        IERC721(games[_gameId].nftContract).transferFrom(address(this), msg.sender, games[_gameId].nftTokenId);
        games[_gameId].nftClaimed = true;
        emit NFTClaimed(_gameId, msg.sender);
    }

    function reclaimNFT(uint256 _gameId) external {
        require(games[_gameId].creator == msg.sender, "Only the game creator can reclaim the NFT.");
        require(games[_gameId].isActive == false, "Game is still active.");
        require(games[_gameId].nftClaimed == false, "NFT already claimed.");

        IERC721(games[_gameId].nftContract).transferFrom(address(this), msg.sender, games[_gameId].nftTokenId);
        games[_gameId].nftClaimed = true;
        emit NFTReclaimed(_gameId, msg.sender);
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

    // This is an alternate fulfillWinner getting random number from service
    // Single winner only
    function fulfillWinnerMt(
        uint256 _gameId
    ) public onlyOwner {
        require(games[_gameId].isActive == false || block.timestamp > games[_gameId].endTime, "Game is still active or not ended yet.");
        require(games[_gameId].participants.length > 0, "No participants found.");
        require(games[_gameId].winners.length == 0, "Winners already found.");

        // set the winner to the participant with the highest score
        // if several tie get the top one

        // get participants for the game
        address[] memory participants = games[_gameId].participants;

        // get the scores for the participants and get the highest score

        uint256 highestScore = 0;
        address winner = address(0);
        for (uint256 i = 0; i < participants.length; i++) {
            uint256 score = getGameParticipantScore(_gameId, participants[i]);
            if (score > highestScore) {
                highestScore = score;
                winner = participants[i];
            }
        }
        games[_gameId].winners.push(winner);

        emit WinnerFulfilled(_gameId, winner);
    }

    // fullfill winners for given all given games
    function fulfillWinnersForGames(uint256[] memory _gameIds) external onlyOwner {
        for (uint256 i = 0; i < _gameIds.length; i++) {
            fulfillWinnerMt(_gameIds[i]);
        }
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
    }

    function createGame(uint256 _startTime, uint256 _endTime) public returns (uint256) {
        require(_endTime > _startTime, "End time must be after start time.");
        
        uint256 currentGameId = nextGameId;
        Game storage newGame = games[currentGameId];
        newGame.creator = msg.sender;
        newGame.startTime = _startTime;
        newGame.endTime = _endTime;
        newGame.isActive = true;
        newGame.participants = new address[](0);
        newGame.winners = new address[](0);

        emit GameCreated(currentGameId, _startTime, _endTime);

        nextGameId++;
        return currentGameId;
    }

    function createGameWithInterval(uint256 _interval) public returns (uint256) {
        createGame(block.timestamp, block.timestamp + _interval);
        i_interval = _interval;
    }

    function createGameDefault() public returns (uint256) {
        createGame(block.timestamp, block.timestamp + 3600);
    }

    function joinGame(uint256 _gameId, uint256 _score) public {
        require(games[_gameId].isActive, "Game is not active.");
        require(block.timestamp >= games[_gameId].startTime, "Game has not started yet.");
        require(block.timestamp <= games[_gameId].endTime, "Game has already ended.");

        // Check if the participant is already in the game
        if (games[_gameId].s_isParticipant[msg.sender] == true) {
            revert ParticipantAlreadyInGame(_gameId, msg.sender);
        }
        games[_gameId].participants.push(msg.sender);
        games[_gameId].s_isParticipant[msg.sender] = true;
        games[_gameId].scores[msg.sender] = _score.toString();

        emit ParticipantJoinedGame(_gameId, msg.sender);
        emit Score(_gameId, msg.sender, _score);
    }

    function endGame(uint256 _gameId) public {
        require(msg.sender == games[_gameId].creator
         || msg.sender == owner(),
         "Only the game creator can end the game.");
        require(games[_gameId].isActive, "Game is already inactive.");
        games[_gameId].isActive = false;
        // Further logic to handle score calculation and rewards can be added here.

        // rewardWinners(_gameId);

        emit GameEnded(_gameId);
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
    function getGameParticipantScore(uint256 gameId, address participant) public view returns (uint256) {
        return stringToUint(games[gameId].scores[participant]);
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

    // get game winner
    function getGameWinner(uint256 gameId) public view returns (address) {
        return games[gameId].winners[0];
    }

    // get all expired games
    function getExpiredGames() public view returns (uint256[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < nextGameId; i++) {
            if (block.timestamp > games[i].endTime) {
                count++;
            }
        }

        uint256[] memory expiredGames = new uint256[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < nextGameId; i++) {
            if (block.timestamp > games[i].endTime) {
                expiredGames[index] = i;
                index++;
            }
        }

        return expiredGames;
    }

    function stringToUint(string memory s) internal pure returns (uint256) {
        bytes memory b = bytes(s);
        uint256 result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            if (b[i] >= 0x30 && b[i] <= 0x39) {
                result = result * 10 + (uint256(uint8(b[i])) - 48);
            } else {
                revert("Invalid character in string");
            }
        }
    return result;
    }


}