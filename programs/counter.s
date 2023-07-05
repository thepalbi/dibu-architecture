IO_OUT_ADDR = 0xff
; main loop will shift for times, and go reverse
; r0 counter
; r1 1
; r2 light register
; r3 wait counter register
; initial values
mov r1 0x1
str [$IO_OUT_ADDR] r1
ShiftingLeft: mov r0 0x3
lsl r2 r2 r1 ; shift bits
sub r0 r0 r1 ; decrement pending shifts counter
str [$IO_OUT_ADDR] r2
call wait ; call wait routine to wait
jnz ShiftingLeft ; if we still have shift, jump
ShiftingRight: mov r0 0x3
lsr r2 r2 r1 ; shift bits
sub r0 r0 r1 ; decrement pending shifts counter
str [$IO_OUT_ADDR] r2
call wait ; call wait routine to wait
jnz ShiftingRight ; if we still have shift, jump
halt ; DELETE THIS LINE WHEN REALLY RUNNING
jmp ShiftingLeft
wait: mov r3 0xff
activeWaitLoop: mov r3 r3 ; noop
sub r3 r3 r1 ; decrement wait counter
jnz activeWaitLoop ; jump if counter still != 0
ret ; if counter zero ret
