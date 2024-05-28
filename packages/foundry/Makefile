-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil 

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make fund [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""

all: clean install build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install Cyfrin/foundry-devops --no-commit && forge install foundry-rs/forge-std --no-commit && forge install openzeppelin/openzeppelin-contracts --no-commit && forge install smartcontractkit/chainlink@develop --no-commit && forge install smartcontractkit/ccip@ccip-develop --no-commit

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test 

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --fork-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vv
endif

ifeq ($(findstring --network mumbai,$(ARGS)),--network mumbai)
    NETWORK_ARGS := --rpc-url $(MUMBAI_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(POLYGONSCAN_API_KEY) -vv
endif

ifeq ($(findstring --network fuji,$(ARGS)),--network fuji)
    NETWORK_ARGS := --rpc-url $(FUJI_CCHAIN_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast  -vv
endif

ifeq ($(findstring --network baseSepolia,$(ARGS)),--network baseSepolia)
    NETWORK_ARGS := --fork-url $(BASE_SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast  --verify --etherscan-api-key $(BASESCAN_API_KEY) -vv
endif

ifeq ($(findstring --network arbitrumSepolia,$(ARGS)),--network arbitrumSepolia)
    NETWORK_ARGS := --fork-url $(ARBITRUM_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast  --verify --etherscan-api-key $(ARBITRUMSCAN_API_KEY) -vv
endif

deploy:
	@forge script script/DeployBasicNft.s.sol:DeployBasicNft $(NETWORK_ARGS)

mint:
	@forge script script/Interactions.s.sol:MintBasicNft ${NETWORK_ARGS}

deployGameSessionNft:
	@forge script script/DeployGameSessionNft.s.sol:DeployGameSessionNft $(NETWORK_ARGS)

mintGameSessionNft: # active session!
	@forge script script/Interactions.s.sol:MintGameSessionNft $(NETWORK_ARGS)

mintCompleteGameSessionNftBase64: # complete session!
	@forge script script/Interactions.s.sol:MintCompleteGameSessionNftBase64 $(NETWORK_ARGS)

deploySourceMinter:
	@forge script script/DeploySourceMinter.s.sol:DeploySourceMinter $(NETWORK_ARGS)

deployDestinationMinter:
	@forge script script/DeployDestinationMinter.s.sol:DeployDestinationMinter $(NETWORK_ARGS)

mintCompleteXChainSepoliaToPolygon:
	@forge script script/Interactions.s.sol:MintCompleteXChainSepoliaToPolygon $(NETWORK_ARGS)

mintCompleteXChainPolygonToFuji:
	@forge script script/Interactions.s.sol:MintNftCompletedSessionPolygonToFuji $(NETWORK_ARGS)

mintNftCompletedSessionEthSepoliaToBase:
	@forge script script/Interactions.s.sol:MintNftCompletedSessionEthSepoliaToBase $(NETWORK_ARGS)

deployTriviaGameHub:
	@forge script script/DeployTriviaGameHub.s.sol:DeployTriviaGameHub $(NETWORK_ARGS)

deployAndPrepareForTesting:
	@forge script script/Interactions.s.sol:PrepareForTesting $(NETWORK_ARGS)