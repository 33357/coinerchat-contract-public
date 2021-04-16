// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

import "../libraries/@openzeppelin/contracts/access/Ownable.sol";
import "../libraries/@openzeppelin/contracts/math/SafeMath.sol";
import "../libraries/@openzeppelin/contracts/token/erc20/SafeERC20.sol";
import "../libraries/@openzeppelin/contracts/token/erc20/IERC20.sol";
import "./interfaces/ICrowdFund.sol";

// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract CrowdFund is ICrowdFund, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public tokenAddr;
    IERC20 token;
    uint256 public tokenBalance;
    address public crowdTokenAddr;
    IERC20 crowdToken;
    uint256 public crowdTokenBalance;
    mapping(address => uint256) public crowdFundBalance;
    mapping(address => bool) public isGetToken;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public tokenPerCrowdToken;

    constructor() {
        tokenAddr = 0xD6f210FA8825Ff2C8664886803945b92AEC587f3;
        token = IERC20(tokenAddr);
        tokenBalance = 10*10**8*10**18;
        crowdTokenAddr = 0xa71EdC38d189767582C38A3145b5873052c3e47a;
        crowdToken = IERC20(crowdTokenAddr);
        startTime = block.timestamp + 1 * 24 * 60 * 60;
        endTime = block.timestamp + 15 * 24 * 60 * 60;
    }

    modifier onlyStart() {
        require(block.timestamp >= startTime&&block.timestamp <= endTime, "onlyStart: not start !");
        _;
    }

    modifier onlyEnd() {
        require(block.timestamp >= endTime, "onlyEnd: not end !");
        _;
    }

    function addCrowdToken(uint256 _amount)
        public
        override
        onlyStart
        returns (bool)
    {
        crowdToken.safeTransferFrom(msg.sender, address(this), _amount);
        crowdFundBalance[msg.sender] = crowdFundBalance[msg.sender].add(
            _amount
        );
        crowdTokenBalance = crowdTokenBalance.add(_amount);
        tokenPerCrowdToken = tokenBalance.div(crowdTokenBalance);
        emit AddCrowdToken(msg.sender, _amount);
        return true;
    }

    function getToken(address _sender) public view override returns (uint256) {
        return crowdFundBalance[_sender].mul(tokenPerCrowdToken);
    }

    function withdrawToken() public override onlyEnd returns (bool) {
        require(isGetToken[msg.sender]==false,'withdrawToken: have withdraw !');
        uint256 balance = getToken(msg.sender);
        token.safeTransfer(msg.sender, balance);
        isGetToken[msg.sender]=true;
        emit WithdrawToken(msg.sender, balance);
        return true;
    }

    function withdrawCrowdToken(address _other)
        public
        override
        onlyOwner
        onlyEnd
        returns (bool)
    {
        crowdToken.safeTransfer(_other, crowdTokenBalance);
        crowdTokenBalance = 0;
        emit WithdrawCrowdToken(_other, crowdTokenBalance);
        return true;
    }
}