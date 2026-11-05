# KUGGUK Tokenomics Network — proposal (branch `kugguk/tokenomics-network`)

Status: **PROPOSAL — not running yet.** Nothing in this folder is wired into the chainlist build.
The draft registry entry (`chainid-2026110.draft.js`) moves into `constants/additionalChainRegistry/`
only after the RPC and explorer below answer for real.

## What this branch adds

| Path | What it is |
|---|---|
| `README.md` | This proposal: network choice, viability gates, rollout |
| `chainid-2026110.draft.js` | Chainlist entry for the testnet, in the upstream format |
| `devnet/` | 4-validator Besu QBFT network you can run locally or on one VM |
| `gcp/main.tf` | Minimal Terraform for phase 1 on GCP (one VM, one disk, budget alert) |

## Network options (facts)

| Option | Own chain ID (chainlist entry)? | Infra you run | Rough monthly cost | Control | Notes |
|---|---|---|---|---|---|
| A. Token on an existing L2 testnet (e.g. Base Sepolia) | No | None | ~0 | Low (shared chain) | Fastest; nothing to list here |
| **B. Own permissioned EVM — Hyperledger Besu, QBFT** | **Yes** | 4 validators on GCP (or AWS) VMs | ~US$50 (1 VM, testnet) → ~US$200 (4 VMs, HA) | Full | Apache-2.0; BFT tolerates 1 faulty of 4; gas price can be 0; org-owned issuance |
| C. Rollup via RaaS (OP Stack / Arbitrum Orbit) | Yes | Vendor runs it | Vendor pricing, typically far above B for mainnet | Medium (vendor) | Settles to Ethereum; vendor dependency |
| D. Avalanche L1 | Yes | Validators + continuous AVAX fees | Variable | Medium | Ties cost to AVAX price — conflicts with the "independent from markets" rule |

Costs are estimates (GCP list prices, europe-west); confirm in the GCP pricing calculator before committing.

**Proposed: B on GCP** — same cloud as the Z<>W deploy target, runs on plain VMs with persistent disks
(Cloud Run is not suitable for validators: they need stable P2P ports and local chain state).
AWS works identically on EC2 + EBS if you prefer; the devnet folder is cloud-agnostic.

## Viability gates (derived from your tokenomics design — confirm or replace)

| Gate | Rule | How the network enforces / evidences it |
|---|---|---|
| V0 | No public mainnet or public token offer before KUGGUK OÜ is registered and a MiCA white-paper check is done | Testnet only; chain ID 2026111 reserved for mainnet later, not created |
| V1 | Market independence ("no double predation") | Own chain, gas price 0, no bridge to exchanges in phase 1 |
| V2 | Org-owned issuance only | Mint rights held by one treasury multisig; validator set = KUGGUK nodes only |
| V3 | Two reserve layers | Contracts: IBNR layer (costs recognised with 3-month lag) + reinsurance layer (non-operational black-swan reserve) |
| V4 | Minimal audit of money/tokens burned | Every mint/burn emits an event; explorer + weekly export |
| V5 | Positive ROI, even minimal | Phase 1 hard budget cap with alert (see `gcp/main.tf`); scale to 4 VMs only when a pilot (e.g. The Actuarials) uses it |

## Rollout

| Phase | What | Exit check |
|---|---|---|
| 0 | Run `devnet/` locally | 4 validators producing blocks; `eth_chainId` = `0x1eea7e` |
| 1 | One GCP VM runs the same compose; RPC behind TLS at `rpc-testnet.kugguk.com` | RPC answers publicly; budget alert live |
| 2 | Deploy token + IBNR/reinsurance contracts; add a Blockscout explorer | Explorer shows mint/burn events |
| 3 | Move draft entry into `constants/additionalChainRegistry/chainid-2026110.js`; open PR to DefiLlama/chainlist | Upstream PR checks pass |
| 4 | 4 VMs across zones (HA) | Survives one VM down |

## Open items (yours to decide)

- Chain name / symbol: draft uses **KUGGUK Testnet / KUGT** — rename freely.
- RPC/explorer subdomains on kugguk.com (draft assumes `rpc-testnet.` and `explorer-testnet.`).
- Chain IDs 2026110 / 2026111 were free in ethereum-lists on 2026-11-05; re-check right before the upstream PR.
- EVM signatures are secp256k1 (not post-quantum). Keep that boundary explicit where this chain meets Z<>W (ML-DSA).
