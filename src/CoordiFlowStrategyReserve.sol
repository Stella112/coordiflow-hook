// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract CoordiFlowStrategyReserve {
    address public immutable owner;
    address public vault;

    event VaultUpdated(address indexed vault);
    event AssetsReturned(address indexed token, uint256 amount);

    error OnlyOwner();
    error OnlyVault();

    constructor(address initialOwner) {
        owner = initialOwner;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }

    modifier onlyVault() {
        if (msg.sender != vault) revert OnlyVault();
        _;
    }

    function setVault(address vault_) external onlyOwner {
        vault = vault_;
        emit VaultUpdated(vault_);
    }

    function returnAssets(address token, uint256 amount) external onlyVault {
        IERC20(token).transfer(vault, amount);
        emit AssetsReturned(token, amount);
    }
}
