// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

interface IPoolDB{
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    function poolAddrs() external view returns (address[] memory);
    function minerAddrs() external view returns (address[] memory);

}