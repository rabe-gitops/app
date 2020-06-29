<template>
  <div class="hello">
    <h1>{{ msg }}</h1>
    <h2>{{ welcomeMessage }}</h2>
    <ul>
    </ul>
    <h4><i>made with <span style="color: #e25555;">&hearts;</span> by</i></h4>
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
        url: 'https://api.rabegitops.it/messages/welcome',
        timeout: '3000'
      }).then(response => {
          console.log(response);
          this.welcomeMessage = response.data;
        })
        .catch(error => {
          console.log(error);
          this.welcomeMessage = "error";
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
