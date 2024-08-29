# 引用chainlink生成随机数，并生成随机的NFT-demo

简单的实现，说明怎么安全的生成随机数供我们的合约使用，首先VRF设计的基本路线是

1.首先我们需要调用requestRandomWords（）请求VRF Coordinator给我们生成随机数，会有一定的延迟。

2.VRF Coordinator的去中心化网络节点根据合约event的数据，在线下使用他们的私钥签名并生成随机数

3.节点调用rawFulfillRandomWords（），需要把随机数更新到我们的合约中

4.中间的延迟时间以及操作不足以我们在同一个mint NFT交易里面生成随机数，并基于随机数mint

5.所以用户的mint行为，我们会认为是请求随机数requestRandomWords（）

6.节点调用rawFulfillRandomWords（）传随机数的操作，可以认为是mint（）


```shell
1.https://vrf.chain.link/bnb-chain-testnet 可以根据切换网络选择测试区块链，在这里注册我们的服务Creat Subscription，会提供Subscription Id
2.deploy NFT-demo合约，0xac...bd  constructor参数是在第一步生成的Subscription Id
3.在https://vrf.chain.link/bnb-chain-testnet， add consumer 添加我们第二部生成的合约地址即可
4.在合约调用requestRandomWords（bool）即可申请我们的随机数，参数true表示使用原生币，false表示使用link代币
5.等待一定时间，Coordinator会给我们的传入随机数并生成NFT
```
