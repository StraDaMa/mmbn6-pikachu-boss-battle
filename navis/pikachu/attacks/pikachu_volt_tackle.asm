@PIKACHU_VOLT_TACKLE_STATE_BEGIN_MOVE equ 0x00
@PIKACHU_VOLT_TACKLE_STATE_FINISH_MOVE equ 0x04
@PIKACHU_VOLT_TACKLE_STATE_BEGIN_ATTACK equ 0x08
@PIKACHU_VOLT_TACKLE_STATE_CHARGE_ATTACK equ 0x0C
@PIKACHU_VOLT_TACKLE_STATE_ATTACK equ 0x10
@PIKACHU_VOLT_TACKLE_STATE_END equ 0x14

pikachu_volt_tackle:
	push r7, r14
	ldr r1, =@@pikachu_volt_tackle_pool
	ldrb r0, [r7, 0x00]
	ldr r1, [r0, r1]
	mov r14, r15
	bx r1
	pop r7, r15
	.pool
@@pikachu_volt_tackle_pool:
	.word pikachu_volt_tackle_begin_move|1;00
	.word pikachu_volt_tackle_move|1;04
	.word pikachu_volt_tackle_begin|1;08
	.word pikachu_volt_tackle_charge|1;0C
	.word pikachu_volt_tackle_attack|1;10
	.word pikachu_volt_tackle_end|1;14

pikachu_volt_tackle_begin_move:
push r4-r7,r14
	add sp, -0x08
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
	bl object_can_move
	bne @@canmove
	mov r0, 0x08
	strh r0, [r7, 0x18]
	b @@endroutine
@@canmove:
;Get move parameters based on which side pikachu is on
	mov r6, r7
	ldr r2, [r7, 0x2C]
	ldrb r0, [r2, 0x13]
	ldrb r2, [r5, 0x16]
	ldr r3, =pikachu_move_parameters
	lsl r2, r2, 0x03
	add r3, r3, r2
	ldr r2, [r3, 0x00]
	ldr r3, [r3, 0x04]
	mov r7, sp
	bl object_get_panels_in_row_filtered
	mov r4, r0
	tst r0, r0
	bne @@validpanel
@@no_move2:
	mov r0, @PIKACHU_VOLT_TACKLE_STATE_BEGIN_ATTACK
	strh r0, [r6, 0x00]
	b @@endroutine
@@validpanel:
	;mov r0, r7
	;mov r1, r4
	;mov r2, r4
	;bl list_shuffle_byte
	ldrb r0, [r7, 0x00]
	lsr r1, r0, 0x04
	lsl r0, r0, 32-4
	lsr r0, r0, 32-4
	ldrb r2, [r5, 0x12]
	cmp r0, r2
	bne @@new_panel
	ldrb r2, [r5, 0x13]
	cmp r1, r2
	bne @@new_panel
	b @@no_move2
@@new_panel:
	mov r7, r6
;Reserve panel Pikachu is jumping to
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
	mov r0, @PIKACHU_VOLT_TACKLE_STATE_FINISH_MOVE
	strh r0, [r7, 0x00]
@@endroutine:
	add sp, 0x08
	pop r4-r7,r15

pikachu_volt_tackle_move:
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
	mov r0, @PIKACHU_VOLT_TACKLE_STATE_BEGIN_ATTACK
	strh r0, [r7, 0x00]
@@endroutine:
	pop r4,r15

pikachu_volt_tackle_begin:
	push r14
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@state_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
	mov r0, PIKACHU_ANIMATION_VOLT_TACKLE_BEGIN
	strb r0, [r5, 0x10]
	mov r0, 12
	strh r0, [r7, 0x10]
@@state_initialized:
	ldrh r0, [r7, 0x10]
	sub r0, 0x01
	strh r0, [r7, 0x10]
	bgt @@endroutine
	mov r0, @PIKACHU_VOLT_TACKLE_STATE_CHARGE_ATTACK
	strh r0, [r7, 0x00]
;initialize timer used for yellowing
	mov r0, 0x08
	strb r0, [r7, 0x12]
@@endroutine:
	pop r15

