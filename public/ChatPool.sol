// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

import "./IChatPool.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./IERC20.sol";
import "./AcceptedCaller.sol";

contract ChatPool is IChatPool, AcceptedCaller {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct Miner {
        uint256 reward;
        uint256 totalReward;
        uint256 lastRewardBlock;
        bool seted;
    }

    struct Pool {
        IERC20 token;
        uint256 point;
        uint256 totalReward;
        uint256 lastRewardBlock;
        uint256 minBalance;
        bool paused;
        bool seted;
    }

    address public tokenAddr;
    IERC20 token;
    uint256 public balance;
    uint256 public totalPoint;
    uint256 public totalReward;
    uint256 public limitBlock = 20;
    uint256 public startBlock;
    uint256 public reducePeriod = (30 * 24 * 60 * 60) / 3;
    uint256 public reducePercentage = 10;
    uint256 public blockReward;
    uint256 public reduceFrequency;
    bool public paused;

    mapping(address => Miner) miners;
    mapping(address => Pool) pools;

    address[] private _minerAddrs;
    address[] private _poolAddrs;

    modifier checkStart() {
        require(block.number >= startBlock, "checkStart: not start!");
        require(paused == false, "checkStart: paused!");
        _;
    }

    modifier checkReduce() {
        if (
            block.number>=startBlock&&
            block.number.sub(startBlock) >=
            reduceFrequency.add(1).mul(reducePeriod)
        ) {
            reduceFrequency = reduceFrequency.add(1);
            blockReward = blockReward.mul(uint256(100).sub(reducePercentage)).div(100);
        }
        _;
    }

    modifier onlySetedPool(address _token) {
        require(
            pools[_token].seted == true,
            "onlySetedPool: token is not setedPool!"
        );
        _;
    }

    constructor(address _token, uint256 _balance) {
        tokenAddr = _token;
        token = IERC20(tokenAddr);
        startBlock = block.number + (1 * 24 * 60 * 60) / 3;
        balance = _balance*10**18;
        blockReward = balance / 10 / reducePeriod;
    }

    function poolAddrs() public view override returns (address[] memory) {
        return _poolAddrs;
    }

    function minerAddrs() public view override returns (address[] memory) {
        return _minerAddrs;
    }

    function getReward(address _token) public view override returns (uint256) {
        return block.number.sub(pools[_token].lastRewardBlock).mul(
            blockReward.mul(pools[_token].point).div(totalPoint)
        );
    }

    function getMiner(address _sender)
        public
        view
        override
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (
            miners[_sender].reward,
            miners[_sender].totalReward,
            miners[_sender].lastRewardBlock
        );
    }

    function getPool(address _token)
        public
        view
        override
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            bool
        )
    {
        return (
            pools[_token].point,
            pools[_token].totalReward,
            pools[_token].lastRewardBlock,
            pools[_token].minBalance,
            pools[_token].paused
        );
    }

    function addPool(
        address _token,
        uint256 _minBalance,
        uint256 _point
    ) public override onlyOwner returns (bool) {
        require(pools[_token].seted == false, "addPool: token is seted!");
        _poolAddrs.push(_token);
        pools[_token].token = IERC20(_token);
        pools[_token].point = _point;
        pools[_token].minBalance = _minBalance;
        pools[_token].seted = true;
        if (block.number <= startBlock) {
            pools[_token].lastRewardBlock = startBlock;
        } else {
            pools[_token].lastRewardBlock = block.number;
        }
        totalPoint = totalPoint.add(_point);
        return true;
    }

    function setPoolPoint(address _token, uint256 _point)
        public
        override
        onlySetedPool(_token)
        onlyOwner
        returns (bool)
    {
        require(pools[_token].paused == true, "setPoolPoint: not paused pool!");
        pools[_token].point = _point;
        return true;
    }

    function setLimitBlock(uint256 _limitBlock)
        public
        override
        onlyOwner
        returns (bool)
    {
        limitBlock = _limitBlock;
        return true;
    }

    function setMinBalance(address _token, uint256 _minBalance)
        public
        override
        onlySetedPool(_token)
        onlyOwner
        returns (bool)
    {
        pools[_token].minBalance = _minBalance;
        return true;
    }


    function pausePool(address _token)
        public
        override
        onlySetedPool(_token)
        onlyOwner
        returns (bool)
    {
        require(pools[_token].paused == false, "setPoolPoint: not start pool!");
        totalPoint = totalPoint.sub(pools[_token].point);
        pools[_token].paused = true;
        return true;
    }

    function startPool(address _token)
        public
        override
        onlySetedPool(_token)
        onlyOwner
        returns (bool)
    {
        require(pools[_token].paused == true, "setPoolPoint: not paused pool!");
        totalPoint = totalPoint.add(pools[_token].point);
        pools[_token].paused = false;
        return true;
    }

    function pause() public override onlyOwner returns (bool) {
        paused = true;
        return true;
    }

    function start() public override onlyOwner returns (bool) {
        paused = false;
        return true;
    }

    function min(address _sender, address _token)
        public
        override
        onlyAcceptedCaller(msg.sender)
        checkReduce
        returns (bool)
    {
        bool isGetReward = false;
        if (
            block.number.sub(miners[_sender].lastRewardBlock) >= limitBlock &&
            miners[_sender].lastRewardBlock < block.number &&
            pools[_token].paused == false &&
            pools[_token].seted == true &&
            block.number >= startBlock &&
            paused == false
        ) {
            if (
                _token == address(0) &&
                _sender.balance >= pools[_token].minBalance
            ) {
                isGetReward = true;
            } else if (
                pools[_token].token.balanceOf(_sender) >=
                pools[_token].minBalance
            ) {
                isGetReward = true;
            }
        }
        if (isGetReward == true) {
            if (miners[_sender].seted == false) {
                _minerAddrs.push(_sender);
                miners[_sender].seted = true;
            }
            uint256 reward = getReward(_token);
            miners[_sender].reward = miners[_sender].reward.add(reward);
            miners[_sender].totalReward = miners[_sender].totalReward.add(
                reward
            );
            pools[_token].totalReward = pools[_token].totalReward.add(reward);
            totalReward = totalReward.add(reward);
            miners[_sender].lastRewardBlock = block.number;
            pools[_token].lastRewardBlock = block.number;
            emit Min(_sender, _token, reward);
            return true;
        } else {
            return false;
        }
    }

    function withdrawReward() public override checkStart returns (bool) {
        if (miners[msg.sender].reward > 0) {
            uint256 reward = miners[msg.sender].reward;
            miners[msg.sender].reward = 0;
            balance = balance.sub(reward);
            token.safeTransfer(msg.sender, reward);
            emit WithdrawReward(msg.sender, reward);
        }
        return true;
    }

    function sendTokenToAddress(address _other)
        public
        override
        onlyOwner
        returns (bool)
    {
        require(paused == true,'sendTokenToAddress: not paused!');
        token.safeTransfer(_other, balance);
        balance = 0;
        return true;
    }
}
