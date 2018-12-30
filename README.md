# 数据公布平台
本仓库存放的是一个基于Ethereum的数据公布平台的源代码,是2018年上学期的区块链课程设计.前端基于[Vue框架](https://cn.vuejs.org/index.html)构建,使用了[Element前端UI库](http://element-cn.eleme.io)设计界面,并调用[echarts API](http://echarts.baidu.com/)进行可视化的显示.

# 部署与运行
运行这个数据公布平台需要连接上一个Ethereum的节点.平台允许使用MetaMask或普通的Ethereum节点进行连接.
## MetaMask
把智能合约部署到公链或测试链上,记录智能合约的部署地址,填入`/src/contract/config.json`文件内.
```json
{
  "contractAddressMetaMask": "0xaa348a67fb3005ec3ff766d55fae607e73d7b4ce"
}
```

## 普通节点
部署好自己的节点后,记录智能合约的部署地址,填入`/src/contract/config.json`文件内.
```json
{
  "contractAddressLocal": "0xe7d1f44fe73cd146c21d8aa4721d6bb642bd9078",
}
```
修改`/vue.config.js`文件,把节点地址填入(此处以`http://localhost:8545`为例):
```js
module.exports = {
  devServer: {
    proxy: {
      "/web3": {
        target: 'http://localhost:8545',
        changeOrigin: true
      },
    }
  }
}
```
# vue相关
## Project setup
```
npm install
```

### Compiles and hot-reloads for development
```
npm run serve
```

### Compiles and minifies for production
```
npm run build
```

### Run your tests
```
npm run test
```

### Lints and fixes files
```
npm run lint
```

### Customize configuration
See [Configuration Reference](https://cli.vuejs.org/config/).
