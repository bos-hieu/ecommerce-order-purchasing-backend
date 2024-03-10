// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;


// reference: https://docs.soliditylang.org/en/latest/style-guide.html
// Orders contract is used to manage the orders
contract Orders {
    mapping(string => Order) private _orders;
    uint8 orderIDSequence = 1;
    string constant ORDER_ID_PREFIX = "order_id_";

    // OrderStatus is an enum type that represents the status of an order
    enum OrderStatus {
        PaymentPending,
        PaymentFailed,
        New,
        Canceled,
        PartialRefunded
    }

    // Order is a struct type that represents the information of an order
    struct Order {
        string id;
        string productID;
        uint256 amount; // double in frontend
        address payable customerAddress;
        OrderStatus status;
        uint256 refundedAmount; // double in frontend
    }

    // uint8ToString is a private function that converts a uint8 to a string
    // @param number (UINT8) - The number to be converted
    // @return (STRING) - The string of the number
    function uint8ToString(uint8 number) private pure returns (string memory) {
        // Convert uint8 to ASCII (single-character string)
        bytes1 b = bytes1(uint8(number) + 48);

        // Convert ASCII to string
        return string(abi.encodePacked(b));
    }

    // concatTwoStrings is a private function that concatenates two strings
    // @param a (STRING) - The first string
    // @param b (STRING) - The second string
    // @return (STRING) - The concatenated string
    function concatTwoStrings(string memory a, string memory b) internal pure returns (string memory){
        return string(abi.encodePacked(a, b));
    }

    // generateOrderID is a private function that generates an order id
    // @return (STRING) - The order id
    function generateOrderID() private returns (string memory) {
        string memory orderIDSequenceStr = uint8ToString(orderIDSequence);
        string memory newOrderID = concatTwoStrings(ORDER_ID_PREFIX, orderIDSequenceStr);
        orderIDSequence++;
        return newOrderID;
    }

    // addOrderToOrders is a private function that adds an order to the _orders
    // @param order (ORDER) - The order to be added
    function addOrderToOrders(Order memory order) internal {
        _orders[order.id] = order;
    }

    // getOrder is a private function that gets an order from the _orders
    function getOrder(string memory orderID)
    internal
    view
    returns (Order memory)
    {
        Order memory order = _orders[orderID];
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
        order.status = newStatus;
    }
}


// Products contract is used to manage the products
contract Products {
    // Product is a struct type that represents the information of a product
    struct Product {
        string id;
        string name;
        string description;
        string image;
        uint256 price; // double in frontend
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
            "product_id_1",
            "Product 1",
            "Description 1",
            "image_1",
            1e17 // in wei, is equal to 0.1 ether
        );
        listProducts[1] = Product(
            "product_id_2",
            "Product 2",
            "Description 2",
            "image_2",
            2e17 // in wei, is equal to 0.2 ether
        );
        listProducts[2] = Product(
            "product_id_3",
            "Product 3",
            "Description 3",
            "image_3",
            3e17 // in wei, is equal to 0.3 ether
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
            if (
                keccak256(abi.encodePacked(listProducts[i].id)) ==
                keccak256(abi.encodePacked(productID))
            ) {
                return listProducts[i];
            }
        }

        return Product("", "", "", "", 0);
    }
}


// EcommercePurchasingInterface is an interface that defines the functions of EcommercePurchasing
// It inherits from Products
abstract contract EcommercePurchasingAbstract is Products {
    // getProducts is a function that returns the list of products
    function getProducts() public view virtual returns (Product[3] memory);

    // placeOrder is a function that is used to place an order
    function placeOrder(
        string memory,
        uint256,
        address payable
    ) external payable virtual returns (string memory);

    // cancelOrder is a function that is used to cancel an order
    function cancelOrder(string memory) public virtual returns (string memory);

    // issueRefund is a function that is used to issue a refund
    function issueRefund(string memory, uint256)
    public
    payable
    virtual
    returns (string memory, bool);

    // setRetailer is a function that is used to set the retailer
    function setRetailer(address payable) public virtual;
}


