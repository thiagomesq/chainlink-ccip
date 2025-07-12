// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {CCIPLocalSimulator, IRouterClient, LinkToken} from "@chainlink/local/src/ccip/CCIPLocalSimulator.sol";
import {Client} from "@chainlink/contracts/src/v0.8/ccip/libraries/Client.sol";
import {MessageSender} from "src/chainlink-local/MessageSender.sol";
import {MessageReceiver} from "src/chainlink-local/MessageReceiver.sol";

contract Example02Test is Test {
    CCIPLocalSimulator public ccipLocalSimulator;
    MessageSender public messageSender;
    MessageReceiver public messageReceiver;

    IRouterClient public router;
    uint64 public destinationChainSelector;
    LinkToken public linkToken;

    function setUp() public {
        ccipLocalSimulator = new CCIPLocalSimulator();

        (uint64 chainSelector, IRouterClient sourceRouter, IRouterClient destinationRouter,, LinkToken link,,) =
            ccipLocalSimulator.configuration();

        router = sourceRouter;
        destinationChainSelector = chainSelector;
        linkToken = link;

        messageSender = new MessageSender(address(router), address(linkToken));
        messageReceiver = new MessageReceiver(address(destinationRouter));
    }

    function testMessageSendingAndReceiving() external {
        ccipLocalSimulator.requestLinkFromFaucet(address(messageSender), 5 ether);

        bytes32 messageId = messageSender.sendMessage(destinationChainSelector, address(messageReceiver));

        (bytes32 latestMessageId, string memory latestMessage) = messageReceiver.getLastReceivedMessageDetails();

        assertEq(latestMessageId, messageId);
        assertEq(latestMessage, "Hey there!");
    }
}
