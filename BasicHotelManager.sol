// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.17;

import {StringUtils} from "./StringUtils.sol";

contract BasicHotelManager {
    mapping (string => string) private clientBalances;
    string private roomOwner;
    string private roomPrice;

    function isRoomAvailable() public view returns (bool) {
        return StringUtils.isEmpty(roomOwner);
    }

    function queryRoomPrice() external view returns (uint256) {
        // default price is 500
        uint256 result = 500;

        if (!StringUtils.isEmpty(roomPrice)) {
            result = StringUtils.stringToUint(roomPrice);
        }

        return result;   
    }

    function queryClientBalance() public view returns (uint256) {
        string memory varName = formulateClientBalanceVarName(tx.origin);
        string memory balance = clientBalances[varName];

        if (!StringUtils.isEmpty(balance)) {
            return StringUtils.stringToUint(balance);
        }

        // initial balance
        return 1000;
    }

    function changeRoomPrice(uint256 newPrice) external {
        string memory priceS = StringUtils.uintToString(newPrice);
        roomPrice = priceS;
    }

    function addToClientBalance(uint256 amountToAdd) external {
        require(amountToAdd > 0, "The amount must be a positive value!");
        string memory varName = formulateClientBalanceVarName(tx.origin);
        uint256 balance = queryClientBalance();
        uint256 newBalance = balance + amountToAdd;
        string memory newBalanceS = StringUtils.uintToString(newBalance);
        clientBalances[varName] = newBalanceS;    
    }

    function bookRoom() external {
        bool available = isRoomAvailable();
        require(available, "the room must be available!");
        uint256 price = this.queryRoomPrice();
        deductFromClientBalance(price);
        roomOwner = StringUtils.addressToHexString(tx.origin);   
    }

    function hasReservation() external view returns (bool) {
        string memory currentClient = StringUtils.addressToHexString(tx.origin);
        return StringUtils.compareStrings(roomOwner, currentClient); 
    }

    function checkout() external {
        bool gotReservation = this.hasReservation();
        require(gotReservation, "you must have a reservation in order to checkout!");
        roomOwner = "";
    }

    function deductFromClientBalance(uint256 amountToDeduct) internal {
        string memory varName = formulateClientBalanceVarName(tx.origin);
        uint256 balance = queryClientBalance();
        uint256 newBalance = balance - amountToDeduct;
        require(newBalance >= 0, "The amount to deduct cannot be larger than the current balance!");
        string memory newBalanceS = StringUtils.uintToString(newBalance);
        clientBalances[varName] = newBalanceS;
    }

    function formulateClientBalanceVarName(address client) private pure returns (string memory) {
        return StringUtils.addressToHexString(client);
    }

}