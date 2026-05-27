const selectors = {
  poolState: "0xe0b01bac",
  walletStats: "0x378a7a4c",
  claimable: "0xf4b38c30",
  owner: "0x8da5cb5b",
};

const personas = ["Unclassified", "Seeder", "Builder", "Stabilizer", "Restricted"];

const els = {
  hookAddress: document.querySelector("#hookAddress"),
  poolId: document.querySelector("#poolId"),
  vaultAddress: document.querySelector("#vaultAddress"),
  walletAddress: document.querySelector("#walletAddress"),
  rpcUrl: document.querySelector("#rpcUrl"),
  status: document.querySelector("#status"),
  connectWallet: document.querySelector("#connectWallet"),
  refreshState: document.querySelector("#refreshState"),
  coordinationScore: document.querySelector("#coordinationScore"),
  phaseLabel: document.querySelector("#phaseLabel"),
  uniqueParticipants: document.querySelector("#uniqueParticipants"),
  positiveParticipants: document.querySelector("#positiveParticipants"),
  restrictedParticipants: document.querySelector("#restrictedParticipants"),
  liquidityRelease: document.querySelector("#liquidityRelease"),
  marketSignal: document.querySelector("#marketSignal"),
  claimableRewards: document.querySelector("#claimableRewards"),
  personaName: document.querySelector("#personaName"),
  buyVolume: document.querySelector("#buyVolume"),
  sellVolume: document.querySelector("#sellVolume"),
  swapCount: document.querySelector("#swapCount"),
  liquidityActions: document.querySelector("#liquidityActions"),
  rapidRoundTrips: document.querySelector("#rapidRoundTrips"),
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
  setStatus("Wallet connected. Add hook and pool addresses, then refresh.");
});

els.refreshState.addEventListener("click", refresh);

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

function renderWalletStats(words) {
  const buyVolume = words[4];
  const sellVolume = words[5];
  const swapCount = words[7];
  const liquidityActions = words[8];
  const rapidRoundTrips = words[9];
  const persona = Number(words[10]);

  els.personaName.textContent = personas[persona] || "Unknown";
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
  ctx.fillStyle = "#0b1018";
  ctx.fillRect(0, 0, width, height);

  for (let i = 0; i < 80; i++) {
    const x = (i / 79) * width;
    const y = height / 2 + Math.sin(i * 0.42 + positive) * 64 * quality;
    const radius = 2 + ((i + positive) % 7) * quality;
    ctx.beginPath();
    ctx.arc(x, y, radius, 0, Math.PI * 2);
    ctx.fillStyle = i % 5 === 0 ? "#59a9ff" : "#48e0a4";
    ctx.globalAlpha = 0.24 + quality * 0.64;
    ctx.fill();
  }

  ctx.globalAlpha = 1;
  ctx.lineWidth = 3;
  ctx.strokeStyle = "#48e0a4";
  ctx.beginPath();
  for (let x = 0; x <= width; x += 10) {
    const y = height / 2 + Math.sin(x / 54 + positive) * 68 * quality;
    if (x === 0) ctx.moveTo(x, y);
    else ctx.lineTo(x, y);
  }
  ctx.stroke();

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

function signed16(word) {
  const masked = Number(word & 0xffffn);
  return BigInt(masked >= 0x8000 ? masked - 0x10000 : masked);
}

function setStatus(message) {
  els.status.textContent = message;
}

drawSignal();
