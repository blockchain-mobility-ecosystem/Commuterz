var common = require('./common');
var web3 = common.getWeb3();
var commuterzInstance = common.getCommuterzInstance();
var rideCost = common.getRideCost();

web3.eth.defaultAccount = common.getDriverAddress();

var rideId = common.getCurrentRideId();

var ret = commuterzInstance.endRide(rideId);
console.log(ret);