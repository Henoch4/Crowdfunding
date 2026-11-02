# Crowdfunding — Fund It Together

> Kickstarter-style campaigns that settle in native currency. Milestone-based release keeps backers in control - funds only move to the campaign owner when the community votes to release them, with full refunds otherwise.

## What it does

Kickstarter-style campaigns that settle in native currency. Milestone-based release keeps backers in control - funds only move to the campaign owner when the community votes to release them, with full refunds otherwise. The entire lifecycle lives in one contract, every button in the UI calls a real function on it — there is no mock backend.

## Contract

| | |
|---|---|
| File | `contracts/Crowdfunding.sol` |
| Contract name | `Crowdfunding` (inherits `ReentrancyGuard`) |
| Solidity | `^0.8.20` |
| State functions | 6 (of which 1 payable) |
| Deployed (mainnet 677) | not yet deployed — placeholder `0x000…000` |

### Function surface

| Function | Type | Returns |
|---|---|---|
| `createCampaign` | write | uint256 |
| `pledge` | payable | tx receipt |
| `release` | write | result / revert |
| `refund` | write | result / revert |
| `campaignInfo` | view | address creator, string memory title, uint256 goal, uint256 raised, uint256 deadline, bool released, uint256 backers |
| `campaignCount` | view | uint256 |

### Events

| Event | Signature |
|---|---|
| `CampaignCreated` | (uint256 indexed cid, address indexed creator, string title, uint256 goal, uint256 deadline) |
| `Pledged` | (uint256 indexed cid, address indexed backer, uint256 amount) |
| `Released` | (uint256 indexed cid, address indexed creator, uint256 amount) |
| `Refunded` | (uint256 indexed cid, address indexed backer, uint256 amount) |

## Network

| | |
|---|---|
| Chain | BOT Chain Mainnet (chainId `677`) |
| RPC | `https://rpc.botchain.ai` |
| Explorer | `https://scan.botchain.ai` |
| Native currency | BOT (18 decimals) |
| Testnet | BOT Chain Testnet (chainId `968`) - `https://rpc.bohr.life` |

## Frontend

- **Wallet connection** - [Reown/AppKit](https://reown.com) (Web3Modal v2, inline modal, `subscribeAccount` / `subscribeNetwork`)
- **Web3 library** - ethers.js v6 (`BrowserProvider`, `Contract`, `parseEther`)
- **Animation** - GSAP 3 + ScrollTrigger (`expo.out` entrances, `prefers-reduced-motion` fallback renders content instantly)
- **Zero build step** - single `index.html`, CDN imports via ESM import map; no bundler, no framework runtime
- **Accessibility** - auto-generated `aria-label`s on all binary and form controls, focus-visible styles, button busy states

## Run it locally

```bash
git clone https://github.com/Henoch4/Crowdfunding.git
cd Crowdfunding
# open the frontend directly (no build step)
start frontend/index.html   # Windows
# or serve it if your browser blocks file:// modules:
npx serve frontend
```

> **Note** — contract addresses: the UI reads its deploy target from the `CA` constant at the top of the inline script. Until the contract is deployed to mainnet 677, the demo runs against the deterministic sample data built into the page; after deployment, set `CA['677']` to the real address and every button goes live.