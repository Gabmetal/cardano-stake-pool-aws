#!/usr/bin/env bash

# Builds the Cardano Node from source code.

start=$(date +%s.%N)
banner="--------------------------------------------------------------------------"

# Navigate to the working directory
mkdir -p "$HOME/git"
cd "$HOME/git" || exit 1

# Clone Cardano Node repository
git clone https://github.com/input-output-hk/cardano-node.git
cd cardano-node || exit 1

# Fetch all tags and submodules
git fetch --all --recurse-submodules --tags

# Checkout the latest tagged version
LATEST_TAG=$(curl -s https://api.github.com/repos/input-output-hk/cardano-node/releases/latest | jq -r .tag_name)
git checkout "$LATEST_TAG"

# Update Cabal and configure the build
cabal update
GHC_VERSION=$(ghc --version | awk '{print $NF}') # Automatically detect GHC version
cabal configure -O0 -w ghc-"$GHC_VERSION"

# Create cabal.project.local file and configure it to avoid installing custom libsodium
echo "package cardano-crypto-praos" >> cabal.project.local
echo "  flags: -external-libsodium-vrf" >> cabal.project.local

# Build the cardano-node and cardano-cli binaries
cabal build cardano-node cardano-cli

# Copy the binaries to /usr/local/bin
sudo cp -p "$(./scripts/bin-path.sh cardano-node)" /usr/local/bin/cardano-node
sudo cp -p "$(./scripts/bin-path.sh cardano-cli)" /usr/local/bin/cardano-cli

end=$(date +%s.%N)
runtime=$(echo "$end - $start" | bc -l)

# Display script completion information
echo "$banner"
echo "Script runtime: $runtime seconds"
echo "cardano-node version: $(cardano-node --version)"
echo "cardano-cli version: $(cardano-cli --version)"
echo "$banner"
