// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {HookMiner} from "@uniswap/v4-periphery/src/utils/HookMiner.sol";

import {CoordiFlowHook} from "../src/CoordiFlowHook.sol";

contract DeployCoordiFlowHookScript is Script {
    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        IPoolManager poolManager = IPoolManager(vm.envAddress("POOL_MANAGER"));

        uint160 flags = uint160(
            Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_SWAP_FLAG | Hooks.BEFORE_ADD_LIQUIDITY_FLAG
                | Hooks.BEFORE_REMOVE_LIQUIDITY_FLAG
        );

        bytes memory constructorArgs = abi.encode(poolManager);
        (address expectedHookAddress, bytes32 salt) =
            HookMiner.find(CREATE2_FACTORY, flags, type(CoordiFlowHook).creationCode, constructorArgs);

        vm.startBroadcast(privateKey);
        CoordiFlowHook hook = new CoordiFlowHook{salt: salt}(poolManager);
        vm.stopBroadcast();

        require(address(hook) == expectedHookAddress, "CoordiFlow hook address mismatch");

        console2.log("CoordiFlowHook", address(hook));
        console2.log("PoolManager", address(poolManager));
    }
}
