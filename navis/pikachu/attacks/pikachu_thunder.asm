@PIKACHU_THUNDER_STATE_START equ 0x00
@PIKACHU_THUNDER_STATE_HIGHLIGHT_PANELS equ 0x04
@PIKACHU_THUNDER_STATE_ATTACK_TRANSITION equ 0x08
@PIKACHU_THUNDER_STATE_ATTACK equ 0x0C
@PIKACHU_THUNDER_STATE_END equ 0x10

pikachu_thunder:
	push r7, r14
	ldr r1, =@@pikachu_thunder_pool
	ldrb r0, [r7, 0x00]
	ldr r1, [r0, r1]
	mov r14, r15
	bx r1
	pop r7, r15
	.pool
@@pikachu_thunder_pool:
	.word pikachu_thunder_start|1;0x00
	.word pikachu_thunder_highlight_panels|1;0x04
	.word pikachu_thunder_attack_transition|1;0x04
	.word pikachu_thunder_attack|1;0x0C
	.word pikachu_thunder_end|1;0x10

pikachu_thunder_start:
	push r14
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
;start animation
	mov r0, 0x04
	strb r0, [r7, 0x01]
	mov r0, PIKACHU_ANIMATION_THUNDER_BEGIN
	strb r0, [r5, 0x10]
	mov r0, 16
	strh r0, [r7, 0x10]
	bl object_set_default_counter_time
@@step_initialized:
	ldrh r0, [r7, 0x10]
	sub r0, 0x01
	strh r0, [r7, 0x10]
	bgt @@endroutine
;set next phase
	mov r0, @PIKACHU_THUNDER_STATE_HIGHLIGHT_PANELS
	strh r0, [r7, 0x00]
;zero number of times next phase has been repeated
	mov r0, 0x00
	strh r0, [r7, 0x12]
;zero the region that will be used to store the panels
	mov r0, 0x16
	add r0, r0, r7
	mov r1, 9
	bl memory_zero8
@@endroutine:
	pop r15

pikachu_thunder_highlight_panels:
	push r4-r7, r14
	add sp, -0x1C
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x01
	strb r0, [r7, 0x01]
;start animation
	mov r0, PIKACHU_ANIMATION_THUNDER_CHARGE
	strb r0, [r5, 0x10]
;set timer
	mov r0, 0x10
	strh r0, [r7, 0x10]
;Get any 3 random opponent panels
	mov r6, r7;save attack parameters pointer
	ldrb r0, [r5, 0x16]
	lsl r0, r0, 0x03
	ldr r1, =pikachu_thunder_panel_parameters
	add r0, r0, r1
	ldr r2, [r0, 0x00]
	ldr r3, [r0, 0x04]
	mov r7, sp
	bl object_get_panels_filtered
;save number of panels returned
	mov r4, r0
;shuffle the list so the first 3 can just be copied
	mov r0, sp
	mov r1, r4
	mov r2, r4
	bl list_shuffle_byte
;check if there's 3 panels otherwise only copy the number returned
	mov r2, 0x03
	cmp r4, 0x03
	bgt @@enough_panels
	mov r2, r4
@@enough_panels:
	mov r0, 0x3
	ldrh r1, [r6, 0x12]
	mul r1, r0
	add r1, 0x16
	add r1, r1, r6
	mov r0, sp
	bl memory_copy8
	b @@endroutine
@@step_initialized:
;highlight current 3 panels
	mov r6, 0x3
	ldrh r4, [r7, 0x12]
	mul r4, r6
	add r4, 0x16
@@loop:
	ldrb r0, [r7, r4]
	tst r0, r0
	beq @@breakLoop
	lsr r1, r0, 0x04
	lsl r0, r0, 32-4
	lsr r0, r0, 32-4
	bl object_highlight_panel
	add r4, 0x01
	sub r6,0x01
	bgt @@loop
