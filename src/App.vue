<template>
  <div id="app">
    <div id="xchange-box">
      <img id="xchange-logo" alt="Xchange 2020 logo" src="./static/img/xchange2020-logo.png">
    </div>
    <div id="storm-box">
      <img id="storm-logo" alt="Storm Reply logo" src="./static/img/storm.svg">
    </div>
    <HelloWorld msg="Rabe GitOps"/>
  </div>
</template>

<script>
import HelloWorld from './components/HelloWorld.vue';

export default {
  name: 'App',
  components: {
    HelloWorld,
  },
};
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #ffffff;
  margin-top: 60px;
}

#xchange-box {
  /* width: 400px;
  height: 200px;
  text-align: center;
  margin: 0 auto 150px auto; */
  position: absolute;
  top: 20px;
  left: 10px;
  width: 300px;
  height: 150px;
}

#storm-box {
  /* width: 400px;
  height: 200px;
  text-align: center;
  margin: 0 auto 150px auto; */
  position: absolute;
  top: 20px;
  right: 40px;
  width: 200px;
  height: 100px;
}

#storm-logo {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

#xchange-logo {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

body {
  background-color: black;
}
</style>
