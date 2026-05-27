// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";

interface ICoordiFlowRewardsVault {
    function accrueReward(PoolId poolId, address wallet, uint256 amount) external;
}
