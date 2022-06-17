// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import "../utils/Ownable.sol";
import "../utils/Address.sol";
import "../utils/ERC165.sol";
import "../utils/Initializable.sol";

abstract contract ERC721Storage is Initializable, Ownable, ERC165 {
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