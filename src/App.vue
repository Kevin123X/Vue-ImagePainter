<template>
  <div id="app">
    <ImgDraw />
  </div>
</template>

<script>
import ImgDraw from './components/imgDraw/imgDraw'

export default {
  name: 'app',
  components: {
    ImgDraw
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
  margin-top: 60px;
}
</style>
