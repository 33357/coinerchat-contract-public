// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

import "./IMessageDB.sol";
import "./SafeMath.sol";
import "./AcceptedCaller.sol";

contract MessageDB is IMessageDB, AcceptedCaller {
    using SafeMath for uint256;

    struct Group {
        uint256[] messageIds;
        address[] persons;
        mapping(address => bool) havePerson;
        bool seted;
    }

    struct Person {
        uint256[] messageIds;
        address[] groups;
        mapping(address => bool) haveGroup;
        bool seted;
    }

    struct Message {
        address person;
        address group;
        string content;
        uint256 typeNumber;
        uint256 createDate;
    }

    mapping(address => Group) groups;
    mapping(address => Person) persons;
    mapping(uint256 => Message) messages;

    address[] private _groupAddrs;
    address[] private _personAddrs;
    uint256 private _messagesLength;


    function groupAddrs() public view override returns (address[] memory) {
        return _groupAddrs;
    }

    function addGroupMessageId(
        address _person,
        address _group,
        uint256 _messageId
    ) public override onlyAcceptedCaller(msg.sender) returns (bool) {
        if (groups[_group].seted == false) {
            groups[_group].seted = true;
            _groupAddrs.push(_group);
        }
        if (groups[_group].havePerson[_person] == false) {
            groups[_group].havePerson[_person] = true;
            groups[_group].persons.push(_person);
        }
        groups[_group].messageIds.push(_messageId);
        emit AddGroupMessageId(_group, _messageId);
        return true;
    }

    function getGroupMessageIds(address _group)
        public
        view
        override
        returns (uint256[] memory)
    {
        return groups[_group].messageIds;
    }

    function getGroupMessageIdsLength(address _group)
        public
        view
        override
        returns (uint256)
    {
        return groups[_group].messageIds.length;
    }

    function getGroupMessageIdsByLimit(
        address _group,
        uint256 _limit,
        uint256 _startIndex
    ) public view override returns (uint256[] memory) {
        uint256 len = groups[_group].messageIds.length;
        require(_startIndex <= len.sub(1), "startIndex over messageIds length");
        uint256[] memory arr;
        uint256 limit;
        if (_startIndex.add(_limit) > len.sub(1)) {
            limit = len.sub(_startIndex);
        } else {
            limit = _limit;
        }
        arr = new uint256[](limit);
        for (uint256 i = 0; i < limit; i++) {
            arr[i] = (groups[_group].messageIds[i.add(_startIndex)]);
        }
        return arr;
    }

    function getGroupPersons(address _group)
        public
        view
        override
        returns (address[] memory)
    {
        return groups[_group].persons;
    }

    function personAddrs() public view override returns (address[] memory) {
        return _personAddrs;
    }

    function addPersonMessageId(
        address _group,
        address _person,
        uint256 _messageId
    ) public override onlyAcceptedCaller(msg.sender) returns (bool) {
        if (persons[_person].seted == false) {
            persons[_person].seted = true;
            _personAddrs.push(_person);
        }
        if (persons[_person].haveGroup[_group] == false) {
            persons[_person].haveGroup[_group] = true;
            persons[_person].groups.push(_group);
        }
        persons[_person].messageIds.push(_messageId);
        emit AddPersonMessageId(_person, _messageId);
        return true;
    }

    function getPersonMessageIds(address _person)
        public
        view
        override
        returns (uint256[] memory)
    {
        return (persons[_person].messageIds);
    }

    function getPersonMessageIdsLength(address _person)
        public
        view
        override
        returns (uint256)
    {
        return persons[_person].messageIds.length;
    }

    function getPersonMessageIdsByLimit(
        address _person,
        uint256 _limit,
        uint256 _startIndex
    ) public view override returns (uint256[] memory) {
        uint256 len = persons[_person].messageIds.length;
        require(_startIndex <= len.sub(1), "startIndex over messageIds length");
        uint256[] memory arr;
        uint256 limit;
        if (_startIndex.add(_limit) > len.sub(1)) {
            limit = len.sub(_startIndex);
        } else {
            limit = _limit;
        }
        arr = new uint256[](limit);
        for (uint256 i = 0; i < limit; i++) {
            arr[i] = (persons[_person].messageIds[i.add(_startIndex)]);
        }
        return arr;
    }

    function getPersonGroups(address _person)
        public
        view
        override
        returns (address[] memory)
    {
        return persons[_person].groups;
    }

    function messagesLength() public view override returns (uint256) {
        return _messagesLength;
    }

   function createMessage(
        address _person,
        address _group,
        string memory _content,
        uint256 _typeNumber
    ) public override onlyAcceptedCaller(msg.sender) returns (bool, uint256) {
        uint256 messageId = _messagesLength;
        _messagesLength = _messagesLength.add(1);
        messages[messageId] = Message(
            _person,
            _group,
            _content,
            _typeNumber,
            block.timestamp
        );
        emit MessageCreated(
            messageId,
            _person,
            _group,
            _content,
            _typeNumber,
            block.timestamp
        );
        return (true, messageId);
    }  

    function getMessage(uint256 _messageId)
        public
        view
        override
        returns (
            address,
            address,
            string memory,
            uint256,
            uint256
        )
    {
        return (
            messages[_messageId].person,
            messages[_messageId].group,
            messages[_messageId].content,
            messages[_messageId].typeNumber,
            messages[_messageId].createDate
        );
    }
}
