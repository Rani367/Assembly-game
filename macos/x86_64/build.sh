#!/bin/bash

echo "Building 2D Platformer for macOS x86-64 (Intel)..."

# Check if NASM is installed
if ! command -v nasm &> /dev/null; then
    echo "ERROR: NASM not found. Please install NASM."
    echo "You can install it using Homebrew: brew install nasm"
    exit 1
fi

# Check if Xcode Command Line Tools are installed
if ! command -v clang &> /dev/null; then
    echo "ERROR: Xcode Command Line Tools not found."
    echo "Please install them: xcode-select --install"
    exit 1
fi

# Assemble the code
echo "Assembling platformer_macos_x64.asm..."
nasm -f macho64 platformer_macos_x64.asm -o platformer_macos_x64.o
if [ $? -ne 0 ]; then
    echo "ERROR: Assembly failed"
    exit 1
fi

# Link with macOS frameworks
echo "Linking..."
ld -o platformer \
   -framework Cocoa \
   -framework CoreGraphics \
   -framework Foundation \
   -lSystem \
   -syslibroot `xcrun -sdk macosx --show-sdk-path` \
   -arch x86_64 \
   platformer_macos_x64.o

if [ $? -eq 0 ]; then
    echo "Build successful! Run ./platformer to play."
    # Make executable
    chmod +x platformer
else
    echo "ERROR: Linking failed"
    exit 1
fi