@@breakLoop:
;update timer
	ldrh r0, [r7, 0x10]
	sub r0, 0x01
	strh r0, [r7, 0x10]
	bgt @@endroutine
;check how many times this phase has been repeated
	ldrh r0, [r7, 0x12]
	add r0, 0x01
	strh r0, [r7, 0x12]
;If it's been done 3 times go on to next phase
	cmp r0, 0x03
	blt @@continue_state
	mov r0, @PIKACHU_THUNDER_STATE_ATTACK_TRANSITION
	strh r0, [r7, 0x00]
;Zero number of times next phase has been repeated
	mov r0, 0x00
	strh r0, [r7, 0x12]
	b @@endroutine
@@continue_state:
	mov r0, @PIKACHU_THUNDER_STATE_HIGHLIGHT_PANELS
	strh r0, [r7, 0x00]
@@endroutine:
	add sp, 0x1C
	pop r4-r7, r15

pikachu_thunder_attack_transition:
	push r14
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
;start animation
	mov r0, 0x04
	strb r0, [r7, 0x01]
	mov r0, PIKACHU_ANIMATION_THUNDER_ATTACK_TRANSITION
	strb r0, [r5, 0x10]
	mov r0, 8
	strh r0, [r7, 0x10]
@@step_initialized:
	ldrh r0, [r7, 0x10]
	sub r0, 0x01
	strh r0, [r7, 0x10]
	bgt @@endroutine
;set next phase
	mov r0, @PIKACHU_THUNDER_STATE_ATTACK
	strh r0, [r7, 0x00]
@@endroutine:
	pop r15

pikachu_thunder_attack:
	push r4-r7, r14
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x01
	strb r0, [r7, 0x01]
;start animation
	mov r0, PIKACHU_ANIMATION_THUNDER_ATTACK
	strb r0, [r5, 0x10]
;set timer
	mov r0, 0x10
	strh r0, [r7, 0x10]
;spawn thunderbolts on 3 panels
	mov r6, 0x3
	ldrh r4, [r7, 0x12]
	mul r4, r6
	add r4, 0x16
@@loop:
	ldrb r0, [r7, r4]
	tst r0, r0
	beq @@breakLoop
	lsr r1, r0, 0x04
	lsl r0, r0, 32-4
	lsr r0, r0, 32-4
	push r4, r6
	mov r2, AttackElement_Elec
	mov r3, 0x00
	mov r4, 0x00
	ldr r6, =(0x000A << 0x10) | (PIKACHU_THUNDER_DAMAGE)
	bl thunderbolt_object_spawn
	pop r4, r6
	add r4, 0x01
	sub r6,0x01
	bgt @@loop
@@breakLoop:
	b @@endroutine
@@step_initialized:
;update timer
	ldrh r0, [r7, 0x10]
	sub r0, 0x01
	strh r0, [r7, 0x10]
	bgt @@endroutine
;check how many times this phase has been repeated
	ldrh r0, [r7, 0x12]
	add r0, 0x01
	strh r0, [r7, 0x12]
;If it's been done 3 times go on to next phase
	cmp r0, 0x03
	blt @@continue_state
	mov r0, @PIKACHU_THUNDER_STATE_END
	strh r0, [r7, 0x00]
	b @@endroutine
@@continue_state:
	mov r0, @PIKACHU_THUNDER_STATE_ATTACK
	strh r0, [r7, 0x00]
@@endroutine:
	pop r4-r7, r15

pikachu_thunder_end:
	push r14
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
;start animation
	mov r0, 0x04
	strb r0, [r7, 0x01]
	mov r0, PIKACHU_ANIMATION_THUNDER_END
	strb r0, [r5, 0x10]
	mov r0, 24
	strh r0, [r7, 0x10]
@@step_initialized:
	ldrh r0, [r7, 0x10]
	sub r0, 0x01
	strh r0, [r7, 0x10]
	bgt @@endroutine
	bl object_exit_attack_state
@@endroutine:
	pop r15

;eof