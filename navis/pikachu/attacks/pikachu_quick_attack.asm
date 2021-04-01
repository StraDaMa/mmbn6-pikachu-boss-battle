;this attack changes based on low/high hp
pikachu_volt_tackle_quick_attack:
	push r14
;get if pikachu is in low or high hp ai
	ldrb r1, [r6, 0x00]
	ldr r0, =@@pikachu_volt_tackle_quick_attack_pool
	ldr r1, [r0, r1]
	mov r14, r15
	bx r1
	pop r15
	.pool
@@pikachu_volt_tackle_quick_attack_pool:
	.word pikachu_quick_attack|1;high hp
	.word pikachu_volt_tackle|1;low hp

@PIKACHU_QUICK_ATTACK_STATE_INIT equ 0x00
@PIKACHU_QUICK_ATTACK_STATE_DOUBLE_TEAM equ 0x04
@PIKACHU_QUICK_ATTACK_STATE_DASHY equ 0x08
@PIKACHU_QUICK_ATTACK_STATE_DASHX equ 0x0C
@PIKACHU_QUICK_ATTACK_STATE_END equ 0x10

pikachu_quick_attack:
	push r7, r14
	ldr r1, =@@pikachu_quick_attack_pool
	ldrb r0, [r7, 0x00]
	ldr r1, [r0, r1]
	mov r14, r15
	bx r1
	pop r7, r15
	.pool
@@pikachu_quick_attack_pool:
	.word pikachu_quick_attack_init|1;0
	.word pikachu_quick_attack_double_team|1;4
	.word pikachu_quick_attack_dash_y|1;8
	.word pikachu_quick_attack_dash_x|1;C
	.word pikachu_quick_attack_end|1;0x10

pikachu_quick_attack_init:
	push r14
;set number of times to move
	mov r0, 0x04
	strh r0, [r7, 0x12]
	mov r0, @PIKACHU_QUICK_ATTACK_STATE_DOUBLE_TEAM
	strh r0, [r7, 0x00]
	pop r15

pikachu_quick_attack_double_team:
	push r4-r7,r14
	add sp, -0x1C
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
	bl object_can_move
	beq @@cant_move
;set timer
	mov r0, 0x10
	strh r0, [r7, 0x10]
	bl object_set_counter_time
;Get move parameters based on which side pikachu is on
	ldrb r0, [r5,0x16]
	ldr r1, =pikachu_move_parameters
	lsl r0, r0, 0x03
	add r0, r0, r1
	ldr r2, [r0, 0x00]
	ldr r3, [r0, 0x04]
	mov r7, sp
	bl object_get_panels_except_current_filtered
	mov r4, r0
	tst r0, r0
	bne @@validpanel
@@cant_move:
	bl object_exit_attack_state
	b @@endroutine
@@validpanel:
	mov r0, 0x94
	bl sfx_play
;shuffle list to just take top 4
	mov r0, sp
	mov r1, r4
	mov r2, r4
	bl list_shuffle_byte
;first one is where real pikachu moves
	mov r6, sp
	ldrb r0, [r6, 0x00]
	lsr r1, r0, 0x04
	lsl r0, r0, 32 - 4
	lsr r0, r0, 32 - 4
	strb r0, [r5, 0x12]
	strb r1, [r5, 0x13]
	bl object_set_coordinates_from_panels
	bl object_update_collision_panels
	mov r0, PIKACHU_ANIMATION_MOVE_IN
;strh so the the animation could be repeated every it is written
	strh r0, [r5, 0x10]
;next 3 are for illusions
	mov r7, 0x01
@@loop:
	push r4-r7
	;Set up parameters for illusion object
	bl object_get_flip
	lsl r0, r0, 0x18
	ldr r4, =(PIKACHU_ANIMATION_MOVE_IN << 0x10) | (PIKACHU_SPRITE_INDEX << 8) | (PIKACHU_SPRITE_CATEGORY)
	orr r4, r0;illusion parameters
	ldrb r0, [r6, r7]
	lsr r1, r0, 0x04
	lsl r0, r0, 32 - 4
	lsr r0, r0, 32 - 4
	bl object_get_coordinates_for_panels
	mov r2, r1;illusion y
	mov r1, r0;illusion x
	mov r3, 0x00;illusion z
	mov r7, 0x13;illusion duration
;get attack state offset again, this was formerly r7
	ldr r6, [r5, 0x58]
	add r6, 0xA0 + 0x12; + 0x12 to get the current amount of movements
	cmp r6, 0x01
	bne @@no_extra_time
	add r7, 0x20
@@no_extra_time:
	mov r6, 0x00;color modification
	bl illusion_object_spawn
	;stops illusion from flickering
	bl 0x080E3422
	pop r4-r7
	add r7, 0x01
	cmp r7, r4
	bge @@endroutine
	cmp r7, 0x04
	blt @@loop
	b @@endroutine
@@step_initialized:
;update timer for phase
	ldrh r0, [r7, 0x10]
	sub r0, 0x01
	strh r0, [r7, 0x10]
	bge @@endroutine
