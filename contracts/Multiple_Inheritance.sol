// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

contract A {
    string name;

    function setName(string memory _name) external {
        name = _name;
    }
}

contract B {
    uint256 salary;

    function setSalary(uint256 _salary) external {
        salary = _salary;
    }
}

contract C is A, B {
    function getName() public view returns (string memory) {
        return name;
    }

    function getSalary() public view returns (uint256) {
        return salary;
    }
}
