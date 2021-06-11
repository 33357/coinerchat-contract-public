// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

interface ILPPool {
    event WithdrawReward(address miner, address token ,uint256 reward);
    event WithdrawLP(address miner, address token ,uint256 amount);
    event StakeLP(address miner, address token ,uint256 amount);

    function poolAddrs() external view returns (address[] memory);

    function getMiner(address _token,address _miner)
        external
        view
        returns (
            uint256,
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
            uint256,
            bool
        );

    function addPool(
        address _token,
        uint256 _point
    ) external returns (bool);

    function setPoolPoint(address _token, uint256 _point)
        external
        returns (bool);

    function pausePool(address _token) external returns (bool);

    function startPool(address _token) external returns (bool);

    function pause() external returns (bool);

    function start() external returns (bool);

    function getReward(address _token,address _miner) external view returns (uint256);

    function stakeLP(address _token,uint256 _amount) external returns (bool);

    function withdrawLP(address _token,uint256 _amount) external returns (bool);

    function withdrawReward(address _token) external returns (bool);

    function exit(address _token) external returns (bool);

    function transferAnyERC20Token(address _token, address _to, uint256 _amount) external returns (bool);
}