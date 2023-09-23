.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

.word _estack
.word _sdata
.word _edata
.word _sidata
.word _sbss
.word _ebss

.section .text, "ax", %progbits

.global Reset_Handler

# VERY IMPORTANT DIRECTIVE!!! I dont know why but without it core will not execute ANY
# instruction and go to HardFault
.type Reset_Handler, %function

Reset_Handler:
    ldr sp, =_estack
    ldr r0, =_sdata
    ldr r1, =_edata
    ldr r2, =_sidata

    mov r3, #0x00
    bl StartCopyingDataSection

    ldr r1, =_sbss
    ldr r2, =_ebss
    mov r3, #0x00
    mov r5, #0x00
    bl StartFillingBssWithZeroes

    bl main
    b InfinityLoop

StartCopyingDataSection:
    add r4, r0, r3
    cmp r4, r1
    bne CopyDataSection
    bx lr

CopyDataSection:
    ldr r4, [r2, r3]
    str r4, [r0, r3]
    add r3, r3, #0x04
    b StartCopyingDataSection

StartFillingBssWithZeroes:
    add r4, r1, r3
    cmp r4, r2
    bne FillBssSection
    bx lr

FillBssSection:
    str r5, [r1, r3]
    add r3, r3, #0x04
    b StartFillingBssWithZeroes

InfinityLoop:
    b InfinityLoop

NMI_Handler:
    b NMI_Handler

HardFault_Handler:
    b HardFault_Handler

MemManage_Handler:
    b MemManage_Handler

BusFault_Handler:
    b BusFault_Handler

UsageFault_Handler:
    b UsageFault_Handler

SVCall_Handler:
    b SVCall_Handler

DebugMonitor_Handler:
    b DebugMonitor_Handler

PendSV_Handler:
    b PendSV_Handler

SysTick_Handler:
    b SysTick_Handler

.section .vector_table, "a", %progbits
vectors:
    .word 0

    .word Reset_Handler
    .weak Reset_Handler

    .word NMI_Handler
    .weak NMI_Handler

    .word HardFault_Handler
    .weak HardFault_Handler

    .word MemManage_Handler
    .weak MemManage_Handler

    .word BusFault_Handler
    .weak BusFault_Handler

    .word UsageFault_Handler
    .weak UsageFault_Handler

    .word 0

    .word SVCall_Handler
    .weak SVCall_Handler

    .word DebugMonitor_Handler
    .weak DebugMonitor_Handler

    .word 0

    .word PendSV_Handler
    .weak PendSV_Handler

    .word SysTick_Handler
    .weak SysTick_Handler
