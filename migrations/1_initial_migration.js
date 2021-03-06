
const MessageDB = artifacts.require("./db/message/MessageDB");
const MessageService = artifacts.require("MessageService");
const MessageRouter = artifacts.require("MessageRouter");

module.exports = function (deployer) {
  deployer.deploy(MessageDB);
  deployer.deploy(MessageRouter);
  deployer.deploy(MessageService);
};
