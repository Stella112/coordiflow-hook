// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {Permit2Deployer} from "hookmate/artifacts/Permit2.sol";
import {V4PoolManagerDeployer} from "hookmate/artifacts/V4PoolManager.sol";
import {V4PositionManagerDeployer} from "hookmate/artifacts/V4PositionManager.sol";
import {V4RouterDeployer} from "hookmate/artifacts/V4Router.sol";

contract DeployXLayerTestV4StackScript is Script {
    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(privateKey);

        vm.startBroadcast(privateKey);

        address permit2 = vm.envOr("TEST_PERMIT2", address(0));
        if (permit2 == address(0)) {
            permit2 = Permit2Deployer.deploy();
        }
        address poolManager = V4PoolManagerDeployer.deploy(deployer);
        address positionManager =
            V4PositionManagerDeployer.deploy(poolManager, permit2, 300_000, address(0), address(0));
        address swapRouter = V4RouterDeployer.deploy(poolManager, permit2);

        vm.stopBroadcast();

        console2.log("CoordiFlow X Layer test v4 stack");
        console2.log("Deployer", deployer);
        console2.log("Permit2", permit2);
        console2.log("PoolManager", poolManager);
        console2.log("PositionManager", positionManager);
        console2.log("SwapRouter", swapRouter);
    }
}
