// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

interface IChatPool {
    event WithdrawReward(address sender, uint256 reward);
    event Min(address sender, address pool, uint256 reward);

    function poolAddrs() external view returns (address[] memory);

    function minerAddrs() external view returns (address[] memory);

    function getReward(address _token) external view returns (uint256);

    function getMiner(address _sender)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function getPool(address _token)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            bool
        );

    function addPool(
        address _token,
        uint256 _minBalance,
        uint256 _point
    ) external returns (bool);

    function setPoolPoint(address _token, uint256 _point)
        external
        returns (bool);
    
    function setMinBalance(address _token, uint256 _minBalance)
        external
        returns (bool);

    function setLimitBlock(uint256 _limitBlock)
        external
        returns (bool);

    function pausePool(address _token) external returns (bool);

    function startPool(address _token) external returns (bool);

    function pause() external returns (bool);

    function start() external returns (bool);

    function min(address _sender, address _token) external returns (bool);

    function withdrawReward() external returns (bool);

    function sendTokenToAddress(address _other) external returns (bool);
}
