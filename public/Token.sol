// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./IToken.sol";

// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract Token is IToken, Ownable {
    using SafeMath for uint256;

    struct Pool {
        bool have;
        bool seted;
    }

    string public symbol;
    string public name;
    uint256 public decimals;
    uint256 public _totalSupply;
    uint256 public lockTime;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => Pool) pools;

    address[] private poolAddrs;

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() {
        symbol = "HCT";
        name = "HecoChat Token";
        decimals = 18;
        _totalSupply = 100 * 10**8 * 10**18;
        balances[msg.sender] = _totalSupply;
        lockTime = block.timestamp + 4 * 365 * 24 * 60 * 60;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function addToken(address _to, uint256 _tokens)
        public
        override
        onlyOwner
        returns (bool)
    {
        require(block.timestamp >= lockTime, "addToken: at lockTime!");
        require(
            _tokens <= _totalSupply.mul(5).div(100),
            "addToken: over 5% of the totalSupply!"
        );
        _totalSupply = _totalSupply.add(_tokens);
        balances[_to] = balances[_to].add(_tokens);
        lockTime = block.timestamp + 1 * 365 * 24 * 60 * 60;
        emit AddToken(address(0), _to, _tokens);
        return true;
    }

    function getPoolAddrs() public view override returns (address[] memory) {
        uint256 len = poolAddrs.length;
        uint256 _len = 0;
        address[] memory arr = new address[](len);
        for (uint256 i = 0; i < len; i++) {
            if (pools[poolAddrs[i]].have == true) {
                arr[_len] = poolAddrs[i];
                _len = _len + 1;
            }
        }
        address[] memory _arr = new address[](_len);
        if (_len == 0) {
            return _arr;
        } else {
            for (uint256 i = 0; i < _len; i++) {
                _arr[i] = arr[i];
            }
            return _arr;
        }
    }

    function addPool(address _pool) public override onlyOwner returns (bool) {
        require(pools[_pool].have == false, "removePool: is setedPool!");
        if (pools[_pool].seted == false) {
            pools[_pool].seted = true;
            poolAddrs.push(_pool);
        }
        pools[_pool].have = true;
        return true;
    }

    function removePool(address _pool)
        public
        override
        onlyOwner
        returns (bool)
    {
        require(pools[_pool].have == true, "removePool: not setedPool!");
        pools[_pool].have = false;
        return true;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply - balances[address(0)];
    }

    function totalCirculation() public view override returns (uint256) {
        uint256 len = poolAddrs.length;
        uint256 __totalCirculation = totalSupply();
        if (len == 0) {
            return __totalCirculation;
        } else {
            for (uint256 i = 0; i < len; i++) {
                if (pools[poolAddrs[i]].have == true) {
                    __totalCirculation =
                        __totalCirculation -
                        balances[poolAddrs[i]];
                }
            }
            return __totalCirculation;
        }
    }

    // ------------------------------------------------------------------------
    // Get the token balance for account tokenOwner
    // ------------------------------------------------------------------------
    function balanceOf(address _tokenOwner)
        public
        view
        override
        returns (uint256)
    {
        return balances[_tokenOwner];
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to to account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address _to, uint256 _tokens)
        public
        override
        returns (bool)
    {
        balances[msg.sender] = balances[msg.sender].sub(_tokens);
        balances[_to] = balances[_to].add(_tokens);
        emit Transfer(msg.sender, _to, _tokens);
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
    function approve(address _spender, uint256 _tokens)
        public
        override
        returns (bool)
    {
        allowed[msg.sender][_spender] = _tokens;
        emit Approval(msg.sender, _spender, _tokens);
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
        address _from,
        address _to,
        uint256 _tokens
    ) public override returns (bool) {
        balances[_from] = balances[_from].sub(_tokens);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_tokens);
        balances[_to] = balances[_to].add(_tokens);
        emit Transfer(_from, _to, _tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address _tokenOwner, address _spender)
        public
        view
        override
        returns (uint256)
    {
        return allowed[_tokenOwner][_spender];
    }
}
