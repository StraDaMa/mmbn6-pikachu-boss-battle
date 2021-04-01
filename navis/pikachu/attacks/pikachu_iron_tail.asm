@PIKACHU_IRON_TAIL_STATE_BEGIN_MOVE equ 0x00
@PIKACHU_IRON_TAIL_STATE_MOVE equ 0x04
@PIKACHU_IRON_TAIL_STATE_ATTACK equ 0x08
@PIKACHU_IRON_TAIL_STATE_BEGIN_RETURN equ 0x0C
@PIKACHU_IRON_TAIL_STATE_RETURN equ 0x10

pikachu_iron_tail:
	push r7, r14
	ldr r1, =@@pikachu_iron_tail_pool
	ldrb r0, [r7, 0x00]
	ldr r1, [r0, r1]
	mov r14, r15
	bx r1
	pop r7, r15
	.pool
@@pikachu_iron_tail_pool:
	.word pikachu_iron_tail_begin_move|1;0
	.word pikachu_iron_tail_move|1;4
	.word pikachu_iron_tail_attack|1;8
	.word pikachu_iron_tail_begin_return|1;C
	.word pikachu_iron_tail_return|1;0x10

pikachu_iron_tail_begin_move:
	push r4,r14
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
	bl object_can_move
	beq @@cantmove
;target panel was set up on pikachu_update_ai.asm when the attack was set
;double check that panel is still ok to jump to
	ldrb r0, [r7, 0x14]
	ldrb r1, [r7, 0x15]
	ldr r3, =pikachu_iron_tail_jump_panel_parameters
	ldr r2, [r3, 0x00]
	ldr r3, [r3, 0x04]
	push r0, r1
	bl object_check_panel_parameters
	tst r0, r0
	pop r0, r1
	bne @@validpanel
@@cantmove:
	bl object_exit_attack_state
	b @@endroutine
@@validpanel:
;reserve target panel
	bl object_reserve_panel
;Reserve original panel
	ldrb r0, [r5, 0x12]
	ldrb r1, [r5, 0x13]
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
	sub r0, 0x01
	strb r0, [r7, 0x10]
	bge @@endroutine
	mov r0, @PIKACHU_IRON_TAIL_STATE_MOVE
	strh r0, [r7, 0x00]
@@endroutine:
	pop r4,r15

pikachu_iron_tail_move:
	push r4,r14
	ldrb r0,[r7, 0x01]
	tst r0,r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0,[r7, 0x01]
	ldrb r0, [r7, 0x14]
	ldrb r1, [r7, 0x15]
	strb r0, [r5, 0x12]
	strb r1, [r5, 0x13]
	bl object_set_coordinates_from_panels
	bl object_update_collision_panels
	mov r0, 0x40
	bl object_clear_flag
	mov r0, PIKACHU_ANIMATION_MOVE_IN
	strb r0, [r5, 0x10]
	mov r0, 0x04 + 8
	strh r0, [r7, 0x10]
@@step_initialized:
	ldrh r0, [r7, 0x10]
	sub r0, 0x01
	strh r0, [r7, 0x10]
	bgt @@endroutine
	mov r0, @PIKACHU_IRON_TAIL_STATE_ATTACK
	strh r0, [r7, 0x00]
@@endroutine:
	pop r4,r15

pikachu_iron_tail_attack:
	push r4-r7,r14
	ldrb r0, [r7, 0x01]
	tst r0,r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
;start iron tail animation
	mov r0, PIKACHU_ANIMATION_IRON_TAIL
	strb r0, [r5, 0x10]
;timer for phase
	mov r0, 88
	strh r0, [r7, 0x10]
	mov r0, 0x00
	strh r0, [r7, 0x12]
;start metal sound
	mov r0, 0xA4
	bl sfx_play
	b @@endroutine
@@step_initialized:
;update panel highlight timer
	ldrh r0, [r7, 0x12]
	add r0, 0x01
	strh r0, [r7, 0x12]
;only highlight panel for first part of attack
	cmp r0, 88-36
	bgt @@no_highlight
	lsr r0, r0, 0x03
	bcs @@no_highlight
	bl object_get_front_direction
	ldrb r1, [r5, 0x12]
	add r0, r0, r1
	ldrb r1, [r5, 0x13]
	bl object_highlight_panel
@@no_highlight:
;update timer for phase
	ldrh r0, [r7, 0x10]
	sub r0, 0x01
	strh r0, [r7, 0x10]
	cmp r0, 88 - 32
	bne @@no_sound
;start swing sound
	mov r0, 0x188 - 0xFF
	add r0, 0xFF
	bl sfx_play
	b @@endroutine
@@no_sound:
	cmp r0, 88 - 36
	bne @@no_impact
;spawn collision region and a hit effect
;only if pikachu hits a panel that is not a hole
	bl object_get_front_direction
	ldrb r1, [r5, 0x12]
	add r0, r0, r1
	ldrb r1, [r5, 0x13]
	push r0,r1
	bl object_is_panel_solid
	pop r0,r1
	beq @@endroutine
	push r0, r1
;spawn hit effect
	bl object_get_coordinates_for_panels
	mov r2, r1
	mov r1, r0
	mov r3, 0x00
	mov r4, 0x34
	bl effect_object_spawn
	pop r0, r1
	push r0, r1
	bl object_crack_panel
	mov r0,0x02
	mov r1, 8 + 6
	bl camera_shake
	pop r0, r1
;spawn collision region
	mov r2, AttackElement_Break
	mov r3, 0x00
	ldr r4,=0x15050A01
	ldr r6, =(10 << 0x10) | (PIKACHU_IRON_TAIL_DAMAGE)
	mov r7, 0x03
	bl collision_region_spawn
;large hit sound
	mov r0, 0xC0
	bl sfx_play
	b @@endroutine
@@no_impact:
	cmp r0, 0x00
	bgt @@endroutine
	mov r0, @PIKACHU_IRON_TAIL_STATE_BEGIN_RETURN
	strh r0, [r7, 0x00]
@@endroutine:
	pop r4-r7,r15

pikachu_iron_tail_begin_return:
	push r4,r14
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
	mov r0, 0x40
	bl object_set_flag
	mov r0, PIKACHU_ANIMATION_MOVE_OUT
	strb r0, [r5, 0x10]
	mov r0, 0x02
	strb r0, [r7, 0x10]
@@step_initialized:
	ldrb r0, [r7, 0x10]
	sub r0, 0x01
	strb r0, [r7, 0x10]
	bge @@endroutine
	mov r0, @PIKACHU_IRON_TAIL_STATE_RETURN
	strh r0, [r7, 0x00]
@@endroutine:
	pop r4,r15

pikachu_iron_tail_return:
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
	ldrb r0, [r7, 0x14]
	ldrb r1, [r7, 0x15]
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
	bl object_exit_attack_state
@@endroutine:
	pop r4,r15
.pool
;eof