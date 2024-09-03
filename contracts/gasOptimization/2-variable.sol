// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract CalldataAndMemory {
    struct Person {
        uint16 age;
        string name;
        string wish;
    }

    Person xiaoming;
    Person xiaoming2;

    // calldata param: gas 67905 ✅
    function writeByCalldata(Person calldata xiaoming_) external {
        xiaoming = xiaoming_;
    }

    // memory param: gas 68456
    function writeByMemory(Person memory xiaoming2_) external {
        xiaoming2 = xiaoming2_;
    }
}

contract Constant {
    uint256 public constant varConstant = 1000;
}

contract Immutable {
    uint256 public immutable varImmutable = 1000;
}

contract Public {
    uint256 public variable = 1000;
}
