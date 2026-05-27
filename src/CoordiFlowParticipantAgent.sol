// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {IUniswapV4Router04} from "hookmate/interfaces/router/IUniswapV4Router04.sol";

contract CoordiFlowParticipantAgent {
    address public immutable owner;

    error OnlyOwner();

    constructor(address owner_) {
        owner = owner_;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }

    function approveToken(address token, address spender) external onlyOwner {
        IERC20(token).approve(spender, type(uint256).max);
    }

    function swapExactInput(
        IUniswapV4Router04 router,
        address tokenIn,
        uint256 amountIn,
        bool zeroForOne,
        PoolKey calldata poolKey
    ) external onlyOwner {
        IERC20(tokenIn).approve(address(router), amountIn);
        router.swapExactTokensForTokens({
            amountIn: amountIn,
            amountOutMin: 0,
            zeroForOne: zeroForOne,
            poolKey: poolKey,
            hookData: abi.encode(address(this)),
            receiver: address(this),
            deadline: block.timestamp + 30 minutes
        });
    }
}
