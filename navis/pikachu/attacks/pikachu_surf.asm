@PIKACHU_SURF_STATE_BEGIN_MOVE equ 0x00
@PIKACHU_SURF_STATE_MOVE equ 0x04
@PIKACHU_SURF_STATE_HIGHLIGHT equ 0x08
@PIKACHU_SURF_STATE_JUMP equ 0x0C
@PIKACHU_SURF_STATE_WAVE1 equ 0x10
@PIKACHU_SURF_STATE_WAVE2 equ 0x14
@PIKACHU_SURF_STATE_RETURN equ 0x18

pikachu_surf:
	push r7, r14
	ldr r1, =@@pikachu_surf_pool
	ldrb r0, [r7, 0x00]
	ldr r1, [r0, r1]
	mov r14, r15
	bx r1
	pop r7, r15
	.pool
@@pikachu_surf_pool:
	.word pikachu_surf_begin_move|1;0
	.word pikachu_surf_move|1;4
	.word pikachu_surf_highlight|1;8
	.word pikachu_surf_jump|1;C
	.word pikachu_surf_wave1|1;10
	.word pikachu_surf_wave2|1;14
	.word pikachu_surf_return|1;18

pikachu_surf_begin_move:
	push r4-r7,r14
	add sp, -0x08
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
	bl object_can_move
	bne @@canmove
	mov r0, @PIKACHU_SURF_STATE_HIGHLIGHT
	strh r0, [r7, 0x00]
	b @@endroutine
@@canmove:
;get the closest panel matching the target's row
	mov r6, r7
	ldr r2, [r7, 0x2C]
	ldrb r0, [r2, 0x13]
;Get move parameters based on which side pikachu is on
	ldrb r2, [r5, 0x16]
	ldr r3, =pikachu_move_parameters
	lsl r2, r2, 0x03
	add r3, r3, r2
	ldr r2, [r3, 0x00]
	ldr r3, [r3, 0x04]
	mov r7, sp
	bl object_get_panels_in_row_filtered
	tst r0, r0
	bne @@validpanel
@@no_move2:
	mov r0, @PIKACHU_SURF_STATE_HIGHLIGHT
	strh r0, [r6, 0x00]
	b @@endroutine
@@validpanel:
;first result is the closest
	ldrb r0, [r7, 0x00]
	lsr r1, r0, 0x04;get panely
	lsl r0, r0, 32 - 4
	lsr r0, r0, 32 - 4;get panelx
;check if this is the panel pikachu is already on, if so skip moving to it
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
	mov r0, @PIKACHU_SURF_STATE_MOVE
	strh r0, [r7, 0x00]
@@endroutine:
	add sp, 0x08
	pop r4-r7,r15

pikachu_surf_move:
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
	mov r0, @PIKACHU_SURF_STATE_HIGHLIGHT
	strh r0, [r7, 0x00]
@@endroutine:
	pop r4,r15

pikachu_surf_highlight:
	push r4-r7, r14
	ldrb r0,[r7, 0x01]
	tst r0,r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0,[r7, 0x01]
	mov r0, PIKACHU_ANIMATION_SURF_BEGIN
	strb r0, [r5, 0x10]
;set timer for phase
	mov r0, 0x18
	strh r0, [r7, 0x10]
	bl object_set_counter_time
;screen shake timer
	mov r0, 0x0A
	strh r0, [r7, 0x12]
	mov r0, 0x00
	mov r1, 0x0A
	bl camera_shake
;start rumbling sound
	mov r0, 0xF7
	bl sfx_play
	b @@endroutine
@@step_initialized:
;update screen shake timer
	ldrh r0, [r7, 0x12]
	sub r0, 0x01
	strh r0, [r7, 0x12]
	bgt @@no_shake
	mov r0, 0x0A
	strh r0, [r7, 0x12]
	mov r0, 0x00
	mov r1, 0x0A
	bl camera_shake
@@no_shake:
;update timer for phase
	ldrh r0, [r7, 0x10]
	sub r0, 0x01
	strh r0, [r7, 0x10]
	lsr r0, r0, 0x03
	bcs @@no_highlight
	bl pikachu_surf_highlight_panels
