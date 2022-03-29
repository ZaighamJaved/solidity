// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.5;

contract Inbox {
    string public message;

    constructor(string memory initialMessage) {
        message = initialMessage;
    }

    function setMessage(string memory newMessage) public {
        message = newMessage;
    }
}
