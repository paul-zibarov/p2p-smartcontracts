// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../utils/Ownable.sol";
import "../utils/Address.sol";
import "../utils/Initializable.sol";

abstract contract BEP721Storage is Initializable, Ownable {
    using Address for address;

    address internal _implementationAddress;
    uint public version;

    string internal _name;
    string internal _symbol;

    uint[] internal _allTokens;

    mapping(uint => string) internal _uris;
    mapping(uint => address) internal _owners;
    mapping(address => uint) internal _balances;
    mapping(uint => address) internal _tokenApprovals;
    mapping(address => mapping(address => bool)) internal _operatorApprovals;
    mapping(address => mapping(uint => uint)) internal _ownedTokens;
    mapping(uint => uint) internal _ownedTokensIndex;
    mapping(uint => uint) internal _allTokensIndex;
}