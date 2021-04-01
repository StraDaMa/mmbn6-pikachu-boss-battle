@PIKACHU_THUNDERBALL_STATE_BEGIN equ 0x00
@PIKACHU_THUNDERBALL_STATE_ATTACK equ 0x04
@PIKACHU_THUNDERBALL_STATE_END equ 0x08


pikachu_thunderball:
	push r7, r14
	ldr r1, =@@pikachu_thunderball_pool
	ldrb r0, [r7, 0x00]
	ldr r1, [r0, r1]
	mov r14, r15
	bx r1
	pop r7, r15
	.pool
@@pikachu_thunderball_pool:
	.word pikachu_thunderball_begin|1;0
	.word pikachu_thunderball_attack|1;0
	.word pikachu_thunderball_end|1;0

pikachu_thunderball_begin:
	push r14
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@state_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
	mov r0, PIKACHU_ANIMATION_THUNDER_BEGIN
	strb r0, [r5, 0x10]
	mov r0, 16
	strh r0, [r7, 0x10]
	bl object_set_default_counter_time
@@state_initialized:
	ldrh r0, [r7, 0x10]
	sub r0, 0x01
	strh r0, [r7, 0x10]
	bgt @@endroutine
	mov r0, @PIKACHU_THUNDERBALL_STATE_ATTACK
	strh r0, [r7, 0x00]
@@endroutine:
	pop r15

pikachu_thunderball_attack:
	push r4-r7, r14
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@state_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
	mov r0, PIKACHU_ANIMATION_THUNDER_CHARGE
	strb r0, [r5, 0x10]
	mov r0, 0x18
	strh r0, [r7, 0x10]
	b @@endroutine
@@state_initialized:
	ldrh r0, [r7, 0x10]
	sub r0, 0x01
	strh r0, [r7, 0x10]
	cmp r0, 0x0C
	bne @@no_thunderball
	bl object_get_front_direction
	ldrb r1, [r5, 0x12]
	add r0, r1, r0
	ldrb r1, [r5, 0x13]
	mov r2, AttackElement_Elec
	mov r3, 0x0A
	lsl r3, 0x10
	ldr r4, =0x00100701
	ldr r6,= (0x0A << 0x10) | (PIKACHU_THUNDERBALL_DAMAGE)
	mov r7, 0x00
	bl thunderball_object_spawn
	b @@endroutine
@@no_thunderball:
	cmp r0, 0x00
	bgt @@endroutine
	mov r0, @PIKACHU_THUNDERBALL_STATE_END
	strh r0, [r7, 0x00]
@@endroutine:
	pop r4-r7, r15

pikachu_thunderball_end:
	push r14
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@state_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
	mov r0, PIKACHU_ANIMATION_THUNDER_CHARGE_END
	strb r0, [r5, 0x10]
	mov r0, 16
	strh r0, [r7, 0x10]
@@state_initialized:
	ldrh r0, [r7, 0x10]
	sub r0, 0x01
	strh r0, [r7, 0x10]
	bgt @@endroutine
	mov r0, PIKACHU_ANIMATION_IDLE
	strb r0, [r5, 0x10]
	bl object_exit_attack_state
@@endroutine:
	pop r15

;eof