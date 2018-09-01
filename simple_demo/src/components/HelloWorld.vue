<template>
  <v-container align-center text-xs-center id="create">
    <v-layout fill-height column justify-space-around align-space-around wrap>
      <v-icon v-if="!otherWaiting" size="20rem">{{otherChoose}}</v-icon>
      <div v-else class="text-xs-center">
        <v-progress-circular
          :size="200"
          :width="20"
          color="grey"
          indeterminate
        ></v-progress-circular>
      </div>
      <v-icon size="20rem">{{myChoose}}</v-icon>
    </v-layout>
    <v-speed-dial
      v-model="fab"
      bottom
      right
      direction='top'
      transition='slide-y-reverse-transition'
    >
      <v-btn
        slot="activator"
        v-model="fab"
        color="pink"
        dark
        fab
      >
        <v-icon>add</v-icon>
        <v-icon>close</v-icon>
      </v-btn>
      <v-btn
        fab
        dark
        small
        color="green"
        @click.native="startGame('rock')"
      >
        <v-icon>fa-hand-rock</v-icon>
      </v-btn>
      <v-btn
        fab
        dark
        small
        color="indigo"
        @click.native="startGame('scissors')"
      >
        <v-icon>fa-hand-scissors</v-icon>
      </v-btn>
      <v-btn
        fab
        dark
        small
        color="red"
        @click.native="startGame('paper')"
      >
        <v-icon>fa-hand-paper</v-icon>
      </v-btn>
    </v-speed-dial>


    <v-dialog
      v-model="dialog"
      max-width="290"
    >
      <v-card>
        <v-card-title class="headline">{{dialogText}}</v-card-title>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            color="green darken-1"
            flat="flat"
            @click="dialog = false"
          >
            Play Again
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog
      v-model="otherWaiting"
      hide-overlay
      persistent
      width="300"
    >
      <v-card
        color="primary"
        dark
      >
        <v-card-text>
          Waiting for CONTRACT
          <v-progress-linear
            indeterminate
            color="white"
            class="mb-0"
          ></v-progress-linear>
        </v-card-text>
      </v-card>
    </v-dialog>
  </v-container>
</template>


<script>
  //import Nervos from '@nervos/chain'
  //const nervos = Nervos('http://121.196.200.225:1337');
  //const nervos = Nervos('http://172.16.101.142:1337');
  const nervos = require('../nervos');
  const { abi } = require('../contract/compiled');
  const { contractAddress } = require('../config');
  const transaction = require('../contract/transaction');
  const getRSPContract = new nervos.appchain.Contract(abi, contractAddress);

  export default {
    data () {
      return {
        title: 'HelloWorld',
        fab: false,
        otherWaiting: false,
        myChoose: 'fa-question',
        myRes: 0,
        otherChoose: 'fa-question',
        dialogText: 'You Won!',
        dialog: false
      }
    },
    methods: {
      startGame(my) {
        let myNum = 0;
        this.otherWaiting = true;
        switch (my) {
          case 'rock':
            console.log(my);
            this.myChoose = 'fa-hand-rock';
            myNum = 0;
            break;
          case 'paper':
            console.log(my);
            this.myChoose = 'fa-hand-paper';
            myNum = 1;
            break;
          case 'scissors':
            console.log(my);
            this.myChoose = 'fa-hand-scissors';
            myNum = 2;
            break;
        }
        this.myRes = myNum;

        nervos.appchain.getBlockNumber()
          .then(currentBlockHeight => {
              const tx = {
                ...transaction,
                from: window.neuron.getAccount(),
                validUntilBlock: +currentBlockHeight + 88
              };
              console.log("account: " + window.neuron.getAccount());
              return getRSPContract.methods.oneRound(myNum).send(tx);
            })
          .then(res => {
            console.log(res);
            if (res) {
              return nervos.listeners.listenToTransactionReceipt(res)
            } else {
              throw new Error('No Transaction Hash Received');
            }
          }).then(receipt => {
            console.log(receipt);
            let otherRes = parseInt(receipt['logs'][0]['topics'][2], 16);
            console.log(otherRes);
            switch (otherRes) {
              case 0 :
                this.otherChoose = 'fa-hand-rock';
                break;
              case 1 :
                this.otherChoose = 'fa-hand-paper';
                break;
              case 2 :
                this.otherChoose = 'fa-hand-scissors';
                break;
            }
            if (otherRes - this.myRes === -1 || otherRes - this.myRes == 2) {
              this.dialogText = 'You Win!';
            } else if (otherRes === this.myRes) {
              this.dialogText = 'Oops...';
            } else {
              this.dialogText = 'You Lose';
            }
            this.dialog = true;
            this.otherWaiting = false;
        })

      }
    },
    created() {
      console.log("Created Hello World Component");
      console.log(abi);
      console.log(transaction);
      console.log(contractAddress);
      nervos.appchain.getMetaData()
        .then(res => {
          console.log(res)
        })
    },
    name: 'HelloWorld'
  }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h1, h2 {
  font-weight: normal;
  font-size: 10em;
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

/* This is for documentation purposes and will not be needed in your application */
#create .v-speed-dial {
  position: absolute;
}



#create .v-btn--floating {
  position: relative;
}
</style>
