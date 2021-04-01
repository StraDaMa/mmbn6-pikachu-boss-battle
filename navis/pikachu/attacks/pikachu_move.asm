pikachu_move:
	push r7, r14
	ldr r1, =@@pikachu_move_pool
	ldrb r0, [r7, 0x00]
	ldr r1, [r0, r1]
	mov r14, r15
	bx r1
	pop r7, r15
	.pool
@@pikachu_move_pool:
	.word pikachu_move_start|1
	.word pikachu_move_end|1
	.word pikachu_move_end_idle|1

pikachu_move_start:
	push r4,r14
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
	bl object_can_move
	beq @@cantmove
;Get move parameters based on which side pikachu is on
	ldrb r0, [r5,0x16]
	ldr r1, =pikachu_move_parameters
	lsl r0, r0, 0x03
	add r0, r0, r1
	ldr r2, [r0, 0x00]
	ldr r3, [r0, 0x04]
;Judgeman's panel choosing routine (should be good enough)
	ldr r1, =judgeman_choose_panel|1
	mov r14, r15
	bx r1
	tst r0, r0
	bne @@validpanel
@@cantmove:
	mov r0, 0x08
	strh r0, [r7, 0x00]
	b @@endroutine
@@validpanel:
	strb r0, [r5, 0x14]
	strb r1, [r5, 0x15]
	bl object_reserve_panel
	mov r0, 0x40
	bl object_set_flag
	mov r0, PIKACHU_ANIMATION_MOVE_OUT
	strb r0, [r5, 0x10]
	mov r0, 0x02
	strb r0, [r7, 0x10]
@@step_initialized:
	ldrb r0, [r7, 0x10]
	sub r0,1
	strb r0, [r7, 0x10]
	bge @@endroutine
	mov r0, 0x04
	strh r0, [r7, 0x00]
@@endroutine:
	pop r4,r15

pikachu_move_end:
	push r4,r14
	ldrb r0,[r7, 0x01]
	tst r0,r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0,[r7, 0x01]
	ldrb r0, [r5, 0x14]
	ldrb r1, [r5, 0x15]
	strb r0, [r5, 0x12]
	strb r1, [r5, 0x13]
	bl object_remove_panel_reserve
	bl object_set_coordinates_from_panels
	bl object_update_collision_panels
	mov r0, 0x40
	bl object_clear_flag
	mov r0, PIKACHU_ANIMATION_MOVE_IN
	strb r0, [r5, 0x10]
	mov r0, 0x04
	strh r0, [r7, 0x10]
@@step_initialized:
	ldrh r0, [r7, 0x10]
	sub r0, 0x01
	strh r0, [r7, 0x10]
	bgt @@endroutine
	mov r0, 0x08
	strh r0, [r7, 0x00]
@@endroutine:
	pop r4,r15

pikachu_move_end_idle:
	push r14
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04 
	strb r0, [r7, 0x01]
	mov r0, PIKACHU_ANIMATION_IDLE
	strb r0, [r5, 0x10]
	mov r0, 0x14
	strh r0, [r7, 0x10]
	b @@endroutine
@@step_initialized:
	ldrh r0, [r7,0x10]
	sub r0, 0x01
	strb r0, [r7,0x10]
	bgt @@endroutine
	bl object_exit_attack_state
@@endroutine:
	pop r15
.pool
;eof