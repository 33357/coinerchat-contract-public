// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

import "../libraries/@openzeppelin/contracts/access/Ownable.sol";
import "../libraries/@openzeppelin/contracts/math/SafeMath.sol";
import "./interfaces/IToken.sol";

// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract FucksToken is IToken, Ownable {
    using SafeMath for uint256;

    string public symbol;
    string public name;
    uint256 public decimals;
    uint256 public _totalSupply;
    uint256 public lockTime;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() {
        symbol = "HCT";
        name = "HecoChat Token";
        decimals = 18;
        _totalSupply = 1 * 10**10 * 10**18;
        balances[msg.sender] = _totalSupply;
        lockTime = block.timestamp + 4 * 365 * 24 * 60 * 60;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function addToken(address to, uint256 tokens)
        public
        override
        onlyOwner
        returns (bool)
    {
        require(block.timestamp >= lockTime);
        _totalSupply = _totalSupply.add(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(address(0), to, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view override returns (uint256) {
        return _totalSupply - balances[address(0)];
    }

    // ------------------------------------------------------------------------
    // Get the token balance for account tokenOwner
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner)
        public
        view
        override
        returns (uint256)
    {
        return balances[tokenOwner];
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to to account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint256 tokens)
        public
        override
        returns (bool)
    {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces
    // ------------------------------------------------------------------------
    function approve(address spender, uint256 tokens)
        public
        override
        returns (bool)
    {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Transfer tokens from the from account to the to account
    //
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the from account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(
        address from,
        address to,
        uint256 tokens
    ) public override returns (bool) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return allowed[tokenOwner][spender];
    }
}
