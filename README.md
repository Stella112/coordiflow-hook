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
- v2 contracts automatically record restricted-flow penalty credits from the hook into the rewards vault ledger
- future settlement modules can route actual hook-collected fee proceeds into the vault

## Flap Positioning

CoordiFlow is positioned as a coordination layer for Flap-powered launches.

Flap can handle the simple token creation and early trading flow. CoordiFlow adds the missing behavior-aware market layer at the Uniswap v4 hook level: it watches how wallets participate, classifies launch behavior, adjusts fees and caps, advances market stages, and routes rewards toward constructive participants.

This repo does not claim a private Flap API integration. The MVP is intentionally built as a pure Uniswap v4 Hook so it can be attached to any compatible v4 launch pool, including Flap-style launch flows on X Layer.

## What Is Built

- `src/CoordiFlowHook.sol` tracks real wallet behavior per pool.
- `src/interfaces/IExchangeOSSignalProvider.sol` defines the optional X Layer intelligence adapter.
- `src/CoordiFlowRewardsVault.sol` holds and pays real claimable rewards for positive coordination.
- `src/CoordiFlowRewardsVault.sol` also exposes the v2 penalty ledger: `penaltyCredits(poolId)` and `walletPenaltyCredits(poolId, wallet)`.
- `src/CoordiFlowRehypothecationVault.sol` lets positive personas deposit idle CQUOTE and claim real OKB yield.
- `src/CoordiFlowUserActions.sol` is the public user-facing helper for real swaps and LP actions against the CoordiFlow v4 pool.
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

Run real participant swaps for the dashboard persona walkthrough:

```bash
forge script script/04_RunCoordiFlowScenario.s.sol:RunCoordiFlowScenarioScript \
  --rpc-url xlayer_testnet \
  --broadcast
```

Use `xlayer_mainnet` for the official X Layer mainnet deployment.

## X Layer Mainnet Deployment

Current deployed mainnet addresses are recorded in `deployments/xlayer-mainnet.json`.

- Hook: `0x42D04F47EB54d48D39EA177E418E322e1FaF4AC0`
- User actions helper: `0xfb2C898DB77D6FECba6b6A9e4Cd8A0869F166734`
- USDT0 route pool ID: `0x4dee7db9acada05cd1be6a1bb4d3d63e54dc83dad2cf625ace41c8b3efbaba6a`
- USDT0 route user actions helper: `0x7e4B149Fd681cc2649a3CC7e8Bb3f786b3eAE33b`
- Pool ID: `0x7dbd1af7f0d60d90005b959f35d17c09ddd8a145b689234d45dbf1ce599938a9`
- Launch token: `0xACdF5260e2d89Cd29c3b09a32EEf3Ae6aB679081`
- Quote token: `0xB20ECE2960cD24eA0E8476F397bC0F06BCBa2BE5`
- Rewards vault: `0xD26732420947b470B2d92F07B083254E7Bcd6Dfa`
- Rehypothecation vault: `0xf8875dDE68F71f6BA448C5B58b43D4bCAFe93bdb`
- Strategy reserve: `0xDc22FfCDfc4d14D35bF64E0c41FB608Ad2912808`
- Signal provider: `0x904d734b523BFD94542f93A9a3a2d46e3aC6767A`
- Persona badge SBT: `0x82b4Cb5AC9C68eB6cbbb4eFcAB637054AA43c815`
- Aave-ready strategy reserve: `0x07062Ef73A544690Ea590B6e75715222f060fa6c`
- Builder agent: `0xc313710fA15c76fFac68b90d016209Fd85598a42`
- Stabilizer agent: `0x532f7C92cAB420689B7A324724790a20b7c2f406`
- Restricted agent: `0x1f5a737Bef38ACFd3C2e51a2b07e8B0CE34d82F8`
- PoolManager: `0x360E68faCcca8cA495c1B759Fd9EEe466db9FB32`
- PositionManager: `0xcF1eAFC6928dC385A342E7c6491D371d2871458B`
- Permit2: `0x000000000022D473030F116dDEE9F6B43aC78BA3`

Official X Layer assets surfaced in the dashboard:

