const selectors = {
  poolState: "0xe0b01bac",
  walletStats: "0x378a7a4c",
  claimable: "0x4499f5b3",
  penaltyCredits: "0xb4fbfce6",
  walletPenaltyCredits: "0xed2e6a48",
  owner: "0x8da5cb5b",
  deposits: "0xfc7e286d",
  claimableYield: "0x3180afec",
  totalDeposits: "0x7d882097",
  availableAssets: "0x20124bce",
  deployedAssets: "0x1efa1881",
  yieldPool: "0x8f188dd4",
  getSignal: "0x8dc09e01",
  badgeOf: "0x26f61604",
  balanceOf: "0x70a08231",
  allowance: "0xdd62ed3e",
  approve: "0x095ea7b3",
  swapExactInput: "0x58f3f1da",
  addLiquidity: "0xc9158c51",
  claimRewards: "0xbd66528a",
  deposit: "0xb6b55f25",
  claimYieldTx: "0x406cf229",
  badgeMint: "0x509d58f8",
};

const personas = ["Unclassified", "Seeder", "Builder", "Stabilizer", "Restricted"];
const deployments = {
  mainnet: {
    label: "X Layer mainnet",
    hook: "0x42D04F47EB54d48D39EA177E418E322e1FaF4AC0",
    userActions: "0xfb2C898DB77D6FECba6b6A9e4Cd8A0869F166734",
    usdt0UserActions: "0x7e4B149Fd681cc2649a3CC7e8Bb3f786b3eAE33b",
    poolId: "0x7dbd1af7f0d60d90005b959f35d17c09ddd8a145b689234d45dbf1ce599938a9",
    usdt0PoolId: "0x4dee7db9acada05cd1be6a1bb4d3d63e54dc83dad2cf625ace41c8b3efbaba6a",
    vault: "0xD26732420947b470B2d92F07B083254E7Bcd6Dfa",
    rehypothecationVault: "0xf8875dDE68F71f6BA448C5B58b43D4bCAFe93bdb",
    signalProvider: "0x904d734b523BFD94542f93A9a3a2d46e3aC6767A",
    badgeContract: "0x82b4Cb5AC9C68eB6cbbb4eFcAB637054AA43c815",
    rpc: "https://rpc.xlayer.tech",
    wallet: "0xE66581C8f5B91d257b5EAa90168B547Ba28f8e19",
    launchToken: "0xACdF5260e2d89Cd29c3b09a32EEf3Ae6aB679081",
    quoteToken: "0xB20ECE2960cD24eA0E8476F397bC0F06BCBa2BE5",
    launchTokenIsCurrency0: true,
    assets: {
      usdt0: "0x779Ded0c9e1022225f8E0630b35a9b54bE713736",
      usdt: "0x1E4a5963aBFD975d8c9021ce480b42188849D41d",
      wokb: "0xe538905cf8410324e03A5A23C1c177a474D59b2b",
    },
    participants: {
      seeder: "0xE66581C8f5B91d257b5EAa90168B547Ba28f8e19",
      builder: "0xc313710fA15c76fFac68b90d016209Fd85598a42",
      stabilizer: "0x532f7C92cAB420689B7A324724790a20b7c2f406",
      restricted: "0x1f5a737Bef38ACFd3C2e51a2b07e8B0CE34d82F8",
    },
  },
  testnet: {
    label: "X Layer testnet",
    hook: "0xDee0822330A786313E46A4f6d9E2d58c33B20AC0",
    userActions: "",
    poolId: "0x660353cea0aed4458ad5404c32f8033627539819271ca4738d325bd063370ac2",
    vault: "0x90407637D45588F0663b722438C6452c637c51d2",
    rehypothecationVault: "",
    signalProvider: "",
    badgeContract: "",
    rpc: "https://testrpc.xlayer.tech/terigon",
    wallet: "0xE66581C8f5B91d257b5EAa90168B547Ba28f8e19",
    launchToken: "",
    quoteToken: "",
    launchTokenIsCurrency0: true,
    assets: {},
    participants: {
      seeder: "0xE66581C8f5B91d257b5EAa90168B547Ba28f8e19",
      builder: "0xCD5aB02bF3B5fBEB12d118B25e53692dc4321fd2",
      stabilizer: "0x7d481820489ae41C705564FEB7C75130AD06Bcf6",
      restricted: "0x0Db499F22fEd9c1c557785620C23594101c5f0A0",
    },
  },
};
const personaSummaries = {
  Unclassified: "No meaningful launch behavior has been recorded for this wallet yet.",
  Seeder: "This wallet added early liquidity and helped seed the market.",
  Builder: "This wallet shows repeated constructive participation.",
  Stabilizer: "This wallet has healthy market interaction without toxic round trips.",
  Restricted: "This wallet triggered toxic-flow rules such as rapid round trips or sell-heavy behavior.",
};

const verifiedActivity = [
  {
    type: "swap",
    color: "var(--c-builder)",
    label: "USDT0 swap",
    text: "0.01 USDT0 -> CFLOW through the v2 X Layer v4 route",
    hash: "0xc56f7a3c3815820a274142eb6cceaa7ac848510e55b6f091a7f76e9b293457db",
  },
  {
    type: "approval",
    color: "var(--p)",
    label: "USDT0 approval",
    text: "USDT0 spend approved for the v2 CoordiFlow route helper",
    hash: "0xc2612e99e08bb33bad5b278e07ec14413e4762ed8985e4eae0f575649c848166",
  },
  {
    type: "builder",
    color: "var(--c-builder)",
    label: "Builder flow",
    text: "Repeated constructive swaps formed the Builder persona",
    hash: "0xde2598d5cacedbbb748c894f6d53b75cb206b141b4197deecf303889291e24d4",
  },
  {
    type: "restricted",
    color: "var(--c-restr)",
    label: "Restricted flow",
    text: "Round-trip behavior was recorded and automatically credited to the penalty ledger",
    hash: "0xee3ccdaabaacf0f3c3246756f19504d5d7fee7c9d1cc182edd6c347756ad61f5",
  },
  {
    type: "yield",
    color: "var(--c-seeder)",
    label: "Yield accrual",
    text: "Light rehypothecation yield accrued for eligible positive personas",
    hash: "0xdd3c0e1f651328c364ce6bdc99aafcf93bc42dd728fd9e954cc0a5b4e266c738",
  },
  {
    type: "signal",
    color: "var(--p)",
    label: "Signal layer",
    text: "V2 X Layer intelligence provider connected to CoordiFlow",
    hash: "0xbb29bf1c062d904d4ca50ee1a44890e9799019381c1cd0c7d899d80e05c4154d",
  },
  {
    type: "badge",
    color: "var(--c-stab)",
    label: "Persona SBT",
    text: "V2 persona badges minted from hook-recorded behavior",
    hash: "0xd7264fa55df7c8b8a1c2d7327561ab8d9abd794c1c0a05bfe39f677795605b43",
  },
];

