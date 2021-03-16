// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

import "./interfaces/IPoolDB.sol";
import "../../libraries/@openzeppelin/contracts/math/SafeMath.sol";
import "../../libraries/AcceptedCaller.sol";

contract PoolDB is IPoolDB, AcceptedCaller {
    using SafeMath for uint256;

    struct Miner {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt.
        uint256 multLpRewardDebt; //multLp Reward debt.
        bool seted;
    }

    // Info of each pool.
    struct Pool {
        uint256 point;
        uint256 balance;
        address[] miners;
        mapping(address => uint256) minerBalances;
        uint256 lastRewardBlock;
        bool paused=false;
        bool seted;
    }

    mapping(address => Pool) pools;
    mapping(address => Miner) miners;

    address[] private _poolAddrs;
    address[] private _minerAddrs;

    address public token;
    uint256 public balance;
    uint256 public totalPoint;
    uint256 public startBlock;
    uint256 public reducePeriod = (30 * 24 * 60 * 60) / 3;
    uint256 public reducePercentage = 10;
    uint256 public blockReward;
    bool public paused=false;

    constructor(address _token,uint256 _balance) {
        token = _token;
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

    modifier onlyNotSetedPool(address _token) {
        require(
            pools[_token].seted == false,
            "onlySetedPool: token is setedPool!"
        );
        _;
    }

    function poolAddrs() public view override returns (address[] memory) {
        return _poolAddrs;
    }

    function minerAddrs() public view override returns (address[] memory) {
        return _minerAddrs;
    }

    function addPool(address _token, uint256 _point)public override onlyNotSetedPool(_token) onlyOwner returns (bool) {
        _poolAddrs.push(_token);
        pools[_token]=Pool({point:_point,seted:true})
        totalPoint=totalPoint.add(_point)
        return true;
    }

    function setPoolPoint(address _token, uint256 _point)public override onlySetedPool(_token) onlyOwner returns (bool) {
        totalPoint=totalPoint.sub(pools[_token].point)
        totalPoint=totalPoint.add(_point)
        pools[_token].point=_point;
        return true;
    }

    function pausePool(address _token)public override onlySetedPool(_token) onlyOwner returns (bool) {
        totalPoint=totalPoint.sub(pools[_token].point)
        pools[_token].paused=true;
        return true;
    }

    function startPool(address _token)public override onlySetedPool(_token) onlyOwner returns (bool) {
        totalPoint=totalPoint.add(pools[_token].point)
        pools[_token].paused=false;
        return true;
    }
}
