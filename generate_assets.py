#!/usr/bin/env python3
"""Generate placeholder sprite assets for the platformer game."""

from PIL import Image, ImageDraw
import os

# Ensure assets directory exists
os.makedirs("assets", exist_ok=True)

# Define colors
PLAYER_COLOR = (0, 100, 255)  # Blue
PLATFORM_COLOR = (100, 60, 30)  # Brown
BACKGROUND_COLOR = (135, 206, 235)  # Sky blue
GROUND_COLOR = (34, 139, 34)  # Green

# Create player sprite (32x32)
player = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
draw = ImageDraw.Draw(player)
# Draw a simple character
draw.ellipse([8, 4, 24, 20], fill=PLAYER_COLOR)  # Head
draw.rectangle([10, 16, 22, 28], fill=PLAYER_COLOR)  # Body
draw.rectangle([6, 16, 10, 24], fill=PLAYER_COLOR)  # Left arm
draw.rectangle([22, 16, 26, 24], fill=PLAYER_COLOR)  # Right arm
draw.rectangle([12, 24, 16, 32], fill=PLAYER_COLOR)  # Left leg
draw.rectangle([16, 24, 20, 32], fill=PLAYER_COLOR)  # Right leg
player.save('assets/player.png')

# Create platform tile (32x32)
platform = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
draw = ImageDraw.Draw(platform)
# Draw brick pattern
draw.rectangle([0, 0, 32, 32], fill=PLATFORM_COLOR)
# Add some texture
for y in range(0, 32, 8):
    draw.line([(0, y), (32, y)], fill=(80, 40, 20), width=1)
for x in range(0, 32, 16):
    for y in range(0, 32, 16):
        draw.line([(x, y), (x, y+8)], fill=(80, 40, 20), width=1)
        draw.line([(x+16, y+8), (x+16, y+16)], fill=(80, 40, 20), width=1)
platform.save('assets/platform.png')

# Create grass platform tile (32x32)
grass_platform = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
draw = ImageDraw.Draw(grass_platform)
# Draw grass on top of dirt
draw.rectangle([0, 8, 32, 32], fill=PLATFORM_COLOR)  # Dirt
draw.rectangle([0, 0, 32, 12], fill=GROUND_COLOR)  # Grass
# Add grass texture
for x in range(0, 32, 3):
    height = 4 + (x % 5)
    draw.line([(x, 12), (x, 12-height)], fill=(20, 100, 20), width=1)
grass_platform.save('assets/grass_platform.png')

# Create background (800x600)
background = Image.new('RGB', (800, 600), BACKGROUND_COLOR)
draw = ImageDraw.Draw(background)

# Add clouds
cloud_color = (255, 255, 255)
# Cloud 1
draw.ellipse([100, 50, 180, 90], fill=cloud_color)
draw.ellipse([150, 40, 230, 80], fill=cloud_color)
draw.ellipse([200, 50, 280, 90], fill=cloud_color)

# Cloud 2
draw.ellipse([500, 100, 580, 140], fill=cloud_color)
draw.ellipse([550, 90, 630, 130], fill=cloud_color)
draw.ellipse([600, 100, 680, 140], fill=cloud_color)

# Add distant mountains
mountain_color = (100, 100, 150)
points = [(0, 400), (200, 250), (400, 350), (600, 200), (800, 300), (800, 600), (0, 600)]
draw.polygon(points, fill=mountain_color)

# Add ground
draw.rectangle([0, 500, 800, 600], fill=GROUND_COLOR)

background.save('assets/background.png')

# Create coin/collectible sprite (24x24)
coin = Image.new('RGBA', (24, 24), (0, 0, 0, 0))
draw = ImageDraw.Draw(coin)
draw.ellipse([2, 2, 22, 22], fill=(255, 215, 0))  # Gold
draw.ellipse([6, 6, 18, 18], fill=(255, 235, 0))  # Lighter gold center
draw.text((9, 7), '$', fill=(200, 150, 0))
coin.save('assets/coin.png')

# Create enemy sprite (32x32)
enemy = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
draw = ImageDraw.Draw(enemy)
# Draw a simple enemy (red square with eyes)
draw.rectangle([4, 8, 28, 32], fill=(255, 0, 0))  # Body
draw.ellipse([8, 12, 14, 18], fill=(255, 255, 255))  # Left eye
draw.ellipse([18, 12, 24, 18], fill=(255, 255, 255))  # Right eye
draw.ellipse([10, 14, 12, 16], fill=(0, 0, 0))  # Left pupil
draw.ellipse([20, 14, 22, 16], fill=(0, 0, 0))  # Right pupil
enemy.save('assets/enemy.png')

print("Placeholder assets generated successfully!")
print("Created:")
print("  - assets/player.png (32x32)")
print("  - assets/platform.png (32x32)")
print("  - assets/grass_platform.png (32x32)")
print("  - assets/background.png (800x600)")
print("  - assets/coin.png (24x24)")
print("  - assets/enemy.png (32x32)")