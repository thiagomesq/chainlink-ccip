// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {CCIPLocalSimulator, IRouterClient, LinkToken} from "@chainlink/local/src/ccip/CCIPLocalSimulator.sol";

abstract contract CodeConstants {
    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 public constant BASE_SEPOLIA_CHAIN_ID = 84532;
    uint256 public constant ZKSYNC_SEPOLIA_CHAIN_ID = 300;
    uint256 public constant LOCAL_CHAIN_ID = 31337;
}

contract HelperConfig is CodeConstants, Script {
    error HelperConfig__InvalidChainId();

    struct NetworkConfig {
        uint64[] chainSelectors;
        address router;
        address link;
        address account;
    }

    NetworkConfig public localNetworkConfig;
    mapping(uint256 => NetworkConfig) public networkConfigs;

    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getSepoliaConfig();
        networkConfigs[BASE_SEPOLIA_CHAIN_ID] = getBaseSepoliaConfig();
        networkConfigs[ZKSYNC_SEPOLIA_CHAIN_ID] = getZksyncSepoliaConfig();
    }

    function getConfigChainId(uint256 chainId) public returns (NetworkConfig memory) {
        if (networkConfigs[chainId].router != address(0)) {
            return networkConfigs[chainId];
        } else if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateAnvilEthConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigChainId(block.chainid);
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        uint64[] memory selectors = new uint64[](2);
        selectors[0] = 10344971235874465080;
        selectors[1] = 6898391096552792247;
        return NetworkConfig({
            chainSelectors: selectors,
            router: 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            account: 0xe7FDf6cA472c484FA8b7b2E11a5E62adaF1e649F
        });
    }

    function getBaseSepoliaConfig() public pure returns (NetworkConfig memory) {
        uint64[] memory selectors = new uint64[](1);
        selectors[0] = 16015286601757825753;
        return NetworkConfig({
            chainSelectors: selectors,
            router: 0xD3b06cEbF099CE7DA4AcCf578aaebFDBd6e88a93,
            link: 0xE4aB69C077896252FAFBD49EFD26B5D171A32410,
            account: 0xe7FDf6cA472c484FA8b7b2E11a5E62adaF1e649F
        });
    }

    function getZksyncSepoliaConfig() public pure returns (NetworkConfig memory) {
        uint64[] memory selectors = new uint64[](1);
        selectors[0] = 16015286601757825753;
        return NetworkConfig({
            chainSelectors: selectors,
            router: 0xA1fdA8aa9A8C4b945C45aD30647b01f07D7A0B16,
            link: 0x23A1aFD896c8c8876AF46aDc38521f4432658d1e,
            account: 0xe7FDf6cA472c484FA8b7b2E11a5E62adaF1e649F
        });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (localNetworkConfig.router != address(0)) {
            return localNetworkConfig;
        }

        // Deploy ccip local simulator
        vm.startBroadcast(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        CCIPLocalSimulator ccipLocalSimulator = new CCIPLocalSimulator();
        vm.stopBroadcast();
        (uint64 chainSelector, IRouterClient router,,, LinkToken linkToken,,) = ccipLocalSimulator.configuration();
        uint64[] memory chainSelectors = new uint64[](1);
        chainSelectors[0] = chainSelector;
        localNetworkConfig = NetworkConfig({
            chainSelectors: chainSelectors,
            router: address(router),
            link: address(linkToken),
            account: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
        });
        return localNetworkConfig;
    }
}
