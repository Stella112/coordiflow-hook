// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {CoordiFlowHook} from "../src/CoordiFlowHook.sol";
import {CoordiFlowRewardsVault} from "../src/CoordiFlowRewardsVault.sol";
import {ICoordiFlowRewardsVault} from "../src/interfaces/ICoordiFlowRewardsVault.sol";

contract DeployRewardsVaultScript is Script {
    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(privateKey);
        address hook = vm.envAddress("COORDIFLOW_HOOK");

        vm.startBroadcast(privateKey);
        CoordiFlowRewardsVault vault = new CoordiFlowRewardsVault(deployer);
        vault.setHook(hook);
        CoordiFlowHook(hook).setRewardsVault(ICoordiFlowRewardsVault(address(vault)));
        vm.stopBroadcast();

        console2.log("CoordiFlowRewardsVault", address(vault));
        console2.log("Hook", hook);
        console2.log("Owner", deployer);
    }
}
