// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";

interface IExchangeOSSignalProvider {
    struct Signal {
        bool available;
        int16 walletSignalBps;
        int16 marketSignalBps;
        uint40 updatedAt;
        bytes32 source;
    }

    function getSignal(PoolId poolId, address wallet) external view returns (Signal memory);
}
