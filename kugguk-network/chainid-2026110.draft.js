// DRAFT — move to constants/additionalChainRegistry/chainid-2026110.js only once
// the RPC and explorer below are live (see kugguk-network/README.md, phase 3).
export const data = {
  "name": "KUGGUK Testnet",
  "chain": "KUGT",
  "rpc": [
    "https://rpc-testnet.kugguk.com"
  ],
  "faucets": [],
  "nativeCurrency": {
    "name": "KUGGUK Test",
    "symbol": "KUGT",
    "decimals": 18
  },
  "features": [
    { "name": "EIP155" },
    { "name": "EIP1559" }
  ],
  "infoURL": "https://kugguk.com",
  "shortName": "kugt",
  "chainId": 2026110,
  "networkId": 2026110,
  "icon": "kugguk",
  "explorers": [
    {
      "name": "KUGGUK Testnet Explorer",
      "url": "https://explorer-testnet.kugguk.com",
      "standard": "EIP3091"
    }
  ]
}
