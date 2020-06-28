<template>
  <div class="hello">
    <h1>{{ msg }}</h1>
    <p>
      A comprehensive journey into the future of DevOps.
    </p>
    <h2>Xchange 2020</h2>
    <ul>
    </ul>
    <h6>made with <span style="color: #e25555;">&hearts;</span> by</h6>
    <h4>Claudio Scalzo</h4>
    <h4>Luca Lombardo</h4>
  </div>
</template>

<script>
export default {
  name: 'HelloWorld',
  props: {
    msg: String,
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h2 {
  margin: 40px 0 0;
}
h4 {
  margin-block-end: -1.3em;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
