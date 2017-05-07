var common = require('./common');
var web3 = common.getWeb3();
var commuterzInstance = common.getCommuterzInstance();
var rideCost = common.getRideCost();

web3.eth.defaultAccount = common.getRiderAddress();

var rideId = commuterzInstance.getRideId(common.getRiderAddress());
console.log(rideId);

var ret = commuterzInstance.passangerRideRequest(rideCost);
console.log(ret);