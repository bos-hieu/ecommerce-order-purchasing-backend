const EcommercePurchasing = artifacts.require("EcommercePurchasing");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("EcommercePurchasing", function (/* accounts */) {
  it("should assert true", async function () {
    await EcommercePurchasing.deployed();
    return assert.isTrue(true);
  });
});
