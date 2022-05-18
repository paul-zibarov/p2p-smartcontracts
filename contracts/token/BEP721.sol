//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../interfaces/IBEP721.sol";
import "../interfaces/IBEP721Enumerable.sol";
import "../interfaces/IBEP721Metadata.sol";
import "../storage/BEP721Storage.sol";

contract BEP721 is IBEP721, IBEP721Metadata, BEP721Storage {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    modifier onlyTokenOwner(uint tokenId) {
        require(msg.sender == ownerOf(tokenId), "BEP721: msg sender is not an owner of token");
        _;
    }

    function initialize(string memory name_, string memory symbol_) external initializer {
        _name = name_;
        _symbol = symbol_;
    }

    function name() external view virtual override returns (string memory) {
        return _name;
    }

    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }
        
    function uri(uint id) external view virtual override returns (string memory) {
        return _uris[id];
    }


    function balanceOf(address owner) public view virtual override returns (uint) {
        require(owner != address(0), "BEP721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "BEP721: owner query for nonexistent token");
        return owner;
    }


    function approve(address to, uint tokenId) public virtual override {
        address owner = BEP721.ownerOf(tokenId);
        require(to != owner, "BEP721: approval to current owner");

        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "BEP721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "BEP721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != msg.sender, "BEP721: approve to caller");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }



    function transferFrom(address from, address to, uint tokenId) public virtual override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "BEP721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint tokenId) public virtual override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "BEP721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId);
    }



    function safeMint(address to, uint tokenId) external onlyOwner {
        _mint(to, tokenId);
    }

    function safeBurn(uint tokenId) external onlyTokenOwner(tokenId) {
        _burn(tokenId);
    }


    function _exists(uint tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _mint(address to, uint tokenId) internal virtual {
        require(to != address(0), "BEP721: mint to the zero address");
        require(!_exists(tokenId), "BEP721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint tokenId) internal virtual {
        address owner = owner();
        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint tokenId) internal virtual {
        require(BEP721.ownerOf(tokenId) == from, "BEP721: transfer of token that is not own");
        require(to != address(0), "BEP721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(BEP721.ownerOf(tokenId), to, tokenId);
    }
    
    function _isApprovedOrOwner(address spender, uint tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "BEP721: operator query for nonexistent token");
        address owner = BEP721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeTransfer(address from, address to, uint tokenId) internal virtual {
        _transfer(from, to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint tokenId) internal virtual {
    }
}