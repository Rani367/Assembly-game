# 2D Platformer in Pure Assembly

A fully-featured 2D platformer game written in 100% pure assembly language for multiple platforms. Features sprite rendering, physics, and smooth gameplay - all without any high-level language dependencies.

## 🎮 Features

- **Pure Assembly**: Written entirely in assembly language - no C, C++, or other high-level languages
- **Cross-Platform**: Supports Windows (x64/x86), macOS (ARM64/x86-64), and Linux
- **Sprite Graphics**: Full sprite rendering with placeholder assets
- **Physics Engine**: Gravity, jumping, and collision detection
- **Smooth Gameplay**: 60 FPS with double buffering
- **Level Design**: Tile-based level system with multiple platform types

## 🖼️ Game Assets

The game includes placeholder sprite assets:
- Player character (32x32)
- Platform tiles (32x32)
- Grass platform tiles (32x32)
- Background (800x600)
- Coins (24x24)
- Enemies (32x32)

## 📁 Project Structure

```
.
├── assets/                    # Sprite assets (PNG format)
│   ├── player.png
│   ├── platform.png
│   ├── grass_platform.png
│   ├── background.png
│   ├── coin.png
│   └── enemy.png
├── windows/
│   ├── x64/
│   │   ├── platformer_win64.asm         # Basic Windows x64 version
│   │   ├── platformer_win64_sprites.asm # Enhanced version with sprites
│   │   └── build.bat
│   └── x86/
│       ├── platformer_win32.asm
│       └── build.bat
├── macos/
│   ├── arm64/
│   │   ├── platformer_macos_arm64.asm
│   │   └── build.sh
│   └── x86_64/
│       ├── platformer_macos_x64.asm
│       └── build.sh
├── linux/
│   ├── platformer.asm         # Terminal-based Linux version
│   └── Makefile
└── generate_assets.py         # Script to generate placeholder assets
```

## 🛠️ Building the Game

### Prerequisites

- **NASM**: The Netwide Assembler (all platforms)
- **Platform-specific tools**:
  - Windows: GoLink, Visual Studio Build Tools, or MinGW
  - macOS: Xcode Command Line Tools
  - Linux: GNU Make, ld

### Windows (x64)

```bash
cd windows/x64
build.bat
```

The build script will automatically detect and use available linkers (GoLink, MSVC, or MinGW).

### macOS (ARM64 - Apple Silicon)

```bash
cd macos/arm64
chmod +x build.sh
./build.sh
```

### macOS (x86-64 - Intel)

```bash
cd macos/x86_64
chmod +x build.sh
./build.sh
```

### Linux

```bash
cd linux
make
./platformer
```

## 🎮 Controls

- **Arrow Keys** or **A/D**: Move left/right
- **Space** or **W** or **Up Arrow**: Jump (only when on ground)
- **Escape** or **Q**: Quit game

## 🏗️ Technical Details

### Windows Implementation
- Uses Win32 API for window creation and event handling
- GDI/GDI+ for graphics rendering
- Double buffering for smooth animation
- Timer-based game loop (60 FPS)

### macOS Implementation
- Uses Cocoa framework through Objective-C runtime
- Core Graphics for rendering
- NSTimer for game loop
- Supports both ARM64 and x86-64 architectures

### Linux Implementation
- Terminal-based graphics using ANSI escape codes
- Raw terminal mode for real-time input
- Custom rendering engine

## 🎯 Game Mechanics

- **Gravity**: Constant downward acceleration
- **Jumping**: Fixed impulse when on ground
- **Collision Detection**: Tile-based collision system
- **Level Format**: 2D array where:
  - `0` = Empty space
  - `1` = Brick platform
  - `2` = Grass platform

## 🚀 Advanced Features

The Windows sprite version (`platformer_win64_sprites.asm`) includes:
- PNG sprite loading support (via GDI+)
- Transparent sprite rendering
- Background gradients
- Enhanced visual effects

## 📝 Notes

- The game is written in pure assembly with no external dependencies beyond system APIs
- Each platform version is optimized for its specific architecture
- The code demonstrates advanced assembly techniques including:
  - System call interfaces
  - Window management
  - Event handling
  - Graphics programming
  - Memory management

## 🤝 Contributing

This is a demonstration of pure assembly programming across platforms. Feel free to:
- Add new platform support
- Implement actual sprite loading
- Add sound effects (using platform audio APIs)
- Create new levels
- Optimize the physics engine

## 📄 License

This project is released into the public domain. Use it as you wish!

## 🎨 Generating Assets

To regenerate the placeholder assets:

```bash
python3 generate_assets.py
```

This requires Python 3 with PIL/Pillow installed.