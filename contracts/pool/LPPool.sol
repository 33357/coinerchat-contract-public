// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

import "./interfaces/ILPPool.sol";
import "../libraries/@openzeppelin/contracts/math/SafeMath.sol";
import "../libraries/@openzeppelin/contracts/token/erc20/SafeERC20.sol";
import "../libraries/@openzeppelin/contracts/token/erc20/IERC20.sol";
import "../libraries/AcceptedCaller.sol";

contract LPPool is ILPPool, AcceptedCaller {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct Miner {
        uint256 balance;
        uint256 rewardStored;
        uint256 rewardPerTokenPaid;
        uint256 totalWithdrawReward;
    }

    struct Pool {
        IERC20 token;
        uint256 point;
        uint256 balance;
        uint256 rewardPerTokenStored;
        uint256 totalWithdrawReward;
        uint256 lastUpdateBlock;
        mapping(address => Miner) miners;
        bool paused;
        bool seted;
    }

    IERC20 public token;
    uint256 public tokenBalance;
    uint256 public totalPoint;
    uint256 public totalWithdrawReward;
    uint256 public startBlock;
    uint256 public reducePeriod = (30 * 24 * 60 * 60) / 3;
    uint256 public reducePercentage = 10;
    uint256 public blockReward;
    uint256 public reduceFrequency;
    bool public paused;

    mapping(address => Pool) pools;

    address[] private _poolAddrs;

    modifier _checkStart() {
        require(block.number >= startBlock, "checkStart: not start!");
        require(paused == false, "checkStart: paused!");
        _;
    }

    modifier _onlySetedPool(address _token) {
        require(
            pools[_token].seted == true,
            "onlySetedPool: token is not setedPool!"
        );
        _;
    }

    modifier _onlyStartPool(address _token) {
        require(
            pools[_token].paused == false,
            "onlyStartPool: token is not startPool!"
        );
        _;
    }

    constructor() {
        token = IERC20(0xD6f210FA8825Ff2C8664886803945b92AEC587f3);
        startBlock = block.number + (1 * 24 * 60 * 60) / 3;
        tokenBalance = 10 * 10**8 * 10**18;
        blockReward = tokenBalance / 10 / reducePeriod;
    }

    function poolAddrs() public view override returns (address[] memory) {
        return _poolAddrs;
    }

    function getMiner(address _token, address _miner)
        public
        view
        override
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            pools[_token].miners[_miner].balance,
            pools[_token].miners[_miner].rewardStored,
            pools[_token].miners[_miner].rewardPerTokenPaid,
            pools[_token].miners[_miner].totalWithdrawReward
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
            uint256,
            bool
        )
    {
        return (
            pools[_token].point,
            pools[_token].balance,
            pools[_token].rewardPerTokenStored,
            pools[_token].totalWithdrawReward,
            pools[_token].lastUpdateBlock,
            pools[_token].paused
        );
    }

    function addPool(address _token, uint256 _point)
        public
        override
        onlyOwner
        returns (bool)
    {
        require(pools[_token].seted == false, "addPool: token is seted!");
        _poolAddrs.push(_token);
        pools[_token].token = IERC20(_token);
        pools[_token].point = _point;
        pools[_token].seted = true;
        if (block.number > startBlock) {
            pools[_token].lastUpdateBlock = block.number;
        } else {
            pools[_token].lastUpdateBlock = startBlock;
        }
        totalPoint = totalPoint.add(_point);
        return true;
    }

    function setPoolPoint(address _token, uint256 _point)
        public
        override
        _onlySetedPool(_token)
        onlyOwner
        returns (bool)
    {
        require(pools[_token].paused == true, "setPoolPoint: not paused pool!");
        pools[_token].point = _point;
        return true;
    }

    function pausePool(address _token)
        public
        override
        _onlySetedPool(_token)
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
        _onlySetedPool(_token)
        onlyOwner
        returns (bool)
    {
        require(pools[_token].paused == true, "setPoolPoint: not paused pool!");
        totalPoint = totalPoint.add(pools[_token].point);
        if (block.number > startBlock) {
            pools[_token].lastUpdateBlock = block.number;
        } else {
            pools[_token].lastUpdateBlock = startBlock;
        }
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

    function getBlockReward() internal view returns (uint256) {
        if (
            block.number.sub(startBlock) >=
            reduceFrequency.add(1).mul(reducePeriod)
        ) {
            return blockReward.mul(uint256(100).sub(reducePercentage)).div(100);
        } else {
            return blockReward;
        }
    }

    function getPoolRewardPerTokenStored(address _token)
        internal
        view
        returns (uint256)
    {
        if (
            block.number > pools[_token].lastUpdateBlock &&
            totalPoint != 0 &&
            pools[_token].balance != 0
        ) {
            return
                pools[_token].rewardPerTokenStored.add(
                    block
                        .number
                        .sub(pools[_token].lastUpdateBlock)
                        .mul(getBlockReward())
                        .mul(pools[_token].point)
                        .div(totalPoint)
                        .div(pools[_token].balance)
                );
        } else {
            return pools[_token].rewardPerTokenStored;
        }
    }

    function getMinerRewardStored(address _token, address _miner)
        internal
        view
        returns (uint256)
    {
        return
            pools[_token].miners[_miner].rewardStored.add(
                pools[_token].miners[_miner].balance.mul(
                    getPoolRewardPerTokenStored(_token).sub(
                        pools[_token].miners[_miner].rewardPerTokenPaid
                    )
                )
            );
    }

    modifier _updateBlockReward(address _token) {
        if (
            block.number >= startBlock &&
            block.number.sub(startBlock) >=
            reduceFrequency.add(1).mul(reducePeriod)
        ) {
            reduceFrequency = reduceFrequency.add(1);
            blockReward = blockReward
                .mul(uint256(100).sub(reducePercentage))
                .div(100);
        }
        _;
    }

    modifier _updatePool(address _token) {
        if (block.number > pools[_token].lastUpdateBlock) {
            pools[_token].rewardPerTokenStored = getPoolRewardPerTokenStored(
                _token
            );
            pools[_token].lastUpdateBlock = block.number;
        }
        _;
    }

    modifier _updateMiner(address _token, address _miner) {
        if (pools[_token].miners[_miner].balance > 0) {
            pools[_token].miners[_miner].rewardStored = getMinerRewardStored(
                _token,
                _miner
            );
            pools[_token].miners[_miner].rewardPerTokenPaid = pools[_token]
                .rewardPerTokenStored;
        }
        _;
    }

    function stakeLP(address _token, uint256 _amount)
        public
        override
        _onlySetedPool(_token)
        _onlyStartPool(_token)
        _updateBlockReward(_token)
        _updatePool(_token)
        _updateMiner(_token, msg.sender)
        _checkStart
        returns (bool)
    {
        pools[_token].token.safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );
        pools[_token].balance = pools[_token].balance.add(_amount);
        pools[_token].miners[msg.sender].balance = pools[_token].miners[
            msg.sender
        ]
            .balance
            .add(_amount);
        emit StakeLP(msg.sender, _token, _amount);
        return true;
    }

    function withdrawLP(address _token, uint256 _amount)
        public
        override
        _updateBlockReward(_token)
        _updatePool(_token)
        _updateMiner(_token, msg.sender)
        returns (bool)
    {
        require(_amount <= pools[_token].miners[msg.sender].balance);
        pools[_token].balance = pools[_token].balance.sub(_amount);
        pools[_token].miners[msg.sender].balance = pools[_token].miners[
            msg.sender
        ]
            .balance
            .sub(_amount);
        pools[_token].token.safeTransfer(msg.sender, _amount);
        emit WithdrawLP(msg.sender, _token, _amount);
        return true;
    }

    function getReward(address _token, address _miner)
        public
        view
        override
        _checkStart
        returns (uint256)
    {
        return getMinerRewardStored(_token, _miner);
    }

    function withdrawReward(address _token)
        public
        override
        _checkStart
        _updateBlockReward(_token)
        _updatePool(_token)
        _updateMiner(_token, msg.sender)
        returns (bool)
    {
        uint256 reward = pools[_token].miners[msg.sender].rewardStored;
        if (reward > 0) {
            pools[_token].miners[msg.sender].rewardStored = 0;
            pools[_token].miners[msg.sender].totalWithdrawReward = pools[_token]
                .miners[msg.sender]
                .totalWithdrawReward
                .add(reward);
            pools[_token].totalWithdrawReward = pools[_token]
                .totalWithdrawReward
                .add(reward);
            totalWithdrawReward = totalWithdrawReward.add(reward);
            pools[_token].token.safeTransfer(msg.sender, reward);
            emit WithdrawReward(msg.sender, _token, reward);
        }
        return true;
    }

    function exit(address _token) public override _checkStart returns (bool) {
        withdrawReward(_token);
        withdrawLP(_token, pools[_token].miners[msg.sender].balance);
        return true;
    }

    function transferAnyERC20Token(
        address _token,
        address _to,
        uint256 _amount
    ) public override onlyOwner returns (bool) {
        IERC20(_token).safeTransfer(_to, _amount);
        return true;
    }
}
