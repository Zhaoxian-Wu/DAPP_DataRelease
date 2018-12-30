<template>
  <div id="app" style="heght: 100%">
    <el-container style="height:100%">
      <el-header class="searchBar">
        <!-- 搜索框 -->
        <el-input
          placeholder="请输入需要查询的组织名称:" v-model="orgQuery" clearable>
          <!-- 下拉菜单: 选择地址 -->
          <el-dropdown slot="prepend" @command="chooseAccount">
            <el-button>
              <template v-if="accountNow.length==0">点击选择组织</template>
              <template v-else-if="getName(accountNow).length!=0">
                {{getName(accountNow)}}
              </template>
              <template v-else>{{accountPrefix(accountNow)}}</template>
              <i class="el-icon-arrow-down el-icon--right"></i>
            </el-button>
            <el-dropdown-menu slot="dropdown">
              <el-dropdown-item v-for="account in accounts" :key="account" :command="account">
                <i class="el-icon-goods"></i>{{accountPrefix(account)}}
                <b v-if="getName(account).length != 0">({{getName(account)}})</b>
                <b v-else>(未注册组织)</b>
              </el-dropdown-item>
              <el-dropdown-item divided command="">创建新帐户</el-dropdown-item>
            </el-dropdown-menu>
          </el-dropdown>
          <!-- 确定按钮 -->
          <el-button slot="append" icon="el-icon-search" @click="query">
          </el-button>
        </el-input>
      </el-header>
      
      <el-container style="height:100%">
        <el-aside class="publicYearList" width="240px" style="height:100%">
          <!-- 选择显示年份 -->
          <template v-if="orgName == ''">
            <!-- 组织未注册 -->
            <template v-if="accountNow != ''">
              <el-row class="asside-hint">该账户未注册组织</el-row>
              <el-row>
                <el-button type='primary' @click="Diag_newOrganisation=true">
                  注册新组织
                </el-button>
              </el-row>
            </template>
          </template>
          <template v-else>
            <!-- 组织已注册 -->
            <template v-if="Input_chooseYears.years.length != 0">
              <el-row style="padding:10px 0 10px 0">
                <span style="padding-right:10px">
                  选择显示年份<i class="el-icon-arrow-down el-icon--right"></i>
                </span>
                <el-checkbox :indeterminate="Input_chooseYears.isIndeterminate" 
                  v-model="Input_chooseYears.checkAll" @change="handleCheckAllChange">
                  全选
                </el-checkbox>
              </el-row>
              <el-checkbox-group 
                v-model="Input_chooseYears.checkedYears" @change="handleCheckedYearsChange">
                <el-row v-for="year of Input_chooseYears.years" :key="year">
                  <el-button class="button-chooseYears">
                    <el-checkbox :label="year">
                      {{year}}
                    </el-checkbox>
                  </el-button>
                </el-row>
              </el-checkbox-group>
            </template>
            <template v-else>
              <el-row class="asside-hint">该组织未发布信息</el-row>
            </template>
            <el-row class='row-button-releaseData'>
              <el-button @click="Diag_releaseData=true">
                发布信息
              </el-button>
            </el-row>
          </template>
        </el-aside>

        <el-container style="height:100%">
          <el-header class="title">
            信息公布平台
          </el-header>
          <el-main style="height:100%">
            <!-- 作图 -->
            <div id="plot"></div>
            <el-row class="main-hint" v-if="orgName == '' && accountNow != ''">
              组织仍未发布任何数据
            </el-row>
          </el-main>
        </el-container>
      </el-container>
    </el-container>

    <!-- ====================================================== -->
    <!-- 对话框 -->

    <el-dialog title="创建区块链用户" :visible.sync="Diag_newAccount" width="50%" center>
      <el-form :model="Form_newAccount" status-icon :rules="Rule_newAccount" 
        ref="Form_newAccount" label-width="100px">
        <el-form-item label="密码" prop="pass">
          <el-input type="password" v-model="Form_newAccount.pass" autocomplete="off"></el-input>
        </el-form-item>
        <el-form-item label="确认密码" prop="checkPass">
          <el-input type="password" v-model="Form_newAccount.checkPass" autocomplete="off"></el-input>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="Diag_newAccount = false">取 消</el-button>
        <el-button type="primary" @click="Submit_newAccount">确 定</el-button>
      </span>
    </el-dialog>

    <el-dialog title="注册新组织" :visible.sync="Diag_newOrganisation" width="40%" center>
      <el-form :model="Form_newOrganisation" status-icon :rules="Rule_newOrganisation" 
        ref="Form_newOrganisation" label-width="100px">
        <el-form-item label="新组织名称" prop="name">
          <el-input v-model="Form_newOrganisation.name"
            autocomplete="off" clearable>
            <i slot="suffix" el-icon-document></i>
          </el-input>
        </el-form-item>
        <el-form-item label="账户密码" prop="pass">
          <el-input v-model="Form_newOrganisation.pass"
            autocomplete="off" clearable type="password">
            <i slot="suffix" el-icon-document></i>
          </el-input>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="Diag_newOrganisation=false">取 消</el-button>
        <el-button type="primary" @click="Submit_newOrganisation">确 定</el-button>
      </span>
    </el-dialog>

    <el-dialog title="发布数据" :visible.sync="Diag_releaseData" width="40%" center>
      <el-form :model="Form_releaseData" status-icon :rules="Rule_releaseData" 
        ref="Form_releaseData" label-width="100px">
        <el-form-item label="发布年份" prop="year">
          <el-date-picker type="year"
          v-model="Form_releaseData.year"
          placeholder="选择年份">
          </el-date-picker>
        </el-form-item>
        <el-form-item label="数据标题" prop="title">
          <el-input v-model="Form_releaseData.title"
            autocomplete="off" clearable>
            <i slot="suffix" el-icon-document></i>
          </el-input>
        </el-form-item>
        <el-table :data="['一 月', '二 月', '三 月', '四 月', '五 月', '六 月', '七 月', '八 月', '九 月', '十 月', '十一月', '十二月']" 
          stripe max-height="300" style="width: 100%">
          <el-table-column label="月份">
            <template slot-scope="scope">
              <el-input 
                v-model="Form_releaseData.data[scope.$index]"
                placeholder="输入月份数据">
                <template slot="prepend">{{scope.row}}</template>
              </el-input>
            </template>
          </el-table-column>
        </el-table>
        <el-form-item label="账户密码" prop="pass">
          <el-input v-model="Form_releaseData.pass"
            autocomplete="off" clearable type="password">
            <i slot="suffix" el-icon-document></i>
          </el-input>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="Diag_releaseData=false">取 消</el-button>
        <el-button type="primary" @click="Submit_releaseData">确 定</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import echarts from 'echarts'

