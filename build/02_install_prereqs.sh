#!/usr/bin/env bash

# Maintainer: Meema Labs
# Telegram: https://telegram.meema.io
# Discord: https://discord.meema.io

# This script installs all dependencies required for the Cardano Node, ensuring everything is up-to-date.

start=$(date +%s.%N)
banner="--------------------------------------------------------------------------"

# Versions of dependencies
LIBSODIUM_VERSION="dbb48cc"
LIBSECP256K1_VERSION="ac83be33"

# Update and upgrade packages
sudo apt-get update -y
sudo apt-get upgrade -y

# Enable automatic updates so you don't have to manually install them.
sudo apt-get install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

# Install required packages
sudo apt-get install -y automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev \
libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 \
libtool autoconf nano screen iputils-ping chrony net-tools curl htop liblmdb-dev

# Prepare environment
mkdir -p ~/.local/bin
mkdir -p ~/src && cd ~/src || exit 1

# Install GHCup, GHC, and Cabal
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | BOOTSTRAP_HASKELL_NONINTERACTIVE=1 BOOTSTRAP_HASKELL_GHC_VERSION=latest BOOTSTRAP_HASKELL_CABAL_VERSION=latest BOOTSTRAP_HASKELL_INSTALL_STACK=1 BOOTSTRAP_HASKELL_INSTALL_HLS=0 BOOTSTRAP_HASKELL_ADJUST_BASHRC=P sh

# Reload .bashrc to apply changes made by GHCup installation
source "$HOME/.bashrc" || exit 1

# Install libsodium
git clone https://github.com/input-output-hk/libsodium || exit 1
cd libsodium || exit 1
git checkout $LIBSODIUM_VERSION || exit 1
./autogen.sh || exit 1
./configure || exit 1
make || exit 1
sudo make install || exit 1

# Return to the src directory before cloning the next repository
cd ~/src || exit 1

# Install libsecp256k1
git clone https://github.com/bitcoin-core/secp256k1 || exit 1
cd secp256k1 || exit 1
git checkout $LIBSECP256K1_VERSION || exit 1
./autogen.sh || exit 1
./configure --prefix=/usr --enable-module-schnorrsig --enable-experimental || exit 1
make || exit 1
sudo make install || exit 1

# Clean up
cd $HOME || exit 1
rm -rf ~/src/libsodium
rm -rf ~/src/secp256k1

end=$(date +%s.%N)
runtime=$(echo "$end - $start" | bc -l)

# Display script completion information
echo "$banner"
echo "Script runtime: $runtime seconds"
echo "Finished installing server dependencies."
echo "$banner"
