<template>
  <div class="hello">
    <div id="welcome">
      <h1>{{ msg }}</h1>
      <h2>{{ welcomeMessage }}</h2>
      <ul>
      </ul>
    </div>
    <div id="madeby">
    <h5><i>made with <span style="color: #e25555;">&hearts;</span> by</i></h5>
    <h4>Claudio Scalzo</h4>
    <h4>Luca Lombardo</h4>
    </div>
  </div>
</template>

<script>
import '../static/js/config.js'

export default {
  name: 'HelloWorld',
  props: {
    msg: String,
  },
  data () {
    return {
      welcomeMessage: ""
    }
  },
  methods: {
    getWelcomeMessage: function() {
      const axios = require('axios');
      axios({
        method: 'get',
        url: `https://${endpoints.API_ENDPOINT}/message/welcome`,
        timeout: '3000'
      }).then(response => {
          console.log(response);
          this.welcomeMessage = response.data;
        })
        .catch(error => {
          console.log(error);
          this.welcomeMessage = "A comprehensive journey into the future of DevOps";
        });
    }
  },
  mounted () {
    this.getWelcomeMessage()
  }
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h1 {
  font-size: 400%;
  font-weight: bold;
}

h2 {
  margin: 40px 0 0;
  font-size: 150%;
  font-weight: lighter;
}
h4 {
  margin-block-end: -1.3em;
}

h5 {
  font-weight: lighter;
  font-size: 100%;
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

#welcome {
  position: absolute;
  margin: auto;
  width: 50%;
  height: 30%;
  top: 50%;
  left: 50%;
  margin-top: -15%;
  margin-left: -25%;
}

#madeby {
  position: fixed;
  width: 100%;
  bottom: 0;
  text-align: center;
  margin: 0 auto 50px auto;
}
</style>