pikachu_volt_tackle_charge:
	push r14
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@state_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
	mov r0, PIKACHU_ANIMATION_THUNDER_ATTACK
	strb r0, [r5, 0x10]
	mov r0, 48
	strh r0, [r7, 0x10]
	mov r0, 0x01
	strb r0, [r7, 0x0F]
	mov r0, 24
	bl object_set_counter_time
	mov r0, 0xC6
	bl sfx_play
@@state_initialized:
	ldrb r0, [r7, 0x12]
	add r0, 0x01
	cmp r0, 0x1F
	ble @@no_reset
	mov r0, 0x08
@@no_reset:
	strb r0, [r7, 0x12]
	lsl r1, r0, 0x05
	orr r0,r1
	bl sprite_set_color_shader
	ldrb r0, [r7, 0x0F]
	sub r0, 0x01
	strb r0, [r7, 0x0F]
	bne @@no_spark
	mov r0, 0x0C
	strb r0, [r7, 0x0F]
	bl rng1_get_int
	mov r4, 0x1F
	mov r6, 0x1F
	and r4, r0
	lsr r0, 0x08
	and r6, r0
	lsl r4, r4, 32 - 5
	asr r4, r4, 32 - 5 - 16
	lsl r6, r6, 0x10
	mov r0, 0x34
	add r0, r5, r0
	ldmia r0!, r1-r3
	add r1, r1, r4
	add r3, r3, r6
	mov r4, 0x0A
	bl effect_object_spawn
@@no_spark:
	ldrh r0, [r7, 0x10]
	sub r0, 0x01
	strh r0, [r7, 0x10]
	bgt @@endroutine
	mov r0, @PIKACHU_VOLT_TACKLE_STATE_ATTACK
	strh r0, [r7, 0x00]
@@endroutine:
	pop r15

pikachu_volt_tackle_attack:
	push r4-r7, r14
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
;update collision properties to make it pierce most things
	mov r1, 0x30
	mov r2, 0x02
	mov r3, 0x03
	bl 0x0801A082
;set damage
	ldr r0, =PIKACHU_VOLT_TACKLE_DAMAGE
	ldr r1, [r5, 0x54]
	strh r0, [r1, 0x2E]
	mov r0, PIKACHU_ANIMATION_QUICK_ATTACK
	strb r0, [r5, 0x10]
	bl object_get_front_direction
	ldr r1, =(0x00280000) / 6
	mul r0, r1
	str r0, [r5, 0x40]
	mov r0, 0x00
	strh r0, [r7, 0x10]
;clear previous panel
	mov r0, 0x00
	strh r0, [r7, 0x0C]
	mov r4, 0x35
	mov r7, r5
	add r7, 0x4C
	bl temp_attack_object_spawn
	mov r0, 0xA1
	bl sfx_play
	b @@endroutine
@@step_initialized:
;invulnerable while running
	mov r0, 0x01
	bl object_set_invulnerable_time
	ldrb r1, [r5, 0x16]
	lsl r1, r1, 0x02
	ldr r2, =pikachu_quick_attack_collision_checks
	ldr r4, [r2, r1]
	mov r3, r4
	ldrb r0, [r5, 0x12]
	ldrb r1, [r5, 0x13]
	mov r2, 0x00
;Need to check for player collision through panel parameters because of invulnerability
	bl object_check_panel_parameters
	tst r0, r0
	bne @@no_collision
;clear damage so it doesnt multihit
	mov r0, 0
	ldr r1, [r5, 0x54]
	strh r0, [r1, 0x2E]
;check if this collision was with the player and do recoil damage
	mov r3, 0x0C
	lsl r3, r3, 32-8
	and r3, r4
	ldrb r0, [r5, 0x12]
	ldrb r1, [r5, 0x13]
	mov r2, 0x00
;save these registers because they can be reused for collision region
	push r0-r2
	bl object_check_panel_parameters
	tst r0, r0
	pop r0-r2
	bne @@no_collision
