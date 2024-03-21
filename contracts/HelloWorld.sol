// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HelloWorld {
    string message;

     constructor(){
         message = "Hello World!";
     }

//    constructor(string memory initMessage) {
//        message = initMessage;
//    }

    // A public function that accepts a string argument and updates the `message` storage variable.
    function setMessage(string memory newMessage) public {
        message = newMessage;
    }

    function getMessage() public view returns (string memory) {
        return message;
    }
}
