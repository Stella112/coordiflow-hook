# CoordiFlow Product Docs

## Summary

CoordiFlow is a Uniswap v4 Hook on X Layer that turns token launches into behavior-aware coordination markets.

Instead of treating every wallet and every trade as equal, CoordiFlow observes how participants behave during a launch. The hook classifies wallets into personas, updates a coordination score, applies dynamic fee/cap logic, records anti-snipe and toxic-flow behavior, and connects healthy participation to rewards, badges, and optional idle-liquidity yield.

Core tagline:

> Not all coordination is equal.

Primary one-liner:

> CoordiFlow is a Uniswap v4 Hook on X Layer that turns token launches into behavior-aware coordination markets, where liquidity, fees, rewards, and market stages respond to the quality of participation, not just volume.

Integrated one-liner:

> CoordiFlow combines behavior-aware launch mechanics, X Layer-native market intelligence, and coordination rewards to make token launches mature through healthy participation instead of whale-driven noise.

## Why It Exists

Most launch mechanisms only measure simple inputs:

- How many wallets bought.
- How much volume came in.
- How much liquidity exists.
- Whether the first few blocks were sniped.

CoordiFlow adds a missing layer: behavior quality.

A launch with 100 wallets that immediately dump is not healthier than a launch with 30 wallets that add liquidity, hold, return, and stabilize the market. CoordiFlow makes that difference programmable at the Uniswap v4 Hook layer.

The result is a new launch primitive:

> Anti-snipe protects the first block. CoordiFlow protects the full launch lifecycle.

## Product Stack

### 1. CoordiFlow Core Hook

The core hook is the main product.

It handles:

- wallet behavior tracking
- persona scoring
- coordination score
- dynamic fees
- swap caps
- anti-snipe and anti-round-trip behavior
- market stage state
- rewards eligibility
- penalty ledger accounting

Main contract:

- `src/CoordiFlowHook.sol`

The hook is deployed on X Layer mainnet at:

- `0x42D04F47EB54d48D39EA177E418E322e1FaF4AC0`

### 2. X Layer Intelligence Layer

CoordiFlow includes an on-chain signal provider that acts as the Exchange OS intelligence adapter.

It allows the protocol to attach X Layer-native market context to the hook:

- wallet signal bps
- market signal bps
- signal source hash
- updated timestamp

This gives CoordiFlow a native X Layer edge:

> CoordiFlow does not only look at what happens inside one pool. It can also use X Layer-native market signals to understand whether the launch is attracting healthy market attention or toxic flow.

Main contracts:

- `src/interfaces/IExchangeOSSignalProvider.sol`
- `src/CoordiFlowSignalProvider.sol`

Mainnet signal provider:

- `0x904d734b523BFD94542f93A9a3a2d46e3aC6767A`

Honest integration note:

- The current provider is an on-chain adapter contract.
- It is ready for Exchange OS-style wallet and market signals.
- It does not claim a private off-chain API integration.
- All exposed signal values are verifiable by RPC calls.

### 3. Coordination Rewards Layer

CoordiFlow rewards healthy launch behavior.

The principle:

> Good coordination should earn. Toxic flow should pay.

Positive personas can become eligible for coordination rewards. Restricted behavior does not earn.

The v2 rewards vault includes:

- claimable rewards
- funded reward pools
- automatic restricted-flow penalty credits
- pool-level penalty accounting
- wallet-level penalty accounting

Main contract:

- `src/CoordiFlowRewardsVault.sol`

Mainnet rewards vault:

- `0xD26732420947b470B2d92F07B083254E7Bcd6Dfa`

Penalty ledger functions:

- `penaltyCredits(poolId)`
- `walletPenaltyCredits(poolId, wallet)`

Live v2 proof:

- V2 CFLOW/CQUOTE pool ID: `0x7dbd1af7f0d60d90005b959f35d17c09ddd8a145b689234d45dbf1ce599938a9`
- Restricted wallet: `0x1f5a737Bef38ACFd3C2e51a2b07e8B0CE34d82F8`
- Pool penalty credits: `17,446,177,346,505`
- Restricted wallet penalty credits: `17,446,177,346,505`

Important implementation note:

- The v2 hook automatically records restricted-flow penalty credits into the vault.
- Future production hardening can add full fee-settlement routing so actual hook-collected fee proceeds are programmatically settled into the vault.

### 4. Light Rehypothecation / Agentic Yield Layer

CoordiFlow includes a light rehypothecation vault for positive personas.

