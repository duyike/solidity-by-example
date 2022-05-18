// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
The goal of KingOfEther is to become the king by sending more Ether than
the previous king. Previous king will be refunded with the amount of Ether
he sent.
*/

/*
1. Deploy KingOfEther
2. Alice becomes the king by sending 1 Ether to claimThrone().
2. Bob becomes the king by sending 2 Ether to claimThrone().
   Alice receives a refund of 1 Ether.
3. Deploy Attack with address of KingOfEther.
4. Call attack with 3 Ether.
5. Current king is the Attack contract and no one can become the new king.

What happened?
Attack became the king. All new challenge to claim the throne will be rejected
since Attack contract does not have a fallback function, denying to accept the
Ether sent from KingOfEther before the new king is set.
*/

// THIS CONTRACT CONTAINS A BUG - DO NOT USE
contract KingOfEther {
    address public king;
    uint public balance;

    function claimThrone() public payable {
        require(msg.value > balance, "Insufficient Ether");

        (bool sent, ) = king.call{value: balance}("");
        require(sent, "Failed to send ether");

        king = msg.sender;
        balance = msg.value;
    }
}

contract Attack {
    
    function attack(address _kingOfEtherAddress) public payable {
        KingOfEther(_kingOfEtherAddress).claimThrone{value: msg.value}();
    }

}

// Use pulling(withdraw) instead of pushing to avoid denial of service attack
contract SafeKingOfEther {
    address public king;
    uint public balance;
    mapping(address => uint) public balances;

    function claimThrone() public payable {
        require(msg.value > balance, "Insufficient Ether");

        balances[king] += balance;

        king = msg.sender;
        balance = msg.value;
    }

    function withdraw() public {
        require(balances[msg.sender] > 0, "No balance to withdraw");

        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}