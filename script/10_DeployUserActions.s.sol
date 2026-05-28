// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console2} from "forge-std/Script.sol";

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {CoordiFlowUserActions} from "../src/CoordiFlowUserActions.sol";

contract DeployUserActions is Script {
    function run() external returns (CoordiFlowUserActions actions) {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address poolManager = vm.envAddress("POOL_MANAGER");
        address hook = vm.envAddress("COORDIFLOW_HOOK");
        address launchToken = vm.envAddress("LAUNCH_TOKEN");
        address quoteToken = vm.envAddress("QUOTE_TOKEN");

        vm.startBroadcast(deployerKey);
        actions = new CoordiFlowUserActions(IPoolManager(poolManager), hook, launchToken, quoteToken);
        vm.stopBroadcast();

        console2.log("CoordiFlowUserActions", address(actions));
        console2.log("PoolManager", poolManager);
        console2.log("Hook", hook);
        console2.log("LaunchToken", launchToken);
        console2.log("QuoteToken", quoteToken);
    }
}
