# CoordiFlow

**Not all coordination is equal.**

CoordiFlow is a Uniswap v4 Hook on X Layer that turns token launches into behavior-aware coordination markets. It is designed for Flap-style launches generally: a launch platform can create the token and initial market, while CoordiFlow attaches as the hook layer that controls how the market matures.

CFLOW is the live demo market. The product is the reusable hook.

> Flap launches the token. CoordiFlow governs how the market matures.

## Problem

Most token launches treat all volume as equal. That makes early markets easy to distort:

- snipers buy instantly and dump quickly
- whales dominate early price discovery
- sybil wallets farm launch incentives
- real LPs and stabilizing users are not rewarded enough
- dashboards show activity, but the pool itself has no memory of behavior

A launch with high volume can still be unhealthy if that volume comes from toxic or extractive flow.

## Solution

CoordiFlow makes market formation programmable.

The hook observes real pool actions and classifies wallets into personas:

- **Seeder**: adds early liquidity and helps initialize the market
- **Builder**: returns and participates constructively
- **Stabilizer**: trades or LPs in a balanced way without toxic round trips
- **Restricted**: shows unhealthy behavior such as rapid buy/sell loops, sell-heavy dumping, or oversized flow

Those personas affect:

- dynamic hook fees
- swap limits and launch access
- coordination score
- market stage progression
- reward eligibility
- penalty-credit accounting
- persona badge minting

CoordiFlow is more than anti-snipe:

> Anti-snipe protects the first block. CoordiFlow protects the whole launch lifecycle.

## Product Stack

### 1. CoordiFlow Core Hook

The core hook tracks wallet behavior per pool and turns it into market state.

Live logic includes:

- persona scoring
- coordination score
- positive/restricted wallet counts
- dynamic fee return
- per-wallet swap statistics
- early LP tracking
- round-trip detection
- restricted-flow penalty credit recording

### 2. Flap-Compatible Launch Layer

CoordiFlow is built to complement Flap-style modular token launches.

The intended flow:

1. Flap or another launch flow creates the token and initial market.
2. The new market is initialized as a Uniswap v4 pool.
3. CoordiFlow is attached as the hook.
4. The market matures based on participation quality, not only volume.

This repository does not rely on a private Flap API. The MVP is a pure v4 hook, so it can attach to any compatible v4 launch pool.

### 3. X Layer Exchange OS Intelligence

CoordiFlow includes an on-chain signal provider interface and deployed signal provider.

This lets the protocol add X Layer-native context such as:

- wallet quality signals
- market momentum signals
- risk boosts or penalties
- source hashes for signal provenance

The signal provider is not a replacement for hook behavior. It is an intelligence layer on top of real pool actions.

### 4. Rewards And Penalty Vault

CoordiFlow follows one rule:

> Good coordination should earn. Toxic flow should pay.

The rewards vault supports:

- funded rewards for positive personas
- restricted-flow penalty credit accounting
- wallet-level penalty credit reads
- claim flow when rewards are funded

Penalty-credit accounting is live on-chain. Production fee settlement routing is a future hardening item.

### 5. Persona Badge SBT

The Persona Badge contract mints non-transferable on-chain badges for wallets that have a hook-recorded persona.

Badges represent wallet behavior history:

- Seeder badge
- Builder badge
- Stabilizer badge
- Restricted badge

Minting requires the wallet to already have a non-zero persona in the hook.

### 6. Light Rehypothecation Layer

CoordiFlow includes a real rehypothecation vault for eligible participants.

Current flow:

1. positive-persona wallet deposits CQUOTE
2. strategy agent can deploy part of idle deposits into a reserve
3. yield can be funded/accrued on-chain
4. eligible wallets can claim OKB yield

Depositing requires real CQUOTE balance. Claiming yield requires claimable yield for the caller.

## Live X Layer Mainnet Deployment

Network: **X Layer mainnet**

Chain ID: **196**

