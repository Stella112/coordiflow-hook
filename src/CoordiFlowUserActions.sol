// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IUnlockCallback} from "@uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {BalanceDelta, BalanceDeltaLibrary} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {ModifyLiquidityParams, SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {LPFeeLibrary} from "@uniswap/v4-core/src/libraries/LPFeeLibrary.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";

contract CoordiFlowUserActions is IUnlockCallback {
    using BalanceDeltaLibrary for BalanceDelta;

    enum ActionType {
        Swap,
        ModifyLiquidity
    }

    struct CallbackData {
        ActionType actionType;
        address payer;
        address recipient;
        PoolKey key;
        SwapParams swapParams;
        ModifyLiquidityParams liquidityParams;
        bytes hookData;
        uint256 minAmountOut;
        uint256 maxAmount0;
        uint256 maxAmount1;
    }

    IPoolManager public immutable manager;
    address public immutable hook;
    address public immutable launchToken;
    address public immutable quoteToken;
    bool public immutable launchTokenIsCurrency0;

    mapping(bytes32 positionKey => int256 liquidity) public userLiquidity;

    bool private locked;

    event UserSwap(address indexed user, bool zeroForOne, uint256 amountIn, uint256 amountOut);
    event UserLiquidityAdded(address indexed user, int24 tickLower, int24 tickUpper, bytes32 indexed salt, int256 liquidity);
    event UserLiquidityRemoved(
        address indexed user, int24 tickLower, int24 tickUpper, bytes32 indexed salt, int256 liquidity
    );

    error OnlyPoolManager();
    error NativeCurrencyUnsupported();
    error ReentrantCall();
    error SlippageExceeded(uint256 amountOut, uint256 minAmountOut);
    error MaxTokenExceeded(uint256 amount0, uint256 maxAmount0, uint256 amount1, uint256 maxAmount1);
    error InvalidLiquidityDelta();
    error InsufficientTrackedLiquidity();

    constructor(IPoolManager manager_, address hook_, address launchToken_, address quoteToken_) {
        manager = manager_;
        hook = hook_;
        launchToken = launchToken_;
        quoteToken = quoteToken_;
        launchTokenIsCurrency0 = launchToken_ < quoteToken_;
    }

    modifier nonReentrant() {
        if (locked) revert ReentrantCall();
        locked = true;
        _;
        locked = false;
    }

    function poolKey() public view returns (PoolKey memory) {
        (address token0, address token1) = launchTokenIsCurrency0 ? (launchToken, quoteToken) : (quoteToken, launchToken);
        return PoolKey({
            currency0: Currency.wrap(token0),
            currency1: Currency.wrap(token1),
            fee: LPFeeLibrary.DYNAMIC_FEE_FLAG,
            tickSpacing: 60,
            hooks: IHooks(hook)
        });
    }

    function swapExactInput(uint256 amountIn, bool zeroForOne, uint256 minAmountOut)
        external
        nonReentrant
        returns (uint256 amountOut)
    {
        uint160 sqrtPriceLimitX96 = zeroForOne ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1;
        SwapParams memory params =
            SwapParams({zeroForOne: zeroForOne, amountSpecified: -int256(amountIn), sqrtPriceLimitX96: sqrtPriceLimitX96});

        BalanceDelta delta = abi.decode(
            manager.unlock(
                abi.encode(
                    CallbackData({
                        actionType: ActionType.Swap,
                        payer: msg.sender,
                        recipient: msg.sender,
                        key: poolKey(),
                        swapParams: params,
                        liquidityParams: ModifyLiquidityParams({
                            tickLower: 0,
                            tickUpper: 0,
                            liquidityDelta: 0,
                            salt: bytes32(0)
                        }),
                        hookData: abi.encode(msg.sender),
                        minAmountOut: minAmountOut,
                        maxAmount0: 0,
                        maxAmount1: 0
                    })
                )
            ),
            (BalanceDelta)
        );

        amountOut = uint256(uint128(zeroForOne ? delta.amount1() : delta.amount0()));
        emit UserSwap(msg.sender, zeroForOne, amountIn, amountOut);
    }

    function addLiquidity(
        int24 tickLower,
        int24 tickUpper,
        int256 liquidityDelta,
        bytes32 userSalt,
        uint256 maxAmount0,
        uint256 maxAmount1
    ) external nonReentrant returns (BalanceDelta delta) {
        if (liquidityDelta <= 0) revert InvalidLiquidityDelta();
        bytes32 salt = _positionSalt(msg.sender, userSalt);
        ModifyLiquidityParams memory params = ModifyLiquidityParams({
            tickLower: tickLower,
            tickUpper: tickUpper,
            liquidityDelta: liquidityDelta,
            salt: salt
        });

        delta = abi.decode(
            manager.unlock(
                abi.encode(
                    CallbackData({
                        actionType: ActionType.ModifyLiquidity,
                        payer: msg.sender,
                        recipient: msg.sender,
                        key: poolKey(),
                        swapParams: SwapParams({zeroForOne: false, amountSpecified: 0, sqrtPriceLimitX96: 0}),
                        liquidityParams: params,
                        hookData: abi.encode(msg.sender),
                        minAmountOut: 0,
                        maxAmount0: maxAmount0,
                        maxAmount1: maxAmount1
                    })
                )
            ),
            (BalanceDelta)
        );

        userLiquidity[_userPositionKey(msg.sender, tickLower, tickUpper, userSalt)] += liquidityDelta;
        emit UserLiquidityAdded(msg.sender, tickLower, tickUpper, userSalt, liquidityDelta);
    }

    function removeLiquidity(int24 tickLower, int24 tickUpper, int256 liquidityDelta, bytes32 userSalt)
        external
        nonReentrant
        returns (BalanceDelta delta)
    {
        if (liquidityDelta <= 0) revert InvalidLiquidityDelta();
        bytes32 trackedKey = _userPositionKey(msg.sender, tickLower, tickUpper, userSalt);
        if (userLiquidity[trackedKey] < liquidityDelta) revert InsufficientTrackedLiquidity();

        ModifyLiquidityParams memory params = ModifyLiquidityParams({
            tickLower: tickLower,
            tickUpper: tickUpper,
            liquidityDelta: -liquidityDelta,
            salt: _positionSalt(msg.sender, userSalt)
        });

        delta = abi.decode(
            manager.unlock(
                abi.encode(
                    CallbackData({
                        actionType: ActionType.ModifyLiquidity,
                        payer: msg.sender,
                        recipient: msg.sender,
                        key: poolKey(),
                        swapParams: SwapParams({zeroForOne: false, amountSpecified: 0, sqrtPriceLimitX96: 0}),
                        liquidityParams: params,
                        hookData: abi.encode(msg.sender),
                        minAmountOut: 0,
                        maxAmount0: 0,
                        maxAmount1: 0
                    })
                )
            ),
            (BalanceDelta)
        );

        userLiquidity[trackedKey] -= liquidityDelta;
        emit UserLiquidityRemoved(msg.sender, tickLower, tickUpper, userSalt, liquidityDelta);
    }

    function unlockCallback(bytes calldata rawData) external returns (bytes memory) {
        if (msg.sender != address(manager)) revert OnlyPoolManager();

        CallbackData memory data = abi.decode(rawData, (CallbackData));
        BalanceDelta delta;

        if (data.actionType == ActionType.Swap) {
            delta = manager.swap(data.key, data.swapParams, data.hookData);
            uint256 amountOut =
                uint256(uint128(data.swapParams.zeroForOne ? delta.amount1() : delta.amount0()));
            if (amountOut < data.minAmountOut) revert SlippageExceeded(amountOut, data.minAmountOut);
        } else {
            (delta,) = manager.modifyLiquidity(data.key, data.liquidityParams, data.hookData);
            uint256 amount0 = delta.amount0() < 0 ? uint256(uint128(-delta.amount0())) : 0;
            uint256 amount1 = delta.amount1() < 0 ? uint256(uint128(-delta.amount1())) : 0;
            if (amount0 > data.maxAmount0 || amount1 > data.maxAmount1) {
                revert MaxTokenExceeded(amount0, data.maxAmount0, amount1, data.maxAmount1);
            }
        }

        _settleOrTake(data.key.currency0, delta.amount0(), data.payer, data.recipient);
        _settleOrTake(data.key.currency1, delta.amount1(), data.payer, data.recipient);

        return abi.encode(delta);
    }

    function _settleOrTake(Currency currency, int128 delta, address payer, address recipient) internal {
        if (delta == 0) return;
        address token = Currency.unwrap(currency);
        if (token == address(0)) revert NativeCurrencyUnsupported();

        if (delta < 0) {
            uint256 amount = uint256(uint128(-delta));
            manager.sync(currency);
            IERC20(token).transferFrom(payer, address(manager), amount);
            manager.settle();
        } else {
            manager.take(currency, recipient, uint256(uint128(delta)));
        }
    }

    function _positionSalt(address user, bytes32 userSalt) internal pure returns (bytes32) {
        return keccak256(abi.encode(user, userSalt));
    }

    function _userPositionKey(address user, int24 tickLower, int24 tickUpper, bytes32 userSalt)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(user, tickLower, tickUpper, userSalt));
    }
}
