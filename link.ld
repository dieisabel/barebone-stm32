ENTRY(Reset_Handler);

MEMORY {
    FLASH(RX) : ORIGIN = 0x08000000, LENGTH = 2048K
    SRAM(RWX) : ORIGIN = 0x20000000, LENGTH = 192K
}

_estack = ORIGIN(SRAM) + LENGTH(SRAM);

SECTIONS {
    .vector_table : {
        . = ALIGN(4);
        KEEP(*(.vector_table))
        . = ALIGN(4);
    }> FLASH

    .text : {
        . = ALIGN(4);
        *(.text.*)
        *(.rodata*)
        . = ALIGN(4);
    }> FLASH

    .data : {
        . = ALIGN(4);
        _sdata = .;
        *(.data.*)
        . = ALIGN(4);
        _edata = .;
    }> SRAM AT> FLASH

    _sidata = LOADADDR(.data);

    .bss : {
        . = ALIGN(4);
        _sbss = .;
        *(.bss.*)
        . = ALIGN(4);
        _ebss = .;
    }> SRAM
}
