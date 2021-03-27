// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

interface IToken {

    event Transfer(address indexed _from, address indexed _to, uint256 _tokens);
    event Approval(
        address indexed _tokenOwner,
        address indexed _spender,
        uint256 _tokens
    );
    event AddToken(address indexed _from, address indexed _to, uint256 _tokens);

    function totalCirculation() external view returns (uint256);

    function getPoolAddrs() external view returns (address[] memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _tokenOwner) external view returns (uint256);

    function addPool(address _pool) external returns (bool);

    function removePool(address _pool) external returns (bool);

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

    function addToken(address _to, uint256 _tokens) external returns (bool);


}
