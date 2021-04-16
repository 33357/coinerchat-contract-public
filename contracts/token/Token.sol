// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

import "../libraries/@openzeppelin/contracts/access/Ownable.sol";
import "../libraries/@openzeppelin/contracts/math/SafeMath.sol";
import "./interfaces/IToken.sol";

// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract Token is IToken, Ownable {
    using SafeMath for uint256;

    struct LockPool {
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
    mapping(address => LockPool) lockPools;

    address[] private lockPoolAddrs;

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() {
        symbol = "HCHAT";
        name = "HecoCoinerChatToken";
        decimals = 18;
        _totalSupply = 100 * 10**8 * 10**18;
        balances[msg.sender] = _totalSupply;
        lockTime = block.timestamp + 4 * 365 * 24 * 60 * 60;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function mint(address _to, uint256 _tokens)
        public
        override
        onlyOwner
        returns (bool)
    {
        require(block.timestamp >= lockTime, "mint: at lockTime!");
        require(
            _tokens <= _totalSupply.mul(5).div(100),
            "mint: over 5% of the totalSupply!"
        );
        _totalSupply = _totalSupply.add(_tokens);
        balances[_to] = balances[_to].add(_tokens);
        lockTime = block.timestamp + 1 * 365 * 24 * 60 * 60;
        emit Transfer(address(0), _to, _tokens);
        return true;
    }

    function getLockPoolAddrs() public view override returns (address[] memory) {
        uint256 len = lockPoolAddrs.length;
        uint256 _len = 0;
        address[] memory arr = new address[](len);
        for (uint256 i = 0; i < len; i++) {
            if (lockPools[lockPoolAddrs[i]].have == true) {
                arr[_len] = lockPoolAddrs[i];
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

    function addLockPool(address _pool) public override onlyOwner returns (bool) {
        require(lockPools[_pool].have == false, "removeLockPool: is setedPool!");
        if (lockPools[_pool].seted == false) {
            lockPools[_pool].seted = true;
            lockPoolAddrs.push(_pool);
        }
        lockPools[_pool].have = true;
        emit AddLockPool(_pool);
        return true;
    }

    function removeLockPool(address _pool)
        public
        override
        onlyOwner
        returns (bool)
    {
        require(lockPools[_pool].have == true, "removeLockPool: not setedPool!");
        lockPools[_pool].have = false;
        emit RemoveLockPool(_pool);
        return true;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply - balances[address(0)];
    }

    function totalCirculation() public view override returns (uint256) {
        uint256 len = lockPoolAddrs.length;
        uint256 __totalCirculation = totalSupply();
        if (len == 0) {
            return __totalCirculation;
        } else {
            for (uint256 i = 0; i < len; i++) {
                if (lockPools[lockPoolAddrs[i]].have == true) {
                    __totalCirculation =
                        __totalCirculation -
                        balances[lockPoolAddrs[i]];
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
