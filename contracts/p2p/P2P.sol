//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.10;

import "../storage/P2PStorage.sol";
import "../interfaces/IERC721Receiver.sol";
import "../utils/ERC1155Holder.sol";
import "../interfaces/IERC1155.sol";
import "../interfaces/IERC721.sol";

contract P2P is P2PStorage, IERC721Receiver, ERC1155Holder {    

    event NewTradeSingle(address indexed user, address indexed proposedAsset, uint proposedAmount, uint proposedTokenId, address indexed askedAsset, uint askedAmount, uint askedTokenId, uint deadline, uint tradeId);
    event NewTradeMulti(address indexed user, address[] proposedAssets, uint proposedAmount, uint[] proposedIds, address[] askedAssets, uint askedAmount, uint[] askedIds, uint deadline, uint indexed tradeId);
    event SupportTrade(uint indexed tradeId, address indexed counterparty);
    event CancelTrade(uint indexed tradeId);
    event WithdrawOverdueAsset(uint indexed tradeId);
    event CancelOrWithdrawOverdueAssetTrade(uint indexed tradeId);
    event UpdateIsAnyNFTAllowed(bool indexed isAllowed);
    event UpdateAllowedNFT(address indexed nftContract, bool indexed isAllowed);

    receive() external payable {
        assert(msg.sender == address(WBNB)); // only accept ETH via fallback from the WBNB contract
    }
    
    modifier lock() {
        require(unlocked == 1, 'P2P: locked');
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function createTrade20To20(address proposedAsset, uint proposedAmount, address askedAsset, uint askedAmount, uint deadline) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset) && Address.isContract(askedAsset), "P2P: Not contracts");
        require(proposedAmount > 0, "P2P: Zero amount not allowed");
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, 0, askedAsset, askedAmount, 0, deadline, AssetType.ERC20, AssetType.ERC20);   
    }

    // for trade ERC20 -> Native Coin use createTradeERC20ToERC20 and pass WBNB address as asked asset
    function createTradeBNBto20(address askedAsset, uint askedAmount, uint deadline) payable external returns (uint tradeId) {
        require(Address.isContract(askedAsset), "P2P: Not contract");
        require(msg.value > 0, "P2P: Zero amount not allowed");
        WBNB.deposit{value: msg.value}();
        tradeId = _createTradeSingle(address(WBNB), msg.value, 0, askedAsset, askedAmount, 0, deadline, AssetType.ERC20, AssetType.ERC20);   
    }



    function createTrade20To721(address proposedAsset, uint proposedAmount, address askedAsset, uint tokenId, uint deadline) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset), "P2P: Not contracts");
        require(proposedAmount > 0, "P2P: Zero amount not allowed");
        _requireAllowed721Or1155(askedAsset);
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, 0, askedAsset, 0, tokenId, deadline, AssetType.ERC20, AssetType.ERC721);   
    }

    // for trade NFT -> Native Coin use createTradeNFTtoERC20 and pass WBNB address as asked asset
    function createTrade721to20(address proposedAsset, uint tokenId, address askedAsset, uint askedAmount, uint deadline) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset), "P2P: Not contracts");
        _requireAllowed721Or1155(proposedAsset);
        IERC721(proposedAsset).safeTransferFrom(msg.sender, address(this), tokenId);
        tradeId = _createTradeSingle(proposedAsset, 0, tokenId, askedAsset, askedAmount, 0, deadline, AssetType.ERC721, AssetType.ERC20);   
    }

    function createTradeBNBto721(address askedAsset, uint tokenId, uint deadline) payable external returns (uint tradeId) {
        require(Address.isContract(askedAsset), "P2P: Not contract");
        require(msg.value > 0, "P2P: Zero amount not allowed");
        _requireAllowed721Or1155(askedAsset);
        WBNB.deposit{value: msg.value}();
        tradeId = _createTradeSingle(address(WBNB), msg.value, 0, askedAsset, 0, tokenId, deadline, AssetType.ERC20, AssetType.ERC721);   
    }



    function createTrade1155to20(address proposedAsset, uint proposedAmount, uint proposedTokenId, address askedAsset, uint askedAmount, uint deadline) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset), "P2P: Not contracts");
        require(proposedAmount > 0, "P2P: Zero amount not allowed");
        _requireAllowed721Or1155(proposedAsset);
        IERC1155(proposedAsset).safeTransferFrom(msg.sender, address(this), proposedTokenId, proposedAmount, "");
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, proposedTokenId, askedAsset, askedAmount, 0, deadline, AssetType.ERC1155, AssetType.ERC20);   
    }

    function createTrade20To1155(address proposedAsset, uint proposedAmount, address askedAsset, uint tokenId, uint askedAmount, uint deadline) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset), "P2P: Not contracts");
        require(proposedAmount > 0, "P2P: Zero amount not allowed");
        _requireAllowed721Or1155(askedAsset);
        TransferHelper.safeTransferFrom(proposedAsset, msg.sender, address(this), proposedAmount);
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, 0, askedAsset, askedAmount, tokenId, deadline, AssetType.ERC20, AssetType.ERC1155);   
    }

    function createTradeBNBto1155(address askedAsset, uint tokenId, uint askedAmount, uint deadline) payable external returns (uint tradeId) {
        require(Address.isContract(askedAsset), "P2P: Not contract");
        require(msg.value > 0, "P2P: Zero amount not allowed");
        _requireAllowed721Or1155(askedAsset);
        WBNB.deposit{value: msg.value}();
        tradeId = _createTradeSingle(address(WBNB), msg.value, 0, askedAsset, askedAmount, tokenId, deadline, AssetType.ERC20, AssetType.ERC1155);   
    }



    function createTrade1155To721(address proposedAsset, uint proposedAmount, uint proposedTokenId, address askedAsset, uint tokenId, uint deadline) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset), "P2P: Not contracts");
        require(proposedAmount > 0, "P2P: Zero amount not allowed");
        _requireAllowed721Or1155(askedAsset);
        _requireAllowed721Or1155(proposedAsset);
        IERC1155(proposedAsset).safeTransferFrom(msg.sender, address(this), proposedTokenId, proposedAmount, "");
        tradeId = _createTradeSingle(proposedAsset, proposedAmount, proposedTokenId, askedAsset, 0, tokenId, deadline, AssetType.ERC1155, AssetType.ERC721);   
    }

    function createTrade721to1155(address proposedAsset, uint proposedTokenId, address askedAsset, uint askedAmount, uint askedTokenId, uint deadline) external returns (uint tradeId) {
        require(Address.isContract(proposedAsset), "P2P: Not contracts");
        _requireAllowed721Or1155(askedAsset);
        _requireAllowed721Or1155(proposedAsset);
        IERC721(proposedAsset).safeTransferFrom(msg.sender, address(this), proposedTokenId);
        tradeId = _createTradeSingle(proposedAsset, 0, proposedTokenId, askedAsset, askedAmount, askedTokenId, deadline, AssetType.ERC721, AssetType.ERC1155);   
    }



    function supportTradeSingle(uint tradeId) external lock {
        require(tradeCount >= tradeId && tradeId > 0, "P2P: Invalid trade id");
        TradeSingle storage trade = tradesSingle[tradeId];
        require(trade.status == 0 && trade.deadline > block.timestamp, "P2P: Not active trade");

        if (trade.askedAssetType == AssetType.ERC721) {
            IERC721(trade.askedAsset).safeTransferFrom(msg.sender, trade.initiator, trade.askedTokenId);
        } else if (trade.askedAssetType == AssetType.ERC1155) {
            IERC1155(trade.askedAsset).safeTransferFrom(msg.sender, trade.initiator, trade.askedTokenId, trade.askedAmount, "");
        } else {
            TransferHelper.safeTransferFrom(trade.askedAsset, msg.sender, trade.initiator, trade.askedAmount);
        }
        _supportTradeSingle(tradeId);
    }

    function supportTradeSingleBNB(uint tradeId) payable external lock {
        require(tradeCount >= tradeId && tradeId > 0, "P2P: Invalid trade id");
        TradeSingle storage trade = tradesSingle[tradeId];
        require(trade.status == 0 && trade.deadline > block.timestamp, "P2P: Not active trade");
        require(msg.value >= trade.askedAmount, "P2P: Not enough BNB sent");
        require(trade.askedAsset == address(WBNB), "P2P: ERC20 trade");

        TransferHelper.safeTransferBNB(trade.initiator, trade.askedAmount);
        if (msg.value > trade.askedAmount) TransferHelper.safeTransferBNB(msg.sender, msg.value - trade.askedAmount);
        _supportTradeSingle(tradeId);
    }



    function cancelTrade(uint tradeId) external lock { 
        require(tradeCount >= tradeId && tradeId > 0, "P2P: Invalid trade id");
        require(tradesSingle[tradeId].initiator == msg.sender, "P2P: Not allowed");
        require(tradesSingle[tradeId].status == 0 && tradesSingle[tradeId].deadline > block.timestamp, "P2P: Not active trade");
        
        _cancelTradeOrWithdrawOverdueAssets(tradeId);
        
        tradesSingle[tradeId].status = 2;
        emit CancelTrade(tradeId);
    }

    function cancelTradeOrWithdrawOverdueAssets(uint tradeId) external lock { 
        require(tradeCount >= tradeId && tradeId > 0, "P2P: Invalid trade id");
        require(tradesSingle[tradeId].initiator == msg.sender, "P2P: Not allowed");
        require(tradesSingle[tradeId].status == 0, "P2P: Not active trade");
        
        _cancelTradeOrWithdrawOverdueAssets(tradeId);

        tradesSingle[tradeId].status = 5;
        emit CancelOrWithdrawOverdueAssetTrade(tradeId);
    }



    function withdrawOverdueAssetSingle(uint tradeId) external lock { 
        require(tradeCount >= tradeId && tradeId > 0, "P2P: Invalid trade id");
        TradeSingle storage trade = tradesSingle[tradeId];
        require(trade.initiator == msg.sender, "P2P: Not allowed");
        require(trade.status == 0 && trade.deadline < block.timestamp, "P2P: Not available for withdrawal");

        _cancelTradeOrWithdrawOverdueAssets(tradeId);

        trade.status = 3;
        emit WithdrawOverdueAsset(tradeId);
    }
    


    function onERC721Received(address operator, address from, uint tokenId, bytes memory data) external pure returns (bytes4) {
        return 0x150b7a02;
    }

    function state(uint tradeId) public view returns (TradeState) { //TODO
        require(tradeCount >= tradeId && tradeId > 0, "P2P: Invalid trade id");
        TradeSingle storage trade = tradesSingle[tradeId];
        if (trade.status == 1) {
            return TradeState.Succeeded;
        } else if (trade.status == 2 || trade.status == 3 || trade.status == 5) {
            return TradeState(trade.status);
        } else if (trade.deadline < block.timestamp) {
            return TradeState.Overdue;
        } else {
            return TradeState.Active;
        }
    }

    function userTrades(address user) public view returns (uint[] memory) {
        return _userTrades[user];
    }

    function _requireAllowed721Or1155(address nftContract) private view {
        require(isAnyNFTAllowed || allowedNFT[nftContract], "P2P: Not allowed NFT");
    }

    function _createTradeSingle(
        address proposedAsset, 
        uint proposedAmount, 
        uint proposedTokenId, 
        address askedAsset, 
        uint askedAmount, 
        uint askedTokenId, 
        uint deadline, 
        AssetType proposedAssetType,
        AssetType askedAssetType
    ) private returns (uint tradeId) { 
        require(askedAsset != proposedAsset, "P2P: Asked asset can not be equal to proposed asset");
        require(deadline > block.timestamp, "P2P: Incorrect deadline");
        tradeId = ++tradeCount;
        
        TradeSingle storage trade = tradesSingle[tradeId];
        trade.initiator = msg.sender;
        trade.proposedAsset = proposedAsset;
        if (proposedAmount > 0) trade.proposedAmount = proposedAmount;
        if (proposedTokenId > 0) trade.proposedTokenId = proposedTokenId;
        trade.askedAsset = askedAsset;
        if (askedAmount > 0) trade.askedAmount = askedAmount;
        if (askedTokenId > 0) trade.askedTokenId = askedTokenId;
        trade.deadline = deadline;
        trade.proposedAssetType = proposedAssetType; 
        trade.askedAssetType = askedAssetType; 
        
        _userTrades[msg.sender].push(tradeId);        
        emit NewTradeSingle(msg.sender, proposedAsset, proposedAmount, proposedTokenId, askedAsset, askedAmount, askedTokenId, deadline, tradeId);
    }

    function _supportTradeSingle(uint tradeId) private { 
        TradeSingle memory trade = tradesSingle[tradeId];
        
        if (trade.proposedAssetType == AssetType.ERC721) {
            IERC721(trade.proposedAsset).transferFrom(address(this), msg.sender, trade.proposedTokenId);
        } else if (trade.proposedAssetType == AssetType.ERC1155) {
            IERC1155(trade.proposedAsset).safeTransferFrom(address(this), msg.sender, trade.proposedTokenId, trade.proposedAmount, "");
        } else if (trade.proposedAsset != address(WBNB)) {
            TransferHelper.safeTransfer(trade.proposedAsset, msg.sender, trade.proposedAmount);
        } else {
            WBNB.withdraw(trade.proposedAmount);
            TransferHelper.safeTransferBNB(msg.sender, trade.proposedAmount);
        }
        
        tradesSingle[tradeId].counterparty = msg.sender;
        tradesSingle[tradeId].status = 1;
        emit SupportTrade(tradeId, msg.sender);
    }
    
    function _cancelTradeOrWithdrawOverdueAssets(uint tradeId) internal { 
        TradeSingle memory trade = tradesSingle[tradeId];

        if (trade.proposedAssetType == AssetType.ERC721) {
            IERC721(trade.proposedAsset).transferFrom(address(this), trade.initiator, trade.proposedTokenId);
        } else if (trade.proposedAssetType == AssetType.ERC1155) {
            IERC1155(trade.proposedAsset).safeTransferFrom(address(this), trade.initiator, trade.proposedTokenId, trade.proposedAmount, "");
        } else if (trade.proposedAsset != address(WBNB)) {
            TransferHelper.safeTransfer(trade.proposedAsset, trade.initiator, trade.proposedAmount);
        } else {
            WBNB.withdraw(trade.proposedAmount);
            TransferHelper.safeTransferBNB(trade.initiator, trade.proposedAmount);
        }
    }



    function cancelTradeOrWithdrawOverdueAssetsFor(uint tradeId) external lock onlyOwner { 
        require(tradeCount >= tradeId && tradeId > 0, "P2P: Invalid trade id");
        require(tradesSingle[tradeId].status == 0, "P2P: Not active trade");
        
        _cancelTradeOrWithdrawOverdueAssets(tradeId);
        
        tradesSingle[tradeId].status = 5;
        emit CancelOrWithdrawOverdueAssetTrade(tradeId);
    }

    function toggleAnyNFTAllowed() external onlyOwner {
        isAnyNFTAllowed = !isAnyNFTAllowed;
        emit UpdateIsAnyNFTAllowed(isAnyNFTAllowed);
    }

    function updateAllowedNFT(address nft, bool isAllowed) external onlyOwner {
        require(Address.isContract(nft), "P2P: Not a contract");
        allowedNFT[nft] = isAllowed;
        emit UpdateAllowedNFT(nft, isAllowed);
    }
}