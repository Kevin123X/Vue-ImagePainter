const env = process.env.NODE_ENV;
module.exports = {
  devServer: {
    port: 8080,
    open: true,
  },
  publicPath: env === "production" ? "./" : "",
  indexPath: "index.html",
  outputDir: "docs",
  assetsDir: "",
};
