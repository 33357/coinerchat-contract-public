// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

import "../../db/message/interfaces/IMessageDB.sol";
import "./interfaces/IMessageService.sol";
import "../../libraries/AcceptedCaller.sol";

contract MessageService is IMessageService, AcceptedCaller {
    address public messageDBAddr;

    constructor (address _messageDBAddr,address _messageRouterAddr){
        messageDBAddr=_messageDBAddr;
        super.acceptCaller(_messageRouterAddr);
    }

    function sendMessage(
        address _person,
        address _group,
        string memory _content,
        uint256 _typeNumber
    ) public override onlyAcceptedCaller(msg.sender) returns (bool,uint256) {
        IMessageDB messageDB = IMessageDB(messageDBAddr);
        (, uint256 messageId) =
            messageDB.createMessage(
                _person,
                _group,
                _content,
                _typeNumber
            );
        messageDB.addGroupMessageId(_person,_group, messageId);
        messageDB.addPersonMessageId(_group,_person, messageId);
        return (true,messageId);
    }

    function isAccepted() public view returns (bool) {
        IAcceptedCaller messageDB = IAcceptedCaller(messageDBAddr);
        if(messageDB.isAcceptedCaller(address(this))==false){
            return false;
        }
        return true;
    }
}
