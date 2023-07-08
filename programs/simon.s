; general dibu mem addresses
IO_IN = 0xfe
IO_OUT = 0xff
ANSWERS = 0xc0 ; from here, 4 addresses for each answer until 0xc3
EXPECTED = 0xc4
;;;;;;;;;;;;;;;
; call conventions
; - returns are always in r6
;;;;;;;;;;;;;;;
; -------------
; main
; -------------
main: mov r5 0x0 ; idx = 0
mov r3 0xde
load_test_answers: mov r4 $ANSWERS ; r4 = answers base addr
add r4 r4 r5 ; r4 += idx
str [r4] r3 ; answers[idx] = 0xde
mov r4 $EXPECTED ; r4 = expected base addr
add r4 r4 r5 ; r4 += idx
str [r4] r3 ; expected[idx] = 0xde
addi r5 0d1 ; idx++
mov r7 0d4
cmp r5 r7 ; jmp if idx < 4
jn load_test_answers
mov r6 0xcc
str [$IO_OUT] r6 ; signal calling check_answers
call check_answers
str [$IO_OUT] r6 ; io_out = check_answers()
mov r6 0xcd
str [$IO_OUT] r6 ; signal already shown answer
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
