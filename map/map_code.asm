lans_room_start_pikachu_battle:
	push r14
	ldr r0, =lans_room_pikachu_battle
	mov r1, 0x01
	bl ow_begin_battle
	mov r0,0x2C
	mov r1,0x10
	bl screen_transition_begin
	mov r0, 0x00
	pop r15
	.pool
;eof