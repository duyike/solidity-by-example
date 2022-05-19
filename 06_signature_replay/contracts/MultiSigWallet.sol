// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
pragma experimental ABIEncoderV2;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.5/contracts/utils/cryptography/ECDSA.sol";

contract MultiSignWallet {
    using ECDSA for bytes32;

    address[2] public owners;

    constructor(address[2] memory _owners) {
        owners = _owners;
    }

    function deposit() public payable {}

    function transfer(address _to, uint _amount, bytes[2] memory _sigs) public {
        bytes32 txHash = getTxHash(_to, _amount);
        require(_checkSigs(_sigs, txHash), "Invalid sigs"); 

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    } 

    function getTxHash(address _to, uint _amount) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_to, _amount));
    }

    function _checkSigs(bytes[2] memory _sigs, bytes32 _txHash) private view returns (bool) {
        bytes32 ethSignedMessgaeHash = _txHash.toEthSignedMessageHash();

        for (uint i = 0; i < _sigs.length; i++) {
            address signer = ethSignedMessgaeHash.recover(_sigs[i]);
            if (signer != owners[i]) {
                return false;
            }
        }

        return true;
    }
}

// attack case 1: same sigs & same contract address
// attack case 2: same sigs & different contract address & same code
// attack case 3: same sigs & same contract address & self-destruct


contract SafeMultiSignWallet {
    using ECDSA for bytes32;

    address[2] public owners;
    mapping(bytes32 => bool) public executed;

    constructor(address[2] memory _owners) {
        owners = _owners;
    }

    function deposit() public payable {}

    // use nonce to prevent attack case 1
    function transfer(address _to, uint _amount, uint _nonce, bytes[2] memory _sigs) public {
        bytes32 txHash = getTxHash(_to, _amount, _nonce);
        require(!executed[txHash], "tx executed");
        require(_checkSigs(_sigs, txHash), "Invalid sigs"); 

        executed[txHash] = true;
        
        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    } 

    // use address(this) to prevent attack case 2
    function getTxHash(address _to, uint _amount, uint _nonce) public view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), _to, _amount, _nonce));
    }

    function _checkSigs(bytes[2] memory _sigs, bytes32 _txHash) private view returns (bool) {
        bytes32 ethSignedMessgaeHash = _txHash.toEthSignedMessageHash();

        for (uint i = 0; i < _sigs.length; i++) {
            address signer = ethSignedMessgaeHash.recover(_sigs[i]);
            if (signer != owners[i]) {
                return false;
            }
        }

        return true;
    }
}