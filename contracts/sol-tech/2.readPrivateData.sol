// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract accessPrivateData{
    uint256 public a = 123;     //slot 0
    uint256 public b = 0x456;   //slot 1
    uint256 private c = 789;    //slot 2
    //slot 3  
    uint8 private d = 111;
    uint16 private e = 111;
    uint32 private f = 111;
    uint64 public g = 111;
    uint128 public h = 111;
    //slot 4
    address public user = msg.sender;
    bool private status = true;
    //constant not in the slot
    uint256 constant num = 123;
    //slot 5
    mapping(uint256 => uint256) public data;
    //slot 6 
    mapping(uint256 => uint256) private _data;

    uint256 public k = 123; 

    constructor(){
        setData2(123);
    }

    function setData1(uint256 data_)public{
        data[0xAC] = data_;
    }

    function setData2(uint256 data_)public{
        _data[0xABC] = data_;
    }

    function mapLocation(uint256 slot, uint256 key) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(key, slot));
}
}