;update number of movements remaining
	ldrh r0, [r7, 0x12]
	sub r0, 0x01
	strh r0, [r7, 0x12]
	bgt @@continue_phase
;reserve current panel to jump back to it in the end
	ldrb r0, [r5, 0x12]
	ldrb r1, [r5, 0x13]
	strb r0, [r5, 0x14]
	strb r1, [r5, 0x15]
	bl object_reserve_panel
;update collision properties to make pikachu pierce most defenses
	mov r1, 0x35
	mov r2, 0x02
	mov r3, 0x03
	bl 0x0801A082
;update damage
	mov r0, PIKACHU_QUICK_ATTACK_DAMAGE
	ldr r1, [r5, 0x54]
	strh r0, [r1, 0x2E]
;If Y already matches the target already skip straight to dash x
	ldr r0, [r7, 0x2C]
	ldrb r0, [r0, 0x13]
	ldrb r1, [r5, 0x13]
	cmp r0, r1
	beq @@matched_y
;try to match y first
	mov r0, @PIKACHU_QUICK_ATTACK_STATE_DASHY
	strh r0, [r7, 0x00]
	b @@endroutine
@@matched_y:
	mov r0, @PIKACHU_QUICK_ATTACK_STATE_DASHX
	strh r0, [r7, 0x00]
	b @@endroutine
@@continue_phase:
	mov r0, @PIKACHU_QUICK_ATTACK_STATE_DOUBLE_TEAM
	strh r0, [r7, 0x00]
@@endroutine:
	add sp, 0x1C
	pop r4-r7,r15

pikachu_quick_attack_dash_y:
	push r4-r7, r14
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
	mov r0, PIKACHU_ANIMATION_QUICK_ATTACK
	strb r0, [r5, 0x10]
;fix any minor imperfections from coordinates
	bl object_set_coordinates_from_panels
;check if pikachu will move up or down
	ldr r0, [r7, 0x2C]
	ldrb r0, [r0, 0x13]
	ldrb r2, [r5, 0x13]
	cmp r0, r2
	bne @@notEqual
	mov r0, @PIKACHU_QUICK_ATTACK_STATE_DASHX
	strh r0, [r7, 0x00]
	b @@endroutine
@@notEqual:
	blt @@moveup
	add r2, 0x01
	b @@next
@@moveup:
	sub r2, 0x01
@@next:
;object_get_front_direction does not change r2
	bl object_get_front_direction
	ldrb r1, [r5, 0x12]
	add r0, r0, r1
	mov r1, r2
	bl object_get_coordinates_for_panels
;get velocity to get the target coordinates in constant amount of frames
	ldr r3, [r5, 0x34]
	ldr r4, [r5, 0x38]
	sub r0, r0, r3
	sub r1, r1, r4
	push r1
	mov r1, 0x06
	swi 6;div
	str r0, [r5, 0x40]
	pop r0
	mov r1, 0x06
	swi 6;div
	str r0, [r5, 0x44]
;zero timer for phase
	mov r0, 0x00
	strh r0, [r7, 0x10]
;clear previous panel
	mov r0, 0x00
	strh r0, [r7, 0x12]
;start pew sound
	mov r0, 0xA1
	bl sfx_play
@@step_initialized:
;check if pikachu has collided with anything
	ldr r1, [r5, 0x54]
	ldr r0, [r1, 0x70]
;check if pikachu collided with the opponent, an opponent owned object or a neutral object.
;disable collision if so to avoid multiple hits
	ldrb r1, [r5, 0x16]
	lsl r1, r1, 0x02
	ldr r2, =pikachu_quick_attack_collision_checks
	ldr r1, [r2, r1]
	tst r0, r1
	beq @@nocollision
	bl object_clear_collision_region
@@nocollision:
	ldr r0, [r5, 0x34]
	ldr r1, [r5, 0x38]
	ldr r2, [r5, 0x40]
	ldr r3, [r5, 0x44]
	add r0, r0, r2
	add r1, r1, r3
	str r0, [r5, 0x34]
	str r1, [r5, 0x38]
	bl object_set_panels_from_coordinates
	bl object_update_collision_panels
	bl object_is_current_panel_solid
	beq @@endAttack
	bl object_is_current_panel_valid
	beq @@endAttack
;check if the panel has changed
	ldrh r0, [r5, 0x12]
	ldrh r1, [r7, 0x12]
	cmp r0, r1
	beq @@samePanel
;moving to a new panel sets the collision region again
	strh r0, [r7, 0x12]
	mov r0, 0x01
	bl object_set_collision_region
@@samePanel:
;update timer
	ldrh r0, [r7, 0x10]
	add r0, r0, 0x01
	strh r0, [r7, 0x10]
;spawn illusions every 4 frames
	lsl r0, 32 - 2
	lsr r0, 32 - 2
	cmp r0, 0x00
	bne @@no_illusion
	bl object_get_flip
	lsl r0, r0, 0x18
	ldr r4, = (PIKACHU_ANIMATION_QUICK_ATTACK << 0x10) | (PIKACHU_SPRITE_INDEX << 8) | (PIKACHU_SPRITE_CATEGORY)
	orr r4, r0
	mov r0,0x34
	add r0,r0,r5
	ldmia r0!, r1-r3
