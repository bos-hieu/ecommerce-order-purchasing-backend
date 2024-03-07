const EcomercePurchasing = artifacts.require("EcomercePurchasing");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("EcomercePurchasing", function (/* accounts */) {
  it("should assert true", async function () {
    await EcomercePurchasing.deployed();
    return assert.isTrue(true);
  });
});
