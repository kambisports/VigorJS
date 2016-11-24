const path = require('path');
const config = require('./config');
const webpack = require('webpack');
const pkg = require('./package.json');

const banner = `vigorjs - A small framework for structuring large scale Backbone applications
@version ${pkg.version}
@link https://github.com/kambisports/VigorJS.git
@license ISC`;

module.exports = {
  resolveLoader: {root: path.join(__dirname, 'node_modules')},
  resolve: {
    extensions: ['', '.js'],
    alias: {
      common: path.resolve(__dirname, 'src', 'common'),
      component: path.resolve(__dirname, 'src', 'component'),
      datacommunication: path.resolve(__dirname, 'src', 'datacommunication'),
      utils: path.resolve(__dirname, 'src', 'utils'),
      test: path.resolve(__dirname, 'test')
    }
  },
  entry: `${config.src}/bootstrap.js`,
  output: {
    path: path.join(__dirname, config.dist),
    filename: config.outputName,
    library: config.nameSpace,
    libraryTarget: 'umd',
    umdNamedDefine: false
  },
  externals: {
    jquery: {
      root: '$',
      commonjs2: 'jquery',
      commonjs: 'jquery',
      amd: 'jquery'
    },
    lodash: {
      root: '_',
      commonjs2: 'lodash',
      commonjs: 'lodash',
      amd: 'lodash'
    },
    underscore: {
      root: '_',
      commonjs2: 'lodash',
      commonjs: 'lodash',
      amd: 'lodash'
    },
    backbone: {
      root: 'Backbone',
      commonjs2: 'backbone',
      commonjs: 'backbone',
      amd: 'backbone'
    }
  },
  module: {
    preLoaders: [
      {
        test: /\.(js)$/,
        exclude: /node_modules/,
        loader: 'eslint?{configFile:".eslintrc.js"}'
      }
    ],
    loaders: [
      {
        test: /\.(js)$/,
        loader: 'babel'
      }
    ]
  },
  plugins: [
    new webpack.BannerPlugin(banner)
  ],
  devtool: 'source-map',
  debug: true
}
