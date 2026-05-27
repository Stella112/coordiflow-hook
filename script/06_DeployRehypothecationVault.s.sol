// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {ICoordiFlowPersonaHook} from "../src/interfaces/ICoordiFlowPersonaHook.sol";
import {CoordiFlowRehypothecationVault} from "../src/CoordiFlowRehypothecationVault.sol";
import {CoordiFlowStrategyReserve} from "../src/CoordiFlowStrategyReserve.sol";

contract DeployRehypothecationVaultScript is Script {
    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(privateKey);
        address hook = vm.envAddress("COORDIFLOW_HOOK");
        address launchToken = vm.envAddress("LAUNCH_TOKEN");
        address quoteToken = vm.envAddress("QUOTE_TOKEN");
        address underlying = vm.envOr("REHYPOTHECATION_UNDERLYING", quoteToken);

        vm.startBroadcast(privateKey);
        CoordiFlowStrategyReserve reserve = new CoordiFlowStrategyReserve(deployer);
        CoordiFlowRehypothecationVault vault = new CoordiFlowRehypothecationVault(
            deployer, ICoordiFlowPersonaHook(hook), launchToken, quoteToken, underlying, reserve
        );
        reserve.setVault(address(vault));
        vm.stopBroadcast();

        console2.log("CoordiFlowStrategyReserve", address(reserve));
        console2.log("CoordiFlowRehypothecationVault", address(vault));
        console2.log("Underlying", underlying);
        console2.log("Owner", deployer);
    }
}
