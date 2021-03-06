//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import "./AssetType.sol";

abstract contract TradeMultiStruct {
    struct TradeMulti {
        address initiator;
        address counterparty;
        address[] proposedAssets;
        uint proposedAmount;
        uint[] proposedTokenIds;
        address[] askedAssets;
        uint[] askedTokenIds;
        uint askedAmount;
        uint deadline;
        uint status;
        AssetType proposedAssetType;
        AssetType askedAssetType;
    }
}