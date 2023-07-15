IO_OUT_ADDR = 0xff
again: mov r0 0b00001010
str [$IO_OUT_ADDR] r0
jmp wait_routine
after_wait_1: mov r0 0b00000101
str [$IO_OUT_ADDR] r0
jmp wait_routine_2
after_wait_2: jmp again
wait_routine: mov r6 0u255
mov r2 0d0
wait_loop: mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
addi r2 0d1 ; time--
cmp r6 r2 ; time == 0
jne wait_loop
jmp after_wait_1
wait_routine_2: mov r6 0u255
mov r2 0d0
wait_loop_2: mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
mov r4 r5; nop
addi r2 0d1 ; time--
cmp r6 r2 ; time == 0
jne wait_loop_2
jmp after_wait_2
