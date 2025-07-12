-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil zktest

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
DEFAULT_ZKSYNC_LOCAL_KEY := 0x7726827caac94a7f9e1b160f7ea819f172f7b6f9d2a97f992c38edeab82d4110

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install cyfrin/foundry-devops && forge install foundry-rs/forge-std && forge install openzeppelin/openzeppelin-contracts && forge install smartcontractkit/chainlink-brownie-contracts && forge install smartcontractkit/chainlink-local

# Update Dependencies
update:; forge update

build:; forge build

build-zksync:; foundryup-zksync && forge build --zksync && foundryup

test :; forge test 

zktest :; foundryup-zksync && forge test --zksync && foundryup

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --account $(ACCOUNT) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvvv
else ifeq ($(findstring --network base_sepolia,$(ARGS)),--network base_sepolia)
	NETWORK_ARGS := --rpc-url $(BASE_SEPOLIA_RPC_URL) --account $(ACCOUNT) --broadcast --verify --etherscan-api-key $(BASESCAN_API_KEY) -vvvvv
endif

deploy:
	@forge script script/DeployCCIPTokenSender.s.sol:DeployCCIPTokenSender $(NETWORK_ARGS)

deployVault:
	@forge script script/DeployVault.s.sol:DeployVault $(NETWORK_ARGS)

deploySender:
	@forge script script/DeploySender.s.sol:DeploySender $(NETWORK_ARGS)
	
deployReceiver:
	@forge script script/DeployReceiver.s.sol:DeployReceiver $(NETWORK_ARGS)

deployVaultZK:
	@foundryup-zksync && forge create script/DeployVault.s.sol:DeployVault $(NETWORK_ARGS) --zksync && foundryup