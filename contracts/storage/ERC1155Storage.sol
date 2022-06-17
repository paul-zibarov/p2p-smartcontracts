// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import "../utils/Initializable.sol";
import "../utils/Address.sol";
import "../utils/Ownable.sol";

abstract contract ERC1155Storage is Initializable, Ownable {
    using Address for address;

    address internal _implementationAddress;
    uint public version;

    string internal _name;
    string internal _symbol;

    mapping(uint => uint) internal _totalSupply;
    mapping(uint => string) internal _uris;
    mapping(uint => mapping(address => uint)) internal _balances;
    mapping(address => mapping(address => bool)) internal _operatorApprovals;
}