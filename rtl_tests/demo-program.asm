IO_OUT_ADDR = 0x0ff
WAIT_COUNTER = 0x30
WAIT_VALUE = 0u255
; r1 contains the literal 1
mov r0 0d0
mov r1 0d1
; MAIN PROGRAM
; r0 contains is the remaining loop iterations counter
; r2 is the register to work with
; r3 is the compare register
; r7 is the discard register
; WAIT
; [$WAIT_COUNTER] contains the wait counter
mov r3 0d8
mov r2 0d1 ; set initial value in accumulator
str [$IO_OUT_ADDR] r2 ; initial write r2 to io out
; prepare call to wait
mov r7 $WAIT_VALUE
; str [$WAIT_COUNTER] r7
call Wait
; -------------------------------------------
; MAIN PROGRAM
; -------------------------------------------
ShiftLeft: lsl r2 r2 r1
str [$IO_OUT_ADDR] r2 ; write r2 to io out
; prepare call to wait
mov r7 $WAIT_VALUE
; str [$WAIT_COUNTER] r7
call Wait
; check if we've reached the left end
cmp r2 r3
jne ShiftLeft
; now we know we've reached the left end
ShiftRight: lsr r2 r2 r1
str [$IO_OUT_ADDR] r2 ; write r2 to io out
; prepare call to wait
mov r7 $WAIT_VALUE
; str [$WAIT_COUNTER] r7
call Wait
; check if we've reached the right end
cmp r2 r1
jne ShiftRight
; now we know we've reached the right end
jmp ShiftLeft
; -------------------------------------------
; WAIT
; -------------------------------------------
Wait: sub r7 r7 r1 ; decrement
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
mov r7 r7 ; nop
cmp r7 r0 ; substract zero to check equality
jne Wait
ret