This is not the headline product. It is a reward power-up.

The rule:

> Positive coordination can unlock better capital treatment.

Current flow:

1. A positive persona deposits idle CQUOTE into the rehypothecation vault.
2. The vault records the user deposit on-chain.
3. A protocol owner/agent can deploy idle assets into a strategy reserve.
4. Yield can be funded/accrued back to eligible wallets.
5. Users can claim OKB yield from the vault.

Main contracts:

- `src/CoordiFlowRehypothecationVault.sol`
- `src/CoordiFlowStrategyReserve.sol`
- `src/CoordiFlowAaveStrategyReserve.sol`

Mainnet rehypothecation vault:

- `0xf8875dDE68F71f6BA448C5B58b43D4bCAFe93bdb`

Current proof:

- `10 CQUOTE` deposited by an eligible positive persona.
- `3 CQUOTE` deployed in the strategy reserve.
- `0.0001 OKB` claimable yield accrued on-chain.

Agentic status:

- Real vault: yes.
- Real deposits: yes.
- Real strategy reserve: yes.
- Real yield accounting: yes.
- Agent-gated strategy movement: yes.
- Fully autonomous keeper that runs every few minutes: not yet.

Best description:

> CoordiFlow's rehypothecation layer is agent-controlled: positive personas deposit idle CQUOTE, and the protocol agent deploys idle liquidity into a strategy reserve, accrues yield, and routes rewards back to eligible wallets.

Aave status:

- An Aave-compatible strategy reserve is deployed.
- No unverified X Layer Aave pool address is hardcoded.
- Once an official X Layer Aave pool address is available, the reserve can be pointed to that pool.

### 5. Persona Badges

CoordiFlow includes soulbound-style persona badges.

These badges turn hook-recorded behavior into long-term wallet reputation.

Personas:

- Seeder
- Builder
- Stabilizer
- Restricted

Main contract:

- `src/CoordiFlowPersonaBadge.sol`

Mainnet persona badge contract:

- `0x82b4Cb5AC9C68eB6cbbb4eFcAB637054AA43c815`

V2 badge proof:

- Seeder badge: `#1`
- Builder badge: `#2`
- Stabilizer badge: `#3`
- Restricted badge: `#4`

Badges are not just visual UI labels. They are minted on-chain using hook-recorded persona state.

## Wallet Personas

### Seeder

Seeder is the early liquidity participant.

Typical behavior:

- Adds liquidity early.
- Helps seed the launch.
- Contributes positively to coordination state.

### Builder

Builder is a repeat constructive participant.

Typical behavior:

- Performs repeated healthy buys or participation.
- Does not immediately round-trip.
- Helps show sustained demand.

### Stabilizer

Stabilizer is a healthy market participant.

Typical behavior:

- Interacts without toxic round trips.
- Helps normalize market behavior.
- Can become eligible for rewards.

### Restricted

Restricted is the toxic-flow persona.

Typical triggers:

- rapid buy/sell round trips
- oversized trades
- sell-heavy behavior
- toxic launch participation

Restricted wallets can face:

- higher fees
- stricter caps
- no reward eligibility
- automatic penalty-credit accounting

## Anti-Snipe Design

CoordiFlow includes anti-snipe behavior, but it is broader than a basic anti-snipe hook.

A basic anti-snipe hook usually blocks or taxes early buyers.

CoordiFlow asks a deeper question:

> After a wallet enters the launch, what kind of participant does it become?

CoordiFlow can protect against:

- early sniping
- rapid buy/sell round trips
- oversized wallet flow
- toxic dumping
- low-quality farming
- restricted reward extraction

Clean explanation:

> CoordiFlow starts as anti-snipe, but evolves into behavior-aware launch coordination.

Sharper version:

> Anti-snipe protects the first block. CoordiFlow protects the whole launch lifecycle.

V2 proof:

- Restricted buy proof: `0x1a44029b55b6d1104e69f98ccdc1d61f7eaf3274aad167053e07eaf772d02903`
- Restricted final sell proof: `0xee3ccdaabaacf0f3c3246756f19504d5d7fee7c9d1cc182edd6c347756ad61f5`
- The Restricted wallet is recorded as persona `4`.
- The v2 rewards vault records automatic penalty credits for that wallet.

## Flap Launch Compatibility

CoordiFlow is designed to complement Flap, not replace it.

Flap is the launch layer:

- token creation
- early trading flow
- modular launch setup
- launch/pool UX

CoordiFlow is the hook intelligence layer:

