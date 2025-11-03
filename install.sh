#!/bin/bash

# Install Swift if not already installed
if ! command -v swift &> /dev/null; then
    echo "Swift not found. Please install Swift first."
    echo "Visit https://swift.org/download/ for installation instructions."
    exit 1
fi

# Build the project
echo "Building Bat Computer..."
swift build

# Create a symlink to the executable
echo "Creating executable link..."
ln -sf .build/debug/BatComputer /usr/local/bin/batcomputer

echo "Installation complete! You can now run the Bat Computer by typing 'batcomputer' in your terminal."