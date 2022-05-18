// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IBEP721.sol";

interface IBEP721Metadata is IBEP721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function uri(uint id) external view returns (string memory);
}