;Volt tackle has recoil damage
	push r7
	; ldrb r0, [r5, 0x12]
	; ldrb r1, [r5, 0x13]
	; mov r2, ATTACKELEMENT_NULL
	mov r3, 0x00
	ldr r4,=0x0405FF01
	mov r6, 70
	mov r7, 0x03
	bl collision_region_spawn
;invert alliance so this damages pikachu
	mov r1, 0x01
	ldrb r2, [r0, 0x16]
	eor r2, r1
	strb r2, [r0, 0x16]
	pop r7
	bl object_clear_invulnerable_time
@@no_collision:
;Set this every frame so the wave stays slightly in front of pikachu
	bl object_get_front_direction
	mov r1, 0x08
	lsl r1, r1, 0x10
	mul r1, r0
	ldr r0, [r5, 0x4C]
	str r1, [r0, 0x40]
	ldrb r0, [r7, 0x12]
	add r0, 0x01
	cmp r0, 0x1F
	ble @@no_reset
	mov r0, 0x08
@@no_reset:
	strb r0, [r7, 0x12]
	lsl r1, r0, 0x05
	orr r0,r1
	bl sprite_set_color_shader
	ldr r0, [r5, 0x34]
	ldr r2, [r5, 0x40]
	add r0, r0, r2
	str r0, [r5, 0x34]
	bl object_set_panels_from_coordinates
	bl object_update_collision_panels
	ldrh r0, [r5, 0x12]
	ldrh r1, [r7, 0x0C]
	cmp r0, r1
	beq @@samePanel
	strh r0, [r7, 0x0C]
;reset damage
	ldr r0, =PIKACHU_VOLT_TACKLE_DAMAGE
	ldr r1, [r5, 0x54]
	strh r0, [r1, 0x2E]
@@samePanel:
	ldrh r0, [r7, 0x10]
	add r0, r0, 0x01
	strh r0, [r7, 0x10]
	lsl r0, 32 - 2
	lsr r0, 32 - 2
	cmp r0, 0x00
	bne @@no_aferimage
	bl object_get_flip
	lsl r0, r0, 0x18
	ldr r4, = (PIKACHU_ANIMATION_QUICK_ATTACK<<0x10) | (PIKACHU_SPRITE_INDEX << 8) | (PIKACHU_SPRITE_CATEGORY)
	orr r4, r0
	mov r0,0x34
	add r0,r0,r5
	ldmia r0!, r1-r3
	;R G B
	ldr r6, =((255 >>3) << 0) | ((255 >>3) << 5) | ((0>>3) << 10)
	;ldr r7,=0x1010014
	mov r7,0x08
	bl illusion_object_spawn
@@no_aferimage:
	bl object_is_current_panel_solid
	beq @@endAttack
	bl object_is_current_panel_valid
	bne @@endroutine
@@endAttack:
	mov r0, @PIKACHU_VOLT_TACKLE_STATE_END
	strh r0, [r7, 0x00]
@@endroutine:
	pop r4-r7, r15

pikachu_volt_tackle_end:
	push r14
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
;reset collision properties
;this also resets the damage
	mov r1, 0x10
	mov r2, 0x02
	mov r3, 0x03
	bl 0x0801A082
	mov r0, PIKACHU_ANIMATION_MOVE_IN
	strb r0, [r5, 0x10]

;destroy thunder wave object
	mov r0, 0x00
	str r0, [r5, 0x4C]

	mov r0, 0x34
	add r0, r5, r0
	ldmia r0!, r1-r3
	mov r4, 0x08
	lsl r4, r4, 0x10
	add r3, r3, r4
	mov r4, 0x14
	bl effect_object_spawn
	
	ldrb r0, [r5, 0x14]
	ldrb r1, [r5, 0x15]
	strb r0, [r5, 0x12]
	strb r1, [r5, 0x13]
	bl object_remove_panel_reserve
	bl object_set_coordinates_from_panels
	bl object_update_collision_panels
	mov r0, 0x04 + 0x08
	strh r0, [r7, 0x10]
@@step_initialized:
	ldrh r0, [r7, 0x10]
	sub r0, 0x01
	strh r0, [r7, 0x10]
	bgt @@endroutine
	bl object_exit_attack_state
@@endroutine:
	pop r15
.pool
;eof