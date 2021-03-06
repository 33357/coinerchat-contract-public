// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

import "./IMessageService.sol";
import "./IMessageDB.sol";
import "./IMessageRouter.sol";
import "./AcceptedCaller.sol";

contract MesssageRouter is IMessageRouter, Ownable {
    address public messageServiceAddr;
    address public messageDBAddr;

    constructor(address _messageDBAddr) {
        messageDBAddr = _messageDBAddr;
    }

    function setMessageServiceAddr(address _messageServiceAddr)
        public
        onlyOwner
        returns (bool)
    {
        messageServiceAddr = _messageServiceAddr;
        return true;
    }

    function sendMessage(
        address _group,
        string memory _content,
        uint256 _typeNumber
    ) public override returns (bool) {
        IMessageService messageService = IMessageService(messageServiceAddr);
        (, uint256 messageId) =
            messageService.sendMessage(
                msg.sender,
                _group,
                _content,
                _typeNumber
            );
        emit SendMessage(msg.sender, _group, messageId);
        return true;
    }

    function groupAddrs() public view override returns (address[] memory) {
        IMessageDB messageDB = IMessageDB(messageDBAddr);
        return messageDB.groupAddrs();
    }

    function getGroupMessageIds(address _group)
        public
        view
        override
        returns (uint256[] memory)
    {
        IMessageDB messageDB = IMessageDB(messageDBAddr);
        return messageDB.getGroupMessageIds(_group);
    }

    function getGroupMessageIdsByLimit(
        address _group,
        uint256 _limit,
        uint256 _startIndex
    ) public view override returns (uint256[] memory) {
        IMessageDB messageDB = IMessageDB(messageDBAddr);
        return messageDB.getGroupMessageIdsByLimit(_group, _limit, _startIndex);
    }

    function getGroupMessageIdsLength(address _group)
        public
        view
        override
        returns (uint256)
    {
        IMessageDB messageDB = IMessageDB(messageDBAddr);
        return messageDB.getGroupMessageIdsLength(_group);
    }

    function getGroupPersons(address _group)
        public
        view
        override
        returns (address[] memory)
    {
        IMessageDB messageDB = IMessageDB(messageDBAddr);
        return messageDB.getGroupPersons(_group);
    }

    function personAddrs() public view override returns (address[] memory) {
        IMessageDB messageDB = IMessageDB(messageDBAddr);
        return messageDB.personAddrs();
    }

    function getPersonMessageIds(address _person)
        public
        view
        override
        returns (uint256[] memory)
    {
        IMessageDB messageDB = IMessageDB(messageDBAddr);
        return messageDB.getPersonMessageIds(_person);
    }

    function getPersonMessageIdsByLimit(
        address _person,
        uint256 _limit,
        uint256 _startIndex
    ) public view override returns (uint256[] memory) {
        IMessageDB messageDB = IMessageDB(messageDBAddr);
        return
            messageDB.getPersonMessageIdsByLimit(_person, _limit, _startIndex);
    }

    function getPersonMessageIdsLength(address _person)
        external
        view
        override
        returns (uint256)
    {
        IMessageDB messageDB = IMessageDB(messageDBAddr);
        return messageDB.getPersonMessageIdsLength(_person);
    }

    function getPersonGroups(address _person)
        public
        view
        override
        returns (address[] memory)
    {
        IMessageDB messageDB = IMessageDB(messageDBAddr);
        return messageDB.getPersonGroups(_person);
    }

    function messagesLength() public view override returns (uint256) {
        IMessageDB messageDB = IMessageDB(messageDBAddr);
        return messageDB.messagesLength();
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
        IMessageDB messageDB = IMessageDB(messageDBAddr);
        return messageDB.getMessage(_messageId);
    }

    function isAccepted() public view returns (bool) {
        IAcceptedCaller messageService = IAcceptedCaller(messageServiceAddr);
        if (messageService.isAcceptedCaller(address(this)) == false) {
            return false;
        }
        IAcceptedCaller messageDB = IAcceptedCaller(messageDBAddr);
        if (messageDB.isAcceptedCaller(address(this)) == false) {
            return false;
        }
        return true;
    }
}
