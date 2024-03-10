// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

// reference: https://docs.soliditylang.org/en/latest/style-guide.html
contract Orders {
  mapping(string => Order) private orders;
  uint order_id_sequence = 1;
  string constant order_id_prefix = "order_id_";

  enum OrderStatus {
    PaymentPending,
    PaymentFailed,
    New,
    Canceled,
    PartialRefunded
  }

  struct Order {
    string id;
    string product_id;
    uint amount; // double in frontend
    address customer_address;
    OrderStatus status;
    uint refunded_amount; // double in frontend
  }

  function generateOrderId() private returns (string memory) {
    string memory new_order_id = string(abi.encodePacked(order_id_prefix, order_id_sequence));
    order_id_sequence++;
    return new_order_id;
  }

  function addOrderToOrders(Order memory order) internal {
    orders[order.id] = order;
  }

  function getOrder(string memory order_id) internal view returns (Order memory) {
    Order memory order = orders[order_id];
    require(bytes(order.id).length > 0, "Order is not found");
    return order;
  }

  function createOrder(string memory product_id, uint amount, address customer_address) internal returns (Order memory) {
    Order memory order;
    order.id = generateOrderId();
    order.product_id = product_id;
    order.amount = amount;
    order.customer_address = customer_address;
    order.status = OrderStatus.PaymentPending;
    order.refunded_amount = 0;
    return order;
  }

  function updateOrderStatus(string memory order_id, OrderStatus newStatus) internal {
    Order storage order = orders[order_id];
    order.status = newStatus;
  }
}


contract Products {
  struct Product {
    string id;
    string name;
    string description;
    string image;
    uint price; // double in frontend
  }

  Product[3] internal listProducts;

  constructor() {
    setListProducts();
  }

  function setListProducts() private {
    listProducts[0] = Product("product_id_1", "Product 1", "Description 1", "image_1", 100);
    listProducts[1] = Product("product_id_2", "Product 2", "Description 2", "image_2", 200);
    listProducts[2] = Product("product_id_3", "Product 3", "Description 3", "image_3", 300);
  }

  function getProductFromListProducts(string memory product_id) internal view returns (Product memory) {
    for (uint i = 0; i < listProducts.length; i++) {
      if (keccak256(abi.encodePacked(listProducts[i].id)) == keccak256(abi.encodePacked(product_id))) {
        return listProducts[i];
      }
    }

    // TODO: return error if product is not found
    require(false, "Product is not found");
    return Product("", "", "", "", 0);
  }
}


abstract contract EcommercePurchasingInterface is Products {
  function getProducts() public virtual view returns (Product[3] memory);

  function placeOrder(string memory, uint, address payable) public virtual payable;

  function cancelOrder(string memory) public virtual;

  function issueRefund(string memory, uint) public virtual payable returns (bool);

  function getBalance(address) public virtual view returns (uint);
}


