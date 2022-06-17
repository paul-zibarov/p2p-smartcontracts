// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

import "./IERC721.sol";

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function uri(uint id) external view returns (string memory);
}
