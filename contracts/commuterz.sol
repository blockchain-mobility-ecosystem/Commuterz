pragma solidity ^0.4.8;

import "./token.sol";

contract Commuterz {
    struct User {
        bytes32 IPFSDataHash;
        uint    nonce;
        uint    reputation;
        
        uint    numRides;
        uint    numDisputes;
        uint    numRatedRides;
    }
    
    struct Ride {
        address rider;
        address driver;
        
        uint rideCost;
        
        bool rideEnded;
        bool dispute;
        
        
    }
    
    mapping(address=>User) users;
    mapping(bytes32=>Ride) rides;
    
    CommuterzToken token;
    
    address owner;
    
    uint numUsers;
    uint maxNumUsers;
    
    uint TOKENS_PER_USER = 50;
    
    function Commuterz() {
        token = new CommuterzToken();
        owner = msg.sender;
        
        maxNumUsers = token.balanceOf(this) / TOKENS_PER_USER;
    }
    
    function register( bytes32 userData ) {
        // user already registered
        if( users[msg.sender].nonce != 0 ) throw;
        
        if( numUsers >= maxNumUsers ) throw;
        
        users[msg.sender].IPFSDataHash = userData;
        users[msg.sender].nonce++;
        
        token.transfer(msg.sender, TOKENS_PER_USER);
        numUsers++;
    }
    
    function getRideId( address sender ) constant returns(bytes32) {
        return sha3(sender, users[sender].nonce );
    }
    
    function passangerRideRequest( uint rideCost ) {
        // user is not registered
        if( users[msg.sender].nonce == 0 ) throw;
        
        bytes32 rideId = getRideId( msg.sender );
        users[msg.sender].nonce++;
        
        Ride ride = rides[rideId];
        ride.rider = msg.sender;
        ride.rideCost = rideCost;
        
        // charge for ride
        if( token.allowance(msg.sender,this) < rideCost ) throw;
        token.transferFrom(msg.sender, this, rideCost);
    }
    
    function driverAcceptRequest( bytes32 rideId ) {
    
        Ride ride = rides[rideId];
        if( ride.driver != address(0) ) throw;
        ride.driver = msg.sender;

        // put collateral
        if( token.allowance(msg.sender,this) < ride.rideCost ) throw;        
        token.transferFrom(msg.sender, this, ride.rideCost);
    }
 
    function updateNumRides( address user, bool withDistpute ) internal {
        users[user].numRides++;
        if( withDistpute ) users[user].numDisputes++;
    }
    
    function dispute( bytes32 rideId ) {
        Ride ride = rides[rideId];
        if( ride.rideEnded ) throw;
        if( ride.driver != msg.sender && ride.rider != msg.sender ) throw;
        
        ride.dispute = true;
        
        updateNumRides( ride.rider, true );
        updateNumRides( ride.driver, true );        
    }
    
    function endRide( bytes32 rideId ) {
        Ride ride = rides[rideId];
        
        if( ride.driver != msg.sender ) throw;
        if( ride.dispute ) throw;
        if( ride.rideEnded ) throw;
        
        // else move money to driver
        // * 2 factor because of collateral        
        token.transfer(msg.sender, ride.rideCost * 2 );
        
        ride.rideEnded = true;
        
        updateNumRides( ride.rider, false );
        updateNumRides( ride.driver, false );
    }
    
    function rate( bytes32 rideId, uint rating ) {
        Ride ride = rides[rideId];
        
        if( (! ride.rideEnded) || (! ride.dispute ) ) throw;
        if( ride.rider != msg.sender || ride.driver != msg.sender ) throw;
        if( rating > 5 ) throw;
        
        address otherGuy;
        if( msg.sender != ride.rider ) otherGuy = ride.rider;
        else otherGuy = ride.driver;
        
        users[otherGuy].numRatedRides++;
        users[otherGuy].reputation += rating;
    }
    
    function resolveDispute( bytes32 rideId, bool riderIsRight ) {
        if( msg.sender != owner ) throw;
        
        Ride ride = rides[rideId];
        
        if( ! ride.dispute ) throw;
        if( ride.rideEnded ) throw;
        
        address to;
        
        if( riderIsRight ) to = ride.rider;
        else to = ride.driver;
        
        // * 2 factor because of collateral
        token.transfer(to, ride.rideCost * 2 );
        
        ride.rideEnded = true;
        
    }
}