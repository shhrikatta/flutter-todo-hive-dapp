const TodoContract = artifacts.require("ToDoContract");

module.exports = function (deployer) {
    deployer.deploy(TodoContract);
};