const txProofs = {
  restrictedBuy: "0x1a44029b55b6d1104e69f98ccdc1d61f7eaf3274aad167053e07eaf772d02903",
  restrictedSell: "0xee3ccdaabaacf0f3c3246756f19504d5d7fee7c9d1cc182edd6c347756ad61f5",
  rehypApprove: "0xd00eb424c4cfb6129cac624946726068a3836a98ef5a0a7aa7051d44d56014f3",
  rehypDeposit: "0x5556329b0655518e427c0438e86d683f3eee7a0a8534e690d55e5ddd155ced75",
  rehypDeploy: "0x174f551b7fc2faff13fddb1fbf149fa91d0c57d7dc967036fd9b39a1f12a9b97",
  rehypFundYield: "0xbb7f7446eef47b0fccf5a6f6a75ba86063a03eea199835163f0fd61b0a946b25",
  rehypAccrue: "0xdd3c0e1f651328c364ce6bdc99aafcf93bc42dd728fd9e954cc0a5b4e266c738",
  badgeSeederMint: "0xf7fbee189cb0de46087c92074f9c04a600d1394709fe2ecd4e99f806d171a306",
  usdt0Swap: "0xc56f7a3c3815820a274142eb6cceaa7ac848510e55b6f091a7f76e9b293457db",
};

function one(selector) {
  return document.querySelector(selector);
}

function all(selector) {
  return Array.from(document.querySelectorAll(selector));
}

function last(selector) {
  const nodes = all(selector);
  return nodes[nodes.length - 1] || null;
}

function on(node, event, handler) {
  if (node) node.addEventListener(event, handler);
}

function setAll(selector, value) {
  all(selector).forEach((node) => {
    node.textContent = value;
  });
}

const els = {
  hookAddress: one("#hookAddress"),
  userActions: one("#userActions"),
  poolId: one("#poolId"),
  vaultAddress: one("#vaultAddress"),
  rehypothecationVault: one("#rehypothecationVault"),
  signalProvider: one("#signalProvider"),
  badgeContract: one("#badgeContract"),
  walletAddress: one("#walletAddress"),
  rpcUrl: one("#rpcUrl"),
  status: last("#status"),
  connectWallet: one("#connectWallet"),
  connectWalletTop: one("#connectWalletTop"),
  refreshState: one("#refreshState"),
  walletNetwork: one("#walletNetwork"),
  txStatus: last("#txStatus"),
  swapRoute: one("#swapRoute"),
  swapRouteHint: one("#swapRouteHint"),
  swapFlip: one("#swapFlip"),
  swapAmount: one("#swapAmount"),
  approveSwap: one("#approveSwap"),
  executeSwap: one("#executeSwap"),
  liquidityAmount: one("#liquidityAmount"),
  liquidityMax: one("#liquidityMax"),
  approveLiquidity: one("#approveLiquidity"),
  addLiquidity: one("#addLiquidity"),
  claimRewards: one("#claimRewards"),
  rehypDepositAmount: one("#rehypDepositAmount"),
  approveRehyp: one("#approveRehyp"),
  depositRehyp: one("#depositRehyp"),
  claimYieldButton: one("#claimYield"),
  mintBadge: one("#mintBadge"),
  coordinationScore: one("#coordinationScore"),
  phaseLabel: one("#phaseLabel"),
  stageTitle: one("#stageTitle"),
  stageFill: one("#stageFill"),
  uniqueParticipants: one("#uniqueParticipants"),
  positiveParticipants: one("#positiveParticipants"),
  restrictedParticipants: one("#restrictedParticipants"),
  liquidityRelease: one("#liquidityRelease"),
  marketSignal: one("#marketSignal"),
  claimableRewards: last("#claimableRewards"),
  penaltyCredits: last("#penaltyCredits"),
  walletPenaltyCredits: last("#walletPenaltyCredits"),
  penaltyStatus: last("#penaltyStatus"),
  idleDeposits: last("#idleDeposits"),
  availableAssets: last("#availableAssets"),
  deployedAssets: last("#deployedAssets"),
  yieldPool: last("#yieldPool"),
  claimableYield: last("#claimableYield"),
  walletSignal: last("#walletSignal"),
  personaBadge: last("#personaBadge"),
  signalSummary: last("#signalSummary"),
  signalAddress: last("#signalAddress"),
  badgeSummary: last("#badgeSummary"),
  badgeAddress: last("#badgeAddress"),
  rehypothecationSummary: last("#rehypothecationSummary"),
  rehypothecationAddress: last("#rehypothecationAddress"),
  personaName: one("#personaName"),
  personaSummary: one("#personaSummary"),
  buyVolume: one("#buyVolume"),
  sellVolume: one("#sellVolume"),
  swapCount: one("#swapCount"),
  liquidityActions: one("#liquidityActions"),
  rapidRoundTrips: one("#rapidRoundTrips"),
  networkBadge: one("#networkBadge"),
  canvas: one("#signalCanvas"),
};

let latestState = {
  score: 0n,
  phase: 0n,
  unique: 0n,
  positive: 0n,
  restricted: 0n,
  releaseBps: 0n,
  marketSignal: 0n,
};

let activeDeployment = deployments.mainnet;

document.querySelectorAll(".connect-wallet-trigger").forEach((button) => on(button, "click", connectWallet));

