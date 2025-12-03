#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🦇 Bat Computer Installation${NC}"
echo "================================"

# Check if Swift is installed
if ! command -v swift &> /dev/null; then
    echo -e "${RED}❌ Swift not found. Please install Swift first.${NC}"
    echo "Visit https://swift.org/download/ for installation instructions."
    exit 1
fi

echo -e "${GREEN}✅ Swift detected$(NC)"

# Build the project
echo -e "${YELLOW}🔨 Building Bat Computer...${NC}"
if ! swift build -c release 2>&1; then
    echo -e "${RED}❌ Build failed. Please check your Swift installation.${NC}"
    exit 1
fi

# Create symlink
echo -e "${YELLOW}🔗 Creating executable link...${NC}"
EXECUTABLE_PATH="${PWD}/.build/release/BatComputer"

if [ ! -f "$EXECUTABLE_PATH" ]; then
    echo -e "${RED}❌ Build output not found at $EXECUTABLE_PATH${NC}"
    exit 1
fi

# Try to create symlink with sudo if needed
if sudo ln -sf "$EXECUTABLE_PATH" /usr/local/bin/batcomputer 2>/dev/null; then
    echo -e "${GREEN}✅ Created symlink at /usr/local/bin/batcomputer${NC}"
else
    echo -e "${YELLOW}⚠️  Could not create system symlink. Using local link instead.${NC}"
    ln -sf "$EXECUTABLE_PATH" ./batcomputer
    echo -e "${GREEN}✅ Local symlink created. Run with: ./batcomputer${NC}"
fi

echo ""
echo -e "${GREEN}📋 Setting up Permissions${NC}"
echo "========================================"
echo ""

# Attempt to grant permissions using tccutil
if command -v tccutil &> /dev/null; then
    echo -e "${YELLOW}Granting microphone and speech recognition permissions...${NC}"
    sudo tccutil grant Microphone com.apple.Terminal 2>/dev/null
    sudo tccutil grant SpeechRecognition com.apple.Terminal 2>/dev/null
    echo -e "${GREEN}✅ Permissions granted!${NC}"
else
    echo -e "${YELLOW}⚠️  Could not auto-grant permissions. Please grant manually:${NC}"
    echo ""
    echo "1. Open System Settings"
    echo "2. Navigate to: Privacy & Security → Microphone"
    echo "3. Find 'Terminal' (or your terminal app) and toggle it ON"
    echo ""
    echo "4. Navigate to: Privacy & Security → Speech Recognition"
    echo "5. Find 'Terminal' (or your terminal app) and toggle it ON"
fi

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo -e "${YELLOW}Run Bat Computer with:${NC}"
if command -v batcomputer &> /dev/null; then
    echo "  batcomputer"
else
    echo "  ./.build/release/BatComputer"
fi