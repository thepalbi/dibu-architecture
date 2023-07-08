; general dibu mem addresses
IO_IN = 0xfe
IO_OUT = 0xff
; simon mem addresses
ANSWERS = 0xc0 ; from here, 4 addresses for each answer until 0xc3
EXPECTED = 0xc4
CURRENT_CHALLENGE = 0xc5 ; two words for current challenge, easier to handle
;       7      4  3      0
; 0xc5: [digit 1, digit 0]
;       [digit 3, digit 2]
;;;;;;;;;;;;;;;
; conventions
; - returns are always in r6
; - r7 is a discard register
;;;;;;;;;;;;;;;
; -------------
; main
; -------------
main: mov r4 0x81 ; challenge: 1 4 3 3
mov r3 0x44
mov r5 $CURRENT_CHALLENGE
str [r5] r4
addi r5 0d1
str [r5] r3
call debug_signal ; debug signal
call display_challenge
call debug_signal ; debug signal
end: jmp end
; -------------
; CHECK ROUTINE - returns 0 if ok, 1 if not
; uses r6, r5, r4, r3
; -------------
check_answers: mov r6 0x4
mov r5 0x0 ; r5 is the idx in each 4-element array
; bring first addresses
; r4 and r3 are used for checking equality
check_answers_loop: mov r4 $ANSWERS ; move base addr
add r4 r4 r5 ; increment ansers += idx
load r4 [r4] ; r4 = answers[]
mov r3 $EXPECTED ; move base addr
add r3 r3 r5 ; increment expected += idx
load r3 [r3] ; r3 = expected[idx]
cmp r3 r4 ; check expected[idx] == answers[idx]
jne check_answers_error ; return -1
addi r5 0d1 ; idx ++
cmp r5 r6 ; idx == 4, means we've compared all
je check_answers_ok
jmp check_answers_loop
check_answers_error: mov r6 0x1
ret
check_answers_ok: mov r6 0x0
ret
; -------------
; DISPLAY CHALLENGE ROUTINE
; uses r6, r5
; -------------
display_challenge: load r5 [$CURRENT_CHALLENGE] ; r5 = current_challenge
str [$IO_OUT] r5 ; IO_OUT = current_challenge[0]
call display_challenge_wait
mov r6 0x4
lsr r5 r5 r6 ; r5 = current_challenge >> 4
str [$IO_OUT] r5 ; IO_OUT = current_challenge[1]
call display_challenge_wait
mov r5 $CURRENT_CHALLENGE
addi r5 0d1
load r5 [r5] ; r5 = current_challenge_1
str [$IO_OUT] r5 ; IO_OUT = current_challenge[2]
call display_challenge_wait
mov r6 0x4
lsr r5 r5 r6 ; r5 = current_challenge_1 >> 4
str [$IO_OUT] r5 ; IO_OUT = current_challenge[3]
call display_challenge_wait
ret
display_challenge_wait: mov r1 0d4 ; long wait
call wait_routine
mov r6 0x0
str [$IO_OUT] r6 ; IO_OUT = 0
mov r1 0d2 ; short wait displaying zero
call wait_routine
ret
; -------------
; WAIT ROUTINE
; takes r1 wait iterations
; -------------
wait_routine: mov r7 r7; nop
mov r7 r7; nop
mov r7 r7; nop
mov r7 r7; nop
addi r1 0d-1 ; time--
mov r7 0x0
cmp r1 r7 ; time == 0
jne wait_routine
ret
debug_signal: mov r7 0x0d
str [$IO_OUT] r7 ; IO_OUT = de for debug
mov r7 r7 ; nop
mov r7 0x0e
str [$IO_OUT] r7 ; IO_OUT = de for debug
mov r7 r7 ; nop
ret
