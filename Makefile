PROJECT = main

# MCU
MCU = cortex-m0plus

# C definations
DEFS = -DSTM32L0 -DSTM32L072xx
# Debug level
DBG = -g3

# Optimisation level
OPT = -Os


PREFIX = arm-none-eabi-
CC = $(PREFIX)gcc
CXX = $(PREFIX)g++
GDB = $(PREFIX)gdb
CP = $(PREFIX)objcopy
AS = $(PREFIX)gcc -x assembler-with-cpp
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

# Source Files
SRC = ./src

# Object Files
BUILD_DIR = ./build

# Include directories
INCDIR = ./inc ./inc/CMSIS/device ./inc/CMSIS/core

# Library directories
LIBDIR = ./lib

# Linker script file
LINKER = ./linker/linker_stm32l073xx.ld

# Startup assembly source file
STARTUP = ./startup/startup_stm32l073xx.s

# Add all source files from src/ directory
SRC_FILES = $(wildcard $(SRC)/*.c)

# Object files
OBJ_FILES = $(patsubst $(SRC)/%.c, $(BUILD_DIR)/%.o, $(SRC_FILES))
OBJ_FILES += $(BUILD_DIR)/$(basename $(notdir $(STARTUP))).o

# Header file
INC = $(patsubst %,-I%, $(INCDIR))

# Library files
LIB = $(patsubst %,-L%, $(LIBDIR))

# Flags

COMFLAGS = -mcpu=$(MCU) -mthumb -mfloat-abi=soft
ASFLAGS = $(COMFLAGS) $(DBG)
CPFLAGS = $(COMFLAGS) $(OPT) $(DEFS) $(DBG) -Wall -fmessage-length=0 -ffunction-sections
LDFLAGS = $(COMFLAGS) -T$(LINKER) -Wl,-Map=$(PROJECT).map -Wl,--gc-sections $(LIB)

# Makefile Rules

all: $(OBJ) $(PROJECT).elf $(PROJECT).hex $(PROJECT).bin
	size $(PROJECT).elf

$(BUILD_DIR)/%.o: $(SRC)/%.c | $(BUILD_DIR)
	$(CC) -c $(CPFLAGS) -I . $(INC) $< -o $@

$(BUILD_DIR)/%.o: $(dir $(STARTUP))/%.s | $(BUILD_DIR)
	$(CC) -c $(ASFLAGS) $< -o $@

$(PROJECT).elf: $(OBJ_FILES) | $(BUILD_DIR)
	$(CC) $(OBJ_FILES) $(LDFLAGS) -o $@

%.hex: %.elf
	$(HEX) $< $@

%.bin: %.elf
	$(BIN) $< $@

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

flash: $(PROJECT).bin
	st-flash write $(PROJECT).bin 0x8000000

erase:
	st-flash erase

clean:
	rm -fR $(BUILD_DIR)
	rm *.hex *.bin *.map *.elf


