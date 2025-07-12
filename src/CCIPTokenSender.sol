// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IRouterClient} from "@chainlink/contracts/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts/src/v0.8/ccip/libraries/Client.sol";
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
contract CCIPTokenSender is Ownable {
    using SafeERC20 for IERC20;

    error CCIPTokenSender__InsufficientBalance(IERC20 token, uint256 currentBalance, uint256 requiredAmount);
    error CCIPTokenSender__NothingToWithdraw();

    // https://docs.chain.link/ccip/supported-networks/v1_2_0/testnet#ethereum-testnet-sepolia
    IRouterClient private immutable i_router;
    // https://docs.chain.link/resources/link-token-contracts#ethereum-testnet-sepolia
    IERC20 private immutable i_linkToken;

    event TokenTransferred(
        bytes32 messageId,
        uint64 indexed destinationChainSelector,
        address indexed receiver,
        address token,
        uint256 amount,
        uint256 ccipFee
    );

    constructor(address _router, address _linkToken) Ownable(msg.sender) {
        i_router = IRouterClient(_router);
        i_linkToken = IERC20(_linkToken);
    }

    function transferTokens(address _receiver, uint256 _amount, address _token, uint64 _destinationChainSelector)
        external
        returns (bytes32 messageId)
    {
        IERC20 token = IERC20(_token);
        if (_amount > token.balanceOf(msg.sender)) {
            revert CCIPTokenSender__InsufficientBalance(token, token.balanceOf(msg.sender), _amount);
        }

        Client.EVMTokenAmount[] memory tokenAmounts = _getTokenAmounts(_token, _amount);

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver),
            data: "",
            tokenAmounts: tokenAmounts,
            extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: 0})),
            feeToken: address(i_linkToken)
        });

        uint256 ccipFee = i_router.getFee(_destinationChainSelector, message);

        if (ccipFee > i_linkToken.balanceOf(address(this))) {
            revert CCIPTokenSender__InsufficientBalance(i_linkToken, i_linkToken.balanceOf(address(this)), ccipFee);
        }

        i_linkToken.approve(address(i_router), ccipFee);

        token.safeTransferFrom(msg.sender, address(this), _amount);
        token.approve(address(i_router), _amount);

        // Send CCIP Message
        messageId = i_router.ccipSend(_destinationChainSelector, message);

        emit TokenTransferred(messageId, _destinationChainSelector, _receiver, _token, _amount, ccipFee);
    }

    function withdrawToken(address _beneficiary, address _token) public onlyOwner {
        IERC20 token = IERC20(_token);
        uint256 amount = token.balanceOf(address(this));
        if (amount == 0) revert CCIPTokenSender__NothingToWithdraw();
        token.transfer(_beneficiary, amount);
    }

    function _getTokenAmounts(address _token, uint256 _amount)
        internal
        pure
        returns (Client.EVMTokenAmount[] memory tokenAmounts)
    {
        tokenAmounts = new Client.EVMTokenAmount[](1);
        tokenAmounts[0] = Client.EVMTokenAmount({token: _token, amount: _amount});
    }
}
