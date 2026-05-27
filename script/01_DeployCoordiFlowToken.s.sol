// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {CoordiFlowToken} from "../src/CoordiFlowToken.sol";

contract DeployCoordiFlowTokenScript is Script {
    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(privateKey);

        string memory name = vm.envOr("TOKEN_NAME", string("CoordiFlow"));
        string memory symbol = vm.envOr("TOKEN_SYMBOL", string("COORD"));
        uint256 initialSupply = vm.envOr("TOKEN_SUPPLY", uint256(1_000_000 ether));

        vm.startBroadcast(privateKey);
        CoordiFlowToken token = new CoordiFlowToken(name, symbol, initialSupply, deployer);
        vm.stopBroadcast();

        console2.log("CoordiFlowToken", address(token));
        console2.log("Token name", name);
        console2.log("Token symbol", symbol);
        console2.log("Initial receiver", deployer);
    }
}