@@no_highlight:
	ldrh r0, [r7, 0x10]
	cmp r0, 0x00
	bgt @@endroutine
	mov r0, @PIKACHU_SURF_STATE_JUMP
	strh r0, [r7, 0x00]
@@endroutine:
	pop r4-r7, r15

pikachu_surf_jump:
	push r4-r7, r14
	ldrb r0,[r7, 0x01]
	tst r0,r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0,[r7, 0x01]
	mov r0, PIKACHU_ANIMATION_SURF_JUMP
	strb r0, [r5, 0x10]
	bl sprite_no_shadow
;set timer for phase
	mov r0, 22
	strh r0, [r7, 0x10]
;screen shake timer
	mov r0, 0x00
	strh r0, [r7, 0x12]
;spawn surfboard object
	mov r4, PIKACHU_ANIMATION_SURFBOARD
	lsl r4, r4, 0x08
	add r4, 0x34
	mov r7, r5
	add r7, 0x4C
	bl temp_attack_object_spawn
	b @@endroutine
@@step_initialized:
;update screen shake timer
	ldrh r0, [r7, 0x12]
	sub r0, 0x01
	strh r0, [r7, 0x12]
	bgt @@no_shake
	mov r0, 0x0A
	strh r0, [r7, 0x12]
	mov r0, 0x00
	mov r1, 0x0A
	bl camera_shake
@@no_shake:
;update timer for phase
	ldrh r0, [r7, 0x10]
	sub r0, 0x01
	strh r0, [r7, 0x10]
	lsr r0, r0, 0x03
	bcs @@no_highlight
	bl pikachu_surf_highlight_panels
@@no_highlight:
	ldrh r0, [r7, 0x10]
	cmp r0, 0x00
	bgt @@endroutine
	mov r0, @PIKACHU_SURF_STATE_WAVE1
	strh r0, [r7, 0x00]
@@endroutine:
	pop r4-r7, r15

pikachu_surf_highlight_panels:
	push r4-r7, r14
	ldrb r2, [r5, 0x16]
	ldr r3, =pikachu_surf_panel_parameters
	lsl r2, r2, 0x03
	add r3, r3, r2
	ldr r2, [r3, 0x00]
	ldr r3, [r3, 0x04]
	ldrb r0, [r5, 0x12]
	mov r4, 0x02
@@loop:
	ldrb r1, [r5, 0x13]
	sub r1, 0x01
	add r1, r1, r4
	push r0-r4
	bl object_check_panel_parameters
	tst r0, r0
	pop r0-r4
	beq @@continue
	push r0-r4
	mov r2, 0x06
	ldrh r3, [r5, 0x16]
	bl object_highlight_panel_region
	pop r0-r4
@@continue:
	sub r4, 0x01
	bge @@loop
;Highlight panels for second wave
	bl object_get_front_direction
	mov r1, 0x02
	mul r1, r0
	ldrb r0, [r5, 0x12]
	add r0, r0, r1
	ldrb r1, [r5, 0x13]
	push r0-r1
	bl object_check_panel_parameters
	tst r0, r0
	pop r0-r1
	beq @@continue2
	mov r2, 0x06
	ldrh r3, [r5, 0x16]
	bl object_highlight_panel_region
@@continue2:
	pop r4-r7, r15

pikachu_surf_wave1:
	push r4-r7, r14
	ldrb r0,[r7, 0x01]
	tst r0,r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0,[r7, 0x01]
	mov r0, PIKACHU_ANIMATION_SURF
	strb r0, [r5, 0x10]
	bl object_clear_collision_region
;set timer for phase
	mov r0, 32
	strh r0, [r7, 0x10]
;duration for the move
	mov r0, 38
	strb r0, [r7, 0x0D]
;screen shake timer
	mov r0, 0x0A
	strh r0, [r7, 0x12]
	mov r0, 0x00
	mov r1, 0x0A
	bl camera_shake
	bl pikachu_surf_spawn_wave1
	tst r0, r0
	beq @@endAttack
;Get speeds for pikachu's surf
	bl object_get_front_direction
	mov r1, 0x02
	mul r1, r0
	ldrb r0, [r5, 0x12]
	add r0, r0, r1
	ldrb r1, [r5, 0x13]
	bl pikachu_surf_init_surf_velocities
	b @@endroutine
