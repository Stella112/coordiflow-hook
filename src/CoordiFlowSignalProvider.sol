// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";

import {IExchangeOSSignalProvider} from "./interfaces/IExchangeOSSignalProvider.sol";

contract CoordiFlowSignalProvider is IExchangeOSSignalProvider {
    address public immutable owner;
    bytes32 public constant SOURCE = keccak256("COORDIFLOW_X_LAYER_SIGNAL_PROVIDER_V1");

    mapping(PoolId poolId => mapping(address wallet => Signal signal)) internal signals;

    event SignalUpdated(
        bytes32 indexed poolId,
        address indexed wallet,
        int16 walletSignalBps,
        int16 marketSignalBps,
        bytes32 indexed source
    );
    event MomentumRecorded(bytes32 indexed poolId, uint256 previousPrice, uint256 nextPrice, int16 marketSignalBps);

    error OnlyOwner();
    error SignalOutOfRange();

    constructor(address initialOwner) {
        owner = initialOwner;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }

    function getSignal(PoolId poolId, address wallet) external view returns (Signal memory signal) {
        signal = signals[poolId][wallet];
        Signal memory market = signals[poolId][address(0)];

        if (!signal.available) {
            signal = Signal({
                available: market.available,
                walletSignalBps: 0,
                marketSignalBps: market.marketSignalBps,
                updatedAt: market.updatedAt,
                source: market.source
            });
        } else if (market.available) {
            signal.marketSignalBps = market.marketSignalBps;
        }
    }

    function setWalletSignal(PoolId poolId, address wallet, int16 walletSignalBps) external onlyOwner {
        _validateSignal(walletSignalBps);
        Signal storage signal = signals[poolId][wallet];
        signal.available = true;
        signal.walletSignalBps = walletSignalBps;
        signal.updatedAt = uint40(block.timestamp);
        signal.source = SOURCE;

        emit SignalUpdated(PoolId.unwrap(poolId), wallet, walletSignalBps, signal.marketSignalBps, SOURCE);
    }

    function setMarketSignal(PoolId poolId, int16 marketSignalBps) external onlyOwner {
        _setMarketSignal(poolId, marketSignalBps);
    }

    function recordMomentum(PoolId poolId, uint256 previousPrice, uint256 nextPrice) external onlyOwner {
        require(previousPrice != 0, "NO_PREVIOUS_PRICE");

        int256 changeBps = (int256(nextPrice) - int256(previousPrice)) * 10_000 / int256(previousPrice);
        if (changeBps > 2_500) changeBps = 2_500;
        if (changeBps < -2_500) changeBps = -2_500;

        int16 marketSignalBps = int16(changeBps);
        _setMarketSignal(poolId, marketSignalBps);
        emit MomentumRecorded(PoolId.unwrap(poolId), previousPrice, nextPrice, marketSignalBps);
    }

    function _setMarketSignal(PoolId poolId, int16 marketSignalBps) internal {
        _validateSignal(marketSignalBps);
        Signal storage signal = signals[poolId][address(0)];
        signal.available = true;
        signal.marketSignalBps = marketSignalBps;
        signal.updatedAt = uint40(block.timestamp);
        signal.source = SOURCE;

        emit SignalUpdated(PoolId.unwrap(poolId), address(0), 0, marketSignalBps, SOURCE);
    }

    function _validateSignal(int16 signalBps) internal pure {
        if (signalBps > 5_000 || signalBps < -5_000) revert SignalOutOfRange();
    }
}
