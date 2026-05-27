# CoordiFlow

CoordiFlow is a behavior-aware Uniswap v4 launch protocol on X Layer.

Tagline: **Not all coordination is equal.**

The hook turns launch participation into market state. Wallets become Seeder, Builder, Stabilizer, or Restricted based on real pool behavior, and those personas influence per-swap fees, launch phase, coordination score, and liquidity-release state.

## What Is Built

- `src/CoordiFlowHook.sol` tracks real wallet behavior per pool.
- `src/CoordiFlowToken.sol` is a launch token contract for an on-chain CoordiFlow launch asset.
- `script/00_DeployCoordiFlowHook.s.sol` mines and deploys the hook at a valid Uniswap v4 hook-permission address.
- `script/01_DeployCoordiFlowToken.s.sol` deploys the launch token.
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
TEST_PERMIT2=0x3191Fc1E303EF4e12a7DE5f5d2e8d53A0660c5b9
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

Use `xlayer_mainnet` after testnet is fully validated.

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

It does not simulate data. It reads `poolState` and `walletStats` directly from the deployed hook.