@@step_initialized:
;update x
	ldr r0, [r5, 0x34]
	ldr r1, [r5, 0x40]
	add r0, r0, r1
	str r0, [r5, 0x34]
;update y
	ldr r0, [r5, 0x38]
	ldr r1, [r5, 0x44]
	add r0, r0, r1
	str r0, [r5, 0x38]
;update z
	ldr r0, [r5, 0x3C]
	ldr r1, [r5, 0x48]
	add r0, r0, r1
	str r0, [r5, 0x3C]
;update z velocity by acceleration
	ldr r0, =0xFFFFC000
	add r1, r1, r0
	str r1, [r5, 0x48]
	bl object_set_panels_from_coordinates
	bl object_is_current_panel_valid
	tst r0, r0
	bne @@valid_panel
@@endAttack:
	mov r0, @PIKACHU_SURF_STATE_RETURN
	strh r0, [r7, 0x00]
	b @@endroutine
@@valid_panel:
;update movement timer
;This timer cant run out during this phase so not checking for it
	ldrb r0, [r7, 0x0D]
	sub r0, 0x01
	strb r0, [r7, 0x0D]
;udate screen shake tiemr
	ldrh r0, [r7, 0x12]
	sub r0, 0x01
	strh r0, [r7, 0x12]
	bgt @@no_shake
	mov r0, 0x0A
	strh r0, [r7, 0x12]
	mov r0, 0x00
	mov r1, 0x0A
	bl camera_shake
@@no_shake:
;update timer for phase
	ldrh r0, [r7, 0x10]
	sub r0, 0x01
	strh r0, [r7, 0x10]
	bgt @@endroutine
	mov r0, @PIKACHU_SURF_STATE_WAVE2
	strh r0, [r7, 0x00]
@@endroutine:
	pop r4-r7, r15

pikachu_surf_spawn_wave1:
	push r4-r7, r14
	mov r7, 0x00
	str r0, [sp]
	ldrb r2, [r5, 0x16]
	ldr r3, =pikachu_surf_panel_parameters
	lsl r2, r2, 0x03
	add r3, r3, r2
	ldr r2, [r3, 0x00]
	ldr r3, [r3, 0x04]
	ldrb r0, [r5, 0x12]
	mov r4, 0x02
@@loop:
	ldrb r1, [r5, 0x13]
	sub r1, 0x01
	add r1, r1, r4
	push r0-r4
	bl object_check_panel_parameters
	tst r0, r0
	pop r0-r4
	beq @@continue
	push r0-r4
	mov r2, AttackElement_Aqua
	mov r7, 0x01
	mov r3, 0x00
	mov r4, 0x00
	ldr r6, =(0x000A << 0x10) | (PIKACHU_SURF_DAMAGE)
	bl diveman_wave_object_spawn
	pop r0-r4
@@continue:
	sub r4, 0x01
	bge @@loop
	mov r0, r7
	pop r4-r7, r15

pikachu_surf_wave2:
	push r4-r7, r14
	ldrb r0,[r7, 0x01]
	tst r0,r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0,[r7, 0x01]
;set timer for phase
	mov r0, 42
	strh r0, [r7, 0x10]
	bl pikachu_surf_spawn_wave2
	tst r0,r0
	bne @@endroutine
	mov r0, @PIKACHU_SURF_STATE_RETURN
	strh r0, [r7, 0x00]
	b @@endroutine
@@step_initialized:
;update x
	ldr r0, [r5, 0x34]
	ldr r1, [r5, 0x40]
	add r0, r0, r1
	str r0, [r5, 0x34]
;update y
	ldr r0, [r5, 0x38]
	ldr r1, [r5, 0x44]
	add r0, r0, r1
	str r0, [r5, 0x38]
;update z
	ldr r0, [r5, 0x3C]
	ldr r1, [r5, 0x48]
	add r0, r0, r1
	str r0, [r5, 0x3C]
