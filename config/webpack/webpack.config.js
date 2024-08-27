// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.
const { generateWebpackConfig, merge } = require("shakapacker");

const webpackConfig = generateWebpackConfig();

const customConfig = {
  resolve: {
    extensions: [".css"],
  },
  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader",
          options: {
            presets: ["@babel/preset-react"],
          },
        },
      },
    ],
  },
};

module.exports = merge(webpackConfig, customConfig);
