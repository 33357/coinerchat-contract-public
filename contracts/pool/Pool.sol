// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

import "./interfaces/IPool.sol";
import "../libraries/@openzeppelin/contracts/math/SafeMath.sol";
import "../libraries/@openzeppelin/contracts/token/erc20/SafeERC20.sol";
import "../libraries/@openzeppelin/contracts/token/erc20/IERC20.sol";
import "../libraries/AcceptedCaller.sol";

contract Pool is IPool, AcceptedCaller {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct Miner {
        uint256 balance;
        uint256 reward;
        uint256 lastTime;
        bool seted;
    }

    struct Pool {
        IERC20 token;
        uint256 point;
        uint256 balance;
        uint256 totalReward;
        uint256 lastRewardBlock;
        uint256 rewardPerEnergy;
        address[] minerAddrs;
        mapping(address => Miner) miners;
        bool paused=false;
        bool seted;
    }

    mapping(address => Pool) pools;

    address[] private _poolAddrs;

    address public tokenAddr;
    IERC20 token;
    uint256 public balance;
    uint256 public totalPoint;
    uint256 public startBlock;
    uint256 public reducePeriod = (30 * 24 * 60 * 60) / 3;
    uint256 public reducePercentage = 10;
    uint256 public blockReward;
    uint256 public maxEnergyTime=12*60*60;
    bool public paused=false;

    constructor(address _token,uint256 _balance) {
        tokenAddr = _token;
        token= IERC20(tokenAddr);
        startBlock = block.number + (1 * 24 * 60 * 60) / 3;
        balance=_balance;
        blockReward= balance / 10 / reducePeriod;
    }

    modifier onlySetedPool(address _token) {
        require(
            pools[_token].seted == true,
            "onlySetedPool: token is not setedPool!"
        );
        _;
    }

    modifier onlyStartedPool(address _token) onlySetedPool(_token){
        require(
            pools[_token].paused == false,
            "onlySetedPool: token is not startedPool!"
        );
        _;
    }

    modifier onlyNotSetedPool(address _token) {
        require(
            pools[_token].seted == false,
            "onlySetedPool: token is setedPool!"
        );
        _;
    }

    modifier checkStart(){
        require(block.number >= startBlock,"checkStart: not start!");
        _;
    }

    function poolAddrs() public view override returns (address[] memory) {
        return _poolAddrs;
    }

    function addPool(address _token, uint256 _point)public override onlyNotSetedPool(_token) onlyOwner returns (bool) {
        _poolAddrs.push(_token);
        pools[_token]=Pool({token:IERC20(_token),point:_point,seted:true});
        totalPoint=totalPoint.add(_point);
        return true;
    }

    function setPoolPoint(address _token, uint256 _point)public override onlySetedPool(_token) onlyOwner returns (bool) {
        totalPoint=totalPoint.sub(pools[_token].point);
        totalPoint=totalPoint.add(_point)
        pools[_token].point=_point;
        return true;
    }

    function pausePool(address _token)public override onlySetedPool(_token) onlyOwner returns (bool) {
        totalPoint=totalPoint.sub(pools[_token].point);
        pools[_token].paused=true;
        return true;
    }

    function startPool(address _token)public override onlySetedPool(_token) onlyOwner returns (bool) {
        totalPoint=totalPoint.add(pools[_token].point);
        pools[_token].paused=false;
        return true;
    }

    function setMaxEnergyTime(uint256 _time)public override onlyOwner returns (bool) {
        maxEnergyTime=_time;
        return true;
    }

    function getEnergy(address _token,address _miner)public view returns (uint256){
        uint256 time=block.timestamp-pools[_token].miners[_miner].lastTime;
        if(time>maxEnergyTime){
            time=maxEnergyTime;
        }
        return pools[_token].miners[_miner].balance.mul(time)
    }

    function stake(address _token,uint256 amount) public onlyStartedPool(address _token) updateReward(_token,msg.sender) checkStart returns (bool){
        require(amount > 0, "stake: cannot stake 0!");
        pools[_token].balance=pools[_token].balance.add(amount)
        pools[_token].miners[msg.sender]=pools[_token].miners[msg.sender].add(amount)
        pools[_token].token.safeTransferFrom(msg.sender, address(this), amount);
        emit Stake(msg.sender,_token, amount);
        return true;
    }

    modifier updateReward(address _token,address _miner) onlyStartedPool(_token) {
        pools[_token].rewardPerEnergy = rewardPerEnergy();
        lastUpdateTime = lastBlockReward(_token);
        if (_miner != address(0)) {
            rewards[_miner] = earned(_token,_miner);
            userRewardPerTokenPaid[_miner] = rewardPerTokenStored;
        }
        _;
    }

    function rewardPerEnergy(address _token) public view returns (uint256) {
        if (pools[_token].balance == 0) {
            return pools[_token].rewardPerEnergy;
        }
        return
            pools[_token].rewardPerEnergy.add(
                lastBlockReward()
                    .sub(pools[_token].lastRewardBlock)
                    .mul(1e18)
                    .div(pools[_token].totalEnergy)
            );
    }

    function earned(address _token)public view returns (uint256){
        uint256 time=block.timestamp-pools[_token].miners[msg.sender].lastTime;
        if(time>maxEnergyTime){
            time=maxEnergyTime;
        }
        return pools[_token].miners[msg.sender].balance.mul(time)
    }

    function withdrawReward(address _token)public checkStart returns (bool){
        uint256 reward = getReward(address _token);
        if (reward > 0) {
            pools[_token].miners[msg.sender].reward = 0;
            token.safeTransfer(msg.sender, reward);
            emit WithdrawReward(msg.sender, reward);
        }
        return true;
    }

    function withdraw(address _token,uint256 _amount) public updateReward(_token,msg.sender) checkStart returns (bool){
        require(amount > 0, "withdraw: cannot withdraw 0!");
        pools[_token].balance=pools[_token].balance.sub(_amount)
        pools[_token].miners[msg.sender]=pools[_token].miners[msg.sender].sub(_amount)
        pools[_token].token.safeTransferFrom(msg.sender, _amount);
        emit Withdraw(msg.sender, _amount);
        return true;
    }

    function exit(address _token) external checkStart returns (bool){
        withdraw(_token,pools[_token].miners[msg.sender]);
        withdrawReward(_token);
        return true;
    }

    function lastBlockReward(address _token)public view returns (uint256){
        return block.number < pools[_token].lastRewardBlock ? block.number : pools[_token].lastRewardBlock;
    }
}
