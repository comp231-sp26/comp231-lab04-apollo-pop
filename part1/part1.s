.text
.global _start

_start:                             
          // initialization code here
        ldr r2, =0xFF200050    	// key register address
   	   	ldr r3, =0xFF200020    	// hex0 address
    	mov r5, #0             	// current displayed number

loop:
		ldr r4, [r2]           	// read keys
    	and r0, r4, #1			// check key0
    	cmp r0, #0
    	bne key0
    	and r0, r4, #2			// check key1
    	cmp r0, #0
   		bne key1
   		and r0, r4, #4			// check key2
   		cmp r0, #0
   		bne key2
    	and r0, r4, #8			// check key3
    	cmp r0, #0
   		bne key3
        b loop
          
key0:
    	mov r5, #0				// reset to 0
     	mov r0, r5				
    	bl seg7_code			// get bit pattern
    	str r0, [r3]			// display
wait0:
    	ldr r0, [r2]
    	and r0, r0, #1			// wait for release
    	cmp r0, #0
    	bne wait0
    	b loop

key1:
    	add r5, r5, #1			// increment by 1
    	mov r0, r5
    	bl seg7_code
    	str r0, [r3]
wait1:
    	ldr r0, [r2]			// decrease by 1
    	and r0, r0, #2
    	cmp r0, #0
    	bne wait1
    	b loop

key2:
    	sub r5, r5, #1			// blank display
    	mov r0, r5
    	bl seg7_code
    	str r0, [r3]
wait2:
    	ldr r0, [r2]
    	and r0, r0, #4
    	cmp r0, #0
    	bne wait2
    	b loop

key3:
    	mov r0, #0 
   	    str r0, [r3]
wait3:
    	ldr r0, [r2]
    	and r0, r0, #8
    	cmp r0, #0
    	bne wait3
    	b loop

bit_codes:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment

seg7_code:  ldr     r1, =bit_codes  
            ldrb    r0, [r1, r0]    
            bx      lr
            
/* display r5 on hex1-0, r6 on hex3-2 and r7 on hex5-4 */
display:    ldr     r8, =0xff200020 // base address of hex3-hex0
			mov		r0, #0			// set r0 to 0
            bl      seg7_code    	// returns r0 converted to a bit code in r0   
            str		r0, [r8]   
          
.end