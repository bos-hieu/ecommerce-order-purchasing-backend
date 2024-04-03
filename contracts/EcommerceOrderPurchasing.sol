/*
  @class: CCMP 603 - Introduction to Smart Contracts - Assignment 2
  @title: E-commerce Order Purchasing Smart Contract
  @member: Le, Trung Hieu
  @date: March 10, 2024
  @notice: This contract allows customers to purchase products from a retailer.
  @dev: The contract is implemented using Solidity version greater than 0.8.13

  This contract is for educational purposes only. It is not intended for use in a production environment.
  The aim of this contract is to not only complete the assignment but also try to implement as many of Solidity's features as possible, including
  the use of libraries, interfaces, and abstract contracts.
  There are some points that should be considered before reviewing the code:
  - The EcommerceOrderPurchasing is the main contract of the EcommerceOrderPurchasing system.
  - The EcommerceOrderPurchasingAbstract is an abstract contract that defines the functions of EcommerceOrderPurchasing.
  - The EcommerceOrderPurchasingImplement is a contract that implements the functions of EcommerceOrderPurchasing.
  - The Products contract is used to manage the products.
  - The Orders contract is used to manage the orders.
  - The library Utils contains utility functions for the EcommerceOrderPurchasing system.
  - Because there is no double type in Solidity, the uint256 type is used to represent any double type that is defined in Assignment 1.
  - Because there is no print function in Solidity, all print statements in Assignment 1 are replaced by the return statement.
  - The number of products is fixed to 3, and the product information is hardcoded in the contract.
  - The retailer is set by the deployer of the contract.

  I am looking forward to receiving your feedback. Thank you for your time and consideration.
*/
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

