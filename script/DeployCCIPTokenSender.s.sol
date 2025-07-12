// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {CCIPTokenSender} from "src/CCIPTokenSender.sol";

contract DeployCCIPTokenSender is Script {
    function run() external returns (CCIPTokenSender) {
        vm.startBroadcast();
        CCIPTokenSender ccipTokenSender = new CCIPTokenSender({
            _router: 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59,
            _linkToken: 0x779877A7B0D9E8603169DdbD7836e478b4624789
        });
        vm.stopBroadcast();
        return ccipTokenSender;
    }
}
