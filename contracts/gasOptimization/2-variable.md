calldata、memory 引用类型修饰符,constant、immutable、变量

## 功能简述

1. memory：函数里的参数和临时变量一般用 memory，存储在内存中，不上链。

2. calldata：和 memory 类似，存储在内存中，不上链。与 memory 的不同点在于 calldata 变量不能修改（immutable），一般用于函数的参数。

3. constant：声明一个常量，需要在声明时进行赋值，且后期不可变更。

4. immutable：声明一个常量，可以在声明时和 constructor 中进行赋值，且后期不可变更。
 
5. 变量：声明一个变量，可以在任意环节进行赋值，且后期可以变更。


## DemoCode

下面分别用 calldata 和 memory 来写入相同的数据。

```solidity
contract CalldataAndMemory {
    struct Person {
        uint16 age;
        string name;
        string wish;
    }

    Person xiaoming;
    Person xiaoming2;

    function writeByCalldata(Person calldata xiaoming_) external {
        xiaoming = xiaoming_;
    }

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
```

以下是 2 种情况下，写入变量消耗的 gas 差异对比。gas 优化建议如下：

1. 结合实际情况下，建议优先使用 calldata 进行变量写入。
2. 结合实际情况，应尽量避免使用 variable 对变量进行定义；
3. 对于无需修改的常量，建议使用 immutable 进行定义，其在功能性和 gas 上均为最佳。
   
| 关键字   | gas 消耗 | 节省     | 结果    |
| -------- | -------- | -------- | ------- |
| calldata | 67905    | 551(≈1%) | ✅ 建议 |
| memory   | 68456    |          |         |
|constant  |  161	  |2100(≈93%)｜ ✅ 建议	
|immutable |  161	  |2100(≈93%)｜ ✅ 建议	
|variable  |  2261		
