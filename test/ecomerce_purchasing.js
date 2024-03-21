const Web3 = require("web3");
const EcommercePurchasing = artifacts.require("EcommercePurchasing");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("EcommercePurchasing", function (/* accounts */) {
    // it("should assert true", async function () {
    //     await EcommercePurchasing.deployed();
    //     return assert.isTrue(true);
    // });
    //
    it("length of products should equal to 3", async function () {
        let instance = await EcommercePurchasing.deployed();
        let products = await instance.getProducts();
        console.log(products);
        assert.equal(products.length, 3);
    });

    it("should place an order", async function () {
        let instance = await EcommercePurchasing.deployed();
        let products = await instance.getProducts();
        let product = products[0];
        let result = await instance.placeOrder(product.id, {
            value: Web3.utils.toWei(product.price, "wei"),
            from: "0xFdE41Cde2114265Ff1E51d2BdA535b261163cbD9"
        });
        console.log(result);
        assert.equal(result.receipt.status, true);
    });
});
