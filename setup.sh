#!/bin/bash
set -e

echo "Setting up CloudFileBrowser project..."

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "This script must be run on macOS"
    exit 1
fi

# Install XcodeGen if not present
if ! command -v xcodegen &> /dev/null; then
    echo "Installing XcodeGen..."
    if command -v brew &> /dev/null; then
        brew install xcodegen
    else
        echo "Homebrew not found. Installing XcodeGen via Mint..."
        if ! command -v mint &> /dev/null; then
            echo "Installing Mint..."
            brew install mint
        fi
        mint install yonaskolb/XcodeGen
    fi
fi

# Generate Xcode project
echo "Generating Xcode project..."
xcodegen generate

echo "Project setup complete!"
echo "You can now open CloudFileBrowser.xcodeproj in Xcode"
