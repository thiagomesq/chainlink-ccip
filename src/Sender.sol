// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IRouterClient} from "@chainlink/contracts/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts/src/v0.8/ccip/libraries/Client.sol";
import {IERC20} from
    "@chainlink/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from
    "@chainlink/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IVault} from "./interfaces/IVault.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */
contract Sender is Ownable {
    using SafeERC20 for IERC20;

    // https://docs.chain.link/ccip/supported-networks/v1_2_0/testnet#ethereum-testnet-sepolia
    IRouterClient private immutable i_router;
    // https://docs.chain.link/resources/link-token-contracts#ethereum-testnet-sepolia
    IERC20 private immutable i_linkToken;
    mapping(uint64 => bool) private s_destinationChainSelectors;

    event TokenTransferred(
        bytes32 messageId,
        uint64 indexed destinationChainSelector,
        address indexed receiver,
        address token,
        uint256 amount,
        uint256 ccipFee
    );

    error Sender__NotAllowedForDestinationChain(uint64 destinationChainSelector);
    error Sender__InsufficientBalance(IERC20 token, uint256 currentBalance, uint256 requiredAmount);
    error Sender__NothingToWithdraw();

    constructor(uint64[] memory _destinationChainSelectors, address _linkToken, address _router) Ownable(msg.sender) {
        i_linkToken = IERC20(_linkToken);
        i_router = IRouterClient(_router);
        for (uint256 i = 0; i < _destinationChainSelectors.length; i++) {
            s_destinationChainSelectors[_destinationChainSelectors[i]] = true;
        }
    }

    modifier onlyAllowlisted(uint64 _destinationChainSelector) {
        if (!s_destinationChainSelectors[_destinationChainSelector]) {
            revert Sender__NotAllowedForDestinationChain(_destinationChainSelector);
        }
        _;
    }

    function addDestinationChainSelector(uint64 _destinationChainSelector) external onlyOwner {
        if (s_destinationChainSelectors[_destinationChainSelector]) {
            return; // Already allowlisted
        }
        s_destinationChainSelectors[_destinationChainSelector] = true;
    }

    function transferTokens(
        address token,
        uint64 destinationChainSelector,
        address _receiver,
        uint256 _amount,
        address _target
    ) external onlyAllowlisted(destinationChainSelector) returns (bytes32 messageId) {
        if (_amount > IERC20(token).balanceOf(msg.sender)) {
            revert Sender__InsufficientBalance(IERC20(token), IERC20(token).balanceOf(msg.sender), _amount);
        }
        Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](1);
        Client.EVMTokenAmount memory tokenAmount = Client.EVMTokenAmount({token: token, amount: _amount});
        tokenAmounts[0] = tokenAmount;
        bytes memory depositFunctionCalldata =
            abi.encodeWithSelector(IVault.deposit.selector, token, msg.sender, _amount);

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver),
            data: abi.encode(
                _target, // Address of the target contract
                depositFunctionCalldata
            ), // Encode the function selector and the arguments of the stake function
            tokenAmounts: tokenAmounts,
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 200000}) // we need a gas limit to call the receive function
            ),
            feeToken: address(i_linkToken)
        });

        uint256 ccipFee = i_router.getFee(destinationChainSelector, message);

        if (ccipFee > i_linkToken.balanceOf(address(this))) {
            revert Sender__InsufficientBalance(i_linkToken, i_linkToken.balanceOf(address(this)), ccipFee);
        }

        i_linkToken.approve(address(i_router), ccipFee);

        IERC20(token).safeTransferFrom(msg.sender, address(this), _amount);
        IERC20(token).approve(address(i_router), _amount);

        // Send CCIP Message
        messageId = i_router.ccipSend(destinationChainSelector, message);

        emit TokenTransferred(messageId, destinationChainSelector, token, _receiver, _amount, ccipFee);
    }

    function withdrawToken(address token, address _beneficiary) public onlyOwner {
        uint256 amount = IERC20(token).balanceOf(address(this));
        if (amount == 0) revert Sender__NothingToWithdraw();
        IERC20(token).transfer(_beneficiary, amount);
    }
}
