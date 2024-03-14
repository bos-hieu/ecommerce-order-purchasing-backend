const ecommerceOrderPurchasing = artifacts.require("./EcommerceOrderPurchasing.sol");
module.exports = function (_deployer) {
    _deployer.deploy(ecommerceOrderPurchasing);
};
