// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {CoordiFlowRehypothecationVault} from "../src/CoordiFlowRehypothecationVault.sol";

contract RunRehypothecationProofScript is Script {
    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(privateKey);
        address vaultAddress = vm.envAddress("REHYPOTHECATION_VAULT");
        address underlying = vm.envOr("REHYPOTHECATION_UNDERLYING", vm.envAddress("QUOTE_TOKEN"));

        uint256 depositAmount = vm.envOr("REHYPOTHECATION_DEPOSIT", uint256(10 ether));
        uint256 deployAmount = vm.envOr("REHYPOTHECATION_DEPLOY", uint256(5 ether));
        uint256 returnAmount = vm.envOr("REHYPOTHECATION_RETURN", uint256(2 ether));
        uint256 yieldFunding = vm.envOr("REHYPOTHECATION_YIELD_FUNDING", uint256(0.0002 ether));
        uint256 yieldAccrual = vm.envOr("REHYPOTHECATION_YIELD_ACCRUAL", uint256(0.0001 ether));

        CoordiFlowRehypothecationVault vault = CoordiFlowRehypothecationVault(payable(vaultAddress));

        vm.startBroadcast(privateKey);
        IERC20(underlying).approve(vaultAddress, depositAmount);
        vault.deposit(depositAmount);
        vault.deployToStrategy(deployAmount, keccak256("COORDIFLOW_LIGHT_REHYPOTHECATION_V1"));
        vault.returnFromStrategy(returnAmount);
        vault.fundYield{value: yieldFunding}();
        vault.accrueYield(deployer, yieldAccrual);
        vm.stopBroadcast();

        console2.log("RehypothecationVault", vaultAddress);
        console2.log("Depositor", deployer);
        console2.log("Deposit", vault.deposits(deployer));
        console2.log("AvailableAssets", vault.availableAssets());
        console2.log("DeployedAssets", vault.deployedAssets());
        console2.log("YieldPool", vault.yieldPool());
        console2.log("ClaimableYield", vault.claimableYield(deployer));
    }
}
