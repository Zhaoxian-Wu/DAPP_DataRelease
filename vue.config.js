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