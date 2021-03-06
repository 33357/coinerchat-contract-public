// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

interface IMessageDB {
    event AddGroupMessageId(
        address indexed group,
        uint256 indexed messageId
    );
    event AddPersonMessageId(
        address indexed person,
        uint256 indexed messageId
    );
    event MessageCreated(
        uint256 indexed messageId,
        address indexed sender,
        address indexed group,
        string content,
        uint256 typeNumber,
        uint256 createDate
    );

    function groupAddrs() external view returns (address[] memory);

    function addGroupMessageId(
        address _person,
        address _group,
        uint256 _messageId
    ) external returns (bool);

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

    function addPersonMessageId(
        address _group,
        address _person,
        uint256 _messageId
    ) external returns (bool);

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

    function messagesLength() external view returns (uint256);

    function createMessage(
        address _person,
        address _group,
        string memory _content,
        uint256 _typeNumber
    ) external returns (bool, uint256);

    function getMessage(uint256 _messageId)
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
