module.exports = {
  publicPath: '/',
  devServer: {
    disableHostCheck: true,
    host: '0.0.0.0',
    port: 8080,
  },
  configureWebpack: {
    module: {
      rules: [
        {
          test: /.*config\.js$/,
          use: [
            {
              loader: 'file-loader',
              options: {
                name: 'js/config.js'
              },
            }
          ]
        }
      ]
    }
  }
};
