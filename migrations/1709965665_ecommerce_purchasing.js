const ecommercePurchasing = artifacts.require("EcommercePurchasing");
module.exports = function (_deployer) {
    // Use deployer to state migration tasks.
    _deployer.deploy(ecommercePurchasing);
};
