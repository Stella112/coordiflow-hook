// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {CoordiFlowStrategyReserve} from "./CoordiFlowStrategyReserve.sol";
import {IAavePool} from "./interfaces/IAavePool.sol";

contract CoordiFlowAaveStrategyReserve is CoordiFlowStrategyReserve {
    IAavePool public aavePool;

    event AavePoolUpdated(address indexed aavePool);
    event SuppliedToAave(address indexed asset, uint256 amount);
    event WithdrawnFromAave(address indexed asset, uint256 amount);

    constructor(address initialOwner) CoordiFlowStrategyReserve(initialOwner) {}

    function setAavePool(IAavePool aavePool_) external onlyOwner {
        aavePool = aavePool_;
        emit AavePoolUpdated(address(aavePool_));
    }

    function supplyToAave(address asset, uint256 amount) external onlyOwner {
        IERC20(asset).approve(address(aavePool), amount);
        aavePool.supply(asset, amount, address(this), 0);
        emit SuppliedToAave(asset, amount);
    }

    function withdrawFromAave(address asset, uint256 amount) external onlyOwner returns (uint256 withdrawn) {
        withdrawn = aavePool.withdraw(asset, amount, address(this));
        emit WithdrawnFromAave(asset, withdrawn);
    }
}
