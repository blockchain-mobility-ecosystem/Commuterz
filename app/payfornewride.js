var common = require('./common');
var web3 = common.getWeb3();
var commuterzInstance = common.getCommuterzInstance();
var tokenInstance = common.getTokenInstance();
var rideCost = common.getRideCost();

web3.eth.defaultAccount = common.getRiderAddress();
ret = tokenInstance.approve(commuterzInstance.address, rideCost); 
console.log(ret);