async function connectWallet() {
  const provider = walletProvider();
  if (!provider) {
    const message = "No wallet provider found. Open this page in a browser with OKX Wallet or MetaMask enabled.";
    setStatus(message);
    setTxStatus(message);
    return;
  }

  try {
    setStatus("Opening wallet connection...");
    const accounts = await provider.request({ method: "eth_requestAccounts" });
    const account = accounts[0];
    if (!account) throw new Error("Wallet returned no account.");
    els.walletAddress.value = account;
    updateWalletDisplay(account);
    await ensureXLayer();
    await updateWalletNetworkLabel();
    setStatus("Wallet connected on X Layer. Loading verified on-chain state...");
    setTxStatus("Wallet connected. You can now approve, swap, add liquidity, deposit, and claim with real transactions.");
    await refresh();
  } catch (error) {
    setStatus(error.message || "Wallet connection failed.");
    setTxStatus(error.message || "Wallet connection failed.");
  }
}

function walletProvider() {
  if (window.ethereum?.providers?.length) {
    return (
      window.ethereum.providers.find((provider) => provider.isOkxWallet || provider.isOKExWallet) ||
      window.ethereum.providers.find((provider) => provider.isMetaMask) ||
      window.ethereum.providers[0]
    );
  }
  return window.okxwallet || window.ethereum || null;
}

on(els.refreshState, "click", refresh);
on(els.approveSwap, "click", approveSwap);
on(els.executeSwap, "click", executeSwap);
on(els.approveLiquidity, "click", approveLiquidity);
on(els.addLiquidity, "click", addLiquidity);
on(els.claimRewards, "click", claimRewards);
on(els.approveRehyp, "click", approveRehypothecation);
on(els.depositRehyp, "click", depositRehypothecation);
on(els.claimYieldButton, "click", claimYield);
on(els.swapRoute, "change", () => {
  updateSwapRouteUi();
  refresh().catch((error) => setTxStatus(error.message));
});
on(els.swapFlip, "click", flipSwapRoute);
on(els.mintBadge, "click", mintPersonaBadge);
document.querySelectorAll("[data-wallet]").forEach((button) => {
  button.addEventListener("click", () => {
    els.walletAddress.value = button.dataset.wallet;
    highlightSelectedWallet(button.dataset.wallet);
    refresh();
  });
});
document.querySelectorAll("[data-preset]").forEach((button) => {
  button.addEventListener("click", () => {
    applyDeployment(button.dataset.preset);
    refresh();
  });
});

function applyDeployment(name) {
  const deployment = deployments[name];
  if (!deployment) return;

  activeDeployment = deployment;
  els.hookAddress.value = deployment.hook;
  els.userActions.value = deployment.userActions;
  els.poolId.value = deployment.poolId;
  els.vaultAddress.value = deployment.vault;
  els.rehypothecationVault.value = deployment.rehypothecationVault;
  els.signalProvider.value = deployment.signalProvider;
  els.badgeContract.value = deployment.badgeContract;
  els.signalAddress.textContent = shortAddress(deployment.signalProvider);
  els.badgeAddress.textContent = shortAddress(deployment.badgeContract);
  els.rehypothecationAddress.textContent = shortAddress(deployment.rehypothecationVault);
  setAll("#signalAddress, #signalAddressB", shortAddress(deployment.signalProvider));
  setAll("#badgeAddress, #badgeAddressB", shortAddress(deployment.badgeContract));
  setAll("#rehypothecationAddress", shortAddress(deployment.rehypothecationVault));
  els.rpcUrl.value = deployment.rpc;
  els.walletAddress.value = deployment.wallet;
  els.networkBadge.textContent = `Verified on ${deployment.label}`;
  setAll("#networkBadge", `Verified on ${deployment.label}`);
  document.querySelectorAll("[data-preset]").forEach((button) => {
    button.classList.toggle("selected", button.dataset.preset === name);
  });
  document.querySelectorAll("[data-persona]").forEach((button) => {
    button.dataset.wallet = deployment.participants[button.dataset.persona];
  });
  highlightSelectedWallet(deployment.wallet);
  updateSwapRouteUi();
  renderVerifiedActivity();
}

async function refresh() {
  try {
    const hook = assertAddress(els.hookAddress.value.trim(), "Hook contract");
    const wallet = assertAddress(els.walletAddress.value.trim(), "Wallet");
    const poolId = selectedPoolId();

    setStatus("Reading hook state from X Layer RPC...");

    const poolState = await ethCall(hook, selectors.poolState + strip0x(poolId));
    const walletStats = await ethCall(hook, selectors.walletStats + strip0x(poolId) + padAddress(wallet));

    renderPoolState(decodeWords(poolState));
    renderWalletStats(decodeWords(walletStats));
    await renderRewards(poolId, wallet);
    await renderRehypothecation(wallet);
    await renderSignalsAndBadge(poolId, wallet);
    await refreshWalletBalances();
    await updateWalletNetworkLabel();
    await renderLatestBlock();
    renderVerifiedActivity();
    drawSignal();

    setStatus("Loaded verified on-chain state.");
  } catch (error) {
    setStatus(error.message);
  }
}

async function ethCall(to, data) {
  const body = {
    jsonrpc: "2.0",
    id: Date.now(),
    method: "eth_call",
    params: [{ to, data }, "latest"],
  };

  const response = await fetch(els.rpcUrl.value.trim(), {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  const json = await response.json();
  if (json.error) throw new Error(json.error.message || "RPC call failed.");
  return json.result;
}

async function renderLatestBlock() {
  try {
    const response = await fetch(els.rpcUrl.value.trim(), {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ jsonrpc: "2.0", id: Date.now(), method: "eth_blockNumber", params: [] }),
    });
    const json = await response.json();
    if (!json.result) return;
    const block = Number(BigInt(json.result)).toLocaleString();
    setAll("#latestBlock", `Block ${block}`);
  } catch {
    setAll("#latestBlock", "Block unavailable");
  }
}

async function tokenBalance(token, wallet, decimals = 18, precision) {
  if (!token) return "-";
  const result = await ethCall(assertAddress(token, "Token"), selectors.balanceOf + padAddress(wallet));
  return formatUnits(decodeWords(result)[0], decimals, precision ?? (decimals === 6 ? 6 : 8));
}

async function tokenBalanceRaw(token, wallet) {
  if (!token) return 0n;
  const result = await ethCall(assertAddress(token, "Token"), selectors.balanceOf + padAddress(wallet));
  return decodeWords(result)[0];
}

