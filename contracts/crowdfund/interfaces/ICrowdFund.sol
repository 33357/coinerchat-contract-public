// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

interface ICrowdFund {
    event WithdrawToken(address sender, uint256 amount);
    event AddCrowdToken(address sender, uint256 amount);
    event WithdrawCrowdToken(address to, uint256 amount);

    function getToken(address _sender) external view returns (uint256);
    function addCrowdToken(uint256 _amount) external returns (bool);

    function withdrawToken() external returns (bool);
    function withdrawCrowdToken(address _other) external returns (bool);
}
