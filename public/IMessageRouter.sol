// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

interface IMessageRouter {
    event SendMessage(
        address indexed person,
        address indexed group,
        uint256 messageId
    );

    function sendMessage(
        address _group,
        string memory _content,
        uint256 _typeNumber
    ) external returns (bool);

    function groupAddrs() external view returns (address[] memory);

    function getGroupMessageIds(address _group)
        external
        view
        returns (uint256[] memory);

    function getGroupMessageIdsByLimit(
        address _group,
        uint256 _limit,
        uint256 _startIndex
    ) external view returns (uint256[] memory);
    
    function getGroupMessageIdsLength(address _group)
        external
        view
        returns (uint256);

    function getGroupPersons(address _group)
        external
        view
        returns (address[] memory);

    function personAddrs() external view returns (address[] memory);

    function getPersonMessageIds(address _person)
        external
        view
        returns (uint256[] memory);

    function getPersonMessageIdsByLimit(
        address _person,
        uint256 _limit,
        uint256 _startIndex
    ) external view returns (uint256[] memory);

    function getPersonMessageIdsLength(address _person)
        external
        view
        returns (uint256);

    function getPersonGroups(address _person)
        external
        view
        returns (address[] memory);

    function messagesLength()external view returns (uint256);

    function getMessage(uint256 messageId)
        external
        view
        returns (
            address,
            address,
            string memory,
            uint256,
            uint256
        );
}
