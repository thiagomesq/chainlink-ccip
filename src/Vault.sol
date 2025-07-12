// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from
    "@chainlink/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";

contract Vault {
    mapping(address => uint256) public s_balances;

    event Deposit(address indexed account, uint256 amount);
    event Withdraw(address indexed account, uint256 amount);

    error Vault__InsufficientBalance(uint256 currentBalance, uint256 requiredAmount);
    error Vault__FailedToTransfer(address to, uint256 amount);
    error Vault__FailedToDeposit(address to, uint256 amount);

    // Allow anyone to deposit any token
    // Make sure you approve this contract before calling!
    function deposit(address token, address account, uint256 amount) external {
        s_balances[account] += amount;
        IERC20(token).transferFrom(account, address(this), amount);
        emit Deposit(account, amount);
    }

    function withdraw(address token, uint256 amount) external {
        if (s_balances[msg.sender] < amount) {
            revert Vault__InsufficientBalance(s_balances[msg.sender], amount);
        }
        s_balances[msg.sender] -= amount;
        IERC20(token).transfer(msg.sender, amount);
        emit Withdraw(msg.sender, amount);
    }
}
