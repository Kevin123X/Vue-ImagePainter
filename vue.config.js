const ENV=process.env.NODE_ENV
module.exports = { 
    publicPath: ENV === "development" ? "" : "/Vue-ImagePainter/",
    devServer: { 
    port: 8080,
    open:true
    } 
} 