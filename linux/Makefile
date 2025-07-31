# Makefile for Simple 2D Platformer

# Assembler and linker
AS = nasm
LD = ld

# Flags
ASFLAGS = -f elf64
LDFLAGS = -m elf_x86_64

# Target executable
TARGET = platformer

# Source files
SRC = platformer.asm
OBJ = platformer.o

# Build rules
all: $(TARGET)

$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) -o $(TARGET) $(OBJ)

$(OBJ): $(SRC)
	$(AS) $(ASFLAGS) -o $(OBJ) $(SRC)

clean:
	rm -f $(OBJ) $(TARGET)

run: $(TARGET)
	./$(TARGET)

.PHONY: all clean run