async function refreshWalletBalances() {
  const wallet = els.walletAddress?.value?.trim();
  if (!wallet || !/^0x[a-fA-F0-9]{40}$/.test(wallet)) return;
  const route = selectedSwapRoute();
  const receiveToken = route.outputToken;
  const [payBalance, receiveBalance, launchBalance, quoteBalance] = await Promise.all([
    tokenBalance(route.tokenIn, wallet, route.decimals, displayPrecision(route.inputSymbol, route.decimals)),
    tokenBalance(receiveToken, wallet, route.outputDecimals, displayPrecision(route.outputSymbol, route.outputDecimals)),
    tokenBalance(activeDeployment.launchToken, wallet, 18, displayPrecision("CFLOW", 18)),
    tokenBalance(activeDeployment.quoteToken, wallet, 18, displayPrecision("CQUOTE", 18)),
  ]);

  setAll("#swapBalPay", payBalance);
  setAll("#swapBalRec", receiveBalance);
  setAll("#liqBalLaunch", launchBalance);
  setAll("#liqBalQuote", quoteBalance);
  setAll("#balanceSource", `${route.inputSymbol}.balanceOf(${shortAddress(wallet)})`);
  setAll("#payTokenAddress", shortAddress(route.tokenIn));
  setAll("#receiveTokenAddress", shortAddress(route.outputToken));
  setAll("#activeWalletSource", shortAddress(wallet));
}

function renderPoolState(words) {
  latestState = {
    unique: words[0],
    positive: words[1],
    restricted: words[2],
    phase: words[3],
    score: words[4],
    releaseBps: words[5],
    marketSignal: signed16(words[6]),
  };

  const score = latestState.score.toString();
  const phase = latestState.phase.toString();
  const release = `${Number(latestState.releaseBps) / 100}%`;
  const signal = `${latestState.marketSignal > 0 ? "+" : ""}${latestState.marketSignal.toString()} bps`;

  setAll("#coordinationScore, #heroCoordinationScore, #landingCoordinationScore", score);
  setAll("#phaseLabel, #landingPhaseLabel", `Phase ${phase}`);
  setAll("#uniqueParticipants", latestState.unique.toString());
  setAll("#positiveParticipants", latestState.positive.toString());
  setAll("#restrictedParticipants", latestState.restricted.toString());
  setAll("#positivePersonaCount, #heroPositiveCount", latestState.positive.toString());
  setAll("#heroRestrictedCount", latestState.restricted.toString());
  setAll("#liquidityRelease", release);
  setAll("#heroReleaseLabel", release);
  setAll("#marketSignal, #marketSignalB", signal);
  setAll("#liquidityStage", `Phase ${phase}`);
  setAll("#heroPhaseLabel", `Phase ${phase}`);
  updatePersonaBars();
  renderStage();
}

function updatePersonaBars() {
  const total = Number(latestState.positive + latestState.restricted);
  const positivePct = total === 0 ? 0 : Math.round((Number(latestState.positive) / total) * 100);
  const restrictedPct = total === 0 ? 0 : 100 - positivePct;
  all("#positivePersonaSeg").forEach((node) => {
    node.style.width = `${positivePct}%`;
  });
  all("#restrictedPersonaSeg").forEach((node) => {
    node.style.width = `${restrictedPct}%`;
  });
  all("#heroPositiveBar").forEach((node) => {
    node.style.width = `${positivePct}%`;
  });
  all("#heroRestrictedBar").forEach((node) => {
    node.style.width = `${restrictedPct}%`;
  });
  all("#heroPhaseBar").forEach((node) => {
    node.style.width = `${Math.min(100, Number(latestState.phase) * 25)}%`;
  });
  all("#heroReleaseBar").forEach((node) => {
    node.style.width = `${Math.min(100, Number(latestState.releaseBps) / 100)}%`;
  });
}

async function renderRewards(poolId, wallet) {
  const vault = els.vaultAddress.value.trim();
  if (!vault) {
    setAll("#claimableRewards, #claimableRewardsDisplay, #penaltyCredits, #walletPenaltyCredits", "Not set");
    setAll("#penaltyStatus", "Rewards vault is not configured.");
    return;
  }

  assertAddress(vault, "Rewards vault");
  const result = await ethCall(vault, selectors.claimable + strip0x(poolId) + padAddress(wallet));
  const claimable = `${formatTokenUnits(decodeWords(result)[0])} OKB`;
  setAll("#claimableRewards, #claimableRewardsDisplay", claimable);
  await renderPenaltyCredits(vault, poolId, wallet);
}

async function renderPenaltyCredits(vault, poolId, wallet) {
  try {
    const [poolPenalty, walletPenalty] = await Promise.all([
      ethCall(vault, selectors.penaltyCredits + strip0x(poolId)),
      ethCall(vault, selectors.walletPenaltyCredits + strip0x(poolId) + padAddress(wallet)),
    ]);

    setAll("#penaltyCredits", `${formatTokenUnits(decodeWords(poolPenalty)[0])} units`);
    setAll("#walletPenaltyCredits", `${formatTokenUnits(decodeWords(walletPenalty)[0])} units`);
    setAll(
      "#penaltyStatus",
      "Live v2 penalty ledger: Restricted swaps automatically record penalty credits from the hook.",
    );
  } catch {
    setAll("#penaltyCredits", "V2 redeploy required");
    setAll("#walletPenaltyCredits", "V2 redeploy required");
    setAll(
      "#penaltyStatus",
      "The selected vault does not expose the v2 penalty getters. Switch to the X Layer mainnet v2 preset to read live automatic penalty credits.",
    );
  }
}

async function renderRehypothecation(wallet) {
  const vault = els.rehypothecationVault.value.trim();
  if (!vault) {
    setAll("#idleDeposits, #availableAssets, #deployedAssets, #yieldPool, #claimableYield", "Not set");
    return;
  }

  assertAddress(vault, "Rehypothecation vault");
  const [deposits, available, deployed, yieldPool, yieldAmount] = await Promise.all([
    ethCall(vault, selectors.deposits + padAddress(wallet)),
    ethCall(vault, selectors.availableAssets),
    ethCall(vault, selectors.deployedAssets),
    ethCall(vault, selectors.yieldPool),
    ethCall(vault, selectors.claimableYield + padAddress(wallet)),
  ]);

  const idleText = `${formatTokenUnits(decodeWords(deposits)[0])} CQUOTE`;
  const availableText = `${formatTokenUnits(decodeWords(available)[0])} CQUOTE`;
  const deployedText = `${formatTokenUnits(decodeWords(deployed)[0])} CQUOTE`;
  const yieldPoolText = `${formatTokenUnits(decodeWords(yieldPool)[0])} OKB`;
  const yieldText = `${formatTokenUnits(decodeWords(yieldAmount)[0])} OKB`;
  const summary = `${deployedText} deployed, ${availableText} idle`;

  setAll("#idleDeposits", idleText);
  setAll("#availableAssets", availableText);
  setAll("#deployedAssets", deployedText);
  setAll("#yieldPool", yieldPoolText);
  setAll("#claimableYield", yieldText);
  setAll("#rehypothecationSummary", summary);
}

