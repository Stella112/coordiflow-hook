// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BaseHook} from "@openzeppelin/uniswap-hooks/src/base/BaseHook.sol";

import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {LPFeeLibrary} from "@uniswap/v4-core/src/libraries/LPFeeLibrary.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {SwapParams, ModifyLiquidityParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {IExchangeOSSignalProvider} from "./interfaces/IExchangeOSSignalProvider.sol";
import {ICoordiFlowRewardsVault} from "./interfaces/ICoordiFlowRewardsVault.sol";

contract CoordiFlowHook is BaseHook {
    using PoolIdLibrary for PoolKey;
    using LPFeeLibrary for uint24;

    enum Persona {
        Unclassified,
        Seeder,
        Builder,
        Stabilizer,
        Restricted
    }

    struct WalletStats {
        uint40 firstInteraction;
        uint40 lastInteraction;
        uint40 lastBuy;
        uint40 lastSell;
        uint128 cumulativeBuyVolume;
        uint128 cumulativeSellVolume;
        uint128 maxTradeSize;
        uint32 swapCount;
        uint32 liquidityActions;
        uint16 rapidRoundTrips;
        Persona persona;
        bool countedUnique;
        bool countedPositive;
    }

    struct PoolConfig {
        bool configured;
        bool launchTokenIsCurrency0;
        uint24 baseFee;
        uint24 builderFee;
        uint24 restrictedFee;
        uint128 maxSwapAmount;
        uint40 rapidRoundTripWindow;
        uint16 rewardBps;
    }

    struct PoolState {
        uint32 uniqueParticipants;
        uint32 positiveParticipants;
        uint32 restrictedParticipants;
        uint32 phase;
        uint256 coordinationScore;
        uint16 liquidityReleaseBps;
        int16 lastMarketSignalBps;
    }

    address public immutable owner;
    IExchangeOSSignalProvider public signalProvider;
    ICoordiFlowRewardsVault public rewardsVault;

    mapping(PoolId poolId => PoolConfig config) public poolConfig;
    mapping(PoolId poolId => PoolState state) public poolState;
    mapping(PoolId poolId => mapping(address wallet => WalletStats stats)) public walletStats;

    event PoolConfigured(
        bytes32 indexed poolId,
        bool launchTokenIsCurrency0,
        uint24 baseFee,
        uint24 builderFee,
        uint24 restrictedFee,
        uint128 maxSwapAmount,
        uint16 rewardBps
    );
    event ParticipantUpdated(
        bytes32 indexed poolId,
        address indexed wallet,
        Persona persona,
        uint128 cumulativeBuyVolume,
        uint128 cumulativeSellVolume,
        uint32 liquidityActions,
        uint16 rapidRoundTrips,
        int16 signalBps
    );
    event CoordinationUpdated(
        bytes32 indexed poolId,
        uint256 coordinationScore,
        uint32 phase,
        uint16 liquidityReleaseBps,
        uint32 uniqueParticipants,
        uint32 positiveParticipants,
        int16 marketSignalBps
    );
    event SignalProviderUpdated(address indexed signalProvider);
    event RewardsVaultUpdated(address indexed rewardsVault);

    error OnlyOwner();
    error SwapCapExceeded(uint256 amount, uint256 cap);

    constructor(IPoolManager _poolManager, address owner_) BaseHook(_poolManager) {
        owner = owner_;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: true,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: true,
            afterRemoveLiquidity: false,
            beforeSwap: true,
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    function configurePool(
        PoolKey calldata key,
        bool launchTokenIsCurrency0,
        uint24 baseFee,
        uint24 builderFee,
        uint24 restrictedFee,
        uint128 maxSwapAmount,
        uint40 rapidRoundTripWindow,
        uint16 rewardBps
    ) external onlyOwner {
        baseFee.validate();
        builderFee.validate();
        restrictedFee.validate();
        require(rewardBps <= 10_000, "REWARD_BPS_TOO_HIGH");

        PoolId poolId = key.toId();
        poolConfig[poolId] = PoolConfig({
            configured: true,
            launchTokenIsCurrency0: launchTokenIsCurrency0,
            baseFee: baseFee,
            builderFee: builderFee,
            restrictedFee: restrictedFee,
            maxSwapAmount: maxSwapAmount,
            rapidRoundTripWindow: rapidRoundTripWindow == 0 ? 10 minutes : rapidRoundTripWindow,
            rewardBps: rewardBps
        });

        emit PoolConfigured(
            PoolId.unwrap(poolId), launchTokenIsCurrency0, baseFee, builderFee, restrictedFee, maxSwapAmount, rewardBps
        );
    }

    function setSignalProvider(IExchangeOSSignalProvider signalProvider_) external onlyOwner {
        signalProvider = signalProvider_;
        emit SignalProviderUpdated(address(signalProvider_));
    }

    function setRewardsVault(ICoordiFlowRewardsVault rewardsVault_) external onlyOwner {
        rewardsVault = rewardsVault_;
        emit RewardsVaultUpdated(address(rewardsVault_));
    }

    function personaOf(PoolKey calldata key, address wallet) external view returns (Persona) {
        return walletStats[key.toId()][wallet].persona;
    }

    function _beforeSwap(address sender, PoolKey calldata key, SwapParams calldata params, bytes calldata hookData)
        internal
        override
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        PoolId poolId = key.toId();
        PoolConfig memory config = _configOrDefault(poolId);
        address wallet = _walletFromHookData(sender, hookData);
        uint256 tradeSize = _abs(params.amountSpecified);

        if (config.maxSwapAmount != 0 && tradeSize > config.maxSwapAmount) {
            revert SwapCapExceeded(tradeSize, config.maxSwapAmount);
        }

        uint24 fee = _feeForPersona(config, walletStats[poolId][wallet].persona);
        return (BaseHook.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, fee | LPFeeLibrary.OVERRIDE_FEE_FLAG);
    }

    function _afterSwap(
        address sender,
        PoolKey calldata key,
        SwapParams calldata params,
        BalanceDelta,
        bytes calldata hookData
    ) internal override returns (bytes4, int128) {
        PoolId poolId = key.toId();
        PoolConfig memory config = _configOrDefault(poolId);
        address wallet = _walletFromHookData(sender, hookData);
        WalletStats storage stats = walletStats[poolId][wallet];

        _touch(poolId, wallet, stats);

        uint128 tradeSize = _toUint128(_abs(params.amountSpecified));
        bool isBuy = params.zeroForOne != config.launchTokenIsCurrency0;
        if (isBuy) {
            stats.cumulativeBuyVolume += tradeSize;
            stats.lastBuy = uint40(block.timestamp);
            if (
                stats.lastSell != 0 && block.timestamp - stats.lastSell <= config.rapidRoundTripWindow
                    && stats.cumulativeSellVolume != 0
            ) {
                stats.rapidRoundTrips++;
            }
        } else {
            stats.cumulativeSellVolume += tradeSize;
            stats.lastSell = uint40(block.timestamp);
            if (
                stats.lastBuy != 0 && block.timestamp - stats.lastBuy <= config.rapidRoundTripWindow
                    && stats.cumulativeBuyVolume != 0
            ) {
                stats.rapidRoundTrips++;
            }
        }

        stats.swapCount++;
        if (tradeSize > stats.maxTradeSize) stats.maxTradeSize = tradeSize;

        _refreshPersona(poolId, wallet, stats);
        _accrueCoordinationReward(poolId, wallet, stats.persona, tradeSize, config.rewardBps);
        return (BaseHook.afterSwap.selector, 0);
    }

    function _beforeAddLiquidity(
        address sender,
        PoolKey calldata key,
        ModifyLiquidityParams calldata params,
        bytes calldata hookData
    ) internal override returns (bytes4) {
        if (params.liquidityDelta > 0) {
            PoolId poolId = key.toId();
            address wallet = _walletFromHookData(sender, hookData);
            WalletStats storage stats = walletStats[poolId][wallet];

            _touch(poolId, wallet, stats);
            stats.liquidityActions++;
            _refreshPersona(poolId, wallet, stats);
            _accrueCoordinationReward(
                poolId, wallet, stats.persona, uint256(params.liquidityDelta), _configOrDefault(poolId).rewardBps
            );
        }

        return BaseHook.beforeAddLiquidity.selector;
    }

    function _beforeRemoveLiquidity(
        address sender,
        PoolKey calldata key,
        ModifyLiquidityParams calldata,
        bytes calldata hookData
    ) internal override returns (bytes4) {
        PoolId poolId = key.toId();
        address wallet = _walletFromHookData(sender, hookData);
        WalletStats storage stats = walletStats[poolId][wallet];

        _touch(poolId, wallet, stats);
        _refreshPersona(poolId, wallet, stats);

        return BaseHook.beforeRemoveLiquidity.selector;
    }

    function _touch(PoolId poolId, address, WalletStats storage stats) internal {
        if (stats.firstInteraction == 0) {
            stats.firstInteraction = uint40(block.timestamp);
            if (!stats.countedUnique) {
                stats.countedUnique = true;
                poolState[poolId].uniqueParticipants++;
            }
        }
        stats.lastInteraction = uint40(block.timestamp);
    }

    function _refreshPersona(PoolId poolId, address wallet, WalletStats storage stats) internal {
        IExchangeOSSignalProvider.Signal memory signal = _walletSignal(poolId, wallet);
        Persona oldPersona = stats.persona;
        Persona nextPersona = _classify(stats, signal.walletSignalBps);

        if (oldPersona != nextPersona) {
            bool wasPositive = _isPositive(oldPersona);
            bool isPositive = _isPositive(nextPersona);

            if (!wasPositive && isPositive && !stats.countedPositive) {
                stats.countedPositive = true;
                poolState[poolId].positiveParticipants++;
            }
            if (oldPersona != Persona.Restricted && nextPersona == Persona.Restricted) {
                poolState[poolId].restrictedParticipants++;
            }

            stats.persona = nextPersona;
        }

        _updateCoordination(poolId);
        emit ParticipantUpdated(
            PoolId.unwrap(poolId),
            wallet,
            stats.persona,
            stats.cumulativeBuyVolume,
            stats.cumulativeSellVolume,
            stats.liquidityActions,
            stats.rapidRoundTrips,
            signal.walletSignalBps
        );
    }

    function _classify(WalletStats memory stats, int16 walletSignalBps) internal view returns (Persona) {
        if (walletSignalBps <= -2_500) return Persona.Restricted;
        if (walletSignalBps >= 2_500 && stats.swapCount > 0 && stats.cumulativeBuyVolume >= stats.cumulativeSellVolume)
        {
            return Persona.Builder;
        }
        if (stats.rapidRoundTrips >= 2) return Persona.Restricted;
        if (stats.cumulativeSellVolume > stats.cumulativeBuyVolume && stats.cumulativeBuyVolume != 0) {
            return Persona.Restricted;
        }
        if (stats.liquidityActions > 0 && stats.firstInteraction + 1 days >= block.timestamp) {
            return Persona.Seeder;
        }
        if (stats.swapCount >= 3 && stats.cumulativeBuyVolume >= stats.cumulativeSellVolume) {
            return Persona.Builder;
        }
        if (stats.swapCount > 0 || stats.liquidityActions > 0) return Persona.Stabilizer;
        return Persona.Unclassified;
    }

    function _updateCoordination(PoolId poolId) internal {
        PoolState storage state = poolState[poolId];
        IExchangeOSSignalProvider.Signal memory signal = _marketSignal(poolId);
        state.lastMarketSignalBps = signal.marketSignalBps;

        uint256 quality = 0;
        if (state.uniqueParticipants != 0) {
            quality = (uint256(state.positiveParticipants) * 1e18) / state.uniqueParticipants;
        }

        state.coordinationScore = uint256(state.positiveParticipants) * quality / 1e16;
        state.coordinationScore = _applySignal(state.coordinationScore, signal.marketSignalBps);

        uint32 phase = 0;
        uint16 releaseBps = 0;
        if (state.coordinationScore >= 8_000) {
            phase = 3;
            releaseBps = 10_000;
        } else if (state.coordinationScore >= 3_000) {
            phase = 2;
            releaseBps = 6_000;
        } else if (state.coordinationScore >= 500) {
            phase = 1;
            releaseBps = 2_500;
        }

        if (phase != state.phase || releaseBps != state.liquidityReleaseBps) {
            state.phase = phase;
            state.liquidityReleaseBps = releaseBps;
            emit CoordinationUpdated(
                PoolId.unwrap(poolId),
                state.coordinationScore,
                state.phase,
                state.liquidityReleaseBps,
                state.uniqueParticipants,
                state.positiveParticipants,
                state.lastMarketSignalBps
            );
        }
    }

    function _feeForPersona(PoolConfig memory config, Persona persona) internal pure returns (uint24) {
        if (persona == Persona.Builder || persona == Persona.Seeder) return config.builderFee;
        if (persona == Persona.Restricted) return config.restrictedFee;
        return config.baseFee;
    }

    function _configOrDefault(PoolId poolId) internal view returns (PoolConfig memory config) {
        config = poolConfig[poolId];
        if (!config.configured) {
            config = PoolConfig({
                configured: false,
                launchTokenIsCurrency0: false,
                baseFee: 3000,
                builderFee: 1500,
                restrictedFee: 10000,
                maxSwapAmount: 0,
                rapidRoundTripWindow: 10 minutes,
                rewardBps: 0
            });
        }
    }

    function _walletSignal(PoolId poolId, address wallet)
        internal
        view
        returns (IExchangeOSSignalProvider.Signal memory)
    {
        if (address(signalProvider) == address(0)) {
            return IExchangeOSSignalProvider.Signal({
                available: false, walletSignalBps: 0, marketSignalBps: 0, updatedAt: 0, source: bytes32(0)
            });
        }

        try signalProvider.getSignal(poolId, wallet) returns (IExchangeOSSignalProvider.Signal memory signal) {
            return signal;
        } catch {
            return IExchangeOSSignalProvider.Signal({
                available: false, walletSignalBps: 0, marketSignalBps: 0, updatedAt: 0, source: bytes32(0)
            });
        }
    }

    function _marketSignal(PoolId poolId) internal view returns (IExchangeOSSignalProvider.Signal memory signal) {
        signal = _walletSignal(poolId, address(0));
    }

    function _applySignal(uint256 value, int16 signalBps) internal pure returns (uint256) {
        if (signalBps == 0) return value;

        int256 adjusted = int256(value) + (int256(value) * signalBps) / 10_000;
        if (adjusted <= 0) return 0;
        return uint256(adjusted);
    }

    function _accrueCoordinationReward(
        PoolId poolId,
        address wallet,
        Persona persona,
        uint256 activityAmount,
        uint16 rewardBps
    ) internal {
        if (address(rewardsVault) == address(0) || rewardBps == 0 || !_isPositive(persona)) {
            return;
        }

        uint256 rewardAmount = (activityAmount * rewardBps) / 10_000;
        rewardsVault.accrueReward(poolId, wallet, rewardAmount);
    }

    function _walletFromHookData(address sender, bytes calldata hookData) internal pure returns (address) {
        if (hookData.length >= 32) return abi.decode(hookData, (address));
        return sender;
    }

    function _isPositive(Persona persona) internal pure returns (bool) {
        return persona == Persona.Seeder || persona == Persona.Builder || persona == Persona.Stabilizer;
    }

    function _abs(int256 value) internal pure returns (uint256) {
        return value < 0 ? uint256(-value) : uint256(value);
    }

    function _toUint128(uint256 value) internal pure returns (uint128) {
        if (value > type(uint128).max) return type(uint128).max;
        return uint128(value);
    }
}
