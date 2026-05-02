.text
.global _start

_start:
    	ldr r2, =0xFF20005C        // edge capture register
    	ldr r3, =0xFF200020        // HEX display address
    	ldr r4, =0xFFFEC600        // timer base address
    	mov r5, #0                 // count = 0
    	mov r6, #0                 // running flag 
    

	    ldr r0, =50000000          // 0.25 seconds at 200MHz
    	str r0, [r4]               // write to load register (offset 0)
    	mov r0, #0b011             // e=1 a=1 i=0
    	str r0, [r4, #8]           // write to control register

loop:
		mov r0, r5
    	bl DIVIDE
    	mov r8, r1
    	bl seg7_code
    	mov r9, r0
    	mov r0, r8
    	bl seg7_code
    	lsl r0, r0, #8
    	orr r0, r0, r9
    	str r0, [r3]
    

	    ldr r0, [r2]
    	cmp r0, #0
    	beq check_timer
    	eor r6, r6, #1             // toggle running
    	str r0, [r2]               // clear edge

check_timer:
    	cmp r6, #0                 // if not running, skip
    	beq loop
    
    	ldr r0, [r4, #0xC]         // read interrupt status
    	and r0, r0, #1             // check f bit
    	cmp r0, #0
    	beq loop                   // timer not done yet, loop
    
    	mov r0, #1                 // clear f bit
    	str r0, [r4, #0xC]
    
    	add r5, r5, #1             // increment count
    	cmp r5, #100               // check if 99
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
