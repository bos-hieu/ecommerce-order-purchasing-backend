const helloWorld = artifacts.require("HelloWorld");

module.exports = function(_deployer) {
    // Use deployer to state migration tasks.
    _deployer.deploy(helloWorld);
};
