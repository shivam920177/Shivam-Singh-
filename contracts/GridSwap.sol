// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GridSwap is Ownable {
    IERC20 public energyToken;  

    struct Trade { 
        address seller;
        uint256 amount;
        uint256 pricePerUnit;
        bool isActive;
    }

    mapping(uint256 => Trade) public trades;
    uint256 public tradeCount;

    event TradeCreated(uint256 tradeId, address indexed seller, uint256 amount, uint256 pricePerUnit);
    event TradeCompleted(uint256 tradeId, address indexed buyer, uint256 amount, uint256 totalPrice);
    event TradeCancelled(uint256 tradeId);

    constructor(IERC20 _energyToken) Ownable(msg.sender) {
        energyToken = _energyToken;
    }

    function createTrade(uint256 amount, uint256 pricePerUnit) external {
        require(amount > 0, "Amount must be greater than zero");
        require(pricePerUnit > 0, "Price must be greater than zero");

        tradeCount++;
        trades[tradeCount] = Trade({
            seller: msg.sender,
            amount: amount,
            pricePerUnit: pricePerUnit,
            isActive: true
        });

        emit TradeCreated(tradeCount, msg.sender, amount, pricePerUnit);
    }

    function buyEnergy(uint256 tradeId, uint256 amount) external {
        Trade storage trade = trades[tradeId];
        require(trade.isActive, "Trade is not active");
        require(trade.amount >= amount, "Not enough energy available");
        uint256 totalPrice = trade.pricePerUnit * amount;

        energyToken.transferFrom(msg.sender, trade.seller, totalPrice);
        trade.amount -= amount;

        if (trade.amount == 0) {
            trade.isActive = false;
        }

        emit TradeCompleted(tradeId, msg.sender, amount, totalPrice);
    }

    function cancelTrade(uint256 tradeId) external {
        Trade storage trade = trades[tradeId];
        require(trade.seller == msg.sender, "Only seller can cancel");
        require(trade.isActive, "Trade is not active");

        trade.isActive = false;

        emit TradeCancelled(tradeId);
    }
}
