IO_OUT = 0xff
; this program should keep r2 as the random number register, always iterating over it
mov r2 0xd9 ; random seed
main: rnd r2 ; r2 = random
mov r3 0x0f ; mask
and r3 r2 r3 ; r3 = random & mask
str [$IO_OUT] r3 ; io_out = r3
call wait_routine ; wait
jmp main ; repeat
wait_routine: mov r6 0u255
wait_loop: mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
addi r6 0d-1 ; time--
mov r7 0d0
cmp r6 r7 ; time == 0
jne wait_loop
ret
