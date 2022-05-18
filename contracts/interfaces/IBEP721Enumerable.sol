// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IBEP721.sol";

interface IBEP721Enumerable is IBEP721 {
    function totalSupply() external view returns (uint);
    function tokenOfOwnerByIndex(address owner, uint index) external view returns (uint tokenId);
    function tokenByIndex(uint index) external view returns (uint);
    function userTokens(address owner) external view returns (uint[] memory);
}
