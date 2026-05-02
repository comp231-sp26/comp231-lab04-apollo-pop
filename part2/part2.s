.text
.global _start

_start:                             
        // initialization code here
		ldr r2, =0xFF20005C    	// edge capture register
   	   	ldr r3, =0xFF200020    	// hex0 address
    	mov r5, #0             	// current displayed number
        mov r6, #0				// running flag


loop:
    	mov r0, r5
    	bl DIVIDE     
    	mov r8, r1				// save tens digit
    	bl seg7_code
    	mov r9, r0				// save ones digit
    	mov r0, r8				// load tens
    	bl seg7_code			
    	lsl r0, r0, #8			// shit to hex1
    	orr r0, r0, r9			// combine with hex0
    	str r0, [r3]			// display
        
        ldr r0, [r2]			// read edge capture
		cmp r0, #0
    	beq do_delay			// did not capture
    	eor r6, r6, #1        	// running
    	str r0, [r2]			// clear edge

do_delay:
		cmp r6, #0				// if not running loop
        beq loop
        ldr r7, =200000000
sub_loop: subs r7, r7, #1    // subtract one, set status
		  bne sub_loop
          add r5, r5, #1		// increment count
          cmp r5, #100			// check if 99
          blt loop
          mov r5, #0
          b loop
                   
DIVIDE: MOV     R1, #0

CONT:   CMP     R0, #10
        BLT     DIV_END
        SUB     R0, R0, #10
        ADD     R1, R1, #1
        B       CONT

DIV_END:   
        BX      LR


bit_codes:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment

seg7_code:  ldr     r1, =bit_codes  
            ldrb    r0, [r1, r0]    
            bx      lr              
          
.end
