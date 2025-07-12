// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {Receiver} from "src/Receiver.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployReceiver is Script {
    function run() external returns (Receiver) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        vm.startBroadcast(config.account);
        Receiver receiver = new Receiver(config.chainSelectors, config.router);
        vm.stopBroadcast();
        return receiver;
    }
}
