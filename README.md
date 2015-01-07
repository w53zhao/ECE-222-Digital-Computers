Developed and debugged using Keil μVision4 IDE, ran on ARM MCB1700 board with LPC1768 microcontroller unit.

These labs were done for the course ECE 222 - Digital Computers at the University of Waterloo.

-----------------------------------------------------------------------------------------------------------------------------
Lab 1: Flashing LED
-----------------------------------------------------------------------------------------------------------------------------
Objective: Complete, assemble, and download a simple assembly language program.

What to do: 
- Write some THUMB assembly language instructions
- Use different memory addressing modes
- Test and debug code on ARM board
- Use on-board RAM instead of Flash memory
- Flash LED (Light Emitting Diode) at approximately 1 Hz frequency

-----------------------------------------------------------------------------------------------------------------------------
Lab 2: Subroutines and Parameter Passing
-----------------------------------------------------------------------------------------------------------------------------
Objective: Practice subroutine calling and parameter passing by implementing a Morse code system.

What to do:
- Turn one LED into a Morse code transmitter that blinks in Morse code for a five character word
- Implement subroutines LED_ON (turn LED on), LED_OFF (turn LED off), DELAY (takes parameter Rn and delays for Rn*500 ms), CHAR2MORSE (converts characters to Morse by using a Morse LUT)

----------------------------------------------------------------------------------------------------------------------------
Lab 3: Input/Output Interfacing
----------------------------------------------------------------------------------------------------------------------------
Objective: Learn how to use peripherals connected to a microprocessor by setting up and using Input/Output ports.

What to do:
- Implement reflex meter to measure user response to event accurate to one tenth of a millisecond
- Initally all LEDs are off, one LED turns on after a random amount of time (2-10 seconds)
- Counter increments after LED turns on and before user presses input button
- Use polling method to determine when input button is pressed
- 32 bit number representing response time sent to 8 LEDs in seperate bytes with 2s delay between each group

Demo:
- Simple counter that increments indefinitely from 0x00 to 0xFF to demonstrate correct manipulation and handling of bits
- Reflex meter

----------------------------------------------------------------------------------------------------------------------------
Lab 4: Interrupt Handling
----------------------------------------------------------------------------------------------------------------------------
Objective: Learn about interrupts and trigger interrupt service routine.

What to do: 
- Implement reflex meter from Lab 3 with an interrupt instead of polling