// EcommercePurchasingImplement is a contract that implements the functions of EcommercePurchasing
// It inherits from Products, Orders, and EcommercePurchasingAbstract
contract EcommercePurchasingImplement is
Products,
Orders,
EcommercePurchasingAbstract
{

    address payable retailer;

    // setRetailer is an implementation of the setRetailer function of EcommercePurchasingAbstract
    // @param initRetailer (address) - The retailer address to be set
    function setRetailer(address payable initRetailer) public override {
        retailer = initRetailer;
    }


    // getProducts is an implementation of the getProducts function of EcommercePurchasingAbstract
    // @return (Product[3]) - The list of products
    function getProducts() public view override returns (Product[3] memory) {
        return listProducts;
    }

    // placeOrder is an implementation of the placeOrder function of EcommercePurchasingAbstract
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
        if (product.id == "") {
            return "Product is invalid";
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
        return concatTwoStrings(
            "You have successfully purchased an order with id ",
            order.id
        );
    }

    // cancelOrder is an implementation of the cancelOrder function of EcommercePurchasingAbstract
    // @param orderID (string) - The order id
    // @return (string) - The message of the result
    function cancelOrder(string memory orderID) public override returns (string memory) {
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
        (string memory refundMessage, bool isRefundSuccess) = issueRefund(orderID, refund_amount);
        if (isRefundSuccess){
            updateOrderStatus(order.id, OrderStatus.Canceled);
            return "You successfully canceled your order";
        }
        return refundMessage;
    }


    // issueRefund is an implementation of the issueRefund function of EcommercePurchasingAbstract
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
                concatTwoStrings(
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
        (bool sent,) = to.call{value: value}("");
        return sent;
    }
}

// EcommercePurchasing is the main contract of the EcommercePurchasing system
// It inherits from Products and Orders
contract EcommercePurchasing is Products, Orders {
    // ecommercePurchasing is an instance of EcommercePurchasingAbstract that is used to call the functions of EcommercePurchasingImplement
    EcommercePurchasingAbstract ecommercePurchasing =
    new EcommercePurchasingImplement();

    constructor() {
        // Set the retailer from the deployer of the contract
        ecommercePurchasing.setRetailer(payable(msg.sender));
    }

    // getProducts is a public function that returns the list of products
    // It calls the getProducts function of ecommercePurchasing
    // @return (Product[3]) - The list of products
    function getProducts() public view returns (Product[3] memory) {
        return ecommercePurchasing.getProducts();
    }

    // placeOrder is a public function that is used to place an order
    // It calls the placeOrder function of ecommercePurchasing
    // @param productId (string) - The product id
    // @return (string) - The message of the result
    function placeOrder(string memory productId)
    public
    payable
    returns (string memory)
    {
        string memory message = ecommercePurchasing.placeOrder{value: msg.value}(
            productId,
            msg.value,
            payable(msg.sender)
        );
        return message;
    }

    // cancelOrder is a public function that is used to cancel an order
    // It calls the cancelOrder function of ecommercePurchasing
    // @param orderID (string) - The order id
    // @return (string) - The message of the result
    function cancelOrder(string memory orderID) public returns (string memory) {
        return ecommercePurchasing.cancelOrder(orderID);
    }

    // issueRefund is a public function that is used to issue a refund
    // It calls the issueRefund function of ecommercePurchasing
    // @param orderID (string) - The order id
    // @param refundAmount (uint256) - The refund amount
    // @return (string) - The message of the result
    function issueRefund(string memory orderID, uint256 refundAmount)
    public
    payable
    returns (string memory)
    {
        ( string memory refundMessage, ) = ecommercePurchasing.issueRefund(orderID, refundAmount);
        return refundMessage;
    }
}