async function approveSwap() {
  const route = selectedSwapRoute();
  await approveToken(route.tokenIn, route.actions, parseAmount(els.swapAmount.value, route.decimals));
}

async function executeSwap() {
  const route = selectedSwapRoute();
  const actions = assertAddress(route.actions, "User actions");
  const amountIn = parseAmount(els.swapAmount.value, route.decimals);
  const from = await connectedAccount();
  const balance = await tokenBalanceRaw(route.tokenIn, from);
  if (balance < amountIn) {
    setTxStatus(
      `Not enough ${route.inputSymbol}. You selected ${route.label}, so the app will spend ${route.inputSymbol}, not ${route.outputSymbol}.`
    );
    return;
  }
  const data = selectors.swapExactInput + encodeUint(amountIn) + encodeBool(route.zeroForOne) + encodeUint(0n);
  await sendAndTrack(
    actions,
    data,
    `Swap sent: ${route.label}. Waiting for X Layer confirmation...`,
    `Swap confirmed: ${route.label}. Balances refreshed from X Layer.`
  );
}

async function approveLiquidity() {
  const actions = assertAddress(els.userActions.value.trim(), "User actions");
  const maxSpend = parseAmount(els.liquidityMax.value);
  await approveToken(activeDeployment.launchToken, actions, maxSpend);
  await approveToken(activeDeployment.quoteToken, actions, maxSpend);
}

async function addLiquidity() {
  const actions = assertAddress(els.userActions.value.trim(), "User actions");
  const liquidity = BigInt(els.liquidityAmount.value.trim());
  const maxSpend = parseAmount(els.liquidityMax.value);
  const tickLower = -887220n;
  const tickUpper = 887220n;
  const data =
    selectors.addLiquidity +
    encodeSigned(tickLower) +
    encodeSigned(tickUpper) +
    encodeSigned(liquidity) +
    "0".repeat(64) +
    encodeUint(maxSpend) +
    encodeUint(maxSpend);
  await sendAndTrack(actions, data, "Add liquidity sent. Waiting for Seeder state...");
}

async function claimRewards() {
  const vault = assertAddress(els.vaultAddress.value.trim(), "Rewards vault");
  const poolId = selectedPoolId();
  await sendAndTrack(vault, selectors.claimRewards + strip0x(poolId), "Reward claim sent...");
}

async function approveRehypothecation() {
  await approveToken(activeDeployment.quoteToken, els.rehypothecationVault.value.trim(), parseAmount(els.rehypDepositAmount.value));
}

async function depositRehypothecation() {
  const vault = assertAddress(els.rehypothecationVault.value.trim(), "Rehypothecation vault");
  const amount = parseAmount(els.rehypDepositAmount.value);
  await sendAndTrack(vault, selectors.deposit + encodeUint(amount), "Rehypothecation deposit sent...");
}

async function claimYield() {
  const vault = assertAddress(els.rehypothecationVault.value.trim(), "Rehypothecation vault");
  await sendAndTrack(vault, selectors.claimYieldTx, "Yield claim sent...");
}

async function approveToken(token, spender, amount) {
  assertAddress(token, "Token");
  assertAddress(spender, "Spender");
  const data = selectors.approve + padAddress(spender) + encodeUint(amount);
  await sendAndTrack(
    token,
    data,
    `Approval sent for ${shortAddress(spender)}...`,
    "Approval confirmed. Now click Swap on X Layer to execute the trade."
  );
}

async function sendAndTrack(to, data, pendingMessage, successMessage) {
  const provider = walletProvider();
  if (!provider) throw new Error("No injected wallet found.");
  await ensureXLayer();
  const from = await connectedAccount();
  setTxStatus(pendingMessage);
  const hash = await provider.request({
    method: "eth_sendTransaction",
    params: [{ from, to, data }],
  });
  setTxStatus(`Tx submitted: ${shortHash(hash)}. Waiting for confirmation...`);
  await waitForReceipt(hash);
  setTxStatus(`Confirmed: ${shortHash(hash)}. Refreshing on-chain state...`);
  await refresh();
  setTxStatus(successMessage || `Confirmed: ${shortHash(hash)}. On-chain state refreshed.`);
}

async function ensureXLayer() {
  const provider = walletProvider();
  if (!provider) throw new Error("No injected wallet found.");
  const chainId = await provider.request({ method: "eth_chainId" });
  if (chainId === "0xc4") return;
  try {
    await provider.request({
      method: "wallet_switchEthereumChain",
      params: [{ chainId: "0xc4" }],
    });
  } catch (error) {
    if (error.code !== 4902) throw error;
    await provider.request({
      method: "wallet_addEthereumChain",
      params: [
        {
          chainId: "0xc4",
          chainName: "X Layer Mainnet",
          nativeCurrency: { name: "OKB", symbol: "OKB", decimals: 18 },
          rpcUrls: ["https://rpc.xlayer.tech"],
          blockExplorerUrls: ["https://www.oklink.com/x-layer"],
        },
      ],
    });
  }
}

async function connectedAccount() {
  const provider = walletProvider();
  if (!provider) throw new Error("No injected wallet found.");
  const accounts = await provider.request({ method: "eth_requestAccounts" });
  const account = accounts[0];
  if (!account) throw new Error("Wallet connection failed.");
  els.walletAddress.value = account;
  updateWalletDisplay(account);
  return account;
}

