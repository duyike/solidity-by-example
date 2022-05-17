// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// The goal of this game is to be the 7th player to deposit 1 Ether.
// Players can deposit only 1 Ether at a time.
// Winner will be able to withdraw all Ether.

/*
1. Deploy EtherGame
2. Players (say Alice and Bob) decides to play, deposits 1 Ether each.
2. Deploy Attack with address of EtherGame
3. Call Attack.attack sending 5 ether. This will break the game
   No one can become the winner.

What happened?
Attack forced the balance of EtherGame to equal 7 ether.
Now no one can deposit and the winner cannot be set.
*/

// THIS CONTRACT CONTAINS A BUG - DO NOT USE
contract EtherGame {
    uint public targetAmount = 7 ether;
    address public winner;

    function deposit() public payable {
        require(msg.value == 1 ether, "You can only deposit 1 ether");

        uint bal = address(this).balance;
        require(bal <= targetAmount, "The game is over");
        
        if (bal == targetAmount) {
            winner = msg.sender;
        }
    }

    function claimReward() public {
        require(msg.sender == winner, "You are not winnner");

        winner = address(0);

        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send ether");
    }

}

contract Attack {

    function attack(address payable _targetAddress) public payable {
        selfdestruct(_targetAddress);
    }

}

contract SafeEtherGame {
    uint public targetAmount = 7 ether;
    address public winner;
    // use a variable to store balance
    // instead of rely on this.balance
    uint public balance;

    function deposit() public payable {
        require(msg.value == 1 ether, "You can only deposit 1 ether");

        balance += msg.value;
        require(balance <= targetAmount, "The game is over");

        if (balance == targetAmount) {
            winner = msg.sender;
        }
    }

    function claimReward() public {
        require(msg.sender == winner, "You are not winnner");

        winner = address(0);

        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send ether");
    }
}