;update z velocity by acceleration
	ldr r0, =0xFFFFC000
	add r1, r1, r0
	str r1, [r5, 0x48]
	bl object_set_panels_from_coordinates
	bl object_is_current_panel_valid
	tst r0, r0
	bne @@valid_panel
	mov r0, @PIKACHU_SURF_STATE_RETURN
	strh r0, [r7, 0x00]
@@valid_panel:
;update movement timer
;this begins with whats left from the last phase
;setting the second set of velocities a bit later so the second wave object has some time to reach a point where it visually makes sense
	ldrb r0, [r7, 0x0D]
	sub r0, 0x01
	strb r0, [r7, 0x0D]
	bgt @@no_reset_speeds
;when the first phase's timer is up, start another one
	bl object_get_front_direction
	mov r1, 0x02
	mul r1, r0
	ldrb r0, [r5, 0x12]
	add r0, r0, r1
	ldrb r1, [r5, 0x13]
	bl pikachu_surf_init_surf_velocities
;Adjust the position slightly so pikachu appears in front of the wave this time instead of behind
	ldrh r0, [r5, 0x38 + 2]
	add r0, 0x02
	strh r0, [r5, 0x38 + 2]
	ldrh r0, [r5, 0x3C + 2]
	add r0, 0x02
	strh r0, [r5, 0x3C + 2]
@@no_reset_speeds:
;update screen shake timer
	ldrh r0, [r7, 0x12]
	sub r0, 0x01
	strh r0, [r7, 0x12]
	bgt @@no_shake
	mov r0, 0x0A
	strh r0, [r7, 0x12]
	mov r0, 0x00
	mov r1, 0x0A
	bl camera_shake
@@no_shake:
;update timer for phase
	ldrh r0, [r7, 0x10]
	sub r0, 0x01
	strh r0, [r7, 0x10]
	bgt @@endroutine
	mov r0, @PIKACHU_SURF_STATE_RETURN
	strh r0, [r7, 0x00]
@@endroutine:
	pop r4-r7, r15

pikachu_surf_spawn_wave2:
	push r4-r7, r14
	ldrb r2, [r5, 0x16]
	ldr r3, =pikachu_surf_panel_parameters
	lsl r2, r2, 0x03
	add r3, r3, r2
	ldr r2, [r3, 0x00]
	ldr r3, [r3, 0x04]
	ldrb r0, [r5, 0x12]
	ldrb r1, [r5, 0x13]
	push r0-r1
	bl object_check_panel_parameters
	tst r0, r0
	pop r0-r1
	bne @@valid_panel
	mov r0, 0x00
	b @@endroutine
@@valid_panel:
	mov r2, AttackElement_Aqua
	mov r3, 0x00
	mov r4, 0x00
	ldr r6, =(0x000A << 0x10) | (PIKACHU_SURF_DAMAGE)
	bl diveman_wave_object_spawn
@@endroutine:
	pop r4-r7, r15

pikachu_surf_init_surf_velocities:
	push r4-r7, r14
	bl object_get_coordinates_for_panels
	mov r2, r1
	mov r1, r0
	mov r3, 0x00
	mov r4, 38
	mov r0, 0x34
	add r0, r0, r5
	ldr r6, =0xFFFFC000
	bl math_get_thow_speeds
	str r0, [r5, 0x40]
	str r1, [r5, 0x44]
	str r2, [r5, 0x48]
	pop r4-r7, r15

pikachu_surf_return:
	push r4,r14
	ldrb r0,[r7, 0x01]
	tst r0,r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0,[r7, 0x01]
;destroy surfboard object
	mov r0, 0x00
	str r0, [r5, 0x4C]
	ldrb r0, [r5, 0x14]
	ldrb r1, [r5, 0x15]
	strb r0, [r5, 0x12]
	strb r1, [r5, 0x13]
	bl object_remove_panel_reserve
	bl object_set_coordinates_from_panels
	mov r0,0x00
	str r0, [r5, 0x3C]
	bl object_update_collision_panels
	mov r0, 0x01
	bl object_set_collision_region
	bl sprite_has_shadow
	mov r0, 0x40
	bl object_clear_flag
	mov r0, PIKACHU_ANIMATION_MOVE_IN
	strb r0, [r5, 0x10]
;set timer for phase
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