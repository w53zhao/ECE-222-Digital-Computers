;*-------------------------------------------------------------------
;* Name:    	lab_4_program.s 
;* Purpose: 	A sample style for lab-4
;* Term:		Winter 2013
;*-------------------------------------------------------------------
				THUMB 								; Declare THUMB instruction set 
				AREA 	My_code, CODE, READONLY 	; 
				EXPORT 		__MAIN 					; Label __MAIN is used externally 
				EXPORT		EINT3_IRQHandler
				ENTRY 

__MAIN

; The following lines are similar to previous labs.
; They just turn off all LEDs
				LDR			R10, =LED_BASE_ADR		; R10 is a  pointer to the base address for the LEDs
				MOV 		R3, #0xB0000000		; Turn off three LEDs on port 1  
				STR 		R3, [r10, #0x20]
				MOV 		R3, #0x0000007C
				STR 		R3, [R10, #0x40] 	; Turn off five LEDs on port 2 

; This line is very important in your main program
; Initializes R11 to a 16-bit non-zero value and NOTHING else can write to R11 !!
				MOV			R11, #0xABCD		; Init the random number generator with a non-zero number
LOOP 			BL 			RNG  

				MOV			R8, R11
				MOV			R3, #0x00001388		; scale R8 to delay for proper amount of time
				SDIV		R8, R8, R3

ALT_FLASH		; LEDs 3-6 on
				MOV			R3, #4				; value to pass to port 2
				STR			R3, [R10, #0x40]
				MOV			R3, #0xB0000000		; value to pass to port 1
				STR			R3, [R10, #0x20]
				MOV			R0, #0x000009C4		;9C4
				BL			DELAY
				
				; LEDs 28-31, 2 on
				MOV			R3, #0x78			; value to pass to port 2
				STR			R3, [R10, #0x40]
				MOV			R3, #0xFF00			; value to pass to port 1
				STR			R3, [R10, #0x20]
				MOV			R0, #0x000009C4		;9C4	
				BL			DELAY

				SUBS		R8, #1
				TEQ			R8, #0				; check if R8 is 0 to exit loop
				BNE			ALT_FLASH
				
				MOV			R6, #1				; set R6 to check for interrupt
				
				LDR			R3, =ISER0			
				MOV			R2, #0x00200000		; bit 21 is set to 1
				STR			R2, [R3]
				
				LDR			R3, =IO2IntEnf
				MOV			R2, #0x00000400		; bit 10 is set to 1
				STR			R2, [R3]
				
				MOV			R9, #0				; counter to track time
				
START_TIMER		TEQ			R6, #0
				BEQ			A
				MOV 		R3, #0x00000000		
				STR 		R3, [R10, #0x20]
				STR 		R3, [R10, #0x40] 	
				MOV			R0, #0x00000271				;271
				BL			DELAY
				MOV			R3, #0xF0000000
				STR 		R3, [R10, #0x20]
				MOV 		R3, #0x000000FF
				STR 		R3, [R10, #0x40]
				MOV			R0, #0x00000271				;271
				BL			DELAY
				ADD			R9, #1						; counter increments every 0.0542s rather than 0.1 ms, scaled in later code
				B			START_TIMER
				
A				MOV			R7, #0xB0000000			; turn light off
				STR			R7, [R10, #0x20]				
				
				MOV			R4, #542				; factor to scale reflex time
				MUL			R9, R9, R4
				MOV			R8, R9					; put counter into register 8 for later use when displying time again

RESET			MOV			R9, R8					

				MOV			R7, #4					; counter to loop 4 times to go through all 32 bits
				
SHOW_TIME		MOV			R3, #0
				BFI			R3, R9, #0, #8			; take 8 bits from the right
				LSR			R9, #8
				BL			DISPLAY_NUM				; display
				MOV			R0, #0x4E20				
				BL			DELAY					; delay
				SUBS		R7, #1	
				TEQ			R7, #0
				BNE			SHOW_TIME
				
				MOV			R0, #0x7530				; extra 3s delay for a total of 5s
				BL			DELAY
				
				B			RESET	
				
				
;*------------------------------------------------------------------- 
; Subroutine RNG ... Generates a pseudo-Random Number in R11 
;*------------------------------------------------------------------- 
; R11 holds a random number as per the Linear feedback shift register (Fibonacci) on WikiPedia
; R11 MUST be initialized to a non-zero 16-bit value at the start of the program
; R11 can be read anywhere in the code but must only be written to by this subroutine
RNG 			STMFD		R13!,{R1-R3, R14} 	; Random Number Generator 
				AND			R1, R11, #0x8000
				AND			R2, R11, #0x2000
				LSL			R2, #2
				EOR			R3, R1, R2
				AND			R1, R11, #0x1000
				LSL			R1, #3
				EOR			R3, R3, R1
				AND			R1, R11, #0x0400
				LSL			R1, #5
				EOR			R3, R3, R1			; The new bit to go into the LSB is present
				LSR			R3, #15
				LSL			R11, #1
				ORR			R11, R11, R3
				LDMFD		R13!,{R1-R3, R15}

;*------------------------------------------------------------------- 
; Subroutine DELAY ... Causes a delay of 1ms * R0 times
;*------------------------------------------------------------------- 
; 		aim for better than 10% accuracy
DELAY			STMFD		R13!,{R2, R14}
; code to generate a delay of 0.1mS * R0 times
MultipleDelay	
				TEQ 		R0, #0
				MOV			R4, #130		;130
				
loop1
				SUBS 		R4, #1
				BNE			loop1
				SUBS		R0, #1
				BEQ			exitDelay
				BNE			MultipleDelay
exitDelay		LDMFD		R13!,{R2, R15}

DISPLAY_NUM		STMFD		R13!,{R1, R2, R14}			; from Lab 3		
				
				MOV			R5, #0						; clear R5
				BFI			R5, R3, #0, #5				; 5 bits to be displayed on port 2
				RBIT		R5, R5						; bits are reversed on port 2
				LSR			R5, #25						; only shift 25 to make room for bit 0 and bit 1
				LSR			R3, #5						; bit shift R3 so it contains only the 3 bits for port 1
				EOR			R5, #0xFFFFFFFF				; invert bits for port 2, since 0 is on and 1 is off
				STR			R5,	[R10, #0x40]			; display the 5 bits to port 2
				
				MOV			R5, #0						; clear R5
				BFI			R5, R3, #0, #1				; make room and insert 'bit 30' of 32-bit word		
				LSL			R3, #1						
				ADD			R3, R5						; add previous bit back, now there are bits 28-31
				BFI			R5, R3, #0, #4				; 3 (4 bits including bit 30) bits to be displayed on port 1
				RBIT		R5, R5						; port 1 is reversed
				EOR			R5, #0xFFFFFFFF				; invert bits for port 1, since 0 is on and 1 is off		
				STR			R5,	[R10, #0x20]			; display the 3 bits to port 1

				LDMFD		R13!,{R1, R2, R15}
				
; The Interrupt Service Routine MUST be in the startup file for simulation 
;   to work correctly.  Add it where there is the label "EINT3_IRQHandler
;
;*------------------------------------------------------------------- 
; Interrupt Service Routine (ISR) for EINT3_IRQHandler 
;*------------------------------------------------------------------- 
; This ISR handles the interrupt triggered when the INT0 push-button is pressed 
; with the assumption that the interrupt activation is done in the main program
EINT3_IRQHandler  	STMFD		R13!,{R4, R5, R14}

				MOV		R6, #0
				LDR 	R5, =IO2IntClr
				MOV		R4, #0x400						; bit 10 is set to 1
				STR		R4, [R5]
				
					LDMFD		R13!,{R4, R5, R15}


;*-------------------------------------------------------------------
; Below is a list of useful registers with their respective memory addresses.
;*------------------------------------------------------------------- 
LED_BASE_ADR	EQU 	0x2009c000 		; Base address of the memory that controls the LEDs 
PINSEL3			EQU 	0x4002C00C 		; Pin Select Register 3 for P1[31:16]
PINSEL4			EQU 	0x4002C010 		; Pin Select Register 4 for P2[15:0]
FIO1DIR			EQU		0x2009C020 		; Fast Input Output Direction Register for Port 1 
FIO2DIR			EQU		0x2009C040 		; Fast Input Output Direction Register for Port 2 
FIO1SET			EQU		0x2009C038 		; Fast Input Output Set Register for Port 1 
FIO2SET			EQU		0x2009C058 		; Fast Input Output Set Register for Port 2 
FIO1CLR			EQU		0x2009C03C 		; Fast Input Output Clear Register for Port 1 
FIO2CLR			EQU		0x2009C05C 		; Fast Input Output Clear Register for Port 2 
IO2IntEnf		EQU		0x400280B4		; GPIO Interrupt Enable for port 2 Falling Edge 
IO2IntClr		EQU		0x400280AC		; GPIO Interrupt Clear
ISER0			EQU		0xE000E100		; Interrupt Set-Enable Register 0 

				ALIGN 

				END 