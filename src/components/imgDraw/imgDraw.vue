<template>
  <div class="imgDraw">
    <a
      href="javascript:void(0);"
      ref="download"
      download="picture.png"
      v-show="false"
    ></a>
    <el-button type="primary" @click="handleShowCanvas">showCanvas</el-button>
    <el-dialog
      destroy-on-close
      :close-on-click-modal="false"
      :close-on-press-escape="false"
      :show-close="false"
      :visible.sync="show"
      fullscreen
    >
      <p slot="title" class="title">Vue-ImagePainter🎨</p>
      <div class="d_body">
        <div class="board" ref="board">
          <canvas
            id="ctx_front"
            ref="ctx_front"
            :style="'cursor:' + cursor"
          ></canvas>
          <canvas
            id="ctx_base"
            ref="ctx_base"
            :style="'cursor:' + cursor"
          ></canvas>
          <canvas
            id="ctx_back"
            ref="ctx_back"
            :style="'cursor:' + cursor"
          ></canvas>
          <input
            name="text"
            id="text"
            @blur="handleTextBlur"
            @keyup.enter="handleTextBlur"
            v-model="text"
            autofocus
            autocomplete="off"
            :style="
              'font-size:' + (this.slide * 10 + 14) + 'px;color:' + defaultColor
            "
          />
        </div>
        <div :class="['tools', 'settings', isExpand ? '' : 'noExpand']">
          <div
            class="tool_item"
            v-for="(item, index) in settings"
            :key="item.icon"
          >
            <button v-if="index == 0">
              <svg
                class="icon"
                aria-hidden="true"
                :style="'color:' + defaultColor"
              >
                <use :xlink:href="item.icon"></use>
              </svg>
              <span :style="'color:' + defaultColor">{{ item.name }}</span>
              <el-color-picker v-model="defaultColor"></el-color-picker>
            </button>
            <div v-else-if="index == 1" class="slide">
              <svg class="icon" aria-hidden="true">
                <use :xlink:href="item.icon"></use>
              </svg>
              <span>{{ item.name }}</span
              >&emsp;&emsp;
              <el-slider
                ref="slide"
                v-model="slide"
                :min="1"
                :max="10"
                :step="1"
              ></el-slider>
            </div>
            <button v-else @click.stop="item.fun">
              <svg class="icon" aria-hidden="true">
                <use :xlink:href="item.icon"></use>
              </svg>
              <span>{{ item.name }}</span>
            </button>
          </div>
          <div class="tool_item" v-for="item in btns" :key="item.icon">
            <button
              @click.stop="item.fun"
              v-if="item.name == '上一步'"
              :disabled="prevDis"
              :style="prevDis ? 'cursor:not-allowed' : ''"
            >
              <svg class="icon" aria-hidden="true">
                <use :xlink:href="item.icon"></use>
              </svg>
              <span>{{ item.name }}</span>
            </button>
            <button
              @click.stop="item.fun"
              v-else-if="item.name == '下一步'"
              :disabled="nextDis"
              :style="nextDis ? 'cursor:not-allowed' : ''"
            >
              <svg class="icon" aria-hidden="true">
                <use :xlink:href="item.icon"></use>
              </svg>
              <span>{{ item.name }}</span>
            </button>
            <button @click.stop="item.fun" v-else>
              <svg class="icon" aria-hidden="true">
                <use :xlink:href="item.icon"></use>
              </svg>
              <span>{{ item.name }}</span>
            </button>
          </div>
          <div class="tool_item go_up">
            <button @click.stop="handleShowOrHide(0)">
              <i class="el-icon-caret-top"></i>
              <span>收起</span>
            </button>
          </div>
          <div class="pull" v-if="!isExpand">
            <span class="line"></span>
            <span
              class="round"
              title="展开"
              @click.stop="handleShowOrHide(1)"
            ></span>
          </div>
        </div>
        <div :class="['tools', 'bars', showTools ? '' : 'hideTools']">
          <div
            class="el-icon-s-tools arrow"
            v-if="!showTools"
            title="展开"
            @click.stop="handleShowTools(1)"
          ></div>
          <div
            class="el-icon-arrow-right arrow"
            v-else
            title="收起"
            @click.stop="handleShowTools(0)"
          ></div>
          <div
            :class="[
              'tool_item',
              activeTool == item.toolType ? 'activeTool' : '',
            ]"
            v-for="item in tools"
            :key="item.toolType"
            @click.stop="handleChangeToolType(item.toolType)"
          >
            <svg class="icon" aria-hidden="true">
              <use :xlink:href="item.icon"></use>
            </svg>
            <span>{{ item.name }}</span>
          </div>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script>
