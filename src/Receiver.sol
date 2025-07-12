// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// Deploy to Base Sepolia

import {IRouterClient} from "@chainlink/contracts/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {IERC20} from
    "@chainlink/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from
    "@chainlink/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */
contract Receiver is CCIPReceiver, Ownable {
    using SafeERC20 for IERC20;

    // Event emitted when a message is received from another chain.
    // The chain selector of the source chain.
    // The address of the sender from the source chain.
    // The data that was received.
    // The token address that was transferred.
    // The token amount that was transferred.
    event MessageReceived( // The unique ID of the CCIP message.
        bytes32 indexed messageId,
        uint64 indexed sourceChainSelector,
        address sender,
        bytes data,
        address token,
        uint256 tokenAmount
    );

    address private s_sender;

    // https://docs.chain.link/ccip/supported-networks/v1_2_0/testnet#ethereum-testnet-sepolia
    mapping(uint64 => bool) private s_sourceChainSelectors;

    error Receiver__NothingToWithdraw();
    error Receiver__NotAllowedForSourceChainOrSenderAddress(uint64 sourceChainSelector, address sender);
    error Receiver__FunctionCallFail();
    error Receiver__SenderNotSet();

    // pass the destination router address to the CCIPReceiver constructor
    constructor(uint64[] memory _sourceChainSelectors, address _router) CCIPReceiver(_router) Ownable(msg.sender) {
        // Initialize the allowlisted source chain selectors
        for (uint256 i = 0; i < _sourceChainSelectors.length; i++) {
            s_sourceChainSelectors[_sourceChainSelectors[i]] = true;
        }
    }

    modifier onlyAllowlisted(uint64 _sourceChainSelector, address _sender) {
        if (s_sender == address(0)) {
            revert Receiver__SenderNotSet();
        }
        if (!s_sourceChainSelectors[_sourceChainSelector] || _sender != s_sender) {
            revert Receiver__NotAllowedForSourceChainOrSenderAddress(_sourceChainSelector, _sender);
        }
        _;
    }

    function setSender(address _sender) external onlyOwner {
        // set the sender contract allowed to receive messages from
        s_sender = _sender;
    }

    function addSourceChainSelector(uint64 _sourceChainSelector) external onlyOwner {
        // Add a new source chain selector to the allowlist
        if (s_sourceChainSelectors[_sourceChainSelector]) {
            return; // Already allowlisted
        }
        s_sourceChainSelectors[_sourceChainSelector] = true;
    }

    /// handle a received message
    function _ccipReceive(Client.Any2EVMMessage memory any2EvmMessage)
        internal
        override
        onlyAllowlisted(any2EvmMessage.sourceChainSelector, abi.decode(any2EvmMessage.sender, (address))) // Make sure source chain and sender are allowlisted
    {
        (address target, bytes memory functionCallData) = abi.decode(any2EvmMessage.data, (address, bytes));
        (bool success,) = target.call(functionCallData);

        if (!success) {
            revert Receiver__FunctionCallFail();
        }

        emit MessageReceived(
            any2EvmMessage.messageId,
            any2EvmMessage.sourceChainSelector,
            abi.decode(any2EvmMessage.sender, (address)),
            any2EvmMessage.data,
            any2EvmMessage.destTokenAmounts[0].token,
            any2EvmMessage.destTokenAmounts[0].amount
        );
    }

    function withdrawToken(address _token) public onlyOwner {
        // Retrieve the balance of this contract
        uint256 amount = IERC20(_token).balanceOf(address(this));

        // Revert if there is nothing to withdraw
        if (amount == 0) revert Receiver__NothingToWithdraw();

        IERC20(_token).safeTransfer(msg.sender, amount);
    }
}