async function waitForReceipt(hash) {
  const provider = walletProvider();
  if (!provider) throw new Error("No injected wallet found.");
  for (let i = 0; i < 40; i++) {
    const receipt = await provider.request({
      method: "eth_getTransactionReceipt",
      params: [hash],
    });
    if (receipt) {
      if (receipt.status !== "0x1") throw new Error(`Transaction reverted: ${shortHash(hash)}`);
      return receipt;
    }
    await new Promise((resolve) => setTimeout(resolve, 2500));
  }
  throw new Error(`Transaction still pending: ${shortHash(hash)}`);
}

async function updateWalletNetworkLabel() {
  const provider = walletProvider();
  if (!provider || !els.walletNetwork) {
    if (els.walletNetwork) els.walletNetwork.textContent = "Wallet not connected";
    return;
  }
  try {
    const chainId = await provider.request({ method: "eth_chainId" });
    els.walletNetwork.textContent = chainId === "0xc4" ? "Wallet on X Layer" : `Wallet chain ${chainId}`;
  } catch {
    els.walletNetwork.textContent = "Wallet not connected";
  }
}

function updateWalletDisplay(address) {
  setAll("#walletAddrDisplay", shortAddress(address));
  document.querySelectorAll(".connect-wallet-trigger").forEach((button) => {
    button.textContent = shortAddress(address);
  });
}

function selectedSwapRoute() {
  const route = els.swapRoute?.value || "quoteToLaunch";
  if (route === "quoteToLaunch") {
    return {
      id: route,
      label: "CQUOTE -> CFLOW",
      inputSymbol: "CQUOTE",
      outputSymbol: "CFLOW",
      tokenIn: activeDeployment.quoteToken,
      outputToken: activeDeployment.launchToken,
      actions: els.userActions.value.trim(),
      poolId: activeDeployment.poolId,
      currency0: activeDeployment.launchTokenIsCurrency0 ? activeDeployment.launchToken : activeDeployment.quoteToken,
      currency1: activeDeployment.launchTokenIsCurrency0 ? activeDeployment.quoteToken : activeDeployment.launchToken,
      zeroForOne: !activeDeployment.launchTokenIsCurrency0,
      decimals: 18,
      outputDecimals: 18,
    };
  }
  if (route === "launchToQuote") {
    return {
      id: route,
      label: "CFLOW -> CQUOTE",
      inputSymbol: "CFLOW",
      outputSymbol: "CQUOTE",
      tokenIn: activeDeployment.launchToken,
      outputToken: activeDeployment.quoteToken,
      actions: els.userActions.value.trim(),
      poolId: activeDeployment.poolId,
      currency0: activeDeployment.launchTokenIsCurrency0 ? activeDeployment.launchToken : activeDeployment.quoteToken,
      currency1: activeDeployment.launchTokenIsCurrency0 ? activeDeployment.quoteToken : activeDeployment.launchToken,
      zeroForOne: activeDeployment.launchTokenIsCurrency0,
      decimals: 18,
      outputDecimals: 18,
    };
  }
  if (route === "usdt0ToLaunch") {
    return {
      id: route,
      label: "USDT0 -> CFLOW",
      inputSymbol: "USDT0",
      outputSymbol: "CFLOW",
      tokenIn: activeDeployment.assets.usdt0,
      outputToken: activeDeployment.launchToken,
      actions: activeDeployment.usdt0UserActions,
      poolId: activeDeployment.usdt0PoolId,
      currency0: activeDeployment.assets.usdt0,
      currency1: activeDeployment.launchToken,
      zeroForOne: true,
      decimals: 6,
      outputDecimals: 18,
    };
  }
  if (route === "launchToUsdt0") {
    return {
      id: route,
      label: "CFLOW -> USDT0",
      inputSymbol: "CFLOW",
      outputSymbol: "USDT0",
      tokenIn: activeDeployment.launchToken,
      outputToken: activeDeployment.assets.usdt0,
      actions: activeDeployment.usdt0UserActions,
      poolId: activeDeployment.usdt0PoolId,
      currency0: activeDeployment.assets.usdt0,
      currency1: activeDeployment.launchToken,
      zeroForOne: false,
      decimals: 18,
      outputDecimals: 6,
    };
  }
  throw new Error("This route needs a funded CoordiFlow pool or external route before it can be enabled.");
}

function flipSwapRoute() {
  const flips = {
    usdt0ToLaunch: "launchToUsdt0",
    launchToUsdt0: "usdt0ToLaunch",
    quoteToLaunch: "launchToQuote",
    launchToQuote: "quoteToLaunch",
  };
  if (!els.swapRoute) return;
  els.swapRoute.value = flips[els.swapRoute.value] || "usdt0ToLaunch";
  updateSwapRouteUi();
  refresh().catch((error) => setTxStatus(error.message));
}

function updateSwapRouteUi() {
  const route = selectedSwapRoute();
  setAll("#swapPairName", route.label);
  setAll("#swapPaySymbol", route.inputSymbol);
  setAll("#swapReceiveSymbol", route.outputSymbol);
  setAll("#swapReceiveEstimate", "On-chain tx");
  setAll("#swapRate", "Quoted by v4 execution");
  setAll("#swapCap", "Enforced by hook state");
  setAll("#balanceSource", `${route.inputSymbol}.balanceOf(wallet)`);
  setAll("#payTokenAddress", shortAddress(route.tokenIn));
  setAll("#receiveTokenAddress", shortAddress(route.outputToken));
  if (els.swapRouteHint) {
    const action = route.id === "usdt0ToLaunch" || route.id === "quoteToLaunch" ? "BUYING" : "SELLING";
    els.swapRouteHint.textContent =
      `${action} route selected: you spend ${route.inputSymbol} and receive ${route.outputSymbol}. Approval only gives permission; Swap sends the trade.`;
  }
}

async function mintPersonaBadge() {
  const badge = assertAddress(els.badgeContract.value.trim(), "Persona badge");
  const data = selectors.badgeMint + encodePoolKey();
  await sendAndTrack(badge, data, "Persona badge mint sent...");
}

function selectedPoolId() {
  const route = selectedSwapRoute();
  const poolId = route.poolId || els.poolId.value.trim();
  return assertBytes32(poolId, "Pool ID");
}