- attaches to the Uniswap v4 pool
- watches launch behavior
- classifies wallets
- applies dynamic fees/caps
- tracks anti-snipe behavior
- routes rewards/penalties
- unlocks market-stage logic

Best framing:

> Flap launches the market. CoordiFlow helps it mature.

Technical status:

- CoordiFlow does not call a private Flap API.
- CoordiFlow does not pretend to launch through Flap's UI.
- CoordiFlow is compatible at the protocol layer: if a Flap-style launch creates or routes into a standard Uniswap v4 pool, CoordiFlow can be used as the hook during pool creation.
- In the live demo, the team deployed the v4 hook and pools directly on X Layer mainnet to prove the mechanism end to end.

Demo line:

> A Flap-style launch can create the token and initialize the market. CoordiFlow attaches as the Uniswap v4 Hook, turning that launch into a behavior-aware coordination market.

## Dashboard

The dashboard is a real on-chain product surface.

It reads:

- hook address
- pool ID
- live X Layer block
- pool state
- wallet stats
- personas
- penalty credits
- claimable rewards
- rehypothecation vault state
- signal provider data
- persona badges
- proof transaction links

It can send:

- wallet connection requests
- token approvals
- real swaps
- add liquidity transactions
- rewards claims
- rehypothecation deposits
- yield claims
- persona badge mint transactions

It should not be described as a mock dashboard.

## User Flow

### Swap

1. Connect wallet.
2. Ensure wallet is on X Layer mainnet.
3. Choose route:
   - `USDT0 -> CFLOW`
   - `CFLOW -> USDT0`
   - `CQUOTE -> CFLOW`
   - `CFLOW -> CQUOTE`
4. Approve token spend.
5. Swap through the CoordiFlow user-actions helper.
6. Hook records behavior.
7. Dashboard refreshes wallet persona and stats.

V2 USDT0 proof:

- Approve: `0xc2612e99e08bb33bad5b278e07ec14413e4762ed8985e4eae0f575649c848166`
- Swap: `0xc56f7a3c3815820a274142eb6cceaa7ac848510e55b6f091a7f76e9b293457db`

### Add Liquidity

1. Connect wallet.
2. Approve both pool tokens.
3. Add liquidity through the user-actions helper.
4. Hook records early liquidity behavior.
5. Wallet can become Seeder if it fits launch conditions.

### Rewards Vault

1. Open Rewards Vault.
2. Inspect anti-snipe proof transactions.
3. Inspect pool penalty credits.
4. Inspect selected wallet penalty credits.
5. Claim rewards if wallet has claimable rewards.

### Rehypothecation

1. Open Rehypothecation.
2. Deposit idle CQUOTE.
3. Protocol agent can deploy idle assets into strategy reserve.
4. Yield accrues to eligible wallets.
5. User claims OKB yield.

### Persona Badges

1. Build a persona through hook-recorded swap or LP behavior.
2. Mint persona badge.
3. Badge reflects wallet's hook-recorded launch behavior.

### X Layer Signals

1. Open X Layer Signals.
2. Read wallet and market signals from the signal provider.
3. Signals can boost or restrict behavior-aware launch scoring.

## Demo Video Flow

Maximum 3 minutes:

1. Overview: explain CoordiFlow in one sentence.
2. Mainnet proof: show hook, pool, live block, coordination score.
3. Swap: show USDT0 to CFLOW route and flip pair.
4. Anti-snipe: show Restricted wallet proof and penalty credits.
5. Personas and badges: show Builder, Stabilizer, Restricted, and SBT badges.
6. X Layer intelligence: show signal provider.
7. Rehypothecation: show agent-controlled idle CQUOTE/yield state.
8. Close: "CoordiFlow makes launches mature through healthy participation, not whale-driven noise."

## Security Notes

CoordiFlow is a hackathon product and not audited production infrastructure.

Current safety choices:

- Owner-gated configuration for sensitive setup.
- Rewards vault only accepts penalty/reward writes from the configured hook.
- User-actions helper has a reentrancy lock.
- User-actions helper only accepts `unlockCallback` from the official X Layer v4 PoolManager.
- Dynamic fees are validated through Uniswap v4 fee validation.
- Oversized swaps can be capped.
- Signal data is transparent and stored on-chain.
- No unverified Aave pool address is hardcoded.

Recommended production hardening:

- lock pool configuration after launch
- move owner powers to multisig/timelock
- add keeper automation for agentic strategy deployment
- add fork tests against live X Layer state
- add third-party audit before meaningful user funds

