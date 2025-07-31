# Simple 2D Platformer in Assembly

A basic 2D platformer game written in x86-64 assembly for Linux, using terminal-based graphics.

## Features

- Terminal-based graphics using ANSI escape codes
- Simple physics with gravity and jumping
- Platform collision detection
- Smooth 60 FPS gameplay
- Level with multiple platforms

## Requirements

- Linux x86-64 system
- NASM assembler
- GNU Make

## Building

```bash
# Install dependencies (if not already installed)
sudo apt-get install nasm make

# Build the game
make

# Or build and run
make run
```

## Controls

- **A/a** - Move left
- **D/d** - Move right
- **W/w/Space** - Jump (only when on ground)
- **Q/q** - Quit game

## How to Play

1. You control the `@` character
2. Navigate through the level by jumping between platforms
3. The `#` characters represent solid platforms
4. Try to explore the entire level!

## Game Mechanics

- **Gravity**: The player is constantly pulled downward
- **Jump**: Press jump while on a platform to leap upward
- **Movement**: Left/right movement is instant
- **Collision**: The player cannot pass through platforms

## Technical Details

The game is written entirely in x86-64 assembly and uses:
- Linux system calls for I/O
- Terminal raw mode for real-time input
- ANSI escape sequences for graphics
- Non-blocking input for smooth gameplay
- Custom physics engine with collision detection

## Level Design

The level is stored as a 40x20 character grid where:
- `#` represents solid platforms
- `.` represents empty space
- The level is surrounded by walls

You can modify the level by editing the `level` data in `platformer.asm`.

## Troubleshooting

If the game doesn't exit cleanly, your terminal might be left in raw mode. To fix this:
```bash
reset
```

## License

This project is released into the public domain.