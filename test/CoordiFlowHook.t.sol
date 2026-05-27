// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";

import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {LPFeeLibrary} from "@uniswap/v4-core/src/libraries/LPFeeLibrary.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {CurrencyLibrary, Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {StateLibrary} from "@uniswap/v4-core/src/libraries/StateLibrary.sol";
import {LiquidityAmounts} from "@uniswap/v4-core/test/utils/LiquidityAmounts.sol";
import {IPositionManager} from "@uniswap/v4-periphery/src/interfaces/IPositionManager.sol";
import {Constants} from "@uniswap/v4-core/test/utils/Constants.sol";

import {EasyPosm} from "./utils/libraries/EasyPosm.sol";

import {CoordiFlowHook} from "../src/CoordiFlowHook.sol";
import {BaseTest} from "./utils/BaseTest.sol";

contract CoordiFlowHookTest is BaseTest {
    using EasyPosm for IPositionManager;
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using StateLibrary for IPoolManager;

    Currency currency0;
    Currency currency1;

    PoolKey poolKey;

    CoordiFlowHook hook;
    PoolId poolId;

    address alice = address(0xA11CE);
    address bob = address(0xB0B);

    function setUp() public {
        deployArtifactsAndLabel();

        (currency0, currency1) = deployCurrencyPair();

        address flags = address(
            uint160(
                Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_SWAP_FLAG | Hooks.BEFORE_ADD_LIQUIDITY_FLAG
                    | Hooks.BEFORE_REMOVE_LIQUIDITY_FLAG
            ) ^ (0xC0F10 << 136)
        );
        bytes memory constructorArgs = abi.encode(poolManager);
        deployCodeTo("CoordiFlowHook.sol:CoordiFlowHook", constructorArgs, flags);
        hook = CoordiFlowHook(flags);

        poolKey = PoolKey(currency0, currency1, LPFeeLibrary.DYNAMIC_FEE_FLAG, 60, IHooks(hook));
        poolId = poolKey.toId();
        poolManager.initialize(poolKey, Constants.SQRT_PRICE_1_1);

        hook.configurePool({
            key: poolKey,
            launchTokenIsCurrency0: false,
            baseFee: 3000,
            builderFee: 1500,
            restrictedFee: 10000,
            maxSwapAmount: 5e18,
            rapidRoundTripWindow: 10 minutes
        });

        int24 tickLower = TickMath.minUsableTick(poolKey.tickSpacing);
        int24 tickUpper = TickMath.maxUsableTick(poolKey.tickSpacing);
        uint128 liquidityAmount = 100e18;

        (uint256 amount0Expected, uint256 amount1Expected) = LiquidityAmounts.getAmountsForLiquidity(
            Constants.SQRT_PRICE_1_1,
            TickMath.getSqrtPriceAtTick(tickLower),
            TickMath.getSqrtPriceAtTick(tickUpper),
            liquidityAmount
        );

        positionManager.mint(
            poolKey,
            tickLower,
            tickUpper,
            liquidityAmount,
            amount0Expected + 1,
            amount1Expected + 1,
            address(this),
            block.timestamp,
            abi.encode(alice)
        );
    }

    function testSeederFromEarlyLiquidity() public view {
        assertEq(uint8(hook.personaOf(poolKey, alice)), uint8(CoordiFlowHook.Persona.Seeder));

        (uint32 uniqueParticipants, uint32 positiveParticipants,,,,) = hook.poolState(poolId);
        assertEq(uniqueParticipants, 1);
        assertEq(positiveParticipants, 1);
    }

    function testBuilderFromRepeatedConstructiveBuys() public {
        _swapAs(bob, true, 1e18);
        _swapAs(bob, true, 1e18);
        _swapAs(bob, true, 1e18);

        assertEq(uint8(hook.personaOf(poolKey, bob)), uint8(CoordiFlowHook.Persona.Builder));

        (uint32 uniqueParticipants, uint32 positiveParticipants,,,,) = hook.poolState(poolId);
        assertEq(uniqueParticipants, 2);
        assertEq(positiveParticipants, 2);
    }

    function testRapidRoundTripRestrictsWallet() public {
        _swapAs(bob, true, 1e18);
        _swapAs(bob, false, 1e18);
        _swapAs(bob, true, 1e18);
        _swapAs(bob, false, 1e18);

        assertEq(uint8(hook.personaOf(poolKey, bob)), uint8(CoordiFlowHook.Persona.Restricted));
    }

    function testSwapCapRevertsOversizedFlow() public {
        vm.expectRevert();
        _swapAs(bob, true, 6e18);
    }

    function _swapAs(address wallet, bool zeroForOne, uint256 amountIn) internal returns (BalanceDelta) {
        return swapRouter.swapExactTokensForTokens({
            amountIn: amountIn,
            amountOutMin: 0,
            zeroForOne: zeroForOne,
            poolKey: poolKey,
            hookData: abi.encode(wallet),
            receiver: address(this),
            deadline: block.timestamp + 1
        });
    }
}
