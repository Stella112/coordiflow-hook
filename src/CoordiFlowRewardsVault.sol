// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";

contract CoordiFlowRewardsVault {
    address public immutable owner;
    address public hook;

    mapping(PoolId poolId => uint256 amount) public poolBalance;
    mapping(PoolId poolId => mapping(address wallet => uint256 amount)) public claimable;

    event HookUpdated(address indexed hook);
    event RewardFunded(bytes32 indexed poolId, address indexed funder, uint256 amount);
    event RewardAccrued(bytes32 indexed poolId, address indexed wallet, uint256 amount);
    event RewardClaimed(bytes32 indexed poolId, address indexed wallet, uint256 amount);

    error OnlyOwner();
    error OnlyHook();
    error NothingToClaim();

    constructor(address initialOwner) {
        owner = initialOwner;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }

    modifier onlyHook() {
        if (msg.sender != hook) revert OnlyHook();
        _;
    }

    function setHook(address hook_) external onlyOwner {
        hook = hook_;
        emit HookUpdated(hook_);
    }

    function fund(PoolId poolId) external payable {
        poolBalance[poolId] += msg.value;
        emit RewardFunded(PoolId.unwrap(poolId), msg.sender, msg.value);
    }

    function accrueReward(PoolId poolId, address wallet, uint256 amount) external onlyHook {
        if (amount == 0 || poolBalance[poolId] < amount) return;

        poolBalance[poolId] -= amount;
        claimable[poolId][wallet] += amount;
        emit RewardAccrued(PoolId.unwrap(poolId), wallet, amount);
    }

    function claim(PoolId poolId) external {
        uint256 amount = claimable[poolId][msg.sender];
        if (amount == 0) revert NothingToClaim();

        claimable[poolId][msg.sender] = 0;
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "CLAIM_FAILED");

        emit RewardClaimed(PoolId.unwrap(poolId), msg.sender, amount);
    }
}
