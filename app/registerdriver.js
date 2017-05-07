var common = require('./common');
var web3 = common.getWeb3();
var commuterzInstance = common.getCommuterzInstance();


var user2IPFSHash = "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccd";


// register
web3.eth.defaultAccount = common.getDriverAddress();
var ret = commuterzInstance.register(user2IPFSHash);
console.log(ret);
