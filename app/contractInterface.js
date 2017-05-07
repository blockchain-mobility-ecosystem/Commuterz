var BigNumber = require('bignumber.js');
var Tx = require('ethereumjs-tx');
var Web3 = require('web3');
// create an instance of web3 using the HTTP provider.
// NOTE in mist web3 is already available, so check first if its available before instantiating
url = "http://localhost:8545/jsonrpc";

//url = "https://mainnet.infura.io:8545" 
var web3 = new Web3(new Web3.providers.HttpProvider(url));


var commuterzAddress = "0x31a0d62ed3cf124c5989183d5608f3509f89f869";
var commuterzABI = [{"constant":false,"inputs":[{"name":"rideId","type":"bytes32"},{"name":"rating","type":"uint256"}],"name":"rate","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"rideId","type":"bytes32"},{"name":"riderIsRight","type":"bool"}],"name":"resolveDispute","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"rideCost","type":"uint256"}],"name":"passangerRideRequest","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"rideId","type":"bytes32"}],"name":"endRide","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"rideId","type":"bytes32"}],"name":"dispute","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"sender","type":"address"}],"name":"getRideId","outputs":[{"name":"","type":"bytes32"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"rideId","type":"bytes32"}],"name":"driverAcceptRequest","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"userData","type":"bytes32"}],"name":"register","outputs":[],"payable":false,"type":"function"},{"inputs":[],"payable":false,"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"name":"user","type":"address"},{"indexed":false,"name":"IPFSHash","type":"bytes32"}],"name":"Register","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"rider","type":"address"},{"indexed":false,"name":"rideId","type":"bytes32"},{"indexed":false,"name":"cost","type":"uint256"},{"indexed":false,"name":"timestamp","type":"uint256"}],"name":"PassangerRideRequest","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"driver","type":"address"},{"indexed":false,"name":"rideId","type":"bytes32"}],"name":"DriverAcceptRequest","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"user","type":"address"},{"indexed":false,"name":"withDispute","type":"bool"}],"name":"UpdateNumRides","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"user","type":"address"},{"indexed":false,"name":"rideId","type":"bytes32"}],"name":"Dispute","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"rideId","type":"bytes32"},{"indexed":false,"name":"timestamp","type":"uint256"}],"name":"EndRide","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"user","type":"address"},{"indexed":false,"name":"rideId","type":"bytes32"},{"indexed":false,"name":"rating","type":"uint256"}],"name":"Rate","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"rideId","type":"bytes32"},{"indexed":false,"name":"riderIsRight","type":"bool"}],"name":"ResolveDispute","type":"event"}];


var commuterzClass = web3.eth.contract(commuterzABI);
var commuterzInstance = commuterzClass.at(commuterzAddress);


var tokenAddress = "0x09877282a0046808FC2c763d7CdD894Fc845c684";
var tokenABI = [{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"INITIAL_SUPPLY","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"remaining","type":"uint256"}],"payable":false,"type":"function"},{"inputs":[],"payable":false,"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"owner","type":"address"},{"indexed":true,"name":"spender","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Transfer","type":"event"}]


var tokenClass = web3.eth.contract(tokenABI);
var tokenInstance = tokenClass.at(tokenAddress);
 

var rider = '0x889d1ab899f607cd21e6a499d76313a1f8ca260d';
var driver = '0xd30c2a33463889ae709cd39f177faa7d848f9e82';


////////////////////////////////////////////////////////////////////////////////

var waitForConfirmation = function( txHash ) {
    /* 
    while(true) {
        var receipt = web3.eth.getTransactionReceipt('txHash');
        if( receipt.blockHash != null ) return;
    }*/
    sleep.sleep(10);
};

////////////////////////////////////////////////////////////////////////////////



// register
var user1IPFSHash = "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc";

var rideCost = 10;


// register

web3.eth.defaultAccount=  driver;//web3.eth.accounts[0];
var ret = commuterzInstance.register(user1IPFSHash);
console.log(ret);
//waitForConfirmation(ret);


// passanger
var user2IPFSHash = "0xcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccd";


web3.eth.defaultAccount = rider;
var ret = commuterzInstance.register(user2IPFSHash);
console.log(ret);
//waitForConfirmation(ret);





// rider invites a drive. needs to put tokens first

web3.eth.defaultAccount = rider;
ret = tokenInstance.approve(new BigNumber(commuterzAddress), rideCost); 
console.log(ret);


var rideId = commuterzInstance.getRideId(rider);

web3.eth.defaultAccount = rider;
ret = commuterzInstance.passangerRideRequest(rideCost);
console.log(ret);
//waitForConfirmation(ret);





// driver approves the ride. need to put tokens first

web3.eth.defaultAccount = driver;
ret = tokenInstance.approve(new BigNumber(commuterzAddress), rideCost); 
console.log(ret);


web3.eth.defaultAccount = driver;
ret = commuterzInstance.driverAcceptRequest(rideId); 
console.log(ret);
//waitForConfirmation(ret);



// driver approves end of ride
web3.eth.defaultAccount = driver;
ret = commuterzInstance.endRide(rideId); 
console.log(ret);
//waitForConfirmation(ret);



// driver rates rider and vice versa

web3.eth.defaultAccount = driver;
ret = commuterzInstance.rate(rideId,3); 
console.log(ret);

var rideId = "0xb0701b3fe4e3fb0ca8e1affa491ba2bc73a0759b8b151f02c796560c1eb72494";
web3.eth.defaultAccount = rider;
ret = commuterzInstance.rate(rideId,3); 
console.log(ret);