| Component | Address |
|---|---|
| PoolManager | `0x360E68faCcca8cA495c1B759Fd9EEe466db9FB32` |
| PositionManager | `0xcF1eAFC6928dC385A342E7c6491D371d2871458B` |
| Permit2 | `0x000000000022D473030F116dDEE9F6B43aC78BA3` |
| CoordiFlow Hook | `0x42D04F47EB54d48D39EA177E418E322e1FaF4AC0` |
| CFLOW token | `0xACdF5260e2d89Cd29c3b09a32EEf3Ae6aB679081` |
| CQUOTE token | `0xB20ECE2960cD24eA0E8476F397bC0F06BCBa2BE5` |
| CFLOW/CQUOTE pool ID | `0x7dbd1af7f0d60d90005b959f35d17c09ddd8a145b689234d45dbf1ce599938a9` |
| CFLOW/CQUOTE user actions | `0xfb2C898DB77D6FECba6b6A9e4Cd8A0869F166734` |
| USDT0/CFLOW pool ID | `0x4dee7db9acada05cd1be6a1bb4d3d63e54dc83dad2cf625ace41c8b3efbaba6a` |
| USDT0/CFLOW user actions | `0x7e4B149Fd681cc2649a3CC7e8Bb3f786b3eAE33b` |
| Rewards vault | `0xD26732420947b470B2d92F07B083254E7Bcd6Dfa` |
| Rehypothecation vault | `0xf8875dDE68F71f6BA448C5B58b43D4bCAFe93bdb` |
| Strategy reserve | `0xDc22FfCDfc4d14D35bF64E0c41FB608Ad2912808` |
| Aave-ready reserve | `0x07062Ef73A544690Ea590B6e75715222f060fa6c` |
| X Layer signal provider | `0x904d734b523BFD94542f93A9a3a2d46e3aC6767A` |
| Persona Badge SBT | `0x82b4Cb5AC9C68eB6cbbb4eFcAB637054AA43c815` |

Official X Layer assets surfaced in the app:

| Asset | Address |
|---|---|
| USDT0 | `0x779Ded0c9e1022225f8E0630b35a9b54bE713736` |
| USDT | `0x1E4a5963aBFD975d8c9021ce480b42188849D41d` |
| WOKB | `0xe538905cf8410324e03A5A23C1c177a474D59b2b` |

Mainnet proof transactions:

| Action | Tx hash |
|---|---|
| USDT0 approval proof | `0xc2612e99e08bb33bad5b278e07ec14413e4762ed8985e4eae0f575649c848166` |
| USDT0 -> CFLOW swap proof | `0xc56f7a3c3815820a274142eb6cceaa7ac848510e55b6f091a7f76e9b293457db` |
| Restricted buy proof | `0x1a44029b55b6d1104e69f98ccdc1d61f7eaf3274aad167053e07eaf772d02903` |
| Restricted sell proof | `0xee3ccdaabaacf0f3c3246756f19504d5d7fee7c9d1cc182edd6c347756ad61f5` |
| Signal provider connected | `0xbb29bf1c062d904d4ca50ee1a44890e9799019381c1cd0c7d899d80e05c4154d` |
| Seeder badge mint | `0xf7fbee189cb0de46087c92074f9c04a600d1394709fe2ecd4e99f806d171a306` |
| Builder badge mint | `0x42f60eff87e767bdff8e10fb773f353e8b132c7b3f62275b2507d45b071be4fd` |
| Stabilizer badge mint | `0x62a07356944d9c82e09748ac4dc793bee879d4f3fcf9016672823876cf1ccf24` |
| Restricted badge mint | `0xd7264fa55df7c8b8a1c2d7327561ab8d9abd794c1c0a05bfe39f677795605b43` |
| Rehypothecation deposit | `0x5556329b0655518e427c0438e86d683f3eee7a0a8534e690d55e5ddd155ced75` |
| Deploy to strategy | `0x174f551b7fc2faff13fddb1fbf149fa91d0c57d7dc967036fd9b39a1f12a9b97` |
| Fund yield | `0xbb7f7446eef47b0fccf5a6f6a75ba86063a03eea199835163f0fd61b0a946b25` |
| Accrue yield | `0xdd3c0e1f651328c364ce6bdc99aafcf93bc42dd728fd9e954cc0a5b4e266c738` |

## X Layer Testnet Deployment

Network: **X Layer testnet**

| Component | Address |
|---|---|
| PoolManager | `0xEAC4fcF2fB22E9887c830cD3EF78F1d28fC3BbCf` |
| PositionManager | `0x8DE4b634760F7942A20B7fA994AAc72F03ce4751` |
| Permit2 | `0x3191Fc1E303EF4e12a7DE5f5d2e8d53A0660c5b9` |
| CoordiFlow Hook | `0xDee0822330A786313E46A4f6d9E2d58c33B20AC0` |
| Launch token | `0x31316Ec55D0f843357F22A8533b467A69b427b26` |
| Quote token | `0xB779178fF3269f4404263Adb930507978887b53b` |
| Pool ID | `0x660353cea0aed4458ad5404c32f8033627539819271ca4738d325bd063370ac2` |
| Rewards vault | `0x90407637D45588F0663b722438C6452c637c51d2` |

Verified testnet persona wallets:

| Persona | Wallet |
|---|---|
| Seeder | `0xE66581C8f5B91d257b5EAa90168B547Ba28f8e19` |
| Builder | `0xCD5aB02bF3B5fBEB12d118B25e53692dc4321fd2` |
| Stabilizer | `0x7d481820489ae41C705564FEB7C75130AD06Bcf6` |
| Restricted | `0x0Db499F22fEd9c1c557785620C23594101c5f0A0` |

