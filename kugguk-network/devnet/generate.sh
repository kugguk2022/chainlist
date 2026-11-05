#!/usr/bin/env bash
# Generates genesis + 4 validator keys and writes .env with the bootnode enode.
# Run once from kugguk-network/devnet/. Keys land in ./nodes/ (git-ignored) — back them up.
set -euo pipefail
cd "$(dirname "$0")"
BESU_IMAGE="${BESU_IMAGE:-hyperledger/besu:latest}"

[ -d nodes ] && { echo "nodes/ already exists — refusing to overwrite keys."; exit 1; }

docker run --rm -v "$PWD":/work -w /work "$BESU_IMAGE" \
  operator generate-blockchain-config \
  --config-file=qbftConfigFile.json --to=networkFiles --private-key-file-name=key

cp networkFiles/genesis.json genesis.json
mkdir -p nodes
i=1
for d in networkFiles/keys/*/; do
  mkdir -p "nodes/node$i/data"
  cp "$d/key" "$d/key.pub" "nodes/node$i/data/"
  i=$((i+1))
done
rm -rf networkFiles

PUB=$(sed 's/^0x//' nodes/node1/data/key.pub)
echo "BOOTNODE=enode://${PUB}@172.28.0.11:30303" > .env
echo "Done. Start with: docker compose up -d"
