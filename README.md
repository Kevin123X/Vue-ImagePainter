# Vue image-painter

图片涂鸦、绘制、标注

[在线预览(GitHub)](https://kevin123x.github.io/Vue-ImagePainter)

[在线预览(Gitee)](http://keivn.vip.com.gitee.io/vue-imagepainter)

### 支持功能

1.画笔颜色 🎨

2.画笔粗细 ✏️

3.画布放大 🔍

4.画布缩小 🔍

5.清除画布 🧹

6.保存图片 🏔

7.回退一步 ↩️

8.前进一步 ↪️

### 画笔工具类型

1.画笔 ✏️

2.直线 📏

3.圆形 ⚪️

4.矩形 🔲

5.橡皮 🧽

6.文字 📝

## 实现思路

创建三个不同作用的画布

```
// 用于绘制的画板
this.canvas_front = document.getElementById("ctx_front");

// 用于生成绘制后效果图的画板
this.canvas_back = document.getElementById("ctx_back");

// 底图画板，橡皮擦除时获取像素放到绘制画板中，达到不擦出底图的效果
this.canvas_base = document.getElementById("ctx_base");
```

鼠标按下判断工具类型，记录初始位置

```
let mousedown = (e) => {
    this.ctx_front.strokeStyle = this.defaultColor;
    this.ctx_front.lineWidth = this.slide;
    e = e || window.event;
    sx = e.clientX - this.canvas_front.offsetLeft;
    sy = e.clientY - this.canvas_front.offsetTop;

    this.ctx_front.moveTo(sx, sy);
    this.canDraw = true;
    ...
```

若是输入文字则定位输入框到画布中，失焦或回车文字绘制到画布中

```
this.handleTextBlur();
    this.text = "";
    text.style.fontSize = 14 + this.slide * 10 + "px";
    text.style.color = this.defaultColor;
    text.style.left =
              e.offsetX + this.canvas_front.offsetLeft - 20 + "px";
    text.style.top =
              e.offsetY + this.canvas_front.offsetTop - 10 + "px";
    text.style.zIndex = 10;
    text.style.display = "block";
    this.tl = e.offsetX - 20;
    this.tt = e.offsetY + 10;
    break;

    ...

handleTextBlur() {
      let text = document.getElementById("text");
      this.ctx_front.font = `300 ${text.style.fontSize} sans-serif`;
      this.ctx_front.fillStyle = this.defaultColor;
      this.ctx_front.fillText(this.text, this.tl, this.tt);
      text.style.display = "none";
      this.handleSaveCanvasStore();
    }
```

鼠标移动，根据工具类型绘制不同路径

```
 let mousemove = (e) => {
        e = e || window.event;
        mx = e.clientX - this.canvas_front.offsetLeft;
        my = e.clientY - this.canvas_front.offsetTop;
        const cbx = this.ctx_base.getImageData(
          e.offsetX - this.slide / 2,
          e.offsetY - this.slide / 2,
          this.slide * 2,
          this.slide * 2
        );
    ...
```

若工具类型是橡皮，则从 canvas_base 中获取底图像素放回 canvas_front 中

```
    const cbx = this.ctx_base.getImageData(
          e.offsetX - this.slide / 2,
          e.offsetY - this.slide / 2,
          this.slide * 2,
          this.slide * 2
    );

    ...

 this.ctx_front.putImageData(
                cbx,
                e.offsetX - this.slide / 2,
                e.offsetY - this.slide / 2
              );
    ...
```

鼠标抬起，从绘制画布 canvas_front 生成绘制图并绘制到 canvas_back 中，然后再重绘 canvas_front

```
handleSaveCanvasStore() {
      let url = this.canvas_front.toDataURL();
      let image = new Image();
      image.src = url;
      image.onload = () => {
        this.ctx_front.clearRect(
          0,
          0,
          this.canvas_front.width,
          this.canvas_front.height
        );
        this.ctx_front.drawImage(image, 0, 0, image.width, image.height);
        this.ctx_back.drawImage(image, 0, 0, image.width, image.height);
        const url2 = this.canvas_back.toDataURL();
        this.currentImg.url = url2;
        this.currentImg.index += 1;
        this.canvasStore.push(url2);
        this.prevDis = false;
        console.log(this.canvasStore);
      };
    },

```
最终保存图片
```
let canvas = document.getElementById("ctx_back");
    this.$refs.download.href = canvas.toDataURL();
    this.$refs.download.click();
```
### Project setup

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

### Lints and fixes files

```
npm run lint
```

### 感谢支持

> 开发不易，且用且珍惜 ，随手给个星，开心到起飞