- WOKB: `0xe538905cf8410324e03A5A23C1c177a474D59b2b`
- USDT: `0x1E4a5963aBFD975d8c9021ce480b42188849D41d`
- USDT0: `0x779Ded0c9e1022225f8E0630b35a9b54bE713736`

Mainnet verification reads:

- Hook bytecode is present at the deployed hook address.
- `poolState`: 4 unique participants, 4 positive participants, 1 restricted participant, coordination score 400.
- Mainnet personas: Builder `2`, Stabilizer `3`, Restricted `4`.
- Rewards vault pool balance after real reward accrual: `525076889504992` wei.
- Rehypothecation proof: `10 CQUOTE` deposited by a positive persona, `3 CQUOTE` currently deployed in the strategy reserve, and `0.0001 OKB` claimable yield accrued on-chain.
- X Layer intelligence proof: hook is connected to the signal provider; restricted wallet signal is `-3000 bps`, market momentum signal is `+500 bps`.
- Persona badge proof: Seeder badge `#1`, Builder badge `#2`, Stabilizer badge `#3`, Restricted badge `#4`.
- Aave integration: an Aave-compatible strategy reserve is deployed and ready for the official X Layer Aave pool address. The current official BGD Aave address book package did not expose an `AaveV3XLayer` constants file, so no unverified Aave pool address is hardcoded.
- Automatic restricted-flow penalty accounting is live in the v2 mainnet hook/vault. The v2 rewards vault reports `17,446,177,346,505` penalty-credit units for the v2 CFLOW/CQUOTE pool after a real Restricted round-trip scenario.

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

Verified participant personas from real testnet swaps:

- Seeder: `0xE66581C8f5B91d257b5EAa90168B547Ba28f8e19`
- Builder: `0xCD5aB02bF3B5fBEB12d118B25e53692dc4321fd2`
- Stabilizer: `0x7d481820489ae41C705564FEB7C75130AD06Bcf6`
- Restricted: `0x0Db499F22fEd9c1c557785620C23594101c5f0A0`

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

The checked-in dashboard is prefilled with the current X Layer mainnet deployment and includes a testnet preset. It does not simulate data. It reads `poolState`, `walletStats`, and reward claims directly from deployed contracts.

The dashboard can also send real wallet transactions:

- approve and swap through the deployed `CoordiFlowUserActions` helper
- approve both pool tokens and add liquidity through the same helper
- claim rewards from the penalty-funded rewards vault
- approve and deposit CQUOTE into the rehypothecation vault
- claim accrued OKB yield

The rewards page reads automatic penalty getters from the v2 mainnet vault. Penalty values come from `penaltyCredits(poolId)` and `walletPenaltyCredits(poolId, wallet)`.

USDT0 is enabled as a v2 funded route. The current route was seeded with real USDT0 and CFLOW, then verified with a real `0.01 USDT0 -> CFLOW` swap:

- USDT0 approve proof: `0xc2612e99e08bb33bad5b278e07ec14413e4762ed8985e4eae0f575649c848166`
- USDT0 swap proof: `0xc56f7a3c3815820a274142eb6cceaa7ac848510e55b6f091a7f76e9b293457db`

USDT and WOKB are displayed as official X Layer funding assets but remain disabled until funded CoordiFlow routes/pools are deployed for those assets; this keeps the dashboard verifiable instead of pretending unsupported routes exist.

## Security Notes

CoordiFlow is a hackathon product, not an audited production deployment. The current security posture is:

- Hook configuration, rewards-vault configuration, signal-provider updates, badge minting, strategy deployment, and yield accrual are owner-gated.
- The public user-actions helper has a reentrancy lock and only accepts `unlockCallback` from the official X Layer v4 PoolManager.
- Dynamic fees are passed through Uniswap v4 `LPFeeLibrary.validate()` during pool configuration.
- Oversized swaps can be capped by pool configuration.
- Restricted-flow penalty credits are only recordable by the configured hook.
- Signal data is transparent through an on-chain signal provider and source hash.
- The Aave strategy adapter is deployed but intentionally has no hardcoded Aave pool until an official X Layer Aave pool address is available.

Recommended post-hackathon hardening:

- freeze/lock pool configuration after launch
- cap persona transitions per wallet per block
- replace owner keys with multisig/timelock roles
- add full integration tests for the user-actions helper against forked X Layer state
- complete third-party review before handling meaningful user funds
