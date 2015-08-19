var path = require("path");
var ExtractTextPlugin = require("extract-text-webpack-plugin");

var entry = './src/app/main.coffee',
  output = {
    path: __dirname,
    filename: 'main.js'
  };

var AUTOPREFIXER_BROWSERS = ["last 2 version"];

module.exports.development = {
  debug : true,
  devtool : 'eval',
  entry: entry,
  output: output,
  module : {
    loaders : [
      { test: /\.coffee?$/, exclude: /node_modules/, loader: 'coffee-loader' },
      { test: /\.jade$/, exclude: /node_modules/, loader: 'jade-loader' },
      {
        test: /\.(css|styl)$/,
        loader: ExtractTextPlugin.extract("style-loader",
            "css!" +
            "autoprefixer?{browsers:" + JSON.stringify(AUTOPREFIXER_BROWSERS) + "}!" +
            "stylus-loader?paths=" + path.resolve(__dirname, "node_modules/material-design-lite"))
      }
    ]
  },
  plugins: [new ExtractTextPlugin("../css/main.css")],
  resolve: {
    extensions: ['', '.js', '.json', '.coffee']
  }
};

module.exports.production = {
  debug: false,
  entry: entry,
  output: output,
  module : {
    loaders : [
      { test: /\.coffee?$/, exclude: /node_modules/, loader: 'coffee-loader' },
      { test: /\.jade$/, exclude: /node_modules/, loader: 'jade-loader' },
      {
        test: /\.(css|styl)$/,
        loader: ExtractTextPlugin.extract("style-loader",
            "css!" +
            "autoprefixer?{browsers:" + JSON.stringify(AUTOPREFIXER_BROWSERS) + "}!" +
            "stylus-loader?paths=" + path.resolve(__dirname, "node_modules/material-design-lite"))
      }
    ]
  },
  plugins: [new ExtractTextPlugin("../css/main.css")],
  resolve: {
    extensions: ['', '.js', '.json', '.coffee']
  }
};
