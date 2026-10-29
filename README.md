# Crowdfunding

**All-or-nothing campaigns. Fund it, or get it back.**

Live on **BOT Chain mainnet (chain ID 677)**.

| | |
|---|---|
| Contract | `0x6a1A0ddb22358597609aA6f9a70deE61818e13Ff` |
| Network | BOT Chain Mainnet |
| Chain ID | 677 |
| RPC | https://rpc.botchain.ai |
| Explorer | https://scan.botchain.ai/ |
| Website | https://botchain.ai |

## What it does

Creators set a goal and a deadline. Pledges sit in the contract until the goal is met, then release to the creator in a single transfer. If the deadline passes short, every backer reclaims their own pledge.

## Functions

- `createCampaign(title, description, goal, durationSeconds)`
- `pledge(campaignId) — payable`
- `release(campaignId) — creator only, requires goal met`
- `refund(campaignId) — backer only, requires deadline passed and goal missed`

## Frontend

A single self-contained `index.html` — no build step, no bundler. Open it directly or serve the folder statically.

- Wallet connect through any injected EIP-1193 wallet (MetaMask, OKX Wallet).
- If chain 677 is not configured, the page offers to add it (`wallet_addEthereumChain`).
- Every number on the page is read live from the contract over JSON-RPC; nothing is mocked.
- All writes are sent from the connected account and confirmed before the UI refreshes.

```bash
# any static server works
npx serve .
```

## Contract

`contracts/Crowdfunding.sol` — self-contained Solidity 0.8.20, no external imports. Reentrancy guard and ownership are declared inline so the file compiles standalone with `solc`.

## License

MIT
