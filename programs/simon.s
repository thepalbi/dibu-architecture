; general dibu mem addresses
IO_IN = 0xfe
IO_OUT = 0xff
; program variables
READ_VALUE_ADDR = 0xf0
RANDOM_VALUES_LEFT_ADDR = 0xf1
RANDOM_SEED = 0xf2
; simon mem addresses
ANSWERS = 0x20
EXPECTED = 0x40 
RANDOM_VALUES = 0x60
; immediate variables
SHORT_WAIT_TIME = 0x2
LONG_WAIT_TIME = 0x4
; -------------
; main
; - r0 Current pos
; - r1 Current level 
; -------------
main: mov r0 0x00 ; init actual_pos
mov r1 0x00 ; init iteration
mov r5 $RANDOM_VALUES ; load RANDOM VALUES pointer
mov r2 0d1 ; load value 00000001
str [r5] r2 ; str value in pointer position 
addi r5 0d1
mov r2 0d2 ; load value 00000010
str [r5] r2
addi r5 0d1
mov r2 0d4 ; load value 00000100
str [r5] r2
addi r5 0d1
mov r2 0d8 ; load value 00001000
str [r5] r2
; load random sed
mov r2 0xd9 ; random seed value
str [$RANDOM_SEED] r2 ; random_seed = 0xd9
jmp generate
; -------------
; GENERATE
; uses r0, r1, r2, r4
; -------------
generate: call get_random ; calculate new random into r2
mov r5 0d3 ; load reg with mask: 00000011
and r2 r2 r5 ; and against random value
mov r5 $RANDOM_VALUES ; load RANDOM VALUES pointer
add r5 r5 r2 ; add offset of random
load r5 [r5] ; r5 <= random_values[r2]
mov r4 $EXPECTED ; load memory pos from expected
add r4 r4 r1 ; add iteration offset
str [r4] r5; store rand value in memory offset
addi r1 0d1 ; increment iteration
jmp show
; -------------
; GET_RANDOM
; returns a random in r2, only uses r2
; -------------
get_random: load r2 [$RANDOM_SEED]
rnd r2 ; r2 = random(r2)
str [$RANDOM_SEED] r2 ; save last random
ret ; return r2
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
call wait_routine
mov r7 0d0
str [$IO_OUT] r7 ; Show zero
call wait_routine
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
load r6 [$READ_VALUE_ADDR] ; r6 <= read_value
str [r5] r6 ; use the value from r6 as input
addi r5 0d1 ; increment pointer to answer
addi r0 0d1 ; increment actual_pos
jmp input_loop
; -------------
; WAIT_FOR_INPUT
; uses r0, r1, r4, r5
; -------------
wait_for_input: load r2 [$IO_IN] ; load input
mov r7 0x0 ; load reg with 0
cmp r2 r7 ; input == 0?
jne register_input ; if not equal, then register input
call short_wait_routine ; if 0, then short wait
jmp wait_for_input ; check input again
register_input: str [$IO_OUT] r2 ; show input value in output
call wait_routine
mov r7 0x0 ; load reg with 0
str [$IO_OUT] r7 ; shutdown output
str [$READ_VALUE_ADDR] r2 ; read_value <= r2
ret
; -------------
; CHECK ROUTINE
; uses r6, r5, r4, r3
; -------------
check_answers: mov r4 $EXPECTED ; load pointer to expected
mov r5 $ANSWERS ; load pointer to answers
mov r0 0x0 ; reset current pos
check_loop: cmp r0 r1 ; compare if already checked everything
je check_answer_ok ; if so add a value to the array
load r6 [r4] ; load expected
load r7 [r5] ; load current
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
check_answer_ok: call display_ok_answer
call wait_routine ; call wait 3 times to give a pause between levels
call wait_routine
jmp generate
; -------------
; DISPLAY WRONG ANSWER ROUTINE
; uses r5
; -------------
display_wrong_answer: mov r5 0d2 ; counter = 2
display_wrong_answer_loop: mov r7 0x0f
str [$IO_OUT] r7 ; io_out = 1111
call wait_routine ; call short wait
mov r7 0x0
str [$IO_OUT] r7 ; io_out = 0
call wait_routine ; call short wait
addi r5 0d-1 ; counter--
mov r7 0d0
cmp r7 r5
jne display_wrong_answer_loop ; if counter != 0
mov r7 0x0
str [$IO_OUT] r7 ; reset io out to no leds
ret
; -------------
; display good answer
; takes r1 wait iterations
; -------------
display_ok_answer: mov r7 0x03
str [$IO_OUT] r7 ; io_out = 0011
call wait_routine ; call short wait
mov r7 0b00001100
str [$IO_OUT] r7 ; io_out = 0
call wait_routine ; call short wait
mov r7 0x03
str [$IO_OUT] r7 ; io_out = 0011
call wait_routine ; call short wait
mov r7 0b00001100
str [$IO_OUT] r7 ; io_out = 0
call wait_routine ; call short wait
ret
; -------------
; WAIT ROUTINE
; takes r1 wait iterations
; -------------
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
; -------------
; WAIT ROUTINE
; takes r1 wait iterations
; -------------
short_wait_routine: mov r6 0u20
short_wait_loop: mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
mov r6 r6; nop
addi r6 0d-1 ; time--
mov r7 0d0
cmp r6 r7 ; time == 0
jne short_wait_loop
ret
