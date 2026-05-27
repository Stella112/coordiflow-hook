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
import {IUniswapV4Router04} from "hookmate/interfaces/router/IUniswapV4Router04.sol";

import {CoordiFlowHook} from "../src/CoordiFlowHook.sol";
import {CoordiFlowParticipantAgent} from "../src/CoordiFlowParticipantAgent.sol";

contract RunCoordiFlowScenarioScript is Script {
    using PoolIdLibrary for PoolKey;

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(privateKey);

        address hook = vm.envAddress("COORDIFLOW_HOOK");
        address launchToken = vm.envAddress("LAUNCH_TOKEN");
        address quoteToken = vm.envAddress("QUOTE_TOKEN");
        address payable swapRouter =
            payable(vm.envOr("SWAP_ROUTER", address(0xbDfdAAbc7286D2F5D96f786D261Ac7093Cd644Ee)));

        PoolKey memory key = _poolKey(launchToken, quoteToken, hook);
        bool quoteForLaunchZeroForOne = Currency.unwrap(key.currency0) == quoteToken;
        bool launchForQuoteZeroForOne = !quoteForLaunchZeroForOne;

        uint256 normalTrade = vm.envOr("SCENARIO_NORMAL_TRADE", uint256(50 ether));
        uint256 toxicTrade = vm.envOr("SCENARIO_TOXIC_TRADE", uint256(25 ether));
        uint256 seedBalance = normalTrade * 5;

        vm.startBroadcast(privateKey);

        CoordiFlowParticipantAgent builder = new CoordiFlowParticipantAgent(deployer);
        CoordiFlowParticipantAgent stabilizer = new CoordiFlowParticipantAgent(deployer);
        CoordiFlowParticipantAgent sprinter = new CoordiFlowParticipantAgent(deployer);

        IERC20(quoteToken).transfer(address(builder), seedBalance);
        IERC20(quoteToken).transfer(address(stabilizer), seedBalance);
        IERC20(quoteToken).transfer(address(sprinter), seedBalance);

        builder.swapExactInput(IUniswapV4Router04(swapRouter), quoteToken, normalTrade, quoteForLaunchZeroForOne, key);
        builder.swapExactInput(IUniswapV4Router04(swapRouter), quoteToken, normalTrade, quoteForLaunchZeroForOne, key);
        builder.swapExactInput(IUniswapV4Router04(swapRouter), quoteToken, normalTrade, quoteForLaunchZeroForOne, key);

        stabilizer.swapExactInput(
            IUniswapV4Router04(swapRouter), quoteToken, normalTrade, quoteForLaunchZeroForOne, key
        );

        sprinter.swapExactInput(IUniswapV4Router04(swapRouter), quoteToken, toxicTrade, quoteForLaunchZeroForOne, key);
        uint256 launchBalance = IERC20(launchToken).balanceOf(address(sprinter));
        sprinter.swapExactInput(
            IUniswapV4Router04(swapRouter), launchToken, launchBalance / 2, launchForQuoteZeroForOne, key
        );
        launchBalance = IERC20(launchToken).balanceOf(address(sprinter));
        sprinter.swapExactInput(
            IUniswapV4Router04(swapRouter), launchToken, launchBalance, launchForQuoteZeroForOne, key
        );

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
