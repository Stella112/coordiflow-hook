// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "forge-std/interfaces/IERC20.sol";

import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {LPFeeLibrary} from "@uniswap/v4-core/src/libraries/LPFeeLibrary.sol";

import {CoordiFlowStrategyReserve} from "./CoordiFlowStrategyReserve.sol";
import {ICoordiFlowPersonaHook} from "./interfaces/ICoordiFlowPersonaHook.sol";

contract CoordiFlowRehypothecationVault {
    uint8 internal constant PERSONA_SEEDER = 1;
    uint8 internal constant PERSONA_BUILDER = 2;
    uint8 internal constant PERSONA_STABILIZER = 3;

    address public immutable owner;
    ICoordiFlowPersonaHook public immutable hook;
    address public immutable launchToken;
    address public immutable quoteToken;
    address public immutable underlying;
    CoordiFlowStrategyReserve public immutable strategyReserve;
    bool public immutable launchTokenIsCurrency0;

    uint256 public totalDeposits;
    uint256 public deployedAssets;
    uint256 public yieldPool;

    mapping(address wallet => uint256 amount) public deposits;
    mapping(address wallet => uint256 amount) public claimableYield;

    event Deposited(address indexed wallet, uint256 amount);
    event Withdrawn(address indexed wallet, uint256 amount);
    event AssetsRehypothecated(address indexed strategy, uint256 amount, bytes32 indexed moduleId);
    event AssetsReturned(uint256 amount);
    event YieldFunded(address indexed funder, uint256 amount);
    event YieldAccrued(address indexed wallet, uint256 amount);
    event YieldClaimed(address indexed wallet, uint256 amount);

    error OnlyOwner();
    error NotPositivePersona();
    error InsufficientDeposit();
    error InsufficientIdleAssets();
    error InsufficientDeployedAssets();
    error NothingToClaim();

    constructor(
        address initialOwner,
        ICoordiFlowPersonaHook hook_,
        address launchToken_,
        address quoteToken_,
        address underlying_,
        CoordiFlowStrategyReserve strategyReserve_
    ) {
        owner = initialOwner;
        hook = hook_;
        launchToken = launchToken_;
        quoteToken = quoteToken_;
        underlying = underlying_;
        strategyReserve = strategyReserve_;
        launchTokenIsCurrency0 = launchToken_ < quoteToken_;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }

    function deposit(uint256 amount) external {
        if (!_isPositivePersona(msg.sender)) revert NotPositivePersona();

        deposits[msg.sender] += amount;
        totalDeposits += amount;
        IERC20(underlying).transferFrom(msg.sender, address(this), amount);

        emit Deposited(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        if (deposits[msg.sender] < amount) revert InsufficientDeposit();
        if (availableAssets() < amount) revert InsufficientIdleAssets();

        deposits[msg.sender] -= amount;
        totalDeposits -= amount;
        IERC20(underlying).transfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    function deployToStrategy(uint256 amount, bytes32 moduleId) external onlyOwner {
        if (availableAssets() < amount) revert InsufficientIdleAssets();

        deployedAssets += amount;
        IERC20(underlying).transfer(address(strategyReserve), amount);

        emit AssetsRehypothecated(address(strategyReserve), amount, moduleId);
    }

    function returnFromStrategy(uint256 amount) external onlyOwner {
        if (deployedAssets < amount) revert InsufficientDeployedAssets();

        deployedAssets -= amount;
        strategyReserve.returnAssets(underlying, amount);

        emit AssetsReturned(amount);
    }

    function fundYield() external payable {
        yieldPool += msg.value;
        emit YieldFunded(msg.sender, msg.value);
    }

    function accrueYield(address wallet, uint256 amount) external onlyOwner {
        if (yieldPool < amount) revert InsufficientIdleAssets();
        yieldPool -= amount;
        claimableYield[wallet] += amount;
        emit YieldAccrued(wallet, amount);
    }

    function claimYield() external {
        uint256 amount = claimableYield[msg.sender];
        if (amount == 0) revert NothingToClaim();
        claimableYield[msg.sender] = 0;
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "YIELD_CLAIM_FAILED");
        emit YieldClaimed(msg.sender, amount);
    }

    function availableAssets() public view returns (uint256) {
        return IERC20(underlying).balanceOf(address(this));
    }

    function poolKey() public view returns (PoolKey memory) {
        (address token0, address token1) = launchTokenIsCurrency0 ? (launchToken, quoteToken) : (quoteToken, launchToken);
        return PoolKey({
            currency0: Currency.wrap(token0),
            currency1: Currency.wrap(token1),
            fee: LPFeeLibrary.DYNAMIC_FEE_FLAG,
            tickSpacing: 60,
            hooks: IHooks(address(hook))
        });
    }

    function _isPositivePersona(address wallet) internal view returns (bool) {
        uint8 persona = hook.personaOf(poolKey(), wallet);
        return persona == PERSONA_SEEDER || persona == PERSONA_BUILDER || persona == PERSONA_STABILIZER;
    }
}
