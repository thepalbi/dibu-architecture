; general dibu mem addresses
IO_IN = 0xfe
IO_OUT = 0xff
; simon mem addresses
ANSWERS = 0x20 ; values from user
EXPECTED = 0x40 ; random values generated
; immediate variables
SHORT_WAIT_TIME = 0x2
LONG_WAIT_TIME = 0x4
; -------------
; main
; - r0 Current pos
; - r1 Current iteration 
; -------------
main: mov r0 0x00 ; init actual_pos
mov r1 0x00 ; init iteration
jmp generate

; -------------
; GENERATE
; uses r0, r1, r2, r4
; -------------
generate: mov r2 0x01 ; generate random not random
mov r4 EXPECTED ; load memory pos from expected
add r4 r4 r0 ; add iteration offset
str [r4] r2; store rand value in memory offset
addi r1 0d1 ; increment iteration
jmp show

; -------------
; SHOW
; uses r0, r1, r4, r5
; -------------
show: mov r4 $EXPECTED ; init pointer to expected
mov r0 0x0 ; init actual_pos
show_loop: cmp r0 r1 ; compare iteration vs current pos
je play ; if equal jump to play since we showed everything
load r5 [r4] ; bring expected value from memory
str [$IO_OUT] r5 ; Show output
call display_challenge_wait
addi r0 0d1 ; increment current pos
addi r4 0d1 ; increment pointer to expected
jmp show_loop

; -------------
; PLAY
; uses r0, r1, r4, r5
; -------------
play: mov r5 $ANSWERS
mov r0 0x00  ; init actual_pos
input_loop: cmp r0 r1 ; compare actual_pos and iteration
je check_answers ; if equal then check answers
call wait_for_input ; wait for user input
str [r5] r4 ; use the value from r4 as input
addi r5 0d1 ; increment pointer to answer
addi r0 0d1 ; increment actual_pos
jmp input_loop

; -------------
; WAIT_FOR_INPUT
; uses r0, r1, r4, r5
; -------------
wait_for_input: load r6 [$IO_IN] ; load input
mov r7 0x0 ; load reg with 0
cmp r6 r7 ; compare input to 0
jne register_input ; if not equal, then register input
call wait_routine ; if 0, then wait
jmp wait_for_input ; check input again

register_input: str [$IO_OUT] r6 ; show input value in output
call wait_routine
mov r7 0x0 ; load reg with 0
str [$IO_OUT] r7 ; shutdown output
ret

; -------------
; CHECK ROUTINE
; uses r6, r5, r4, r3
; -------------
check_answers: mov r4 $EXPECTED ; load pointer to expected
mov r5 $ANSWERS ; load pointer to answers
mov r0 0x0 ; reset current pos
check_loop: cmp r0 r1 ; compare if already checked everything
je generate ; if so add a value to the array
load r6 r4 ; load expected
load r7 r5 ; load current
cmp r6 r7 
jne failed ; if not equal then error
addi r4 0d1 ; increment pointer for expected
addi r5 0d1 ; increment pointer for answer
addi r0 0d1 ; increment current pos
jmp check_loop


failed: mov r0 0x0 ; reset current pos
mov r1 0x0 ; reset iteration
call display_wrong_answer
jmp main

; -------------
; DISPLAY WRONG ANSWER ROUTINE
; uses r6
; -------------
display_wrong_answer: mov r6 0x4 ; times_left = 4
display_wrong_answer_loop: mov r7 0x0f
str [$IO_OUT] r7 ; io_out = 1111
mov r1 $SHORT_WAIT_TIME
call wait_routine ; call short wait
mov r7 0x0
str [$IO_OUT] r7 ; io_out = 0
mov r1 $SHORT_WAIT_TIME
call wait_routine ; call short wait
addi r6 0d-1 ; times_left --
mov r7 0x0
cmp r6 r7 ; times_left == 0
jne display_wrong_answer_loop
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