## How To Test The Live App

Open:

```text
web/index.html
```

or deploy to Vercel using the checked-in `vercel.json`.

### Swap USDT0 to CFLOW

Requirements:

- OKB for gas
- USDT0 balance
- X Layer mainnet selected
- route set to `USDT0 -> CFLOW`

Flow:

1. Connect wallet.
2. Select `USDT0 -> CFLOW`.
3. Enter a small amount such as `0.01`.
4. Click `Approve`.
5. After approval confirms, click `Swap on X Layer`.
6. Confirm the wallet transaction.
7. Refresh balances from the app.

Approval is not a swap. It only gives the route helper permission to spend USDT0.

### Mint Persona Badge

Requirements:

- wallet must already have a non-zero persona in the hook
- unclassified wallets cannot mint a badge

Flow:

1. Perform qualifying hook activity or select a verified persona wallet in the dashboard.
2. Open `Persona Badges`.
3. Click `Mint my Persona SBT`.

### Deposit Into Rehypothecation

Requirements:

- CQUOTE balance
- approved CQUOTE spend
- eligible positive persona

Flow:

1. Open `Rehypothecation`.
2. Approve CQUOTE.
3. Deposit CQUOTE.
4. Strategy deployment and yield accrual are owner/agent-gated.

### Claim Yield

Requirements:

- wallet must have claimable yield in the rehypothecation vault
- claimable yield can be read directly from the vault

If the caller has no claimable yield, the transaction will fail or do nothing.

## Running Locally

```bash
npm install
npm run build
npm start
```

The static web app lives in `web/`. The Vercel build copies `web/` into `dist/`.

## Contract Build And Tests

```bash
forge build
forge test
```

The repo uses `via_ir = true` because the Uniswap v4 dependency graph can hit stack-depth limits without it.

## Deployment Scripts

Core scripts:

- `script/00_DeployXLayerTestV4Stack.s.sol`
- `script/00_DeployCoordiFlowHook.s.sol`
- `script/01_DeployCoordiFlowToken.s.sol`
- `script/02_DeployRewardsVault.s.sol`
- `script/03_CreateCoordiFlowPool.s.sol`
- `script/04_RunCoordiFlowScenario.s.sol`
- `script/05_RunCoordiFlowMainnetScenario.s.sol`
- `script/08_DeployExchangeOSSignalProvider.s.sol`
- `script/09_DeployAndMintPersonaBadges.s.sol`
- `script/10_DeployUserActions.s.sol`
- `script/11_RunUsdt0RouteProof.s.sol`

Example:

```bash
forge script script/11_RunUsdt0RouteProof.s.sol:RunUsdt0RouteProofScript \
  --rpc-url xlayer_mainnet \
  --broadcast
```

## Security Model

CoordiFlow is a hackathon MVP and has not been audited.

Current protections:

- public user-actions helper has reentrancy protection
- `unlockCallback` only accepts the official PoolManager
- sensitive signal, strategy, reward, and config updates are owner-gated
- dynamic fees are bounded by Uniswap v4 validation
- persona badge transfers are disabled
- penalty credits are recordable only by the configured hook

Recommended production hardening:

- multisig/timelock for admin roles
- config freeze after launch
- full fork tests against X Layer state
- production fee settlement routing into the reward vault
- third-party audit before handling meaningful TVL

## Future Integrations

### Flap Launch Pages

CoordiFlow can be exposed as an optional launch mode for Flap-style token launches:

> Launch with behavior-aware coordination.

### X Layer Exchange OS

The current signal provider can be upgraded into a deeper Exchange OS adapter for:

- smart-money flow
- launch momentum
- sybil/risk scoring
- market-quality boosts

### Aave-Compatible Yield Routing

The rehypothecation vault includes an Aave-ready reserve pattern. A production release can connect it to an official X Layer Aave pool once the address is verified.

### Keeper-Based Agentic Rehypothecation

The current strategy movement is owner/agent-gated. A future keeper can automate:

- idle capital deployment
- harvests
- yield accounting
- reward distribution

## Demo Script Summary

1. Explain the problem: launches reward volume, not quality.
2. Show CoordiFlow as the hook solution for Flap-style launches.
3. Show CFLOW as the demo market, not the whole product.
4. Perform or reference the USDT0 -> CFLOW swap route.
5. Show persona scoring and coordination score.
6. Show X Layer Exchange OS signals.
7. Show Persona Badge SBTs.
8. Show rewards and rehypothecation vault state.
9. Close with: “CoordiFlow makes launches mature through healthy participation instead of whale-driven noise.”