contract EcommercePurchasingImplement is Orders, Products, EcommercePurchasingInterface {
  address payable retailerAddress;

  constructor(address payable _retailerAddress){
    retailerAddress = retailerAddress;
  }

  // Function: getProducts
  //    # The getProducts function returns the list of products
  //    RETURNS Product[3]
  //    BEGIN
  //      RETURN listProducts;
  //    END
  function getProducts() public view override returns (Product[3] memory) {
    return listProducts;
  }

  // Function: placeOrder
  //    PARAMS (STRING product_id, DOUBLE amount)
  //    BEGIN
  //      # Step 1: Check if product is valid
  //      SET product = getProductFromListProducts(product_id);
  //      if product is not found THEN
  //        PRINT "Product is invalid";
  //        EXIT;
  //      END
  //
  //      # Step 2: Check if customer has enough balance
  //      SET customer_address = owner.address
  //      if customer balance is less than amount THEN
  //        PRINT "Not enough balance";
  //        EXIT;
  //      END
  //
  //      # Step 3: Create an order
  //      SET order = NEW Order();
  //      order.id = generateOrderId();
  //      order.product_id = product_id;
  //      order.amount = amount;
  //      order.customer_address = customer_address;
  //      order.status = OrderStatus.PaymentPending;
  //      order.refunded_amount = 0;
  //
  //      # Step 4: Issue a transaction from customer address to retailer address
  //      IF transfer transaction is failed THEN
  //        order.status = OrderStatus.PaymentFailed;
  //        PRINT "Transaction failed";
  //      ELSE
  //        order.status = OrderStatus.New;
  //        PRINT "You successfully purchased an order with order id";
  //      END
  //    END
  function placeOrder(string memory product_id, uint amount, address payable customer) public payable override {
    Product memory product = getProductFromListProducts(product_id);
    //        if (bytes(product.id).length == 0) {
    //            return;
    //        }
    require(bytes(product.id).length != 0, "Product is invalid");

    //        if (owner.balance < amount) {
    //            return;
    //        }
    require(customer.balance >= amount, "Not enough balance");

    Order memory order = createOrder(product_id, amount, customer);
    addOrderToOrders(order);
    customer.transfer(amount);
//    if (!payable(customer).send(amount)) {
//      updateOrderStatus(order.id, OrderStatus.PaymentFailed);
//    } else {
//      updateOrderStatus(order.id, order.status = OrderStatus.New);
//    }
  }

  // Function: cancelOrder
  //    PARAMS (STRING order_id)
  //    BEGIN
  //      # Step 1: Get Order info from order id
  //      Order order = getOrder(order_id);
  //
  //      # Step 2: Check if the order is already canceled
  //      IF order.status == OrderStatus.Canceled THEN
  //        PRINT "This order is already canceled";
  //        EXIT;
  //
  //      # Step 3: Proceed to cancel the order.
  //      ELSE IF order.status == OrderStatus.New OR order.status == OrderStatus.PartialRefunded THEN
  //
  //        # Step 3.1: Calculate the refund amount
  //        DOUBLE refund_amount = order.amount - order.refunded_amount;
  //
  //        # Step 3.2: Check if refund amount is 0 then update the order status to canceled.
  //        IF refund_amount == 0 THEN
  //          order.status = OrderStatus.Canceled;
  //          PRINT "You successfully canceled your order";
  //          EXIT;
  //
  //        ELSE
  //          Step 3.3: Issue a refund and update the order status to canceled.
  //          IF issueRefund(order_id, refund_amount) THEN
  //            order.status = OrderStatus.Canceled;
  //            PRINT "You successfully canceled your order";
  //          ELSE
  //            PRINT "Error occurred while refunding";
  //          END
  //        END
  //      ELSE
  //        PRINT "The order status is invalid";
  //      END
  //    END
  //
  function cancelOrder(string memory order_id) public override {
    Order memory order = getOrder(order_id);
    //        if (order.status == uint(OrderStatus.Canceled)) {
    //            return;
    //        }
    require(order.status != OrderStatus.Canceled, "This order is already canceled");

    bool canCancelOrder = (order.status == OrderStatus.New || order.status == OrderStatus.PartialRefunded);
    //        if (!canCancelOrder) {
    //            return;
    //        }
    require(canCancelOrder, "The order status is invalid");

    uint refund_amount = order.amount - order.refunded_amount;
    if (refund_amount == 0) {
      updateOrderStatus(order.id,OrderStatus.Canceled);
      return;
    }

    if (issueRefund(order_id, refund_amount)) {
      updateOrderStatus(order.id, OrderStatus.Canceled);
    }
  }

  // Function: issueRefund
  //    PARAMS (STRING order_id, DOUBLE refund_amount)
  //    BEGIN
  //      # Step 1: Get order info from order id.
  //      Order order = getOrder(order_id);
  //
  //      # Step 2: Calculate max refund amount
  //      DOUBLE max_refund_amount = order.amount - order.refunded_amount;
  //
  //      # Step 3: Compare max refund amount with refund amount
  //      IF refund_amount > max_refund_amount THEN
  //        PRINT "Refund amount is greater than " + max_refund_amount;
  //        EXIT;
  //      ELSE
  //
  //        # Step 4: Issue a refund transaction
  //        IF transaction transfer is failed THEN
  //          PRINT "Transaction failed";
  //        ELSE
  //          PRINT "You successfully refunded your payment";
  //        END
  //      END
  //    END
  function issueRefund(string memory order_id, uint refund_amount) public payable override returns (bool) {
    Order memory order = getOrder(order_id);
    uint max_refund_amount = order.amount - order.refunded_amount;
    require(refund_amount <= max_refund_amount, "Refund amount is greater than max refund amount");

    return payable(order.customer_address).send(refund_amount);
  }

  function getBalance(address sender) public view override returns (uint) {
    return sender.balance;
  }
}


contract EcommercePurchasing is Products {
  EcommercePurchasingInterface ecommercePurchasing;

  constructor() {
    ecommercePurchasing = new EcommercePurchasingImplement(payable(msg.sender));
  }

  function getProducts() public view returns (Product[3] memory) {
    return ecommercePurchasing.getProducts();
  }

  function placeOrder(string memory product_id, uint amount) public payable {
    ecommercePurchasing.placeOrder(product_id, amount, payable(msg.sender));
  }

  function cancelOrder(string memory order_id) public {
    ecommercePurchasing.cancelOrder(order_id);
  }

  function issueRefund(string memory order_id, uint refund_amount) public payable returns (bool) {
    return ecommercePurchasing.issueRefund(order_id, refund_amount);
  }

  function getBalance() public view returns (uint) {
    return ecommercePurchasing.getBalance(msg.sender);
  }
}
