// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

contract OSM{
    
    address private owner;        
    constructor(){ 
        currencyValue["USP"]= 1;
        currencyValue["UNIT"]= 10;
    }

    
    mapping(string => uint256) currencyValue;


    //set currency name and value 
    function setCurrencyValue(string memory currencyName, uint256 value)public returns(bool){
        require(value > 0, "value must bigger than 0");
        currencyValue[currencyName]= value;
        return true;
    }
    
    //get currency value
    function getCurrencyValue(string memory currencyName)public view returns(uint256){
        return currencyValue[currencyName];
    }

}
