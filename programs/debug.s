IO_OUT_ADDR = 0xff
again: mov r0 0b00001010
str [$IO_OUT_ADDR] r0
call wait_routine
mov r0 0b00000101
str [$IO_OUT_ADDR] r0
call wait_routine
jmp again
wait_routine: mov r6 0u10
mov r7 0d0
wait_loop: mov r7 r7; nop
mov r7 r7; nop
mov r7 r7; nop
mov r7 r7; nop
mov r7 r7; nop
mov r7 r7; nop
mov r7 r7; nop
mov r7 r7; nop
mov r7 r7; nop
mov r7 r7; nop
mov r7 r7; nop
mov r7 r7; nop
mov r7 r7; nop
mov r7 r7; nop
mov r7 r7; nop
mov r7 r7; nop
mov r7 r7; nop
mov r7 r7; nop
mov r7 r7; nop
addi r7 0d1 ; time--
cmp r6 r7 ; time == 0
jne wait_loop
ret