// eslint-disable-next-line no-unused-vars
import cursors from "./cursor";
import bg from "../../assets/demo.png";
export default {
  name: "imgDraw",
  data() {
    return {
      show: true,
      defaultColor: "#333333",
      cursor: `url('${cursors.pen}'),auto`,
      slide: 1,
      settings: [
        {
          icon: "#icon-youqitong_huaban1",
          name: "颜色",
          fun: "",
        },
        {
          icon: "#icon-huabi_huaban1",
          name: "粗细",
          fun: "",
        },
        {
          icon: "#icon-fangda_huaban1",
          name: "放大",
          fun: () => {
            return this.handleBeLarge();
          },
        },
        {
          icon: "#icon-suoxiao_huaban1",
          name: "缩小",
          fun: () => {
            return this.handleBeSmall();
          },
        },
      ],
      activeTool: 1,
      tools: [
        {
          icon: "#icon-huabi_huaban1",
          name: "画笔",
          toolType: 1,
        },
        {
          icon: "#icon-zhixian_huaban1",
          name: "直线",
          toolType: 2,
        },
        {
          icon: "#icon-yuanquan_huaban1",
          name: "圆形",
          toolType: 3,
        },
        {
          icon: "#icon-juxinggongju_huaban1",
          name: "矩形",
          toolType: 4,
        },
        {
          icon: "#icon-xiangpi_huaban1",
          name: "橡皮",
          toolType: 5,
        },
        {
          icon: "#icon-wenzi_huaban1",
          name: "文字",
          toolType: 6,
        },
      ],
      btns: [
        {
          icon: "#icon-chexiao",
          name: "上一步",
          fun: ()=>{
           return this.handlePrev()
          },
        },
        {
          icon: "#icon-zhongzuo",
          name: "下一步",
          fun: ()=>{
           return this.handleNext()
          },
        },
        {
          icon: "#icon-lajixiang_huaban1",
          name: "清除",
          fun: () => {
          return  this.handleClearCanvas();
          },
        },
        {
          icon: "#icon-baocun",
          name: "保存",
          fun: () => {
            return this.handleCanvas2Img();
          },
        },
      ],
      canvas_front: null,
      canvas_back: null,
      canvas_base: null,
      ctx_base: null,
      ctx_front: null,
      ctx_back: null,
      currentImg: {
        url: bg,
        width: "",
        height: "",
        scale: 1,
        index: 0,
      },
      isExpand: 1,
      showTools: 1,
      canDraw: false,
      text: "",
      canvasStore: [bg],
      prevDis: true,
      nextDis: true,
      baseMap: bg,
      tl: 0,
      tt: 0,
    };
  },
  methods: {
    /** 显示或隐藏设置栏*/
    handleShowOrHide(status) {
      this.isExpand = status;
    },
    /** 显示或隐藏工具栏*/
    handleShowTools(status) {
      this.showTools = status;
    },
    handleShowCanvas() {
      this.show = true;
    },
    /** 工具切换*/
    handleChangeToolType(type) {
      this.activeTool = type;
      switch (type) {
        case 1:
          this.cursor = `url('${cursors.pen}'),auto`;
          break;
        case 2:
          this.cursor = `crosshair`;
          break;
        case 3:
          this.cursor = `crosshair`;
          break;
        case 4:
          this.cursor = `crosshair`;
          break;
        case 5:
          this.cursor = `url('${cursors.eraser}'),auto`;
          break;
        case 6:
          this.cursor = `url('${cursors.text}'),auto`;
          break;
        default:
          this.cursor = `url('${cursors.pen}'),auto`;
          break;
      }
      this.handleDrawCanvas(type);
    },
    /** 初始化画布*/
    handleInitCanvas() {
      this.currentImg = {
        url: bg,
        width: "",
        height: "",
        scale: 1,
        index: 0,
      };
      this.canvasStore = [bg];
      this.prevDis = true;
      this.nextDis = true;
      // 用于绘制的画板
      this.canvas_front = document.getElementById("ctx_front");
      // 用于生成图片绘制后图片的画板
      this.canvas_back = document.getElementById("ctx_back");
      // 底图画板，橡皮擦除时获取像素放到绘制画板中，达到不擦出底图的效果
      this.canvas_base = document.getElementById("ctx_base");
      this.ctx_base = this.canvas_base.getContext("2d");
      this.ctx_front = this.canvas_front.getContext("2d");
      this.ctx_back = this.canvas_back.getContext("2d");
      this.ctx_front.strokeStyle = this.defaultColor;
      let img = new Image();
      img.src = this.baseMap;
      let _this = this;
      img.onload = function() {
        let width = parseInt(this.width);
        let height = parseInt(this.height);
        _this.currentImg.width = width;
        _this.currentImg.height = height;
        _this.canvas_front.width = width;
        _this.canvas_front.height = height;
        _this.canvas_back.width = width;
        _this.canvas_back.height = height;
        _this.canvas_base.width = width;
        _this.canvas_base.height = height;
        // _this.ctx_front.drawImage(this, 0, 0, width, height);
        _this.ctx_back.drawImage(this, 0, 0, width, height);
        _this.ctx_base.drawImage(this, 0, 0, width, height);
      };
    },
    /** 处理放大缩小*/
    handleDrawImage() {
      let _this = this;
      let img = new Image();
      let baseImg = new Image();
      img.src = this.currentImg.url;
      baseImg.src = this.baseMap;
      _this.currentImg.width = _this.currentImg.width * this.currentImg.scale;
      _this.currentImg.height = _this.currentImg.height * this.currentImg.scale;
      img.onload = function() {
        _this.canvas_front.width = _this.currentImg.width;
        _this.canvas_front.height = _this.currentImg.height;
        _this.canvas_back.width = _this.currentImg.width;
        _this.canvas_back.height = _this.currentImg.height;
        _this.ctx_front.drawImage(
          this,
          0,
          0,
          _this.currentImg.width,
          _this.currentImg.height
        );
        _this.ctx_back.drawImage(
          this,
          0,
          0,
          _this.currentImg.width,
          _this.currentImg.height
        );
      };
      baseImg.onload = () => {
        _this.canvas_base.width = _this.currentImg.width;
        _this.canvas_base.height = _this.currentImg.height;
        _this.ctx_base.drawImage(
          baseImg,
          0,
          0,
          _this.currentImg.width,
          _this.currentImg.height
        );
      };
    },
    handleBeLarge() {
      this.currentImg.scale = 1;
      this.currentImg.scale += 0.1;
      this.$nextTick(() => {
        this.handleDrawImage();
      });
    },
    handleBeSmall() {
      this.currentImg.scale = 1;
      this.currentImg.scale -= 0.1;
      this.$nextTick(() => {
        this.handleDrawImage();
      });
    },
    /** 下载图片*/
    handleCanvas2Img() {
      let canvas = document.getElementById("ctx_back");
      this.$refs.download.href = canvas.toDataURL();
      this.$refs.download.click();
    },
    /** 清除画布*/
    handleClearCanvas() {
      this.handleInitCanvas();
    },
    handleFrommatCanvas() {
      this.ctx_front.clearRect(
        0,
        0,
        this.canvas_front.width,
        this.canvas_front.height
      );
    },
    handleDrawCanvas(type) {
      this.canDraw = false;
      let sx, sy, mx, my;
      let text = document.getElementById("text");
      //鼠标按下
      let mousedown = (e) => {
        this.ctx_front.strokeStyle = this.defaultColor;
        this.ctx_front.lineWidth = this.slide;
        e = e || window.event;
        sx = e.clientX - this.canvas_front.offsetLeft;
        sy = e.clientY - this.canvas_front.offsetTop;
        const cbx = this.ctx_base.getImageData(
          e.offsetX - this.slide / 2,
          e.offsetY - this.slide / 2,
          this.slide * 2,
          this.slide * 2
        );
        this.ctx_front.moveTo(sx, sy);
        this.canDraw = true;
        switch (type) {
          case 1:
            this.ctx_front.beginPath();
            break;
          case 5:
            this.ctx_front.putImageData(
              cbx,
              e.offsetX - this.slide / 2,
              e.offsetY - this.slide / 2
            );
            break;
          case 6:
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
        }
      };
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
        if (this.canDraw) {
          switch (type) {
            case 1:
              this.ctx_front.lineTo(mx - 8, my - 49);
              this.ctx_front.stroke();
              break;
            case 2:
              this.handleFrommatCanvas();
              this.ctx_front.beginPath();
              this.ctx_front.moveTo(sx - 10, sy - 79);
              this.ctx_front.lineTo(mx - 10, my - 79);
              this.ctx_front.stroke();
              break;
            case 3:
              this.handleFrommatCanvas();
              this.ctx_front.beginPath();
              // eslint-disable-next-line no-case-declarations
              let rds = Math.sqrt(
                (sx - 10 - mx) * (sx - 10 - mx) +
                  (sy - 49 - my) * (sy - 49 - my)
              );
              this.ctx_front.arc(sx - 15, sy - 69, rds, 0, Math.PI * 2, false);
              this.ctx_front.stroke();
              break;
            case 4:
              this.handleFrommatCanvas();
              this.ctx_front.beginPath();
              this.ctx_front.moveTo(sx - 10, sy - 79);
              this.ctx_front.lineTo(mx - 10, sy - 79);
              this.ctx_front.lineTo(mx - 10, my - 79);
              this.ctx_front.lineTo(sx - 10, my - 79);
              this.ctx_front.lineTo(sx - 10, sy - 79);
              this.ctx_front.stroke();
              break;
            case 5:
              this.ctx_front.putImageData(
                cbx,
                e.offsetX - this.slide / 2,
                e.offsetY - this.slide / 2
              );
              break;
          }
        }
      };
      let mouseup = () => {
        if (this.canDraw) {
          this.canDraw = false;
          this.ctx_front.closePath();
          this.handleSaveCanvasStore();
        }
      };
      this.canvas_front.onmousedown = (e) => mousedown(e);
      this.canvas_front.onmousemove = (e) => mousemove(e);
      this.canvas_front.onmouseup = (e) => mouseup(e);
      this.canvas_front.onmouseout = (e) => mouseup(e);
      this.canvas_front.onmouseleave = (e) => mouseup(e);
    },
    /** 失焦或者回车绘制文本，框隐藏*/
    handleTextBlur() {
      let text = document.getElementById("text");
      this.ctx_front.font = `300 ${text.style.fontSize} sans-serif`;
      this.ctx_front.fillStyle = this.defaultColor;
      this.ctx_front.fillText(this.text, this.tl, this.tt);
      text.style.display = "none";
      this.handleSaveCanvasStore();
    },
    /** 上一步*/
    handlePrev() {
      if (this.currentImg.index > 0) {
        this.nextDis = false;
        this.currentImg.index -= 1;
        this.currentImg.index==0?this.prevDis = true:this.prevDis = false
        this.currentImg.url = this.canvasStore[this.currentImg.index];
        this.currentImg.scale = 1;
        this.handleDrawImage();
      } else {
        this.prevDis = true;
      }
    },
    /** 下一步*/
    handleNext() {
      if (this.currentImg.index<this.canvasStore.length-1) {
        this.prevDis = false;
        this.currentImg.index += 1;
        this.currentImg.index==this.canvasStore.length-1?this.nextDis = true:this.nextDis = false
        this.currentImg.url = this.canvasStore[this.currentImg.index];
        this.currentImg.scale = 1;
        this.handleDrawImage();
      } else {
        this.nextDis = true;
      }
    },
    /** 保存绘制*/
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
  },
  mounted() {
    this.$nextTick(() => {
      this.handleInitCanvas();
      this.handleChangeToolType(1);
    });
  },
  watch: {},
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped lang="less">
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}
.icon {
  width: 1em;
  height: 1em;
  vertical-align: -0.15em;
  fill: currentColor;
  overflow: hidden;
}
/deep/.el-dialog {
  display: flex;
  flex-direction: column;
  align-items: center;
  & > div {
    width: 100%;
    box-sizing: border-box;
  }
  .el-dialog__header {
    padding: 0 20px;
    p {
      padding: 20px 0;
      border-bottom: 1px solid #bdbdbd;
    }
  }
  .el-dialog__body {
    padding: 10px 20px;
    flex: 1;
    height: 0;
    padding-top: 0;
    position: relative;
    overflow: hidden;
    .d_body {
      height: 100%;
      overflow-y: auto;
      padding-top: 20px;
      .board {
        position: relative;
        min-height: 100%;
        canvas {
          // width: 100%;
          position: absolute;
          margin: 0 auto;
          left: 0;
          right: 0;
          top: 0;
        }
        #ctx_front {
          z-index: 5;
        }
        #ctx_back {
          z-index: 3;
        }
        #ctx_base {
          z-index: 1;
        }
        #text {
          position: absolute;
          z-index: -1;
          resize: none;
          outline: none;
          border: 1px dashed #eeeeee;
          overflow: hidden;
          background: transparent;
          line-height: 30px;
          display: none;
        }
      }
      .tools {
        width: 100%;
        position: absolute;
        display: flex;
        z-index: 5;
        background: #ffffff;
        transition: all 0.2s ease-in-out;
      }
      .settings {
        top: 0;
        left: 50%;
        transform: translateX(-50%);
        z-index: 10;
        padding: 5px 10px;
        border-bottom-left-radius: 4px;
        border-bottom-right-radius: 4px;
        border: 1px solid #eeeeee;
        border-top: 0;
        width: auto;
        .tool_item {
          display: flex;
          align-items: center;
          flex-wrap: nowrap;
          &:not(:last-of-type) {
            margin-right: 25px;
          }
        }
        .go_up {
          margin-right: 0 !important;
        }
        button {
          display: flex;
          flex-wrap: nowrap;
          align-items: center;
          justify-content: center;
          padding: 5px 10px;
          background: #ffffff;
          border: 1px solid #eeeeee;
          outline: none;
          cursor: pointer;
          position: relative;
          flex-wrap: nowrap;
          svg {
            color: #333333;
            font-size: 18px;
            margin-right: 5px;
          }
          span {
            white-space: nowrap;
          }
          /deep/.el-color-picker {
            position: absolute;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            .el-color-picker__trigger {
              width: 100%;
              height: 100%;
              opacity: 0;
              filter: alpha(opacity=0);
            }
          }
        }
        .slide {
          width: 150px;
          display: flex;
          flex-direction: row;
          flex-wrap: nowrap;
          align-items: center;
          svg {
            font-size: 18px;
            margin-right: 5px;
          }
          /deep/.el-slider {
            flex: 1;
            width: 0;
            margin-left: 10px;
            .el-slider__button-wrapper {
              .el-slider__button {
                width: 12px;
                height: 12px;
              }
            }
          }
        }
        .pull {
          position: absolute;
          right: 20px;
          bottom: -45px;
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: flex-start;
          margin-right: 0;
          .line {
            width: 2px;
            height: 30px;
            background: dodgerblue;
          }
          .round {
            width: 15px;
            height: 15px;
            border-radius: 50%;
            background: dodgerblue;
            cursor: pointer;
          }
        }
      }
      .bars {
        top: 100px;
        right: 30px;
        z-index: 10;
        padding: 15px;
        border-top-left-radius: 4px;
        border-bottom-left-radius: 4px;
        border: 1px solid #eeeeee;
        width: auto;
        display: flex;
        flex-direction: column;
        .tool_item {
          cursor: pointer;
          &:not(:last-of-type) {
            margin-bottom: 15px;
            border-bottom: 1px solid #dddddd;
            padding-bottom: 10px;
          }
          svg {
            font-size: 24px;
            margin-right: 8px;
          }
          span {
            font-size: 18px;
          }
          &:hover {
            svg {
              color: dodgerblue;
            }
            span {
              color: dodgerblue;
            }
          }
        }
        .activeTool {
          border-color: dodgerblue !important;
          svg {
            color: dodgerblue;
          }
          span {
            color: dodgerblue;
          }
        }
        .arrow {
          width: 20px;
          height: 20px;
          text-align: center;
          line-height: 20px;
          border-radius: 50%;
          border: 1px solid #606266;
          color: #606266;
          position: absolute;
          left: -10px;
          background: #ffffff;
          top: 50%;
          transform: translateY(-50%);
          cursor: pointer;
        }
        .el-icon-s-tools {
          left: -30px;
          width: 30px;
          height: 30px;
          line-height: 30px;
          font-size: 20px;
          color: dodgerblue;
          border-color: dodgerblue;
        }
        .el-icon-arrow-right {
          left: calc(~"100% - 10px");
        }
      }
      .hideTools {
        right: -100px;
      }
      .noExpand {
        top: -50px;
      }
    }
  }
  .el-dialog__footer {
    text-align: center !important;
    span {
      button {
        padding-left: 40px;
        padding-right: 40px;
        &:first-of-type {
          margin-right: 50px;
        }
        &:last-of-type {
          margin-left: 50px;
        }
      }
    }
  }
}
</style>
