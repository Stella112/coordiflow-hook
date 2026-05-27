// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IUnlockCallback} from "@uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {BalanceDelta, BalanceDeltaLibrary} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";

contract CoordiFlowV4SwapAgent is IUnlockCallback {
    using BalanceDeltaLibrary for BalanceDelta;

    struct CallbackData {
        PoolKey key;
        SwapParams params;
        bytes hookData;
    }

    IPoolManager public immutable manager;
    address public immutable owner;

    error OnlyOwner();
    error OnlyPoolManager();
    error NativeCurrencyUnsupported();

    constructor(IPoolManager manager_, address owner_) {
        manager = manager_;
        owner = owner_;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }

    function swapExactInput(PoolKey calldata key, uint256 amountIn, bool zeroForOne) external onlyOwner {
        uint160 sqrtPriceLimitX96 = zeroForOne ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1;
        SwapParams memory params =
            SwapParams({zeroForOne: zeroForOne, amountSpecified: -int256(amountIn), sqrtPriceLimitX96: sqrtPriceLimitX96});

        manager.unlock(abi.encode(CallbackData({key: key, params: params, hookData: abi.encode(address(this))})));
    }

    function unlockCallback(bytes calldata rawData) external returns (bytes memory) {
        if (msg.sender != address(manager)) revert OnlyPoolManager();

        CallbackData memory data = abi.decode(rawData, (CallbackData));
        BalanceDelta delta = manager.swap(data.key, data.params, data.hookData);

        _settleOrTake(data.key.currency0, delta.amount0());
        _settleOrTake(data.key.currency1, delta.amount1());

        return abi.encode(delta);
    }

    function _settleOrTake(Currency currency, int128 delta) internal {
        if (delta == 0) return;
        address token = Currency.unwrap(currency);
        if (token == address(0)) revert NativeCurrencyUnsupported();

        if (delta < 0) {
            uint256 amount = uint256(uint128(-delta));
            manager.sync(currency);
            IERC20(token).transfer(address(manager), amount);
            manager.settle();
        } else {
            manager.take(currency, address(this), uint256(uint128(delta)));
        }
    }
}
