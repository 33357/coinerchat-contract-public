// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

interface IPool {
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );

    function poolAddrs() external view returns (address[] memory);

    function addPool(address _token, uint256 _point) external returns (bool);

    function setPoolPoint(address _token, uint256 _point)
        external
        returns (bool);

    function pausePool(address _token) external returns (bool);

    function startPool(address _token) external returns (bool);

    function setMaxEnergyTime(uint256 _time) external returns (bool);

    function getEnergy(address _token, address _miner)
        external
        view
        returns (uint256);

    function getReward(address _token, address _miner)
        external
        view
        returns (uint256);

    function withdrawReward(address _token, address _miner)
        external
        returns (bool);

    function stake(address _token, uint256 _amount) external returns (bool);

    function exit(address _token) external returns (bool);

    function withdraw(address _token, uint256 _amount) external returns (bool);
}
