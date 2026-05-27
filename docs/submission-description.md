# CoordiFlow Submission Description

CoordiFlow is a Uniswap v4 Hook on X Layer that turns token launches into behavior-aware coordination markets. Instead of letting the launch mature only through raw volume or whale activity, CoordiFlow measures the quality of participation and makes the market respond on-chain.

Wallets are classified into launch personas based on real pool behavior:

- Seeder: early liquidity provider
- Builder: repeat constructive buyer or participant
- Stabilizer: healthy participant with balanced activity
- Restricted: rapid round-tripper, oversized trader, or toxic flow pattern

These personas shape the launch in real time. Positive coordination can improve market state, deepen the coordination score, unlock launch phases, and qualify wallets for rewards. Toxic or low-quality flow receives stricter treatment through higher fees, caps, and restricted reward access.

CoordiFlow is designed as a natural extension of Flap-style modular token launches. Flap can provide the simple token launch and trading surface; CoordiFlow adds behavior-aware market intelligence at the Uniswap v4 Hook layer. The MVP remains a pure v4 Hook so it can attach to compatible v4 pools without relying on private APIs or off-chain simulation.

On X Layer, this becomes especially powerful because low-cost, high-throughput transactions make broad participation realistic. A launch is no longer judged only by how much volume arrives, but by whether the market is forming through diverse, healthy, sustained participation.

The product stack has three layers:

- CoordiFlow Core Hook: persona scoring, coordination score, dynamic fees/caps, and market stage unlocks.
- X Layer Intelligence Layer: optional on-chain signal adapter for wallet and market-quality context.
- Coordination Rewards Layer: real rewards vault where Seeders, Builders, and Stabilizers can earn from funded coordination rewards.

The current testnet deployment is fully on-chain and verifiable. The dashboard does not use fake data; it reads pool state, wallet stats, personas, and claimable rewards directly from deployed contracts on X Layer testnet.

For the live testnet walkthrough, CoordiFlow includes real on-chain participant agents that executed real swaps against the deployed pool:

- Builder: repeated constructive buys
- Stabilizer: single healthy market interaction
- Restricted: rapid buy/sell round trip behavior

These are not simulated dashboard states. They are addresses with hook-recorded wallet stats that can be inspected through the dashboard or direct RPC calls.

Final one-liner:

> CoordiFlow is a Uniswap v4 Hook on X Layer that turns Flap-style token launches into behavior-aware coordination markets, where liquidity, fees, rewards, and market stages respond to the quality of participation, not just volume.
