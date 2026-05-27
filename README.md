# CoordiFlow

CoordiFlow is a behavior-aware Uniswap v4 launch protocol on X Layer, designed for Flap-style modular token launches.

Tagline: **Not all coordination is equal.**

The hook turns launch participation into market state. Wallets become Seeder, Builder, Stabilizer, or Restricted based on real pool behavior, and those personas influence per-swap fees, launch phase, coordination score, liquidity-release state, and rewards.

One-liner:

> CoordiFlow is a Uniswap v4 Hook on X Layer that turns Flap-style token launches into behavior-aware coordination markets, where liquidity, fees, rewards, and market stages respond to the quality of participation, not just volume.

## Product Stack

**CoordiFlow Core Hook**

- persona scoring
- coordination score
- dynamic fees and caps
- market stage unlocks

**Flap Launch Compatibility**

- designed to attach to standard Uniswap v4 pools created by modular launch flows
- complements Flap-style token creation and trading with behavior-aware launch logic
- supports programmable fee and liquidity-release mechanics at the hook layer

**X Layer Intelligence Layer**

- optional `IExchangeOSSignalProvider` adapter
- wallet and market signal boosts
- disabled unless a real on-chain/provider source is configured

**Coordination Rewards Layer**

- Seeders, Builders, and Stabilizers can earn from a funded rewards vault
- unhealthy/restricted flow does not earn
- future modules can route hook fees, penalties, or idle-liquidity rewards into the vault

## Flap Positioning

CoordiFlow is positioned as a coordination layer for Flap-powered launches.

Flap can handle the simple token creation and early trading flow. CoordiFlow adds the missing behavior-aware market layer at the Uniswap v4 hook level: it watches how wallets participate, classifies launch behavior, adjusts fees and caps, advances market stages, and routes rewards toward constructive participants.

This repo does not claim a private Flap API integration. The MVP is intentionally built as a pure Uniswap v4 Hook so it can be attached to any compatible v4 launch pool, including Flap-style launch flows on X Layer.

## What Is Built

- `src/CoordiFlowHook.sol` tracks real wallet behavior per pool.
- `src/interfaces/IExchangeOSSignalProvider.sol` defines the optional X Layer intelligence adapter.
- `src/CoordiFlowRewardsVault.sol` holds and pays real claimable rewards for positive coordination.
- `src/CoordiFlowToken.sol` is a launch token contract for an on-chain CoordiFlow launch asset.
- `script/00_DeployCoordiFlowHook.s.sol` mines and deploys the hook at a valid Uniswap v4 hook-permission address.
- `script/01_DeployCoordiFlowToken.s.sol` deploys the launch token.
- `script/02_DeployRewardsVault.s.sol` deploys and connects the rewards vault.
- `script/03_CreateCoordiFlowPool.s.sol` initializes a real dynamic-fee v4 pool, configures the hook, mints liquidity, and can fund rewards.
- `web/` is a no-fake-data dashboard that reads hook state from X Layer RPC.

## Local Secret Setup

Create a local `.env` file in this folder:

```text
coordiflow/.env
```

Copy `.env.example`, then paste your fresh burner deployer key into `PRIVATE_KEY`.

Never commit `.env` and never paste private keys into chat.

Required before deployment:

```env
PRIVATE_KEY=
XLAYER_TESTNET_RPC=https://testrpc.xlayer.tech/terigon
XLAYER_MAINNET_RPC=https://rpc.xlayer.tech
POOL_MANAGER=
TOKEN_NAME=CoordiFlow
TOKEN_SYMBOL=COORD
TOKEN_SUPPLY=1000000000000000000000000
```

`POOL_MANAGER` must be the official or hackathon-provided Uniswap v4 PoolManager on X Layer, or the PoolManager address from a V4 stack deployed for the hackathon.

For X Layer testnet, this repo can deploy its own test v4 stack. The current deterministic Permit2 address already has bytecode on X Layer testnet:

```env
PERMIT2=0x3191Fc1E303EF4e12a7DE5f5d2e8d53A0660c5b9
```

## Build And Test

```bash
forge test
forge build
```

This repo uses `via_ir = true` because the Uniswap v4 dependency graph can hit stack-depth limits without it.

## Deploy

Deploy a test Uniswap v4 stack on X Layer testnet:

```bash
forge script script/00_DeployXLayerTestV4Stack.s.sol:DeployXLayerTestV4StackScript \
  --rpc-url xlayer_testnet \
  --broadcast
```

After that script succeeds, copy its `PoolManager` output into `POOL_MANAGER` for testnet hook deployment.

Deploy the token:

```bash
forge script script/01_DeployCoordiFlowToken.s.sol:DeployCoordiFlowTokenScript \
  --rpc-url xlayer_testnet \
  --broadcast
```

Deploy the hook:

```bash
forge script script/00_DeployCoordiFlowHook.s.sol:DeployCoordiFlowHookScript \
  --rpc-url xlayer_testnet \
  --broadcast
```

Deploy and connect the rewards vault:

```bash
forge script script/02_DeployRewardsVault.s.sol:DeployRewardsVaultScript \
  --rpc-url xlayer_testnet \
  --broadcast
```

Create the real CoordiFlow pool and add liquidity:

```bash
forge script script/03_CreateCoordiFlowPool.s.sol:CreateCoordiFlowPoolScript \
  --rpc-url xlayer_testnet \
  --broadcast
```

Use `xlayer_mainnet` after testnet is fully validated.

## X Layer Testnet Deployment

Current deployed testnet addresses are recorded in `deployments/xlayer-testnet.json`.

- Hook: `0xDee0822330A786313E46A4f6d9E2d58c33B20AC0`
- Pool ID: `0x660353cea0aed4458ad5404c32f8033627539819271ca4738d325bd063370ac2`
- Launch token: `0x31316Ec55D0f843357F22A8533b467A69b427b26`
- Quote token: `0xB779178fF3269f4404263Adb930507978887b53b`
- Rewards vault: `0x90407637D45588F0663b722438C6452c637c51d2`
- PoolManager: `0xEAC4fcF2fB22E9887c830cD3EF78F1d28fC3BbCf`
- PositionManager: `0x8DE4b634760F7942A20B7fA994AAc72F03ce4751`
- Permit2: `0x3191Fc1E303EF4e12a7DE5f5d2e8d53A0660c5b9`

## Dashboard

Open:

```text
web/index.html
```

The dashboard requires:

- hook contract address
- pool ID
- wallet address
- X Layer RPC endpoint

The checked-in dashboard is prefilled with the current X Layer testnet deployment. It does not simulate data. It reads `poolState`, `walletStats`, and reward claims directly from deployed contracts.
