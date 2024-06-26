// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {DeployTriviaGameHub} from "../script/DeployTriviaGameHub.s.sol";
import {TriviaGameHub} from "../contracts/TriviaGameHub.sol";
import {Test, console, Vm} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import { MockFunctionsRouter } from "../contracts/test/mocks/MockFunctionsRouter.sol";
import { HelperConfig } from "../script/HelperConfig.s.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import { TriviaGameHubTest } from "../contracts/test/harnes/TriviaGameHubTest.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import {GameSessionNft} from "../contracts/GameSessionNft.sol";
import { DeployGameSessionNft } from "../script/DeployGameSessionNft.s.sol";


contract MonkeyTriviaHub is StdCheats, Test {
    string constant NFT_NAME = "MonkeyTrivia NFT";
    string constant NFT_SYMBOL = "MTSession";
    TriviaGameHubTest public triviaGameHub;
    DeployTriviaGameHub public deployer;

    address public DEPLOYER_ADDRESS;
    address public constant USER = address(1);
    address public constant USER2 = address(2);
    address public constant USER3 = address(3);
    address public constant USER4 = address(4);

    MockFunctionsRouter public mockFunctionsRouter;

    //Nft 
    GameSessionNft public gameSessionNft;
    DeployGameSessionNft public nftDeployer;



    function setUp() public virtual {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory networkConfig = helperConfig.getActiveNetworkConfig();
        mockFunctionsRouter = MockFunctionsRouter(networkConfig.functionsRouter);

        deployer = new DeployTriviaGameHub();
        triviaGameHub = deployer.run();
        DEPLOYER_ADDRESS = deployer.getDeployerPubKey();

        nftDeployer = new DeployGameSessionNft();
        gameSessionNft = nftDeployer.run();
    }

    function testCreateGame() public {
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 3600; // 1 hour later

        triviaGameHub.createGame(startTime, endTime);

        uint256 nextGameId = triviaGameHub.nextGameId();
        require(nextGameId == 1, "Next game ID should be 1");
        require(triviaGameHub.getGameCreator(0) == address(this), "Creator should be this contract");
        require(triviaGameHub.getGameStartTime(0) == startTime, "Start time should match");
        require(triviaGameHub.getGameEndTime(0) == endTime, "End time should match");
        require(triviaGameHub.getGameIsActive(0) == true, "Game should be active");

        (address[] memory participants, string[] memory scores) = triviaGameHub.getGameScores(0);
        require(participants.length == 0, "Participants array should be empty");
        require(scores.length == 0, "Score length should be 0");    

    }

    function testJoinGame() public {
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 3600; // 1 hour later

        triviaGameHub.createGame(startTime, endTime);

        triviaGameHub.joinGame(0);

        address[] memory participants = triviaGameHub.getGameParticipants(0);
        require(participants.length == 1, "There should be 1 participant");
        require(participants[0] == address(this), "Participant should be this contract");
    }

    function testJoinNonExistentGame() public {
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 3600; // 1 hour later

        triviaGameHub.createGame(startTime, endTime);

        (bool success,) = address(triviaGameHub).call(abi.encodeWithSignature("joinGame(uint256)", 1));
        require(success == false, "Should not be able to join non-existent game");
    }

    function testJoinNonStartedGame() public {
        uint256 startTime = block.timestamp + 1800; // 30 minutes later 
        uint256 endTime = startTime + 3600; // 1 hour later

        triviaGameHub.createGame(startTime, endTime);
        uint256 gameId = 0;

        (bool success,) = address(triviaGameHub).call(abi.encodeWithSignature("joinGame(uint256)", gameId));
        require(success == false, "Should not be able to join a game that has not started");
    }

    // Test that a player cannot join a game that has already ended:
    function testJoinEndedGame() public {
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 1800; // 30 minutes later

        triviaGameHub.createGame(startTime, endTime);
        skip(3600); // skip 1 hour
        uint256 gameId = 0;

        (bool success,) = address(triviaGameHub).call(abi.encodeWithSignature("joinGame(uint256)", gameId));
        require(success == false, "Should not be able to join a game that has already ended");
    }

    // Test that a player cannot join a game they are already participating in
    function testJoinTwice() public {
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 3600; // 1 hour later

        triviaGameHub.createGame(startTime, endTime);
        triviaGameHub.joinGame(0);

        (bool success,) = address(triviaGameHub).call(abi.encodeWithSignature("joinGame(uint256)", 0));
        require(success == false, "Should not be able to join a game twice");
    }

    function testEndGame() public {
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 3600; // 1 hour later

        vm.prank(USER);
        triviaGameHub.createGame(startTime, endTime);

        vm.prank(USER);
        triviaGameHub.endGame(0);

        require(triviaGameHub.getGameIsActive(0) == false, "Game should be inactive");
    }

    function testEndGameNotCreator() public {
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 3600; // 1 hour later

        vm.prank(USER);
        triviaGameHub.createGame(startTime, endTime);

        vm.prank(address(2));
        (bool success,) = address(triviaGameHub).call(abi.encodeWithSignature("endGame(uint256)", 0));

        require(success == false, "Should not be able to end game if not creator");
    }

    function testEndGameAlreadyInactive() public {
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 3600; // 1 hour later

        vm.prank(USER);
        triviaGameHub.createGame(startTime, endTime);

        vm.prank(USER);
        triviaGameHub.endGame(0);

        (bool success,) = address(triviaGameHub).call(abi.encodeWithSignature("endGame(uint256)", 0));

        require(success == false, "Should not be able to end game if already inactive");
    }

    modifier setupGame() {
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 3600; // 1 hour later

        vm.startPrank(USER);
        triviaGameHub.createGame(startTime, endTime);
        triviaGameHub.joinGame(0);
        vm.stopPrank();

        _;
    }

    function testRequestScoreNotParticipant() public setupGame {
        vm.startPrank(triviaGameHub.owner());
        vm.expectRevert("Given address is not a participant in this game.");
        triviaGameHub.requestScoreForParticipant(0, address(2));
        vm.stopPrank();     
    }

    function testRequestScoreForPartcipant() public setupGame {
        vm.prank(USER);
        triviaGameHub.requestScoreForParticipant(0, USER);   
    }

    function testRequestScoreForPartcipantNotActive() public setupGame {
        vm.prank(triviaGameHub.owner());
        triviaGameHub.endGame(0);
        vm.startPrank(USER);
        vm.expectRevert("Game is not active.");
        triviaGameHub.requestScoreForParticipant(0, USER);
        vm.stopPrank();  
    }

    function testRequestScoreForPartcipantNotWithinActivePeriod() public setupGame {
        skip(3600 + 1); // skip 1+ hour

        vm.startPrank(triviaGameHub.owner());
        vm.expectRevert("Game is not within active period.");
        triviaGameHub.requestScoreForParticipant(0, USER);
        vm.stopPrank();  
    }

    // test fullfill request
    function testFulfillRequestResponseEvent() public {
        bytes32 requestId = 0xe910a6f0b7e520e3fe304968e01010825c1c635c8d504d4b85177004d593fce7;

        bytes memory response = abi.encodePacked("100");

        vm.recordLogs();
        triviaGameHub.testFulfillRequest(requestId, response);
        Vm.Log[] memory entries = vm.getRecordedLogs();
        console.log("Entries: ", entries.length);
        for (uint i = 0; i < entries.length; i++) {
            if (entries[i].topics.length > 1) {  // Ensure there's at least one indexed topic
                bytes32 loggedRequestId = bytes32(entries[i].topics[1]);
                // Convert bytes32 to uint256 before converting to hex string
                uint256 requestIdAsUint = uint256(loggedRequestId);
                console.log("Logged Request ID: ", Strings.toHexString(requestIdAsUint, 32));  // Second parameter specifies the length of the hex string
                require(requestIdAsUint == uint256(requestId), "Request ID should match");
            }
        }

        // This is for the response in the event
        (bytes memory s1, ) = abi.decode(entries[0].data, (bytes, bytes));

        require(entries.length == 1, "There should be 1 log entry");
        require(keccak256(abi.encodePacked((string(s1))))  == keccak256(abi.encodePacked(("100"))), "Response should be 323232");
    }

    function testFulfillRequestScoreResponse() public setupGame {

        vm.startPrank(USER);
        triviaGameHub.requestScoreForParticipant(0, USER);
        bytes32 requestId = triviaGameHub.getLastRequestId();  
        bytes memory response = abi.encodePacked("33");
        triviaGameHub.testFulfillRequest(requestId, response);
        vm.stopPrank();

        (address[] memory participants, string[] memory scores) = triviaGameHub.getGameScores(0);
        require(participants.length == 1, "There should be 1 participant");
        require(scores.length == 1, "Score length should be 1");
        // require(keccak256(abi.encodePacked(scores[0])) == keccak256(abi.encodePacked("100")), "Score should be 100");

        // Check last score response
        (uint256 gameId, string memory score, address participant) = triviaGameHub.getScoreResponse(requestId);
        require(gameId == 0, "Game ID should be 0");
        require(keccak256(abi.encodePacked(score)) == keccak256(abi.encodePacked("33")), "Score should be 33");
        require(participant == USER, "Participant should be USER");
    }

    function testFulfillRequestScoreGetScore() public setupGame {
        vm.startPrank(USER);
        triviaGameHub.requestScoreForParticipant(0, USER);
        bytes32 requestId = triviaGameHub.getLastRequestId();  
        bytes memory response = abi.encodePacked("3111");
        triviaGameHub.testFulfillRequest(requestId, response);
        vm.stopPrank();

        string memory actual = triviaGameHub.getGameParticipantScore(0, USER);
        // console.log("Actual: ", actual);
        require(keccak256(abi.encodePacked(actual)) == keccak256(abi.encodePacked("3111")), "Score should be 3111");
    
    }

    modifier setupGameMultipleParticipants() {
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + 3600; // 1 hour later

        vm.startPrank(USER);
        triviaGameHub.createGame(startTime, endTime);
        triviaGameHub.joinGame(0);
        vm.stopPrank();


        vm.prank(USER2);
        triviaGameHub.joinGame(0);

        vm.prank(USER3);
        triviaGameHub.joinGame(0);

        vm.prank(USER4);
        triviaGameHub.joinGame(0);
        _;
    }

    // Fulfill random words
    function testFulfillWinners() public setupGameMultipleParticipants {

        vm.prank(triviaGameHub.owner());
        uint256 requestId = triviaGameHub.requestRandomWords(0);

        // Simulate random words
        uint256[] memory randomWords = new uint256[](2);
        randomWords[0] = 23232; // should map to USER
        randomWords[1] = 11123; // should map to USER4

        // Call the internal function via a public or external test helper function
        vm.prank(triviaGameHub.owner());
        console.log("Request ID: ", requestId);
        triviaGameHub.testFulfillRandomWords(requestId, randomWords);

        vm.prank(triviaGameHub.owner());
        triviaGameHub.fulfillWinners(requestId);

        // Check the results
        address[] memory winners = triviaGameHub.getWinners(0); 
        require(winners.length == 2, "There should be two winners");
        require(winners[0] == USER, "First winner should be the first address");
        require(winners[1] == USER4, "Second winner should be the fourth address");
    }

    function testFulfillWinnersAlreadyFulfilled() public setupGameMultipleParticipants {

        vm.prank(triviaGameHub.owner());
        uint256 requestId = triviaGameHub.requestRandomWords(0);

        // Simulate random words
        uint256[] memory randomWords = new uint256[](2);
        randomWords[0] = 23232; // should map to USER
        randomWords[1] = 11123; // should map to USER4

        // Call the internal function via a public or external test helper function
        vm.prank(triviaGameHub.owner());
        triviaGameHub.testFulfillRandomWords(requestId, randomWords);

        (bool success,) = address(triviaGameHub).call(abi.encodeWithSignature("testFulfillRandomWords(uint256,uint256[])", requestId, randomWords));
        require(success == false, "Should not be able to fulfill winners if already fulfilled");
    }

    function fullFillWinners() public {
        vm.prank(triviaGameHub.owner());
        uint256 requestId = triviaGameHub.requestRandomWords(0);

        // Simulate random words
        uint256[] memory randomWords = new uint256[](2);
        randomWords[0] = 23232; // should map to USER
        randomWords[1] = 11123; // should map to USER4

        vm.prank(triviaGameHub.owner());
        triviaGameHub.testFulfillRandomWords(requestId, randomWords);

        vm.prank(triviaGameHub.owner());
        triviaGameHub.fulfillWinners(requestId);
    }

    modifier mintNft() {
        vm.prank(USER);
        gameSessionNft.mint(USER, "session1");
        
        // Check that the balance of the nft is 1
        require(gameSessionNft.balanceOf(USER) == 1, "NFT should be minted to the user");
        _;
    }

    // test for depositing NFT
    function testDepositNFT() public setupGame mintNft {

        // Approve the contract to transfer the NFT
        vm.prank(USER);
        gameSessionNft.approve(address(triviaGameHub), 0);

        // check that the owner is the user
        require(gameSessionNft.ownerOf(0) == USER, "NFT should be owned by the user");

        vm.prank(USER);
        triviaGameHub.depositNFT(0, address(gameSessionNft), 0);

        // Check that the owner of the nft is the trivia game hub contract
        require(gameSessionNft.ownerOf(0) == address(triviaGameHub), "NFT should be deposited to the trivia game hub contract");
    }

    // test for claiming NFT for single winner
    function testClaimNFT() public setupGameMultipleParticipants mintNft {

        // Approve the contract to transfer the NFT
        vm.prank(USER);
        gameSessionNft.approve(address(triviaGameHub), 0);

        vm.prank(USER);
        triviaGameHub.depositNFT(0, address(gameSessionNft), 0);

        // Check that the owner of the nft is the trivia game hub contract
        require(gameSessionNft.ownerOf(0) == address(triviaGameHub), "NFT should be deposited to the trivia game hub contract");

        fullFillWinners();

        // end the game
        vm.prank(triviaGameHub.owner());
        triviaGameHub.endGame(0);

        address[] memory winners = triviaGameHub.getWinners(0);
        require(winners[0] == USER, "First winner should be the first address");

        vm.prank(USER);
        triviaGameHub.claimNFT(0);

        // check the owner of the nft is the user
        require(gameSessionNft.ownerOf(0) == USER, "NFT should be owned by the user");

    }

    function testFulfillWinnersMt() public setupGameMultipleParticipants mintNft {
        
          // Approve the contract to transfer the NFT
        vm.prank(USER);
        gameSessionNft.approve(address(triviaGameHub), 0);

        vm.prank(USER);
        triviaGameHub.depositNFT(0, address(gameSessionNft), 0);

        // Check that the owner of the nft is the trivia game hub contract
        require(gameSessionNft.ownerOf(0) == address(triviaGameHub), "NFT should be deposited to the trivia game hub contract");

        
        // end the game
        vm.prank(triviaGameHub.owner());
        triviaGameHub.endGame(0);

        vm.prank(triviaGameHub.owner());
        triviaGameHub.fulfillWinnerMt(0, 1); // gameId, winnerIndex

        address[] memory winners = triviaGameHub.getWinners(0);
        require(winners[0] == USER2, "First winner should be the first address");

        vm.prank(USER2);
        triviaGameHub.claimNFT(0);

        // check the owner of the nft is the user2
        require(gameSessionNft.ownerOf(0) == USER2, "NFT should be owned by the user2");
    }

    // test for reclaiming NFT
    function testReclaimNFT() public setupGameMultipleParticipants mintNft {
          // Approve the contract to transfer the NFT
        vm.prank(USER);
        gameSessionNft.approve(address(triviaGameHub), 0);

        vm.prank(USER);
        triviaGameHub.depositNFT(0, address(gameSessionNft), 0);

        // Check that the owner of the nft is the trivia game hub contract
        require(gameSessionNft.ownerOf(0) == address(triviaGameHub), "NFT should be deposited to the trivia game hub contract");

        
        // end the game
        vm.prank(triviaGameHub.owner());
        triviaGameHub.endGame(0);

        vm.prank(USER);
        triviaGameHub.reclaimNFT(0);

        // check the owner of the nft is the user
        require(gameSessionNft.ownerOf(0) == USER, "NFT should be owned by USER");

    }
}