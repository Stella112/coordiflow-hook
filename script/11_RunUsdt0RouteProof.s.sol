// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {CoordiFlowUserActions} from "../src/CoordiFlowUserActions.sol";

contract RunUsdt0RouteProof is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address usdt0 = vm.envAddress("USDT0_TOKEN");
        address userActions = vm.envAddress("USDT0_USER_ACTIONS");
        uint256 amountIn = vm.envOr("USDT0_SWAP_AMOUNT", uint256(100_000));

        vm.startBroadcast(deployerKey);
        IERC20(usdt0).approve(userActions, amountIn);
        CoordiFlowUserActions(userActions).swapExactInput(amountIn, true, 0);
        vm.stopBroadcast();

        console2.log("USDT0 route proof amount", amountIn);
        console2.log("USDT0", usdt0);
        console2.log("UserActions", userActions);
    }
}
