const selectors = {
  poolState: "0xe0b01bac",
  walletStats: "0x378a7a4c",
  claimable: "0x4499f5b3",
  owner: "0x8da5cb5b",
  deposits: "0xfc7e286d",
  claimableYield: "0x3180afec",
  totalDeposits: "0x7d882097",
  availableAssets: "0x20124bce",
  deployedAssets: "0x1efa1881",
  yieldPool: "0x8f188dd4",
  getSignal: "0x8dc09e01",
  badgeOf: "0x26f61604",
};

const personas = ["Unclassified", "Seeder", "Builder", "Stabilizer", "Restricted"];
const deployments = {
  mainnet: {
    label: "X Layer mainnet",
    hook: "0x20Ac5a29faB456FEF778F2C4f2aab4C75dae4Ac0",
    poolId: "0x8f8b8bbfaa6be2f4aa115b301e38c2302279f9c702ac6c6c496d352412c62577",
    vault: "0x95dbE7EE5CF85baB9efcE768a44D1f1c1528488D",
    rehypothecationVault: "0xf8875dDE68F71f6BA448C5B58b43D4bCAFe93bdb",
    signalProvider: "0x8d89C6f5d2d961EC39027e5371f6044C96995D98",
    badgeContract: "0xD85e011D8F1CFCaA4d379687aA3FAEdc45c858Cd",
    rpc: "https://rpc.xlayer.tech",
    wallet: "0xE66581C8f5B91d257b5EAa90168B547Ba28f8e19",
    participants: {
      seeder: "0xE66581C8f5B91d257b5EAa90168B547Ba28f8e19",
      builder: "0x0F80054095F3A4cb2A2d14b7326303102B56D137",
      stabilizer: "0xa1638c2BF6Ef24aAFfBBA11520ED993AcC7Eb3E3",
      restricted: "0x64dD322ac2eADb4864c014E5206683a73B8055cd",
    },
  },
  testnet: {
    label: "X Layer testnet",
    hook: "0xDee0822330A786313E46A4f6d9E2d58c33B20AC0",
    poolId: "0x660353cea0aed4458ad5404c32f8033627539819271ca4738d325bd063370ac2",
    vault: "0x90407637D45588F0663b722438C6452c637c51d2",
    rehypothecationVault: "",
    signalProvider: "",
    badgeContract: "",
    rpc: "https://testrpc.xlayer.tech/terigon",
    wallet: "0xE66581C8f5B91d257b5EAa90168B547Ba28f8e19",
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

const els = {
  hookAddress: document.querySelector("#hookAddress"),
  poolId: document.querySelector("#poolId"),
  vaultAddress: document.querySelector("#vaultAddress"),
  rehypothecationVault: document.querySelector("#rehypothecationVault"),
  signalProvider: document.querySelector("#signalProvider"),
  badgeContract: document.querySelector("#badgeContract"),
  walletAddress: document.querySelector("#walletAddress"),
  rpcUrl: document.querySelector("#rpcUrl"),
  status: document.querySelector("#status"),
  connectWallet: document.querySelector("#connectWallet"),
  refreshState: document.querySelector("#refreshState"),
  coordinationScore: document.querySelector("#coordinationScore"),
  phaseLabel: document.querySelector("#phaseLabel"),
  stageTitle: document.querySelector("#stageTitle"),
  stageFill: document.querySelector("#stageFill"),
  uniqueParticipants: document.querySelector("#uniqueParticipants"),
  positiveParticipants: document.querySelector("#positiveParticipants"),
  restrictedParticipants: document.querySelector("#restrictedParticipants"),
  liquidityRelease: document.querySelector("#liquidityRelease"),
  marketSignal: document.querySelector("#marketSignal"),
  claimableRewards: document.querySelector("#claimableRewards"),
  idleDeposits: document.querySelector("#idleDeposits"),
  deployedAssets: document.querySelector("#deployedAssets"),
  claimableYield: document.querySelector("#claimableYield"),
  walletSignal: document.querySelector("#walletSignal"),
  personaBadge: document.querySelector("#personaBadge"),
  signalSummary: document.querySelector("#signalSummary"),
  signalAddress: document.querySelector("#signalAddress"),
  badgeSummary: document.querySelector("#badgeSummary"),
  badgeAddress: document.querySelector("#badgeAddress"),
  rehypothecationSummary: document.querySelector("#rehypothecationSummary"),
  rehypothecationAddress: document.querySelector("#rehypothecationAddress"),
  personaName: document.querySelector("#personaName"),
  personaSummary: document.querySelector("#personaSummary"),
  buyVolume: document.querySelector("#buyVolume"),
  sellVolume: document.querySelector("#sellVolume"),
  swapCount: document.querySelector("#swapCount"),
  liquidityActions: document.querySelector("#liquidityActions"),
  rapidRoundTrips: document.querySelector("#rapidRoundTrips"),
  networkBadge: document.querySelector("#networkBadge"),
  canvas: document.querySelector("#signalCanvas"),
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

els.connectWallet.addEventListener("click", async () => {
  if (!window.ethereum) {
    setStatus("No injected wallet found.");
    return;
  }

  const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
  els.walletAddress.value = accounts[0] || "";
  setStatus("Wallet connected. Refresh to load verified state.");
});

els.refreshState.addEventListener("click", refresh);
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

  els.hookAddress.value = deployment.hook;
  els.poolId.value = deployment.poolId;
  els.vaultAddress.value = deployment.vault;
  els.rehypothecationVault.value = deployment.rehypothecationVault;
  els.signalProvider.value = deployment.signalProvider;
  els.badgeContract.value = deployment.badgeContract;
  els.signalAddress.textContent = shortAddress(deployment.signalProvider);
  els.badgeAddress.textContent = shortAddress(deployment.badgeContract);
  els.rehypothecationAddress.textContent = shortAddress(deployment.rehypothecationVault);
  els.rpcUrl.value = deployment.rpc;
  els.walletAddress.value = deployment.wallet;
  els.networkBadge.textContent = `Verified on ${deployment.label}`;
  document.querySelectorAll("[data-preset]").forEach((button) => {
    button.classList.toggle("selected", button.dataset.preset === name);
  });
  document.querySelectorAll("[data-persona]").forEach((button) => {
    button.dataset.wallet = deployment.participants[button.dataset.persona];
  });
  highlightSelectedWallet(deployment.wallet);
}

async function refresh() {
  try {
    const hook = assertAddress(els.hookAddress.value.trim(), "Hook contract");
    const wallet = assertAddress(els.walletAddress.value.trim(), "Wallet");
    const poolId = assertBytes32(els.poolId.value.trim(), "Pool ID");

    setStatus("Reading hook state from X Layer RPC...");

    const poolState = await ethCall(hook, selectors.poolState + strip0x(poolId));
    const walletStats = await ethCall(hook, selectors.walletStats + strip0x(poolId) + padAddress(wallet));

    renderPoolState(decodeWords(poolState));
    renderWalletStats(decodeWords(walletStats));
    await renderRewards(poolId, wallet);
    await renderRehypothecation(wallet);
    await renderSignalsAndBadge(poolId, wallet);
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

  els.coordinationScore.textContent = latestState.score.toString();
  els.phaseLabel.textContent = `Phase ${latestState.phase.toString()}`;
  els.uniqueParticipants.textContent = latestState.unique.toString();
  els.positiveParticipants.textContent = latestState.positive.toString();
  els.restrictedParticipants.textContent = latestState.restricted.toString();
  els.liquidityRelease.textContent = `${Number(latestState.releaseBps) / 100}%`;
  els.marketSignal.textContent = `${latestState.marketSignal > 0 ? "+" : ""}${latestState.marketSignal.toString()} bps`;
  renderStage();
}

async function renderRewards(poolId, wallet) {
  const vault = els.vaultAddress.value.trim();
  if (!vault) {
    els.claimableRewards.textContent = "Not set";
    return;
  }

  assertAddress(vault, "Rewards vault");
  const result = await ethCall(vault, selectors.claimable + strip0x(poolId) + padAddress(wallet));
  els.claimableRewards.textContent = `${formatTokenUnits(decodeWords(result)[0])} OKB`;
}

async function renderRehypothecation(wallet) {
  const vault = els.rehypothecationVault.value.trim();
  if (!vault) {
    els.idleDeposits.textContent = "Not set";
    els.deployedAssets.textContent = "Not set";
    els.claimableYield.textContent = "Not set";
    return;
  }

  assertAddress(vault, "Rehypothecation vault");
  const [deposits, deployed, yieldAmount] = await Promise.all([
    ethCall(vault, selectors.deposits + padAddress(wallet)),
    ethCall(vault, selectors.deployedAssets),
    ethCall(vault, selectors.claimableYield + padAddress(wallet)),
  ]);

  els.idleDeposits.textContent = `${formatTokenUnits(decodeWords(deposits)[0])} CQUOTE`;
  els.deployedAssets.textContent = `${formatTokenUnits(decodeWords(deployed)[0])} CQUOTE`;
  els.claimableYield.textContent = `${formatTokenUnits(decodeWords(yieldAmount)[0])} OKB`;
  els.rehypothecationSummary.textContent =
    `${formatTokenUnits(decodeWords(deployed)[0])} CQUOTE deployed, ${formatTokenUnits(decodeWords(yieldAmount)[0])} OKB yield`;
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
    els.walletSignal.textContent = `${walletSignal > 0 ? "+" : ""}${walletSignal.toString()} / ${marketSignal > 0 ? "+" : ""}${marketSignal.toString()} bps`;
    els.signalSummary.textContent =
      `Wallet ${walletSignal > 0 ? "+" : ""}${walletSignal.toString()} bps, market ${marketSignal > 0 ? "+" : ""}${marketSignal.toString()} bps`;
  } else {
    els.walletSignal.textContent = "Not set";
    els.signalSummary.textContent = "Not set";
  }

  if (badgeContract) {
    assertAddress(badgeContract, "Persona badge");
    const result = await ethCall(badgeContract, selectors.badgeOf + strip0x(poolId) + padAddress(wallet));
    const tokenId = decodeWords(result)[0];
    els.personaBadge.textContent = tokenId === 0n ? "None" : `#${tokenId.toString()}`;
    els.badgeSummary.textContent = tokenId === 0n ? "No badge for wallet" : `Badge #${tokenId.toString()} minted`;
  } else {
    els.personaBadge.textContent = "Not set";
    els.badgeSummary.textContent = "Not set";
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

  els.personaName.textContent = personaName;
  els.personaSummary.textContent = personaSummaries[personaName] || "Persona unavailable.";
  els.buyVolume.textContent = formatTokenUnits(buyVolume);
  els.sellVolume.textContent = formatTokenUnits(sellVolume);
  els.swapCount.textContent = swapCount.toString();
  els.liquidityActions.textContent = liquidityActions.toString();
  els.rapidRoundTrips.textContent = rapidRoundTrips.toString();
}

function drawSignal() {
  const canvas = els.canvas;
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
  const whole = value / 10n ** 18n;
  const fraction = (value % 10n ** 18n).toString().padStart(18, "0").slice(0, 4);
  return `${whole}.${fraction}`;
}

function shortAddress(value) {
  if (!value) return "Not set";
  return `${value.slice(0, 6)}...${value.slice(-4)}`;
}

function signed16(word) {
  const masked = Number(word & 0xffffn);
  return BigInt(masked >= 0x8000 ? masked - 0x10000 : masked);
}

function setStatus(message) {
  els.status.textContent = message;
}

highlightSelectedWallet(els.walletAddress.value);
drawSignal();
refresh();
