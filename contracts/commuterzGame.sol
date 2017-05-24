pragma solidity ^0.4.8;

import "./token.sol";

contract CommuterzGame {
        
    address public owner;
    address public winner;
    
    CommuterzToken token;
    
    struct Ticket {
        address user;
        uint    amount;
        uint    sumTicketsAmounts; // future preperation for binary search
    }
    
    Ticket[] tickets;
    uint   public totalAmount;
    
    function CommuterzGame( CommuterzToken _token ) {
        owner = msg.sender;
        token = _token;
    }
    
    function addTicket( address user, uint amount ) {
        if( msg.sender != owner ) throw;

        totalAmount += amount;
        
        Ticket memory ticket;
        
        ticket.user = user;
        ticket.amount = amount;
        ticket.sumTicketsAmounts = totalAmount;
        
        tickets.push(ticket);
    }
    
    function chooseWinner( uint seed ) constant returns(address) {
        if( totalAmount == 0 ) return address(0);
        
        uint threshold = seed % totalAmount;
        
        uint currentSum = 0;
        
        for( uint i = 0 ; i < tickets.length ; i++ ) {
            Ticket memory ticket = tickets[i];
            currentSum += ticket.amount;
            
            if( currentSum >= threshold ) {
                return ticket.user;
            }
        }
        
        return address(0); // no users were listed
    }
    
    function setWinner( address theWinner ) {
        if( msg.sender != owner ) throw;
    
        winner = theWinner;
    }
    
    function collectPrize( ) {
        if( msg.sender != winner ) throw;
        token.transfer( winner, token.balanceOf(this) ); 
    }
}