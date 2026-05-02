.text
.global _start

_start:                             
		ldr r2, =0xFF20005C        // edge capture register
    	ldr r3, =0xFF200020        // hex address
    	ldr r4, =0xFFFEC600        // timer base address
    	mov r5, #0                 // hundredths
    	mov r6, #0                 // running flag
    	mov r7, #0                 // seconds
    
    	ldr r0, =2000000          
    	str r0, [r4]               // load register
    	mov r0, #0b011             // e=1, a=1
    	str r0, [r4, #8]           // control register

loop:
        // display hundredths on hex0 hex1
        mov r0, r5
        bl DIVIDE                  
        mov r8, r1                 // save tens
        bl seg7_code               // ones bit pattern
        mov r9, r0                 // save ones pattern
        mov r0, r8
        bl seg7_code               // tens bit pattern
        lsl r0, r0, #8             // shift to hex1
        orr r10, r0, r9            // hex0 plus hex1 combined in r10
        
        // display seconds on hex2 hex3
        mov r0, r7
        bl DIVIDE
        mov r8, r1
        bl seg7_code
        mov r9, r0
        mov r0, r8
        bl seg7_code
        lsl r0, r0, #8             // shift tens to hex3 
        orr r0, r0, r9             // combine seconds digits
        lsl r0, r0, #16            // shift to hex2 hex3
        orr r0, r0, r10            // combine all 4 digits
        str r0, [r3]               // display
        
        ldr r0, [r2]
        cmp r0, #0
        beq check_timer
        eor r6, r6, #1             // toggle running
        str r0, [r2]               // clear edge 

check_timer:
        cmp r6, #0
        beq loop
        
        ldr r0, [r4, #0xC]         // interrupt status
        and r0, r0, #1
        cmp r0, #0
        beq loop
        
        mov r0, #1
        str r0, [r4, #0xC]         // clear f bit
        
        add r5, r5, #1             // increment hundredths
        cmp r5, #100
        blt loop
        mov r5, #0                 // reset hundredths
        add r7, r7, #1             // increment seconds
        cmp r7, #60
        blt loop
        mov r7, #0                 // wrap second
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