// Utils is a library that contains utility functions for the EcommerceOrderPurchasing system
// The functions include uint8ToString, concatTwoStrings, and compareTwoStrings
// reference: https://www.geeksforgeeks.org/solidity-libraries/
library Utils {
    // uint8ToString is a utility function that converts a uint8 to a string
    // @param number (uint8) - The number to be converted
    // @return (string) - The string of the number
    function uint8ToString(uint8 number) internal pure returns (string memory) {
        // Convert uint8 to ASCII (single-character string)
        // In ASCII, the digits 0-9 have the code points 48-57
        // So, to convert a digit to its ASCII code, we can add 48 to the digit
        bytes1 b = bytes1(uint8(number) + 48);

        // Convert ASCII to string
        return string(abi.encodePacked(b));
    }

    // concatTwoStrings is a utility function that concatenates two strings
    // @param a (string) - The first string
    // @param b (string) - The second string
    // @return (string) - The concatenated string
    function concatTwoStrings(string memory a, string memory b)
    internal
    pure
    returns (string memory)
    {
        return string(abi.encodePacked(a, b));
    }

    // compareTwoStrings is a utility function that compares two strings
    // @param a (string) - The first string
    // @param b (string) - The second string
    // @return (bool) - The result of the comparison
    // reference: https://www.educative.io/answers/how-to-compare-two-strings-in-solidity
    function compareTwoStrings(string memory a, string memory b)
    internal
    pure
    returns (bool)
    {
        if (bytes(a).length != bytes(b).length) {
            return false;
        }
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
}

// Orders contract is used to manage the orders
contract Orders {
    // _orders is a private mapping that stores the orders
    mapping(string => Order) private _orders;

    // orderIDSequence is a private variable that stores the sequence of order id
    uint8 private orderIDSequence = 1;

    // ORDER_ID_PREFIX is a private string constant that represents the prefix of an order id
    string private constant ORDER_ID_PREFIX = "order_id_";

    // OrderStatus is an enum type that represents the status of an order
    enum OrderStatus {
        PaymentPending, // default status
        PaymentFailed, // status when payment failed
        New, // status when a new order is created
        Canceled, // status when an order is canceled
        PartialRefunded // status when an order is partially refunded
    }

    // Order is a struct type that represents the information of an order
    struct Order {
        string id; // order id
        string productID; // product id
        uint256 amount; // the amount of the order, in this case, it is the price of the product.
        address payable customerAddress; // the customer address
        OrderStatus status; // the status of the order
        uint256 refundedAmount; // the refunded amount of the order
    }

    // generateOrderID is a private function that generates an order id
    // @return (STRING) - The order id
    function generateOrderID() private returns (string memory) {
        // Convert orderIDSequence to string
        string memory orderIDSequenceStr = Utils.uint8ToString(orderIDSequence);

        // Concatenate ORDER_ID_PREFIX and orderIDSequenceStr to create the order id
        // For example, if orderIDSequence is 1, then the order id will be "order_id_1"
        string memory newOrderID = Utils.concatTwoStrings(
            ORDER_ID_PREFIX,
            orderIDSequenceStr
        );

        // Increment orderIDSequence for the next order
        orderIDSequence++;

        return newOrderID;
    }

    // addOrderToOrders is a internal function that adds an order to the _orders
    // @param order (ORDER) - The order to be added
    function addOrderToOrders(Order memory order) internal {
        _orders[order.id] = order;
    }

    // getOrder is a internal function that gets an order from the _orders
    function getOrder(string memory orderID)
    internal
    view
    returns (Order memory)
    {
        // Get the order from the _orders
        Order memory order = _orders[orderID];

        // Check if the order is found
        // The require function is used to check if the condition is true. If the condition is false, then the function
        // will stop and revert the transaction as well as return the defined error message.
        // For example, if the order is not found, then the function will stop and return the error message "Order is not found"
        require(bytes(order.id).length > 0, "Order is not found");

        return order;
    }

    // createOrder is a private function that creates an order.
    // @param productID (string) - The product id
    // @param amount (uint256) - The amount of the product
    // @param customerAddress (address) - The customer address
    // @return (Order) - The order
    function createOrder(
        string memory productID,
        uint256 amount,
        address payable customerAddress
    ) internal returns (Order memory) {
        Order memory order;
        order.id = generateOrderID();
        order.productID = productID;
        order.amount = amount;
        order.customerAddress = customerAddress;
        order.status = OrderStatus.PaymentPending;
        order.refundedAmount = 0;
        return order;
    }

    // updateOrderStatus is a private function that updates the status of an order.
    // @param orderID (string) - The order id
    // @param newStatus (OrderStatus) - The new status of the order
    function updateOrderStatus(string memory orderID, OrderStatus newStatus)
    internal
    {
        Order storage order = _orders[orderID];

        // Update the status of the order
        // The storage keyword is used to store the value in the storage of the contract. Therefore, the value will be
        // updated in the _orders.
        order.status = newStatus;
    }
}

// Products contract is used to manage the products
contract Products {
    // Product is a struct type that represents the information of a product
    struct Product {
        string id; // the id of the product
        string name; // the name of the product
        string description; // the description of the product
        string image; // the image link of the product
        uint256 price; // the price of the product
    }

    // listProducts is a private variable that stores the list of products
    Product[3] internal listProducts;

    constructor() {
        // Set the list of products
        setListProducts();
    }

    // setListProducts is a private function that sets the list of products
    function setListProducts() private {
        listProducts[0] = Product(
            "product_id_1", // product id
            "Product 1", // product name
            "Description 1", // product description
            "image_1", // product image
            1e18 // product price in wei, is equal to 1 ether
        );
        listProducts[1] = Product(
            "product_id_2", // product id
            "Product 2", // product name
            "Description 2", // product description
            "image_2", // product image
            2e18 // product price in wei, is equal to 2 ether
        );
        listProducts[2] = Product(
            "product_id_3",
            "Product 3",
            "Description 3",
            "image_3",
            3e18 // in wei, is equal to 3 ether
        );
    }

    // getProductFromListProducts is a private function that gets a product from the list of products
    // @param productID (string) - The product id
    // @return (Product) - The product
    function getProductFromListProducts(string memory productID)
    internal
    view
    returns (Product memory)
    {
        for (uint256 i = 0; i < listProducts.length; i++) {
            // Check if the product id is equal to the productID
            if (Utils.compareTwoStrings(listProducts[i].id, productID)) {
                return listProducts[i];
            }
        }

        // Return an empty product if the product is not found
        return Product("", "", "", "", 0);
    }
}

// EcommerceOrderPurchasingAbstract is an interface that defines the functions of EcommerceOrderPurchasing
// It inherits from Products
abstract contract EcommerceOrderPurchasingAbstract is Products {
    // getProducts is a function that returns the list of products
    // @return (Product[3]) - The list of products
    function getProducts() public view virtual returns (Product[3] memory);

    // placeOrder is a function that is used to place an order
    // @param productID (string) - The product id
    // @param amount (uint256) - The amount of order, in this case, it is the price of the product
    // @param customer (address) - The customer address
    // @return (string) - The message of the result
    function placeOrder(
        string memory,
        uint256,
        address payable
    ) external payable virtual returns (string memory);

    // cancelOrder is a function that is used to cancel an order
    // @param orderID (string) - The order id
    // @return (string) - The message of the result
    function cancelOrder(string memory)
    public
    payable
    virtual
    returns (string memory);

    // issueRefund is a function that is used to issue a refund
    // @param orderID (string) - The order id
    // @param refundAmount (uint256) - The refund amount
    function issueRefund(string memory, uint256)
    public
    payable
    virtual
    returns (string memory, bool);

    // setRetailer is a function that is used to set the retailer
    function setRetailer(address payable) public virtual;
}

// EcommerceOrderPurchasingImplement is a contract that implements the functions of EcommerceOrderPurchasing
// It inherits from Products, Orders, and EcommerceOrderPurchasingAbstract
contract EcommerceOrderPurchasingImplement is
Products,
Orders,
EcommerceOrderPurchasingAbstract
{
    // retailer is a private variable that stores the retailer address
    // The retailer is the address that receives the payment from the customer when an order is placed successfully and
    // issues a refund when an order is canceled or partially refunded.
    // The retailer is set by the setRetailer function.
    address payable retailer;

    // setRetailer is an implementation of the setRetailer function of EcommerceOrderPurchasingAbstract
    // @param initRetailer (address) - The retailer address to be set
    function setRetailer(address payable initRetailer) public override {
        retailer = initRetailer;
    }

    // getProducts is an implementation of the getProducts function of EcommerceOrderPurchasingAbstract
    // @return (Product[3]) - The list of products
    function getProducts() public view override returns (Product[3] memory) {
        return listProducts;
    }

    // placeOrder is an implementation of the placeOrder function of EcommerceOrderPurchasingAbstract
    // @param productID (string) - The product id
    // @param amount (uint256) - The amount of the product
    // @param customer (address) - The customer address
    // @return (string) - The message of the result
    function placeOrder(
        string memory productID,
        uint256 amount,
        address payable customer
    ) external payable override returns (string memory) {
        // Step 1: Check if the product is valid.
        Product memory product = getProductFromListProducts(productID);
        // If the product.id is equal to "", then the product is invalid.
        if (Utils.compareTwoStrings(product.id, "")) {
            return "Product is invalid";
        }

        // Step 1.1: Check if the amount is equal to the price of the product.
        // Note: this step is not mentioned in the assignment 1, but I think it is necessary to check if the amount is
        // equal to the price of the product. Therefore, I added this step to make the code more secure.
        if (product.price != amount) {
            return "Amount is not equal to price of product";
        }

        // Step 2: Check if the customer has enough balance.
        if (customer.balance < amount) {
            return "Not enough balance";
        }

        // Step 3: Create an order.
        Order memory order = createOrder(productID, amount, customer);
        addOrderToOrders(order);

        // Step 4: Issue a transaction from customer to retailer.
        bool sent = sendEther(retailer, amount);
        if (!sent) {
            updateOrderStatus(order.id, OrderStatus.PaymentFailed);
            return "Transaction failed";
        }

        updateOrderStatus(order.id, OrderStatus.New);
        return
            Utils.concatTwoStrings(
            "You have successfully purchased an order with id ",
            order.id
        );
    }

    // cancelOrder is an implementation of the cancelOrder function of EcommerceOrderPurchasingAbstract
    // @param orderID (string) - The order id
    // @return (string) - The message of the result
    function cancelOrder(string memory orderID)
    public
    payable
    override
    returns (string memory)
    {
        // Step 1: Get Order info from order id.
        Order memory order = getOrder(orderID);

        // Step 2: Check if the order is already canceled.
        if (order.status == OrderStatus.Canceled) {
            return "This order is already canceled";
        }

        // Step 3: Proceed to cancel the order.
        bool canCancelOrder = (order.status == OrderStatus.New ||
            order.status == OrderStatus.PartialRefunded);
        if (!canCancelOrder) {
            return "The order status is invalid";
        }

        // Step 3.1: Calculate the refund amount.
        uint256 refund_amount = order.amount - order.refundedAmount;

        // Step 3.2: Check if the refund amount is 0 then update the order status to canceled.
        if (refund_amount == 0) {
            updateOrderStatus(order.id, OrderStatus.Canceled);
            return "You successfully canceled your order";
        }

        // Step 3.3: Issue a refund and update the order status to canceled.
        (string memory refundMessage, bool isRefundSuccess) = issueRefund(
            orderID,
            refund_amount
        );
        if (isRefundSuccess) {
            updateOrderStatus(order.id, OrderStatus.Canceled);
            return "You successfully canceled your order";
        }
        return refundMessage;
    }

    // issueRefund is an implementation of the issueRefund function of EcommerceOrderPurchasingAbstract
    // @param orderID (string) - The order id
    // @param refundAmount (uint256) - The refund amount
    function issueRefund(string memory orderID, uint256 refundAmount)
    public
    payable
    override
    returns (string memory, bool)
    {
        // Step 1: Get order info from order id.
        Order memory order = getOrder(orderID);

        // Step 2: Calculate max refund amount.
        uint256 maxRefundAmount = order.amount - order.refundedAmount;

        // Step 3: Compare max refund amount with refund amount
        bool isRefundSuccess = false;
        if (refundAmount > maxRefundAmount) {
            // convert maxRefundAmount to string
            string memory maxRefundAmountStr = string(
                abi.encodePacked(maxRefundAmount)
            );
            return (
                Utils.concatTwoStrings(
                "Refund amount is greater than: ",
                maxRefundAmountStr
            ),
                isRefundSuccess
            );
        }

        // Step 4: Issue a refund transaction.
        bool sent = sendEther(order.customerAddress, refundAmount);
        if (!sent) {
            return ("Transaction failed", isRefundSuccess);
        }

        isRefundSuccess = true;
        return ("You successfully refunded your payment", isRefundSuccess);
    }

    // sendEther is a private function that sends ether to an address
    // @param to (address) - The address to send ether to
    // @param value (uint256) - The value of ether to send
    // @return (bool) - The result of the transaction (true or false)
    function sendEther(address payable to, uint256 value)
    public
    payable
    returns (bool)
    {
        (bool sent, ) = to.call{value: value}("");
        return sent;
    }
}

// EcommerceOrderPurchasing is the main contract of the EcommerceOrderPurchasing system.
// It inherits from Products and Orders.
// I used the contract EcommerceOrderPurchasingImplement to implement the functions of EcommerceOrderPurchasingAbstract.
// This helps to separate the interface and the implementation of the EcommerceOrderPurchasing system.
// Therefore, ensuring the encapsulation of the business logic.
contract EcommerceOrderPurchasing is Products, Orders {
    // EcommerceOrderPurchasing is an instance of EcommerceOrderPurchasingAbstract that is used to call the functions of EcommerceOrderPurchasingImplement
    EcommerceOrderPurchasingAbstract ecommerceOrderPurchasing =
    new EcommerceOrderPurchasingImplement();

    event PlaceOrder(string message);
    event CancelOrder(string message);
    event IssueRefund(string message);

    constructor() {
        // Set the retailer from the deployer of the contract
        ecommerceOrderPurchasing.setRetailer(payable(msg.sender));
    }

    // getProducts is a public function that returns the list of products
    // It calls the getProducts function of EcommerceOrderPurchasing
    // @return (Product[3]) - The list of products
    function getProducts() public view returns (Product[3] memory) {
        return ecommerceOrderPurchasing.getProducts();
    }

    // placeOrder is a public function that is used to place an order
    // It calls the placeOrder function of EcommerceOrderPurchasing
    // @param productId (string) - The product id
    // @return (string) - The message of the result
    function placeOrder(string memory productId)
    public
    payable
    returns (string memory)
    {
        // the {value: msg.value} is used to send the value of the transaction to the placeOrder function of
        // EcommerceOrderPurchasing. Without this, the transaction maybe failed or the transaction will be sent to address's
        // contract instead of the address's retailer.
        string memory message = ecommerceOrderPurchasing.placeOrder{
                value: msg.value
            }(productId, msg.value, payable(msg.sender));
        emit PlaceOrder(message);
        return message;
    }

    // cancelOrder is a public function that is used to cancel an order.
    // It calls the cancelOrder function of EcommerceOrderPurchasing.
    // This function should be called by the retailer.
    // @param orderID (string) - The order id
    // @return (string) - The message of the result
    function cancelOrder(string memory orderID)
    public
    payable
    returns (string memory)
    {
        // the {value: msg.value} is used to send the value of the transaction to the cancelOrder function of
        // EcommerceOrderPurchasing. Without this, the transaction maybe failed or the transaction will be sent to address's
        // contract instead of the address's customer.
        string memory message = ecommerceOrderPurchasing.cancelOrder{value: msg.value}(orderID);
        emit CancelOrder(message);
        return message;
    }

    // issueRefund is a public function that is used to issue a refund.
    // It calls the issueRefund function of EcommerceOrderPurchasing.
    // This function should be called by the retailer.
    // @param orderID (string) - The order id
    // @return (string) - The message of the result
    function issueRefund(string memory orderID)
    public
    payable
    returns (string memory)
    {
        // the {value: msg.value} is used to send the value of the transaction to the issueRefund function of
        // EcommerceOrderPurchasing. Without this, the transaction maybe failed or the transaction will be sent to address's
        // contract instead of the address's customer.
        (string memory refundMessage, ) = ecommerceOrderPurchasing.issueRefund{
                value: msg.value
            }(orderID, msg.value);
        emit IssueRefund(refundMessage);
        return refundMessage;
    }
}
