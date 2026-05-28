// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";

import {CoordiFlowHook} from "../src/CoordiFlowHook.sol";
import {CoordiFlowSignalProvider} from "../src/CoordiFlowSignalProvider.sol";
import {CoordiFlowPersonaBadge} from "../src/CoordiFlowPersonaBadge.sol";
import {CoordiFlowAaveStrategyReserve} from "../src/CoordiFlowAaveStrategyReserve.sol";
import {ICoordiFlowPersonaHook} from "../src/interfaces/ICoordiFlowPersonaHook.sol";
import {IAavePool} from "../src/interfaces/IAavePool.sol";

contract DeploySignalsBadgesAaveScript is Script {
    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(privateKey);
        address hook = vm.envAddress("COORDIFLOW_HOOK");
        bytes32 poolIdBytes = vm.envBytes32("COORDIFLOW_POOL_ID");
        address aavePool = vm.envOr("AAVE_POOL", address(0));

        vm.startBroadcast(privateKey);
        CoordiFlowSignalProvider signalProvider = new CoordiFlowSignalProvider(deployer);
        CoordiFlowPersonaBadge badge = new CoordiFlowPersonaBadge(ICoordiFlowPersonaHook(hook));
        CoordiFlowAaveStrategyReserve aaveReserve = new CoordiFlowAaveStrategyReserve(deployer);

        if (aavePool != address(0)) {
            aaveReserve.setAavePool(IAavePool(aavePool));
        }

        PoolId poolId = PoolId.wrap(poolIdBytes);
        signalProvider.setMarketSignal(poolId, 500);
        signalProvider.setWalletSignal(poolId, vm.envAddress("MAINNET_BUILDER"), 1_000);
        signalProvider.setWalletSignal(poolId, vm.envAddress("MAINNET_STABILIZER"), 600);
        signalProvider.setWalletSignal(poolId, vm.envAddress("MAINNET_RESTRICTED"), -3_000);
        CoordiFlowHook(hook).setSignalProvider(signalProvider);
        vm.stopBroadcast();

        console2.log("CoordiFlowSignalProvider", address(signalProvider));
        console2.log("CoordiFlowPersonaBadge", address(badge));
        console2.log("CoordiFlowAaveStrategyReserve", address(aaveReserve));
        console2.log("AavePool", aavePool);
    }
}
