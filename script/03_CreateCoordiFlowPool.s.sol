// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {LPFeeLibrary} from "@uniswap/v4-core/src/libraries/LPFeeLibrary.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {LiquidityAmounts} from "@uniswap/v4-core/test/utils/LiquidityAmounts.sol";
import {IPositionManager} from "@uniswap/v4-periphery/src/interfaces/IPositionManager.sol";
import {IPoolInitializer_v4} from "@uniswap/v4-periphery/src/interfaces/IPoolInitializer_v4.sol";
import {Actions} from "@uniswap/v4-periphery/src/libraries/Actions.sol";
import {IPermit2} from "permit2/src/interfaces/IPermit2.sol";

import {CoordiFlowHook} from "../src/CoordiFlowHook.sol";
import {CoordiFlowRewardsVault} from "../src/CoordiFlowRewardsVault.sol";

contract CreateCoordiFlowPoolScript is Script {
    using PoolIdLibrary for PoolKey;

    uint160 internal constant STARTING_PRICE = 79228162514264337593543950336; // sqrt(1) * 2^96
    int24 internal constant TICK_SPACING = 60;

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(privateKey);

        address hook = vm.envAddress("COORDIFLOW_HOOK");
        address launchToken = vm.envAddress("LAUNCH_TOKEN");
        address quoteToken = vm.envAddress("QUOTE_TOKEN");
        address positionManager = vm.envOr("POSITION_MANAGER", address(0x8DE4b634760F7942A20B7fA994AAc72F03ce4751));
        address permit2 = vm.envOr("PERMIT2", address(0x3191Fc1E303EF4e12a7DE5f5d2e8d53A0660c5b9));
        address rewardsVault = vm.envOr("REWARDS_VAULT", address(0));

        uint256 launchAmount = vm.envOr("POOL_LAUNCH_AMOUNT", uint256(100_000 ether));
        uint256 quoteAmount = vm.envOr("POOL_QUOTE_AMOUNT", uint256(100_000 ether));
        uint256 rewardFunding = vm.envOr("REWARD_FUNDING", uint256(0.01 ether));

        PoolKey memory key = _poolKey(launchToken, quoteToken, hook);
        bool launchTokenIsCurrency0 = Currency.unwrap(key.currency0) == launchToken;
        uint256 amount0Max = launchTokenIsCurrency0 ? launchAmount : quoteAmount;
        uint256 amount1Max = launchTokenIsCurrency0 ? quoteAmount : launchAmount;

        int24 currentTick = TickMath.getTickAtSqrtPrice(STARTING_PRICE);
        int24 tickLower = _truncateTick(currentTick - 750 * TICK_SPACING);
        int24 tickUpper = _truncateTick(currentTick + 750 * TICK_SPACING);
        uint128 liquidity = LiquidityAmounts.getLiquidityForAmounts(
            STARTING_PRICE,
            TickMath.getSqrtPriceAtTick(tickLower),
            TickMath.getSqrtPriceAtTick(tickUpper),
            amount0Max,
            amount1Max
        );

        bytes memory hookData = abi.encode(deployer);
        (bytes memory actions, bytes[] memory mintParams) =
            _mintLiquidityParams(key, tickLower, tickUpper, liquidity, amount0Max, amount1Max, deployer, hookData);

        bytes[] memory calls = new bytes[](2);
        calls[0] = abi.encodeWithSelector(IPoolInitializer_v4.initializePool.selector, key, STARTING_PRICE);
        calls[1] = abi.encodeWithSelector(
            IPositionManager.modifyLiquidities.selector, abi.encode(actions, mintParams), block.timestamp + 30 minutes
        );

        vm.startBroadcast(privateKey);
        CoordiFlowHook(hook)
            .configurePool(
                key,
                launchTokenIsCurrency0,
                3_000,
                1_000,
                10_000,
                uint128(vm.envOr("MAX_SWAP_AMOUNT", uint256(10_000 ether))),
                uint40(vm.envOr("RAPID_ROUND_TRIP_WINDOW", uint256(10 minutes))),
                uint16(vm.envOr("REWARD_BPS", uint256(100)))
            );

        _approveToken(Currency.unwrap(key.currency0), permit2, positionManager);
        _approveToken(Currency.unwrap(key.currency1), permit2, positionManager);

        IPositionManager(positionManager).multicall(calls);

        if (rewardsVault != address(0) && rewardFunding != 0) {
            CoordiFlowRewardsVault(rewardsVault).fund{value: rewardFunding}(key.toId());
        }
        vm.stopBroadcast();

        PoolId poolId = key.toId();
        console2.log("PoolId");
        console2.logBytes32(PoolId.unwrap(poolId));
        console2.log("Hook", hook);
        console2.log("LaunchToken", launchToken);
        console2.log("QuoteToken", quoteToken);
        console2.log("Currency0", Currency.unwrap(key.currency0));
        console2.log("Currency1", Currency.unwrap(key.currency1));
        console2.log("LaunchTokenIsCurrency0", launchTokenIsCurrency0);
        console2.log("PositionManager", positionManager);
        console2.log("Permit2", permit2);
    }

    function _poolKey(address launchToken, address quoteToken, address hook) internal pure returns (PoolKey memory) {
        require(launchToken != quoteToken, "SAME_TOKEN");
        (address token0, address token1) =
            launchToken < quoteToken ? (launchToken, quoteToken) : (quoteToken, launchToken);

        return PoolKey({
            currency0: Currency.wrap(token0),
            currency1: Currency.wrap(token1),
            fee: LPFeeLibrary.DYNAMIC_FEE_FLAG,
            tickSpacing: TICK_SPACING,
            hooks: IHooks(hook)
        });
    }

    function _mintLiquidityParams(
        PoolKey memory key,
        int24 tickLower,
        int24 tickUpper,
        uint128 liquidity,
        uint256 amount0Max,
        uint256 amount1Max,
        address recipient,
        bytes memory hookData
    ) internal pure returns (bytes memory actions, bytes[] memory params) {
        actions = abi.encodePacked(
            uint8(Actions.MINT_POSITION), uint8(Actions.SETTLE_PAIR), uint8(Actions.SWEEP), uint8(Actions.SWEEP)
        );

        params = new bytes[](4);
        params[0] = abi.encode(key, tickLower, tickUpper, liquidity, amount0Max, amount1Max, recipient, hookData);
        params[1] = abi.encode(key.currency0, key.currency1);
        params[2] = abi.encode(key.currency0, recipient);
        params[3] = abi.encode(key.currency1, recipient);
    }

    function _approveToken(address token, address permit2, address spender) internal {
        IERC20(token).approve(permit2, type(uint256).max);
        IPermit2(permit2).approve(token, spender, type(uint160).max, type(uint48).max);
    }

    function _truncateTick(int24 tick) internal pure returns (int24) {
        return (tick / TICK_SPACING) * TICK_SPACING;
    }
}
