// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {LPFeeLibrary} from "@uniswap/v4-core/src/libraries/LPFeeLibrary.sol";

import {CoordiFlowHook} from "../src/CoordiFlowHook.sol";
import {CoordiFlowV4SwapAgent} from "../src/CoordiFlowV4SwapAgent.sol";

contract RunCoordiFlowMainnetScenarioScript is Script {
    using PoolIdLibrary for PoolKey;

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(privateKey);

        address hook = vm.envAddress("COORDIFLOW_HOOK");
        address launchToken = vm.envAddress("LAUNCH_TOKEN");
        address quoteToken = vm.envAddress("QUOTE_TOKEN");
        address poolManager = vm.envAddress("POOL_MANAGER");

        PoolKey memory key = _poolKey(launchToken, quoteToken, hook);
        bool quoteForLaunchZeroForOne = Currency.unwrap(key.currency0) == quoteToken;
        bool launchForQuoteZeroForOne = !quoteForLaunchZeroForOne;

        uint256 normalTrade = vm.envOr("MAINNET_SCENARIO_NORMAL_TRADE", uint256(0.01 ether));
        uint256 toxicTrade = vm.envOr("MAINNET_SCENARIO_TOXIC_TRADE", uint256(0.005 ether));
        uint256 seedBalance = normalTrade * 5;

        vm.startBroadcast(privateKey);

        CoordiFlowV4SwapAgent builder = new CoordiFlowV4SwapAgent(IPoolManager(poolManager), deployer);
        CoordiFlowV4SwapAgent stabilizer = new CoordiFlowV4SwapAgent(IPoolManager(poolManager), deployer);
        CoordiFlowV4SwapAgent sprinter = new CoordiFlowV4SwapAgent(IPoolManager(poolManager), deployer);

        IERC20(quoteToken).transfer(address(builder), seedBalance);
        IERC20(quoteToken).transfer(address(stabilizer), seedBalance);
        IERC20(quoteToken).transfer(address(sprinter), seedBalance);

        builder.swapExactInput(key, normalTrade, quoteForLaunchZeroForOne);
        builder.swapExactInput(key, normalTrade, quoteForLaunchZeroForOne);
        builder.swapExactInput(key, normalTrade, quoteForLaunchZeroForOne);

        stabilizer.swapExactInput(key, normalTrade, quoteForLaunchZeroForOne);

        sprinter.swapExactInput(key, toxicTrade, quoteForLaunchZeroForOne);
        uint256 launchBalance = IERC20(launchToken).balanceOf(address(sprinter));
        sprinter.swapExactInput(key, launchBalance / 2, launchForQuoteZeroForOne);
        launchBalance = IERC20(launchToken).balanceOf(address(sprinter));
        sprinter.swapExactInput(key, launchBalance, launchForQuoteZeroForOne);

        vm.stopBroadcast();

        PoolId poolId = key.toId();
        console2.log("PoolId");
        console2.logBytes32(PoolId.unwrap(poolId));
        console2.log("BuilderAgent", address(builder));
        console2.log("StabilizerAgent", address(stabilizer));
        console2.log("SprinterAgent", address(sprinter));
        console2.log("BuilderPersona", uint8(CoordiFlowHook(hook).personaOf(key, address(builder))));
        console2.log("StabilizerPersona", uint8(CoordiFlowHook(hook).personaOf(key, address(stabilizer))));
        console2.log("SprinterPersona", uint8(CoordiFlowHook(hook).personaOf(key, address(sprinter))));
    }

    function _poolKey(address launchToken, address quoteToken, address hook) internal pure returns (PoolKey memory) {
        require(launchToken != quoteToken, "SAME_TOKEN");
        (address token0, address token1) =
            launchToken < quoteToken ? (launchToken, quoteToken) : (quoteToken, launchToken);

        return PoolKey({
            currency0: Currency.wrap(token0),
            currency1: Currency.wrap(token1),
            fee: LPFeeLibrary.DYNAMIC_FEE_FLAG,
            tickSpacing: 60,
            hooks: IHooks(hook)
        });
    }
}
