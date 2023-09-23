SHELL = /usr/bin/env bash

MCPU      = cortex-m4
FLOAT_ABI = hard
FPU       = fpv4-sp-d16
ISA       = thumb

SRC    = src
OBJ    = obj
INC    = include
BIN    = bin
CONFIG = config

PREFIX  = arm-none-eabi
ASM     = $(PREFIX)-as
CC      = $(PREFIX)-gcc
LD      = $(PREFIX)-ld
OBJCOPY = $(PREFIX)-objcopy
NM      = $(PREFIX)-nm

OPENOCD           = openocd
OPENOCD_INTERFACE = config/openocd/stlink.cfg
OPENOCD_TARGET    = config/openocd/stm32l4x.cfg
OPENOCDFLAGS     += -f $(OPENOCD_INTERFACE) -f $(OPENOCD_TARGET)

GDB       = gdb-multiarch
GDBFLAGS += -x $(CONFIG)/gdb/launch.gdb

CFLAGS += -std=gnu11
CFLAGS += -mcpu=$(MCPU) -m$(ISA) -mfloat-abi=$(FLOAT_ABI) -mfpu=$(FPU)
CFLAGS += -Wall -Wextra
CFLAGS += -g3 -O0

LDFLAGS += -nostdlib
LDFLAGS += -T $(LINKER_SCRIPT)
LDFLAGS += -Map $(MAP_FILE)

FILENAME = main
ELF      = $(BIN)/$(FILENAME).elf
HEX      = $(BIN)/$(FILENAME).hex

LINKER_SCRIPT = link.ld
MAP_FILE = $(BIN)/memory.map

SOURCES += $(SRC)/startup.s
OBJECTS += $(OBJ)/startup.o

SOURCES += $(SRC)/main.c
OBJECTS += $(OBJ)/main.o

.PHONY: build
build: | $(BIN)
build: compile link copy

.PHONY: copy
copy:
	@echo "Copying instructions from $(ELF) to $(HEX)"
	@$(OBJCOPY) -O ihex $(ELF) $(HEX)

.PHONY: compile
compile: $(OBJECTS)

.PHONY: link
link:
	@echo "Linking object files into $(ELF)"
	@$(LD) $(LDFLAGS) -o $(ELF) $(OBJECTS)

.PHONY: clean
clean:
	@echo "Cleaning created files"
	@rm $(OBJECTS) $(ELF) $(HEX) $(MAP_FILE)

.PHONY: symbols
symbols: build
	@echo "Printing symbols table"
	@$(NM) $(ELF)

.PHONY: flash
flash: build
	@echo "Flashing $(HEX) using openocd"
	@$(OPENOCD) $(OPENOCDFLAGS) -c "program $(ELF) verify reset exit"
	@echo "Flashing is complete!"

.PHONY: openocd
openocd:
	@echo "Starting $(OPENOCD) server"
	@$(OPENOCD) $(OPENOCDFLAGS)

.PHONY: debug
debug:
	@echo "Start debugging session with gdb"
	@$(GDB) $(GDBFLAGS) $(ELF)

$(OBJ)/%.o: $(SRC)/%.c
	@echo "Compiling $< into $@"
	@$(CC) -c $(CFLAGS) -o $@ $<

$(OBJ)/%.o: $(SRC)/%.s
	@echo "Compiling assembly file $< into $@"
	@$(ASM) -c $(ASFLAGS) -o $@ $<

$(OBJ):
	@echo "Creating directory for object files $(OBJ)"
	@mkdir $(OBJ)
$(OBJECTS): | $(OBJ)

$(BIN):
	@echo "Creating directory for build files $(BIN)"
	@mkdir $(BIN)
