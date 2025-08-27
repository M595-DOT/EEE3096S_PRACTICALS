/*
 * assembly.s
 *
 */
 
 @ DO NOT EDIT
	.syntax unified
    .text
    .global ASM_Main
    .thumb_func

@ DO NOT EDIT
vectors:
	.word 0x20002000
	.word ASM_Main + 1

@ DO NOT EDIT label ASM_Main
ASM_Main:

	@ Some code is given below for you to start with
	LDR R0, RCC_BASE  		@ Enable clock for GPIOA and B by setting bit 17 and 18 in RCC_AHBENR
	LDR R1, [R0, #0x14]
	LDR R2, AHBENR_GPIOAB	@ AHBENR_GPIOAB is defined under LITERALS at the end of the code
	ORRS R1, R1, R2
	STR R1, [R0, #0x14]

	LDR R0, GPIOA_BASE		@ Enable pull-up resistors for pushbuttons
	MOVS R1, #0b01010101
	STR R1, [R0, #0x0C]
	LDR R1, GPIOB_BASE  	@ Set pins connected to LEDs to outputs
	LDR R2, MODER_OUTPUT
	STR R2, [R1, #0]
	MOVS R2, #0         	@ NOTE: R2 will be dedicated to holding the value on the LEDs

@ TODO: Add code, labels and logic for button checks and LED patterns


main_loop:

	@ SW0 and SW1 pressed
    LDR   R3, [R0, #0x10]    @ read GPIOA_IDR
    MOVS R4, #0x03 @Bitmask for SW0 and SW1
    ANDS R3, R4		@Remove other bits and leave the bitsfor SW0 and SW1 HIGH
    CMP R3, #0  @compare to zero as active low pin
    BEQ SW0_SW1_pressed

	@ SW0 pressed
    LDR   R3, [R0, #0x10]    @ read GPIOA_IDR
    MOVS R4, #0x01 @Bitmask for SW0
    ANDS R3, R4		@Remove other bits and leave the bit for SW0 HIGH
    CMP R3, #0 @compare to zero as active low pin
    BEQ increment

    @ SW1 pressed
    LDR   R3, [R0, #0x10]    @ read GPIOA_IDR
    MOVS R4, #0x02   		@Bitmask for SW1
    ANDS R3, R4	     @Remove other bits and leave the bit for SW2 HIGH
    CMP R3, #0       @compare to zero as active low pin
    BEQ SW1_pressed

    @ SW2 pressed
    LDR   R3, [R0, #0x10]    @ read GPIOA_IDR
    MOVS R4, #0x04 @Bitmask for SW2 to only focus on SW2
    ANDS R3, R4 @Remove other bits and leave the bit for SW2 HIGH
    CMP R3, #0  @compare to zero as active low pin
 	BEQ SW2_pressed @Go to label SW2_pressed if true

 	@ SW3 pressed
    LDR   R3, [R0, #0x10]    @ read GPIOA_IDR
    MOVS R4, #0x08 @Bitmask for SW3 to only focus on SW3
    ANDS R3, R4		@Remove other bits and leave the bit for SW3 HIGH
    CMP R3, #0  @compare to zero as active low pin
	BEQ SW3_pressed @Go to label SW3_pressed if true


	@default
	ADDS R2, R2, #1 @ Increment count
	B write_leds

increment:
	ADDS R2, R2, #2 @ Increment count by 2
	B write_leds

SW2_pressed:
    MOVS  R2, #0xAA @Set the value in register R2 0xAA
    STR   R2, [R1, #0x14] @Store the actual value in R1 to R2
    B     main_loop

SW3_pressed:
	MOV R3, R2
	STR R3, [R1, #0x14]
sw3_loop:
	LDR   R3, [R0, #0x10] @ read GPIOA_IDR
    MOVS R4, #0x08
    ANDS R3, R4		@remove the bits we are not focussed on
    CMP R3, #0 @compare to zero as active low pin
	BEQ SW3_pressed

SW0_SW1_pressed:
    ADDS R2, R2, #2 @ increment by 2
    STR  R2, [R1, #0x14]
    LDR  R5, =SHORT_DELAY_CNT @ use short delay to make it "faster"
    LDR  R5, [R5]
    B    delay_loop

write_leds:
	STR R2, [R1, #0x14]
   	LDR R5, =LONG_DELAY_CNT
    LDR R5, [R5]
    B delay_loop

    SW1_pressed:
    ADDS R2, R2, #1
    STR R2, [R1, #0x14]
   	LDR R5, =SHORT_DELAY_CNT
    LDR R5, [R5]


	@Decrement value in R5 until it reaches zero, then branch to main loop when done
   delay_loop:
    SUBS R5, R5, #1
    CMP R5, #0
    BNE delay_loop @
    B main_loop

	STR R2, [R1, #0x14]
	B main_loop

@ LITERALS; DO NOT EDIT
	.align
RCC_BASE: 			.word 0x40021000
AHBENR_GPIOAB: 		.word 0b1100000000000000000
GPIOA_BASE:  		.word 0x48000000
GPIOB_BASE:  		.word 0x48000400
MODER_OUTPUT: 		.word 0x5555

@ TODO: Add your own values for these delays
LONG_DELAY_CNT: 	.word 1400000
SHORT_DELAY_CNT: 	.word 600000
