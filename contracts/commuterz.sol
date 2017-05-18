pragma solidity ^0.4.8;

import "./token.sol";
import "./commuterzGame.sol";

contract Commuterz {
    struct User {
        string  IPFSDataLink;
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
        
        bool driverRated;
        bool riderRated;        
    }
    
    mapping(address=>User) users;
    mapping(bytes32=>Ride) rides;
    
    CommuterzToken public   token;
    CommuterzGame public game;
    
    address owner;
    
    uint public numUsers;
    uint public maxNumUsers;
    
    uint TOKENS_PER_USER = 200;

    event Register( address user, string IPFSLink );
    event PassangerRideRequest( address rider, bytes32 rideId, uint cost, uint timestamp ); 
    event DriverAcceptRequest( address driver, bytes32 rideId );
    event UpdateNumRides( address user, bool withDispute );
    event Dispute( address user, bytes32 rideId );
    event EndRide( bytes32 rideId, uint timestamp );
    event Rate( address user, bytes32 rideId, uint rating );
    event ResolveDispute( bytes32 rideId, bool riderIsRight );
    event CreateNewGame( address game, uint time );    
    event DoGame( address winner, address game, uint time );
        
    function createNewGame() internal {
        game = new CommuterzGame(token);
        token.transfer(game, 10000);
        CreateNewGame( game, now );        
    }        
        
    function Commuterz() {
        token = new CommuterzToken();
        owner = msg.sender;
        
        createNewGame();
        
        maxNumUsers = token.balanceOf(this) / TOKENS_PER_USER;
    }
    
    function register( string userData ) {
        // user already registered
        if( users[msg.sender].nonce != 0 ) throw;
        
        if( numUsers >= maxNumUsers ) throw;
        
        users[msg.sender].IPFSDataLink = userData;
        users[msg.sender].nonce++;
        
        token.transfer(msg.sender, TOKENS_PER_USER);
        numUsers++;
        
        Register( msg.sender, userData );
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
        
        
        PassangerRideRequest( msg.sender, rideId, rideCost, now );        
    }
    
    function driverAcceptRequest( bytes32 rideId ) {
    
        Ride ride = rides[rideId];
        if( ride.rider == address(0) ) throw; // no booking
        if( ride.driver != address(0) ) throw;
        ride.driver = msg.sender;

        // put collateral
        if( token.allowance(msg.sender,this) < ride.rideCost ) throw;        
        token.transferFrom(msg.sender, this, ride.rideCost);
        
        DriverAcceptRequest( msg.sender, rideId );        
    }
 
    function updateNumRides( address user, bool withDistpute ) internal {
        users[user].numRides++;
        if( withDistpute ) users[user].numDisputes++;
        
        UpdateNumRides( user, withDistpute );
    }
    
    function dispute( bytes32 rideId ) {
        Ride ride = rides[rideId];
        if( ride.rideEnded ) throw;
        if( ride.driver != msg.sender && ride.rider != msg.sender ) throw;
        
        ride.dispute = true;
        
        updateNumRides( ride.rider, true );
        updateNumRides( ride.driver, true );
        
        Dispute( msg.sender, rideId );         
    }
    
    function endRide( bytes32 rideId ) {
        Ride ride = rides[rideId];
        
        if( ride.driver != msg.sender ) throw;
        if( ride.dispute ) throw;
        if( ride.rideEnded ) throw;
        
        // else move collateral to driver and split payment between game and driver        
        token.transfer(msg.sender, ride.rideCost );
        token.transfer(game, 0 );
        token.transfer(ride.driver, ride.rideCost );        
        
        
        ride.rideEnded = true;
        
        updateNumRides( ride.rider, false );
        updateNumRides( ride.driver, false );
        
        EndRide( rideId, now );
    }
    
    function rate( bytes32 rideId, uint rating ) {
        Ride ride = rides[rideId];
         
        if( (! ride.rideEnded) && (! ride.dispute ) ) throw;

        address otherGuy;
                
        if( msg.sender == ride.rider ) {
            if( ride.riderRated )  throw;
            ride.riderRated = true;
            
            otherGuy = ride.driver;
        }
        else if( msg.sender == ride.driver ) {
            if( ride.driverRated ) throw;
            ride.driverRated = true;
            
            otherGuy = ride.rider;
        }
        else throw;
        
        if( rating > 5 ) throw;
        
        
        users[otherGuy].numRatedRides++;
        users[otherGuy].reputation += rating;
        
        Rate( msg.sender, rideId, rating );
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
 
        ResolveDispute( rideId, riderIsRight );       
    }
    
    function doGame( ) {
        if( msg.sender != owner ) throw;
        
        // this is not secure. change it later to blockhash of some future block
        address winner = game.chooseWinner(uint(sha3(now)));
        game.setWinner(winner);
        
        DoGame( winner, game, now );
        
        createNewGame();            
    }

    ////////////////////////////////////////////////////////////////////////////
    // status functions                                                       //
    ////////////////////////////////////////////////////////////////////////////
 
    function getUserIPFSLink( address sender ) constant returns(string){
        return users[sender].IPFSDataLink;
    }

    function getUserReputation( address sender ) constant returns(uint){
        return users[sender].reputation;
    }

    function getUserNumRides( address sender ) constant returns(uint){
        return users[sender].numRides;
    }

    function getUserNumDisputes( address sender ) constant returns(uint){
        return users[sender].numDisputes;
    }

    function getUserNumRatedRides( address sender ) constant returns(uint){
        return users[sender].numRatedRides;
    }    
}