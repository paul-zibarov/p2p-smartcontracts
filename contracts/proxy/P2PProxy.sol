//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;


import "../utils/Proxy.sol";
import "../storage/P2PStorage.sol";

contract P2PProxy is Proxy, P2PStorage {
    
    event ReplaceImplementation(address oldTarget, address newTarget);

    constructor(address target) {
        _implementationAddress = target;
        emit ReplaceImplementation(address(0), target);
    }
    
    function implementation() public view returns (address) { 
        return _implementationAddress; 
    }

    function _implementation() internal view override returns (address) { 
        return _implementationAddress; 
    }

    function replaceImplementation(address newTarget) external onlyOwner {
        require(newTarget != address(0), "ArtifactsNFTProxy: target's address is equal to zero address");
        version += 1;
        address oldTarget = _implementationAddress;
        _implementationAddress = newTarget;
        emit ReplaceImplementation(oldTarget, newTarget);
    }
}