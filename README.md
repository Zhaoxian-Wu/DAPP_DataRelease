# 数据公布平台
本仓库存放的是一个基于Ethereum的数据公布平台的源代码,是2018年上学期的区块链课程设计.前端基于[Vue框架](https://cn.vuejs.org/index.html)构建,使用了[Element前端UI库](http://element-cn.eleme.io)设计界面,并调用[echarts API](http://echarts.baidu.com/)进行可视化的显示.

# 选题背景
在企业、组织等的运营过程中,我们往往有着对外公布数据的需要。而数据
的公布,我们希望这是一个公开透明的过程:数据公布后,其内容不应该会被重
新修改。区块链中的不可篡改的特性很好地满足的这个需求。
另一方面,数据公布之后,我们希望可以用一些方便而直观的手段查看这些
数据:例如作出数据报表,饼图等辅助我们分析。我们希望我们的客户端能够实
现数据的公布和可视化查看等操作

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

## 运行
使用`npm install`安装依赖.并使用`npm run serve`命令启动后端程序.在保证区块链成功连接的情况下,在浏览器访问`localhost:8080`即可使用.

# 功能
- 创建区块链账户
- 组织负责人使用账户注册组织
- 组织按以一年为单位,精细到一个月发布数据
- 区块链上其他人可以通过智能合约获取某个组织公布的数据,并自定义和可视化地查看数据

# 运行效果
## 查看信息
其他用户可以查看已发布的数据  
![](https://github.com/MrFive5555/DAPP_DataRelease/blob/master/picture/main.png?raw=true)  
## 创建账户
用户可以创建一个区块链账户,进行组织注册和数据发布工作  
![](https://github.com/MrFive5555/DAPP_DataRelease/blob/master/picture/createAccount.png?raw=true)  
## 注册组织
用户可以注册一个用户,以便进行数据发布工作.注册组织需要用户密码解锁账户.  
![](https://github.com/MrFive5555/DAPP_DataRelease/blob/master/picture/newOrganisation.png?raw=true)  
## 发布信息
已注册组织的用户可以进行信息发布,信息发布需要用户密码解锁账户.  
![](https://github.com/MrFive5555/DAPP_DataRelease/blob/master/picture/releaseData.png?raw=true)  
## 完善的错误提示机制
用户界面的错误提示分为输入提示和运行结果提示  
### 输入错误提示
当用户有不合法输入时,界面会对错误进行提示  
![](https://github.com/MrFive5555/DAPP_DataRelease/blob/master/picture/errHint1.png?raw=true)  
![](https://github.com/MrFive5555/DAPP_DataRelease/blob/master/picture/errHint2.png?raw=true)  
### 运行结果提示
当区块链账户解锁密码错误时,界面会弹出提示.  
![](https://github.com/MrFive5555/DAPP_DataRelease/blob/master/picture/mes_passerr.png?raw=true)  
当区块链账户余额不够支付当前交易(如注册和发布数据)时,程序会弹出提示.  
![](https://github.com/MrFive5555/DAPP_DataRelease/blob/master/picture/mes_nogas.png?raw=true)  
当交易允许被进行,将可以等待写入链内,程序会弹出提示框提示用户等待交易被写入.  
![](https://github.com/MrFive5555/DAPP_DataRelease/blob/master/picture/mes_wait.png?raw=true)  
当交易成功后,程序会弹出提示,报告成功.  
![](https://github.com/MrFive5555/DAPP_DataRelease/blob/master/picture/mes_succ.png?raw=true)  


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
