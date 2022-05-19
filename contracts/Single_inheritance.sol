// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

contract Parent {
    uint256 sum;

    function setValue(uint256 num1, uint256 num2) external {
        sum = num1 + num2;
    }
}

contract child is Parent {
    function getValue() public view returns (uint256) {
        return sum;
    }
}
