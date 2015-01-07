; ECE-222 Lab ... Winter 2013 term 
; Lab 3 sample code 
				THUMB 		; Thumb instruction set 
                AREA 		My_code, CODE, READONLY
                EXPORT 		__MAIN
				EXPORT		EINT3_IRQHandler
				
				ENTRY  
__MAIN

; The following lines are similar to Lab-1 but use a defined address to make it easier.
; They just turn off all LEDs 
				LDR			R10, =LED_BASE_ADR		; R10 is a permenant pointer to the base address for the LEDs, offset of 0x20 and 0x40 for the ports

				MOV 		R3, #0xB0000000		; Turn off three LEDs on port 1  
				STR 		R3, [r10, #0x20]
				MOV 		R3, #0x0000007C
				STR 		R3, [R10, #0x40] 	; Turn off five LEDs on port 2 
				MOV			R4, #0
				MOV			R0, #0
				MOV			R5, #0
				MOV			R7, #0
				MOV			R8, #0
				MOV			R12, #0
				
;COUNTER			BL			DISPLAY_NUM
;				B			COUNTER

; This line is very important in your main program
; Initializes R11 to a 16-bit non-zero value and NOTHING else can write to R11 !!
				MOV			R11, #0xABCD		; Init the random number generator with a non-zero number
loop 			BL 			RandomNum 
				
				;--------------------------------------------------------------------------------
				MOV			R0, R11					; delay R11 (random number) * 0.1ms
				BL			DELAY
				MOV			R7, #0x90000000			; turn light on
				STR			R7, [R10, #0x20]
				MOV			R9, #0					;initiate counter
				
POLL			LDR			R6, =FIO2PIN			; check input
				LDR			R6, [R6]				
				
				LSR			R6, #10					; put 10th bit of R6 into R8
				BFI			R8, R6, #0, #1				
				
				MOV			R0, #1					; 0.1 ms delay
				BL			DELAY
				ADD			R9, #1					; increase counter
				
				TEQ			R8, #0					; when INT0 is pressed, 10th bit becomes 0
				BNE			POLL
				
				MOV			R7, #0xB0000000			; turn light off
				STR			R7, [R10, #0x20]
				
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
				
				B			RESET					; put reaction time back into R9, display time again
				B			loop	
				;-----------------------------------------------------------------------------------

;
; Display the number in R3 onto the 8 LEDs
DISPLAY_NUM		STMFD		R13!,{R1, R2, R14}

; Usefull commaands:  RBIT (reverse bits), BFC (bit field clear), LSR & LSL to shift bits left and right, ORR & AND and EOR for bitwise operations
				
				
;--------------------------------------------------------------------------------				
				MOV 		R6, #0		


;loop3			MOV			R3, R6

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
				
				
;				MOV			R0, #0x03E8
;				BL			DELAY
;				ADD			R6, #1
;				TEQ			R6, #0x100
;				BNE			loop3
;---------------------------------------------------------------------------------				


				LDMFD		R13!,{R1, R2, R15}

;
; R11 holds a 16-bit random number via a pseudo-random sequence as per the Linear feedback shift register (Fibonacci) on WikiPedia
; R11 holds a non-zero 16-bit number.  If a zero is fed in the pseudo-random sequence will stay stuck at 0
; Take as many bits of R11 as you need.  If you take the lowest 4 bits then you get a number between 1 and 15.
;   If you take bits 5..1 you'll get a number between 0 and 15 (assuming you right shift by 1 bit).
;
; R11 MUST be initialized to a non-zero 16-bit value at the start of the program OR ELSE!
; R11 can be read anywhere in the code but must only be written to by this subroutine
RandomNum		STMFD		R13!,{R1, R2, R3, R14}

				AND			R1, R11, #0x8000
				AND			R2, R11, #0x2000
				LSL			R2, #2
				EOR			R3, R1, R2
				AND			R1, R11, #0x1000
				LSL			R1, #3
				EOR			R3, R3, R1
				AND			R1, R11, #0x0400
				LSL			R1, #5
				EOR			R3, R3, R1		; the new bit to go into the LSB is present
				LSR			R3, #15
				LSL			R11, #1
				ORR			R11, R11, R3
				
				LDMFD		R13!,{R1, R2, R3, R15}
				
				
				
				
				

;
;		Delay 0.1ms (100us) * R0 times
; 		aim for better than 10% accuracy
DELAY			STMFD		R13!,{R2, R14}
		;
		; code to generate a delay of 0.1mS * R0 times
		;

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
				

LED_BASE_ADR	EQU 	0x2009c000 		; Base address of the memory that controls the LEDs 
PINSEL3			EQU 	0x4002c00c 		; Address of Pin Select Register 3 for P1[31:16]
PINSEL4			EQU 	0x4002c010 		; Address of Pin Select Register 4 for P2[15:0]
FIO2PIN			EQU		0x2009c054		
;	Usefull GPIO Registers
;	FIODIR  - register to set individual pins as input or output
;	FIOPIN  - register to read and write pins
;	FIOSET  - register to set I/O pins to 1 by writing a 1
;	FIOCLR  - register to clr I/O pins to 0 by writing a 1

				ALIGN 

				END 


;--------------------------------- POST-LAB QUESTIONS ------------------------------------------
; Question 1
; 8 bits --> 0.0255 s
; 16 bits --> 6.5535 s
; 24 bits --> 1677.7215 s
; 32 bits --> 429496.7295 s
;
; Question 2
; According to Google, typical human reaction time is 150-300 milliseconds
; Therefore, 16 bits is the best for this task