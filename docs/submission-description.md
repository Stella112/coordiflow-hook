# CoordiFlow Submission Description

CoordiFlow is a Uniswap v4 Hook on X Layer that turns token launches into behavior-aware coordination markets. Instead of letting a launch mature only through raw volume or whale activity, CoordiFlow measures the quality of participation and makes the market respond on-chain.

Wallets are classified into launch personas based on real pool behavior:

- Seeder: early liquidity provider.
- Builder: repeat constructive buyer or participant.
- Stabilizer: healthy participant with balanced activity.
- Restricted: rapid round-tripper, oversized trader, or toxic-flow wallet.

These personas shape the launch in real time. Positive coordination can improve market state, increase the coordination score, support launch progression, qualify wallets for rewards, and unlock reputation badges. Toxic or low-quality flow receives stricter treatment through higher fees, caps, restricted reward access, and automatic penalty-credit accounting.

CoordiFlow is designed as a natural extension of Flap-style modular token launches. Flap can provide token creation and the launch surface. CoordiFlow adds behavior-aware market intelligence at the Uniswap v4 Hook layer. The integration is protocol-compatible: any Flap-style launch that creates or routes into a standard Uniswap v4 pool can attach CoordiFlow as the hook. The project does not claim a private Flap API integration.

On X Layer, this becomes especially powerful because low-cost, high-throughput transactions make broad participation realistic. A launch is no longer judged only by how much volume arrives, but by whether the market is forming through diverse, healthy, sustained participation.

The product stack has five layers:

- CoordiFlow Core Hook: persona scoring, coordination score, dynamic fees/caps, anti-snipe behavior, and market stage state.
- X Layer Intelligence Layer: on-chain signal adapter for wallet and market-quality context.
- Coordination Rewards Layer: rewards vault with automatic restricted-flow penalty credits.
- Rehypothecation Layer: positive personas can deposit idle CQUOTE while a protocol agent deploys idle assets into a strategy reserve and routes OKB yield back to eligible wallets.
- Persona Badge Layer: on-chain SBT-style badges minted from hook-recorded behavior.

The current v2 deployment is live on X Layer mainnet and verifiable. The dashboard does not use fake data; it reads pool state, wallet stats, personas, penalty credits, signals, badges, and vault state directly from deployed contracts.

Live mainnet proof includes:

- V2 Hook: `0x42D04F47EB54d48D39EA177E418E322e1FaF4AC0`
- V2 Rewards Vault: `0xD26732420947b470B2d92F07B083254E7Bcd6Dfa`
- V2 CFLOW/CQUOTE Pool ID: `0x7dbd1af7f0d60d90005b959f35d17c09ddd8a145b689234d45dbf1ce599938a9`
- V2 USDT0/CFLOW Pool ID: `0x4dee7db9acada05cd1be6a1bb4d3d63e54dc83dad2cf625ace41c8b3efbaba6a`
- Signal Provider: `0x904d734b523BFD94542f93A9a3a2d46e3aC6767A`
- Persona Badge Contract: `0x82b4Cb5AC9C68eB6cbbb4eFcAB637054AA43c815`

For the live walkthrough, CoordiFlow includes real on-chain participant agents that executed real swaps against the deployed pool:

- Builder: repeated constructive buys.
- Stabilizer: healthy market interaction.
- Restricted: rapid buy/sell round-trip behavior.

These are not simulated dashboard states. They are addresses with hook-recorded wallet stats that can be inspected through the dashboard or direct RPC calls.

Final one-liner:

> CoordiFlow is a Uniswap v4 Hook on X Layer that turns Flap-style token launches into behavior-aware coordination markets, where liquidity, fees, rewards, and market stages respond to the quality of participation, not just volume.
