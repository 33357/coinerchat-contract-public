// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

import "./IMessageDB.sol";
import "./IMessageService.sol";
import "./AcceptedCaller.sol";
import "./IChatPool.sol";

contract MessageService is IMessageService, AcceptedCaller {
    address public messageDBAddr;
    address public chatPoolAddr;

    constructor (address _messageDBAddr,address _messageRouterAddr,address _chatPoolAddr){
        messageDBAddr=_messageDBAddr;
        chatPoolAddr=_chatPoolAddr;
        super.acceptCaller(_messageRouterAddr);
    }

    function setChatPoolAddr(address _chatPoolAddr)
        public
        onlyOwner
        returns (bool)
    {
        chatPoolAddr = _chatPoolAddr;
        return true;
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
        if(chatPoolAddr!=address(0)){
            IChatPool chatPool=IChatPool(chatPoolAddr);
            chatPool.min(_person, _group);
        }
        return (true,messageId);
    }

    function isAccepted() public view returns (bool) {
        IAcceptedCaller messageDB = IAcceptedCaller(messageDBAddr);
        if(messageDB.isAcceptedCaller(address(this))==false){
            return false;
        }
        IAcceptedCaller chatPool = IAcceptedCaller(chatPoolAddr);
        if(chatPool.isAcceptedCaller(address(this))==false){
            return false;
        }
        return true;
    }
}
