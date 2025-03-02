#!/bin/bash

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Correct path to the Neovim configuration
NVIM_CONFIG="/etc/xdg/nvim/config/nvim"

echo -e "${BLUE}Setting up Neovim configuration for user: ${YELLOW}$(whoami)${NC}"

# Create user directories
mkdir -p ~/.local/share/nvim/site/pack/packer/start
mkdir -p ~/.local/share/nvim/shada

# Clone packer if it doesn't exist
if [ ! -d ~/.local/share/nvim/site/pack/packer/start/packer.nvim ]; then
  echo -e "${BLUE}Installing packer.nvim...${NC}"
  git clone --depth 1 https://github.com/wbthomason/packer.nvim \
    ~/.local/share/nvim/site/pack/packer/start/packer.nvim
fi

# Create local config directory
mkdir -p ~/.config/nvim

# Create symlinks to the configuration
echo -e "${BLUE}Creating symlinks to system Neovim configuration...${NC}"

# Copy init.lua (don't symlink it to avoid permission issues with plugin installations)
cp -f "$NVIM_CONFIG/init.lua" ~/.config/nvim/init.lua

# Create lua directory and link/copy contents
mkdir -p ~/.config/nvim/lua
cp -rf "$NVIM_CONFIG/lua/"* ~/.config/nvim/lua/

# Create an empty plugin directory if it doesn't exist
mkdir -p ~/.config/nvim/plugin

echo -e "${GREEN}Neovim setup complete! ${NC}"
echo -e "${YELLOW}Run 'nvim' and execute ':PackerSync' to install plugins.${NC}"
echo -e "${YELLOW}Then run ':Mason' to install language servers.${NC}"
