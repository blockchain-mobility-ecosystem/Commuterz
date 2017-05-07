var common = require('./common');
var web3 = common.getWeb3();
var commuterzInstance = common.getCommuterzInstance();


var user1IPFSHash = "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc";


// register
web3.eth.defaultAccount = common.getRiderAddress();
var ret = commuterzInstance.register(user1IPFSHash);
console.log(ret);