;color modification	
;R G B
	ldr r6, =((204 >> 3) << 0) | ((236 >> 3) << 5) | ((244 >> 3) << 10)
	mov r7,0x08
	bl illusion_object_spawn
@@no_illusion:
;check if phase is over
	ldrh r0, [r7, 0x10]
	cmp r0, 0x06
	bne @@endroutine
;If Y already matches skip straight to dash x
	ldr r0, [r7, 0x2C]
	ldrb r0, [r0, 0x13]
	ldrb r1, [r5, 0x13]
	cmp r0, r1
	beq @@matched_y
;try to match y first
	mov r0, @PIKACHU_QUICK_ATTACK_STATE_DASHY
	strh r0, [r7, 0x00]
	b @@endroutine
@@matched_y:
	mov r0, @PIKACHU_QUICK_ATTACK_STATE_DASHX
	strh r0, [r7, 0x00]
	b @@endroutine
@@endAttack:
	mov r0, @PIKACHU_QUICK_ATTACK_STATE_END
	strh r0, [r7, 0x00]
@@endroutine:
	pop r4-r7, r15

pikachu_quick_attack_dash_x:
	push r4-r7, r14
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
	mov r0, PIKACHU_ANIMATION_QUICK_ATTACK
	strb r0, [r5, 0x10]
;fix any minor imperfections from coordinates
	bl object_set_coordinates_from_panels
	bl object_get_front_direction
;set constant speed
	ldr r1, =(0x00280000) / 6
	mul r0, r1
	str r0, [r5, 0x40]
	mov r0, 0x00
	strh r0, [r7, 0x10]
;clear previous panel
	mov r0, 0x00
	strh r0, [r7, 0x12]
	mov r0, 0xA1
	bl sfx_play
@@step_initialized:
;check if pikachu has collided with anything
	ldr r1, [r5, 0x54]
	ldr r0, [r1, 0x70]
;check if pikachu collided with the opponent, an opponent owned object or a neutral object.
;disable collision if so to avoid multiple hits
	ldrb r1, [r5, 0x16]
	lsl r1, r1, 0x02
	ldr r2, =pikachu_quick_attack_collision_checks
	ldr r1, [r2, r1]
	tst r0, r1
	beq @@nocollision
	bl object_clear_collision_region
@@nocollision:
	ldr r0, [r5, 0x34]
	ldr r2, [r5, 0x40]
	add r0, r0, r2
	str r0, [r5, 0x34]
	bl object_set_panels_from_coordinates
	bl object_update_collision_panels
;check if the panel has changed
	ldrh r0, [r5, 0x12]
	ldrh r1, [r7, 0x12]
	cmp r0, r1
	beq @@samePanel
;moving to a new panel sets the collision region again
	strh r0, [r7, 0x12]
	mov r0, 0x01
	bl object_set_collision_region
@@samePanel:
;update timer
	ldrh r0, [r7, 0x10]
	add r0, r0, 0x01
	strh r0, [r7, 0x10]
;spawn illusions every 4 frames
	lsl r0, 32 - 2
	lsr r0, 32 - 2
	cmp r0, 0x00
	bne @@no_illusion
	bl object_get_flip
	lsl r0, r0, 0x18
	ldr r4, = (PIKACHU_ANIMATION_QUICK_ATTACK << 0x10) | (PIKACHU_SPRITE_INDEX << 8) | (PIKACHU_SPRITE_CATEGORY)
	orr r4, r0
	mov r0,0x34
	add r0,r0,r5
	ldmia r0!, r1-r3
;color modification	
;R G B
	ldr r6, =((204 >> 3) << 0) | ((236 >> 3) << 5) | ((244 >> 3) << 10)
	mov r7,0x08
	bl illusion_object_spawn
@@no_illusion:
	bl object_is_current_panel_solid
	beq @@endAttack
	bl object_is_current_panel_valid
	bne @@endroutine
@@endAttack:
	mov r0, @PIKACHU_QUICK_ATTACK_STATE_END
	strh r0, [r7, 0x00]
@@endroutine:
	pop r4-r7, r15

pikachu_quick_attack_end:
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
;spawn movement effect object when jumping back to old panel
	mov r0, 0x34
	add r0, r5, r0
	ldmia r0!, r1-r3;r1-r3 = x,y,z
	mov r4, 0x08
	lsl r4, r4, 0x10
	add r3, r3, r4;make z slightly higher
	mov r4, 0x14;14 = movement effect
	bl effect_object_spawn
	ldrb r0, [r5, 0x14]
	ldrb r1, [r5, 0x15]
	strb r0, [r5, 0x12]
	strb r1, [r5, 0x13]
	bl object_remove_panel_reserve
	bl object_set_coordinates_from_panels
	bl object_update_collision_panels
;timer for phase
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