var abi = require('./contract/abi')
var config = require('./contract/config');
var errDictionary = require('./contract/errDictionary')

export default {
  name: 'app',
  data() {
    var validator_newAccount_pass = (rule, value, callback) => {
      if(value == '') {
        callback(new Error('密码不能为空'))
      } else {
        callback()
      }
    }
    var validator_newAccount_checkpass = (rule, value, callback) => {
      if (value === '') {
        callback(new Error('请再次输入密码'));
      } else if (value !== this.Form_newAccount.pass) {
        callback(new Error('两次输入密码不一致!'));
      } else {
        callback();
      }
    }
    var validator_newOrganisation_name = (rule, value, callback) => {
      if(value == '') {
        callback(new Error('组织名不能为空'))
      } else {
        callback()
      }
    }
    var validator_releaseData_title = (rule, value, callback) => {
      if(value == '') {
        callback(new Error('数据标题不能为空'))
      } else {
        callback()
      }
    }
    var validator_releaseData_pass = (rule, value, callback) => {
      if(value == '') {
        callback(new Error('请输入密码'))
      } else {
        callback()
      }
    }
    return {
      orgQuery: "",
      orgQueryExist: "",

      Input_newOrganisation: "",

      accountNow: "",
      accounts: [],

      addrList: {},

      Input_chooseYears: {
        checkAll: false,
        checkedYears: [],
        years: [],
        data: {},
        isIndeterminate: false
      },

      Diag_newAccount: false,
      Form_newAccount: {
        pass: '',
        checkPass: '',
      },
      Rule_newAccount: {
        pass: [
          {validator: validator_newAccount_pass, trigger: 'blur'}
        ],
        checkPass: [
          {validator: validator_newAccount_checkpass, trigger: 'blur'}
        ]
      },

      Diag_newOrganisation: false,
      Form_newOrganisation: {
        name: '',
        pass: '',
      },
      Rule_newOrganisation: {
        name: [
          {validator: validator_newOrganisation_name, trigger: 'blur'}
        ],
        pass: []
      },

      Diag_releaseData: false,
      Form_releaseData: {
        year: new Date(),
        title: '',
        data: Array(12).fill(0),
        pass: ''
      },
      Rule_releaseData: {
        year: [],
        title: [
          {validator: validator_releaseData_title, trigger: 'blur'}
        ],
        data: [],
        pass: [
          {validator: validator_releaseData_pass, trigger: 'blur'}
        ]
      },
    }
  },
  computed: {
    orgName() {
      if(this.orgQueryExist != '') {
        return this.orgQueryExist
      } else if(this.accountNow.length != 0) {
        return this.getName(this.accountNow)
      } else {
        return ''
      }
    },
  },
  mounted() {
    this.ERR_CALLBACK = (err) => {
      // eslint-disable-next-line
      console.log(err)
      this.$notify.error({
        title: '错误',
        message: '未知错误'
      })
    }

    // 导入web3
    var Web3 = require('web3')
    let web3 = window.web3
    let contractAddress = ''
    if (typeof web3 !== 'undefined' 
        && typeof config.contractAddressMetaMask !== 'undefined') {
      web3 = new Web3(web3.currentProvider);
      contractAddress = config.contractAddressMetaMask
    } else {
      // Set the provider you want from Web3.providers
      // web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
      web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8080/web3'))
      contractAddress = config.contractAddressLocal
    }

    let contract = new web3.eth.Contract(abi, contractAddress)

    this.web3 = web3
    this.eth = web3.eth
    this.contract = contract

    this.eth.getAccounts()
      .then((res) => {
        let jobs = []
        for(let addr of res) {
          let job = contract.methods.getName(addr).call({})
            .then((name) => {
              this.addrList[addr] = name
            })
          jobs.push(job)
        }
        return Promise.all(jobs)
      })
      .then(() => {
        for(let account in this.addrList) {
          this.accounts.push(account)
        }
      })
      .catch(this.ERR_CALLBACK)

    // 这个图需要延迟一点点时间才能绘制,不然无法显示.具体原因不明
    setTimeout(() => {
      this.plot = echarts.init(document.getElementById('plot'));
      this.plot.setOption({
        xAxis: {
            type: 'category',
            data: ['Jan', 'Feb', 'Mac', 'Apr', 
                    'May', 'Jun', 'Jul', 'Aug', 
                    'Sep', 'Oct', 'Nov', 'Dec']
        },
        yAxis: {
            type: 'value'
        },
        series: []
      })
    }, 0.5);

    // ! DEBUG
    window.eth = this.eth
    window.ptr = this
  },
  methods: {
    getName(addr) {
      if(typeof(this.addrList[addr]) === 'undefined') {
        return ''
      } else {
        return this.addrList[addr]
      }
    },
    // 查询指定组织
    query() {
      if(this.orgQuery == '') {
        return
      }
      this.contract.methods.getPublicationYears(this.orgQuery).call({})
        .then((res)=>{
          let {data, err} = res
          if(err == 'ERR_NO_REGISTERED') {
            this.$notify.info({
              title: '',
              message: '所找组织不存在',
              offset: 60,
            });
          } else if(err != '') {
            this.$notify.info({
              title: '',
              message: err,
              offset: 60,
            });
          } else if(err == '') {
            this.Input_chooseYears.years = data
            this.orgQueryExist = this.orgQuery
            this.accountNow = ''
            this.updateYears()
          } else {
            this.ERR_CALLBACK('unknown branch')
          }
        })
        .catch(this.ERR_CALLBACK)
    },
    chooseAccount(command) {
      if(command.length == 0) {
        // 创建新用户
        this.Diag_newAccount = true
      } else {
        // 获取注册年份
        this.contract.methods.getPublicationYears(this.addrList[command])
          .call({})
          .then((res)=>{
            // let {data, err} = res
            this.Input_chooseYears = {
              checkAll: false,
              checkedYears: [],
              years: res.data,
              data: {},
              isIndeterminate: false
            },
            this.updateYears()
          })
          .catch(this.ERR_CALLBACK)
        // 选择用户
        this.accountNow = command
        this.orgQueryExist = ''
      }
    },
    updateYears() {
      for(let year of this.Input_chooseYears.years) {
        this.contract.methods.getYearByMonth(this.orgName, year).call({})
          .then((res)=>{
            let {title, data} = res
            this.Input_chooseYears.data[year] = {title: title, data: data}
          }).catch((err) => {
            this.ERR_CALLBACK(err)
          })
      }
    },
    accountPrefix(account, len = 8) {
      return account.substr(0, len) + '...'
    },

    // year choose
    handleCheckAllChange(val) {
      this.Input_chooseYears.checkedYears = val ? this.Input_chooseYears.years : []
      this.Input_chooseYears.isIndeterminate = false
    },
    handleCheckedYearsChange(value) {
      let checkedCount = value.length
      this.Input_chooseYears.checkAll = checkedCount === this.Input_chooseYears.years.length
      this.Input_chooseYears.isIndeterminate = 
        checkedCount > 0 && checkedCount < this.Input_chooseYears.years.length
    },

    // create new account
    Submit_newAccount() {
      this.$refs['Form_newAccount'].validate((valid) => {
        if(!valid) {
          this.$notify({
            title: '创建失败',
            message: '字段信息错误',
            duration: 0,
            type: 'warning'
          });
          return
        }
        let password = this.Form_newAccount['pass']
        this.eth.personal.newAccount(password)
          .then((addr) => {
            this.$notify({
              title: this.accountPrefix(addr, 18),
              message: '创建成功',
              duration: 0,
              type: 'success'
            });
            this.addrList['addr'] = ''
            this.accounts.push(addr)
            this.Diag_newAccount = false
          })
      })
    },
    Submit_newOrganisation() {
      this.$refs['Form_newOrganisation'].validate((valid) => {
        if(!valid) {
          this.$notify({
            title: '创建失败',
            message: '字段信息错误',
            duration: 2000,
            type: 'warning'
          });
          return
        }
        let org = this.Form_newOrganisation.name
        let pass = this.Form_newOrganisation.pass
        let contract_register = this.contract.methods.register(org)

        this.eth.personal.unlockAccount(this.accountNow, pass)
          .then(() => {
            return contract_register.call({from:this.accountNow})
          })
          .then((res)=>{
            let {succ, err} = res
            if(!succ) {
              if(err == 'ERR_INVALID_NAME'
                || err == 'ERR_HAS_REGISTERED_ADDR') {
                  // 前端会阻止这两个错误发生
                  this.$notify.error({
                    title: '创建失败',
                    message: err,
                    duration: 0,
                  });
              } else if(err == 'ERR_HAS_REGISTERED_NAME') {
                this.$notify({
                  title: '创建失败',
                  message: '该组织名已被注册',
                  duration: 0,
                  type: 'warning'
                });
              } else {
                // 合约不会返回其他错误
                this.$notify.error({
                  title: '未知错误',
                  message: err,
                  duration: 0,
                });
              }
              return Promise.resolve('')
            } else {
              this.$notify({
                title: '等待确认',
                message: '等待操作被矿工确认',
                duration: 0,
              });
              return contract_register.send({from: this.accountNow})
            }
          })
          .then((transaction) => {
            if(transaction != '') {
              this.$notify({
                title: '创建',
                message: '组织创建成功',
                duration: 0,
                type: 'success'
              });
            }
          })
          .catch((err) => {
            window.err = err
            let errStr = err.message
            if(typeof(errDictionary[err.message]) !== 'undefined') {
              errStr = errDictionary[err.message]
            }
            this.$notify({
              title: '创建失败',
              message: errStr,
              duration: 0,
              type: 'warning'
            });
          })
      })
    },
    Submit_releaseData() {
      this.$refs['Form_releaseData'].validate((valid) => {
        if(!valid) {
          this.$notify({
            title: '创建失败',
            message: '字段信息错误',
            duration: 2000,
            type: 'warning'
          });
          return
        }
        let {year, title, data, pass} = this.Form_releaseData
        year = year.getFullYear()
        data = data.map(parseFloat)
        let contract_release = this.contract.methods.releaseYearByMonth(
          this.getName(this.accountNow), year, title, data)

        this.eth.personal.unlockAccount(this.accountNow, pass)
          .then(() => {
            return contract_release.call({from:this.accountNow})
          })
          .then((res)=>{
            let {succ, err} = res
            if(!succ) {
              if(err == 'ERR_NO_REGISTERED'
                || err == 'ERR_NOT_REGISTRANT') {
                  // 前端会阻止这两个错误发生
                  this.$notify.error({
                    title: '创建失败',
                    message: err,
                    duration: 0,
                  });
              } else if(err == 'ERR_HAS_RELEASED') {
                this.$notify({
                  title: '创建失败',
                  message: year.toString() + '年数据已发布,不能重新发布',
                  duration: 0,
                  type: 'warning'
                });
              } else {
                // 合约不会返回其他错误
                this.$notify.error({
                  title: '未知错误',
                  message: err,
                  duration: 0,
                });
              }
              return Promise.resolve('')
            } else {
              this.$notify({
                title: '等待确认',
                message: '等待操作被矿工确认',
                duration: 0,
              });
              return contract_release.send({from: this.accountNow})
            }
          })
          .then((transaction) => {
            if(transaction != '') {
              this.$notify({
                title: '发布',
                message: year.toString() + '年数据发布成功',
                duration: 0,
                type: 'success'
              });
            }
          })
          .catch((err) => {
            window.err = err
            let errStr = err.message
            if(typeof(this.errDictionary[err.message]) !== 'undefined') {
              errStr = this.errDictionary[err.message]
            }
            this.$notify({
              title: '创建失败',
              message: errStr,
              duration: 0,
              type: 'warning'
            });
          })
      })
    },
  },
  watch: {
    Input_chooseYears: {
      deep: true,
      handler() {
        let option = {
          title: {
            text: '',
            subtext: '',
            x: 'center'
          },
          xAxis: {
            type: 'category',
            data: ['Jan', 'Feb', 'Mac', 'Apr', 
                    'May', 'Jun', 'Jul', 'Aug', 
                    'Sep', 'Oct', 'Nov', 'Dec']
          },
          yAxis: {
            type: 'value'
          },
          series: [],
          legend:  {
            data:[],
            x: 'left'
          },
        }
        if(this.Input_chooseYears.checkedYears.length == 0) {
          option.title.text = this.orgName
        } else {
          let year = this.Input_chooseYears.checkedYears[0]
          option.title.text = this.Input_chooseYears.data[year].title
          option.title.subtext = '--  ' + this.orgName
        }
        for(let year of this.Input_chooseYears.checkedYears) {
          option.series.push({
            name: year,
            data: this.Input_chooseYears.data[year].data,
            type: 'line',
            smooth: true,
          })
          option.legend.data.push(year)
        }
        this.plot.clear()
        this.plot.setOption(option)
      }
    },
  }
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  width: 100%;
  height: 100%;
}

.publicYearList {
  background-color: rgb(238, 241, 246);
}

.asside-hint {
  padding: 20px 0 20px 0;
}

.main-hint {
  height: 40%;
  margin-top: 50%;
  font-size: 2em;
}

.button-chooseYears {
  width:90%; 
  text-align:left;
}

.row-button-releaseData {
  padding: 20px 0 0 0;
}

.searchBar {
  background-color: #B3C0D1;
  color: #333;
  line-height: 60px;
}

.el-aside {
  color: #333;
}

#plot {
  width: 100%;
  height: 100%;
}

.title {
  font-size: 1.5em;
  line-height: 60px;
  background-color: rgb(60, 74, 94);
  color: rgb(238, 238, 238);
}
</style>