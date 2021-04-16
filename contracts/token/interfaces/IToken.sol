// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

interface IToken {

    event Transfer(address indexed _from, address indexed _to, uint256 _tokens);
    event Approval(
        address indexed _tokenOwner,
        address indexed _spender,
        uint256 _tokens
    );
    event AddLockPool(address indexed _pool);
    event RemoveLockPool(address indexed _pool);

    function totalCirculation() external view returns (uint256);

    function getLockPoolAddrs() external view returns (address[] memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _tokenOwner) external view returns (uint256);

    function addLockPool(address _pool) external returns (bool);

    function removeLockPool(address _pool) external returns (bool);

    function allowance(address _tokenOwner, address _spender)
        external
        view
        returns (uint256);

    function transfer(address _to, uint256 _tokens) external returns (bool);

    function approve(address _spender, uint256 _tokens) external returns (bool);

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokens
    ) external returns (bool);

    function mint(address _to, uint256 _tokens) external returns (bool);


}
