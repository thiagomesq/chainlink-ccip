// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {Sender} from "src/Sender.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeploySender is Script {
    function run() external returns (Sender) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        vm.startBroadcast(config.account);
        Sender sender = new Sender(config.chainSelectors, config.link, config.router);
        vm.stopBroadcast();
        return sender;
    }
}