function encodePoolKey() {
  const route = selectedSwapRoute();
  const currency0 = route.currency0 || (activeDeployment.launchTokenIsCurrency0 ? activeDeployment.launchToken : activeDeployment.quoteToken);
  const currency1 = route.currency1 || (activeDeployment.launchTokenIsCurrency0 ? activeDeployment.quoteToken : activeDeployment.launchToken);
  return (
    padAddress(currency0) +
    padAddress(currency1) +
    encodeUint(0x800000n) +
    encodeSigned(60n) +
    padAddress(els.hookAddress.value.trim())
  );
}

async function renderSignalsAndBadge(poolId, wallet) {
  const signalProvider = els.signalProvider.value.trim();
  const badgeContract = els.badgeContract.value.trim();

  if (signalProvider) {
    assertAddress(signalProvider, "Signal provider");
    const result = await ethCall(signalProvider, selectors.getSignal + strip0x(poolId) + padAddress(wallet));
    const words = decodeWords(result);
    const walletSignal = signed16(words[1]);
    const marketSignal = signed16(words[2]);
    const walletText = `${walletSignal > 0 ? "+" : ""}${walletSignal.toString()} / ${marketSignal > 0 ? "+" : ""}${marketSignal.toString()} bps`;
    const summary = `Wallet ${walletSignal > 0 ? "+" : ""}${walletSignal.toString()} bps, market ${marketSignal > 0 ? "+" : ""}${marketSignal.toString()} bps`;
    setAll("#walletSignal", walletText);
    setAll("#signalSummary, #signalSummaryB", summary);
  } else {
    setAll("#walletSignal", "Not set");
    setAll("#signalSummary, #signalSummaryB", "Not set");
  }

  if (badgeContract) {
    assertAddress(badgeContract, "Persona badge");
    const result = await ethCall(badgeContract, selectors.badgeOf + strip0x(poolId) + padAddress(wallet));
    const tokenId = decodeWords(result)[0];
    setAll("#personaBadge", tokenId === 0n ? "None" : `#${tokenId.toString()}`);
    setAll("#badgeSummary, #badgeSummaryB", tokenId === 0n ? "No badge for wallet" : `Badge #${tokenId.toString()} minted`);
  } else {
    setAll("#personaBadge", "Not set");
    setAll("#badgeSummary, #badgeSummaryB", "Not set");
  }
}

function renderWalletStats(words) {
  const buyVolume = words[4];
  const sellVolume = words[5];
  const swapCount = words[7];
  const liquidityActions = words[8];
  const rapidRoundTrips = words[9];
  const persona = Number(words[10]);
  const personaName = personas[persona] || "Unknown";
  const summary = personaSummaries[personaName] || "Persona unavailable.";

  setAll("#personaName, #walletPersonaName", personaName);
  setAll("#personaSummary, #walletPersonaSummary", summary);
  setAll("#buyVolume", formatTokenUnits(buyVolume));
  setAll("#sellVolume", formatTokenUnits(sellVolume));
  setAll("#swapCount", swapCount.toString());
  setAll("#liquidityActions", liquidityActions.toString());
  setAll("#rapidRoundTrips", rapidRoundTrips.toString());
  setAll("#walletScoreContribution", `${persona === 4 ? "-" : "+"}${scoreContribution(persona)}`);
  setAll("#walletLastSwaps", `${swapCount.toString()} hook-recorded swaps`);
  setAll("#builderPersonaCount", personaName === "Builder" ? "selected" : "-");
  setAll("#stabilizerPersonaCount", personaName === "Stabilizer" ? "selected" : "-");
}

function scoreContribution(persona) {
  if (persona === 1) return "1.0";
  if (persona === 2) return "0.8";
  if (persona === 3) return "0.9";
  if (persona === 4) return "1.0";
  return "0.0";
}

function drawSignal() {
  const canvas = els.canvas;
  if (!canvas) return;
  const ctx = canvas.getContext("2d");
  const width = canvas.width;
  const height = canvas.height;
  const score = Number(latestState.score > 10000n ? 10000n : latestState.score);
  const quality = Math.max(0.08, score / 10000);
  const positive = Number(latestState.positive);
  const restricted = Number(latestState.restricted);

  ctx.clearRect(0, 0, width, height);
  const gradient = ctx.createLinearGradient(0, 0, width, height);
  gradient.addColorStop(0, "#0b1018");
  gradient.addColorStop(0.55, "#121b24");
  gradient.addColorStop(1, "#081016");
  ctx.fillStyle = gradient;
  ctx.fillRect(0, 0, width, height);

  ctx.strokeStyle = "rgba(255,255,255,0.055)";
  ctx.lineWidth = 1;
  for (let x = 0; x <= width; x += 60) {
    ctx.beginPath();
    ctx.moveTo(x, 0);
    ctx.lineTo(x, height);
    ctx.stroke();
  }
  for (let y = 0; y <= height; y += 46) {
    ctx.beginPath();
    ctx.moveTo(0, y);
    ctx.lineTo(width, y);
    ctx.stroke();
  }

  for (let i = 0; i < 96; i++) {
    const x = (i / 95) * width;
    const y = height / 2 + Math.sin(i * 0.42 + positive) * 64 * quality + Math.cos(i * 0.18) * 22;
    const radius = 2 + ((i + positive) % 7) * quality;
    ctx.beginPath();
    ctx.arc(x, y, radius, 0, Math.PI * 2);
    ctx.fillStyle = i % 5 === 0 ? "#59a9ff" : i % 7 === 0 ? "#f5bf5b" : "#48e0a4";
    ctx.globalAlpha = 0.24 + quality * 0.64;
    ctx.fill();
  }

  ctx.globalAlpha = 1;
  ctx.lineWidth = 4;
  const lineGradient = ctx.createLinearGradient(0, 0, width, 0);
  lineGradient.addColorStop(0, "#59a9ff");
  lineGradient.addColorStop(0.5, "#48e0a4");
  lineGradient.addColorStop(1, "#f5bf5b");
  ctx.strokeStyle = lineGradient;
  ctx.beginPath();
  for (let x = 0; x <= width; x += 10) {
    const y = height / 2 + Math.sin(x / 54 + positive) * 68 * quality;
    if (x === 0) ctx.moveTo(x, y);
    else ctx.lineTo(x, y);
  }
  ctx.stroke();

  const ringX = width - 132;
  const ringY = height - 116;
  ctx.lineWidth = 14;
  ctx.strokeStyle = "rgba(255,255,255,0.1)";
  ctx.beginPath();
  ctx.arc(ringX, ringY, 52, 0, Math.PI * 2);
  ctx.stroke();
  ctx.strokeStyle = "#48e0a4";
  ctx.beginPath();
  ctx.arc(ringX, ringY, 52, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * quality);
  ctx.stroke();
  ctx.fillStyle = "#eef4f8";
  ctx.font = "700 22px system-ui";
  ctx.textAlign = "center";
  ctx.fillText(`${Math.round(quality * 100)}%`, ringX, ringY + 8);
  ctx.font = "600 11px system-ui";
  ctx.fillStyle = "#8fa0ad";
  ctx.fillText("QUALITY", ringX, ringY + 28);

  if (restricted > 0) {
    ctx.strokeStyle = "#ff6b6b";
    ctx.lineWidth = 2;
    for (let i = 0; i < restricted; i++) {
      const x = width - 80 - i * 28;
      ctx.beginPath();
      ctx.moveTo(x - 9, 64);
      ctx.lineTo(x + 9, 82);
      ctx.moveTo(x + 9, 64);
      ctx.lineTo(x - 9, 82);
      ctx.stroke();
    }
  }
}

