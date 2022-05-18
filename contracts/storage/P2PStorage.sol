//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../objects/TradeObjects.sol";
import "../utils/Ownable.sol";
import "../utils/Address.sol";
import "../utils/TransferHelper.sol";
import "../interfaces/IWBNB.sol";

enum TradeState {
    Active,
    Succeeded,
    Canceled,
    Withdrawn,
    Overdue,
    CanceledOrWithdrawn
}

contract P2PStorage is Ownable, TradeObjects {    
    
    address public _implementationAddress;
    uint public version;
        
    uint public tradeCount;
    bool public isAnyNFTAllowed;
    uint public unlocked = 1;
    IWBNB public WBNB;
    
    mapping(uint => TradeSingle) public tradesSingle;
    mapping(uint => TradeMulti) public tradesMulti;
    mapping(address => uint[]) internal _userTrades;
    mapping(address => bool) public allowedNFT;
}