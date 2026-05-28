// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {LPFeeLibrary} from "@uniswap/v4-core/src/libraries/LPFeeLibrary.sol";

import {CoordiFlowPersonaBadge} from "../src/CoordiFlowPersonaBadge.sol";
import {ICoordiFlowPersonaHook} from "../src/interfaces/ICoordiFlowPersonaHook.sol";

contract DeployAndMintPersonaBadgesScript is Script {
    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address hook = vm.envAddress("COORDIFLOW_HOOK");
        address launchToken = vm.envAddress("LAUNCH_TOKEN");
        address quoteToken = vm.envAddress("QUOTE_TOKEN");
        address seeder = vm.envAddress("COORDIFLOW_SEEDER");
        address builder = vm.envAddress("MAINNET_BUILDER");
        address stabilizer = vm.envAddress("MAINNET_STABILIZER");
        address restricted = vm.envAddress("MAINNET_RESTRICTED");

        PoolKey memory key = _poolKey(launchToken, quoteToken, hook);

        vm.startBroadcast(privateKey);
        CoordiFlowPersonaBadge badge = new CoordiFlowPersonaBadge(ICoordiFlowPersonaHook(hook));
        uint256 seederBadge = badge.mintFor(key, seeder);
        uint256 builderBadge = badge.mintFor(key, builder);
        uint256 stabilizerBadge = badge.mintFor(key, stabilizer);
        uint256 restrictedBadge = badge.mintFor(key, restricted);
        vm.stopBroadcast();

        console2.log("CoordiFlowPersonaBadge", address(badge));
        console2.log("SeederBadge", seederBadge);
        console2.log("BuilderBadge", builderBadge);
        console2.log("StabilizerBadge", stabilizerBadge);
        console2.log("RestrictedBadge", restrictedBadge);
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