function renderStage() {
  const phase = Number(latestState.phase);
  const titles = [
    "Observation",
    "Early Coordination",
    "Expansion",
    "Mature Launch",
  ];
  els.stageTitle.textContent = titles[phase] || "Unknown Phase";
  els.stageFill.style.width = `${Math.min(100, (phase / 3) * 100)}%`;
  document.querySelectorAll("[data-stage]").forEach((node) => {
    node.classList.toggle("active", Number(node.dataset.stage) <= phase);
  });
}

function renderVerifiedActivity() {
  const rows = verifiedActivity
    .map(
      (item) => `
        <li class="act-item">
          <span class="act-time">TX</span>
          <span class="act-bar" style="background:${item.color}"></span>
          <span class="act-type">${item.label}</span>
          <span class="act-text">
            ${item.text} ·
            <a href="https://www.oklink.com/x-layer/tx/${item.hash}" target="_blank" rel="noreferrer">${shortHash(item.hash)}</a>
          </span>
        </li>`,
    )
    .join("");

  document.querySelectorAll(".activity-list").forEach((list) => {
    list.innerHTML = rows;
  });
  renderProofLinks();
}

function renderProofLinks() {
  document.querySelectorAll("[data-proof]").forEach((node) => {
    const hash = txProofs[node.dataset.proof];
    if (!hash) return;
    node.setAttribute("href", oklinkTx(hash));
    node.textContent = shortHash(hash);
  });
}

function oklinkTx(hash) {
  return `https://www.oklink.com/x-layer/tx/${hash}`;
}

function highlightSelectedWallet(wallet) {
  document.querySelectorAll("[data-wallet]").forEach((node) => {
    node.classList.toggle("selected", node.dataset.wallet?.toLowerCase() === wallet.toLowerCase());
  });
}

function decodeWords(hex) {
  const clean = strip0x(hex);
  const words = [];
  for (let i = 0; i < clean.length; i += 64) {
    words.push(BigInt("0x" + clean.slice(i, i + 64)));
  }
  return words;
}

function padAddress(address) {
  return strip0x(address).padStart(64, "0");
}

function encodeUint(value) {
  return BigInt(value).toString(16).padStart(64, "0");
}

function encodeSigned(value) {
  const signed = BigInt(value);
  const encoded = signed < 0n ? (1n << 256n) + signed : signed;
  return encoded.toString(16).padStart(64, "0");
}

function encodeBool(value) {
  return encodeUint(value ? 1n : 0n);
}

function assertAddress(value, label) {
  if (!/^0x[a-fA-F0-9]{40}$/.test(value)) throw new Error(`${label} must be a valid address.`);
  return value;
}

function assertBytes32(value, label) {
  if (!/^0x[a-fA-F0-9]{64}$/.test(value)) throw new Error(`${label} must be a bytes32 value.`);
  return value;
}

function strip0x(value) {
  return value.startsWith("0x") ? value.slice(2) : value;
}

function formatTokenUnits(value) {
  return formatUnits(value, 18, 4);
}

function formatUnits(value, decimals = 18, precision = 4) {
  const unit = 10n ** BigInt(decimals);
  const whole = value / unit;
  if (precision <= 0 || decimals === 0) return whole.toString();
  const fractionRaw = (value % unit).toString().padStart(decimals, "0");
  const fraction = fractionRaw.slice(0, Math.min(precision, decimals)).replace(/0+$/, "");
  if (!fraction) {
    if (value > 0n && whole === 0n) return `< ${formatSmallestVisible(decimals, precision)}`;
    return whole.toString();
  }
  return `${whole}.${fraction}`;
}

function formatSmallestVisible(decimals, precision) {
  const visible = Math.min(precision, decimals);
  return `0.${"0".repeat(Math.max(visible - 1, 0))}1`;
}

function displayPrecision(symbol, decimals) {
  if (symbol === "CFLOW") return 18;
  if (symbol === "CQUOTE") return 8;
  if (decimals === 6) return 6;
  return 8;
}

function parseAmount(value, decimals = 18) {
  const normalized = value.trim();
  if (!/^\d+(\.\d{0,18})?$/.test(normalized)) throw new Error("Amount must be a positive decimal.");
  const [whole, fraction = ""] = normalized.split(".");
  if (fraction.length > decimals) throw new Error(`Amount supports up to ${decimals} decimals for this asset.`);
  return BigInt(whole) * 10n ** BigInt(decimals) + BigInt(fraction.padEnd(decimals, "0"));
}

function shortAddress(value) {
  if (!value) return "Not set";
  return `${value.slice(0, 6)}...${value.slice(-4)}`;
}

function shortHash(value) {
  return `${value.slice(0, 8)}...${value.slice(-6)}`;
}

function signed16(word) {
  const masked = Number(word & 0xffffn);
  return BigInt(masked >= 0x8000 ? masked - 0x10000 : masked);
}

function setStatus(message) {
  if (els.status) els.status.textContent = message;
}

function setTxStatus(message) {
  if (els.txStatus) els.txStatus.textContent = message;
}

highlightSelectedWallet(els.walletAddress.value);
updateSwapRouteUi();
renderVerifiedActivity();
drawSignal();
refresh();
