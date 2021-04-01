@PIKACHU_FLY_STATE_START_FLOAT equ 0x00
@PIKACHU_FLY_STATE_AIR_IDLE equ 0x04
@PIKACHU_FLY_STATE_AIR_MOVE equ 0x08
@PIKACHU_FLY_STATE_LAND equ 0x0C
@PIKACHU_FLY_STATE_THUNDERBALL equ 0x10
@PIKACHU_FLY_STATE_LAND_MOVE equ 0x14
@PIKACHU_FLY_STATE_RESTART_FLOAT equ 0x18
@PIKACHU_FLY_STATE_RETURN equ 0x1C
@PIKACHU_FLY_STATE_END_IDLE equ 0x20

pikachu_fly:
	push r7, r14
	ldr r1, =@@pikachu_fly_pool
	ldrb r0, [r7, 0x00]
	ldr r1, [r0, r1]
	mov r14, r15
	bx r1
	bl object_highlight_current_collision_panels
	pop r7, r15
	.pool
@@pikachu_fly_pool:
	.word pikachu_fly_start_float|1;00
	.word pikachu_fly_air_idle|1;04
	.word pikachu_fly_air_move|1;08
	.word pikachu_fly_land|1;0C
	.word pikachu_fly_land_thunderball|1;10
	.word pikachu_fly_land_move|1;14
	.word pikachu_fly_restart_float|1;18
	.word pikachu_fly_return|1;0x1C
	.word pikachu_fly_end_idle|1;0x20

pikachu_fly_start_float:
	push r4-r7,r14
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
;save current panels to return to it at the end
	ldrb r0, [r5, 0x12]
	ldrb r1, [r5, 0x13]
	strb r0, [r5, 0x14]
	strb r1, [r5, 0x15]
	bl object_reserve_panel
;pikachu cannot be hit while using fly
	bl object_clear_collision_region
;fix coordinates just in case
	bl object_set_coordinates_from_panels
;start fly animation
	mov r0, PIKACHU_ANIMATION_FLY_BEGIN
	strb r0, [r5, 0x10]
;reset z coordinate
	mov r0, 0x00
	str r0, [r5, 0x3C]
;using this function to make the rise look a bit more interesting
;rise speed decreases over time
	ldr r1, [r5, 0x34]	;target x
	ldr r2, [r5, 0x38]	;target y
	ldr r3, =0x00200000	;target z
	mov r4, 0x30		;number of frames
	ldr r6,=0xFFFFF800	;z acceleration
	mov r0, 0x34
	add r0, r0, r5		;pointer to current coordinates
	bl math_get_thow_speeds
;only store z velocity because the other coordinates wont change
	str r2, [r5, 0x48]
	strh r4, [r7,0x10]
;spawn balloon object
	mov r4, PIKACHU_ANIMATION_BALLOON_INFLATE
	lsl r4, r4, 0x08
	add r4, 0x34
	mov r7, r5
	add r7, 0x4C
	bl temp_attack_object_spawn
;play balloon sound
	mov r0, 0x168 - 0xFF
	add r0, 0xFF
	bl sfx_play
	b @@endroutine
@@step_initialized:
;update Z position
	ldr r0, [r5, 0x3C]
	ldr r1, [r5, 0x48]
	add r0, r0, r1
	str r0, [r5, 0x3C]
;update z velocity by acceleration
	ldr r0, =0xFFFFF800
	add r1, r1, r0
	str r1, [r5, 0x48]
;Update timer
	ldrh r0, [r7,0x10]
	sub r0, 0x01
	strh r0, [r7,0x10]
;change balloon animation to the idle loop after inflate finishes
	cmp r0, 0x30 - 18
	bne @@inflate_animation_not_finished
;update pikachu's animation to idle loop
	mov r0, PIKACHU_ANIMATION_FLY
	strb r0, [r5, 0x10]
;check if the balloon object was allocated
	ldr r1, [r5, 0x4C]
	cmp r1, 0x00
	beq @@inflate_animation_not_finished
	mov r0, PIKACHU_ANIMATION_BALLOON_LOOP
	strb r0, [r1, 0x10]
@@inflate_animation_not_finished:
	ldrh r0, [r7, 0x10]
	cmp r0, 0x00
	bgt @@endroutine
	mov r0, @PIKACHU_FLY_STATE_AIR_IDLE
	strh r0, [r7, 0x00]
;set number of times to land
	mov r0, 0x03
	strb r0, [r7, 0x0F]
;reset the bytes used for thunders
	mov r0, 0x00
	str r0, [r7, 0x1C]
;reset the constantly spawning thunders
	bl pikachu_fly_reset_thunder
@@endroutine:
	pop r4-r7, r15

pikachu_fly_reset_thunder:
	push r4-r7, r14
	add sp, -0x1C
;thunder alternates between shapes
;update shape number
	ldrb r0, [r7, 0x1F]
	add r1, r0, 0x01
	strb r1, [r7, 0x1F]

	ldr r4, =pikachu_fly_thunder_shape_table
;get only last 2 bits of shape to index table
	lsl r0, r0, 32-2
	lsr r0, r0, 32-2
	ldrb r4, [r4, r0]
;get panels centered around the target
	ldr r2, [r7, 0x2C]
	ldrb r0, [r2, 0x12]
	ldrb r1, [r2, 0x13]
	ldrb r2, [r5, 0x16]
	lsl r2, r2, 0x03
	ldr r3, =pikachu_thunder_panel_parameters
	add r3, r3, r2
	ldr r2, [r3, 0x00]
	ldr r3, [r3, 0x04]
	ldrb r6, [r5, 0x16]
	push r7
	add r7, sp, 0x04
	bl object_get_panel_region
	pop r7
	tst r0, r0
	bne @@valid_panel
;fallback for there somehow being no panel
;get any panel matching thunder_panel_parameters
	ldrb r0, [r5, 0x16]
	lsl r0, r0, 0x03
	ldr r3, =pikachu_thunder_panel_parameters
	add r3, r3, r0
	ldr r2, [r3, 0x00]
	ldr r3, [r3, 0x04]
	push r7
	add r7, sp, 0x04
	bl object_get_panels_filtered
	pop r7
;assume this cant fail
@@valid_panel:
	mov r1, r0
	mov r2, r0
	mov r0, sp
	bl list_shuffle_byte
;get first panel result, this should be random now
	mov r0, sp
	ldrb r0, [r0, 0x00]
	lsr r1, r0, 0x04;get panelx
	lsl r0, r0, 32-4
	lsr r0, r0, 32-4;get panely
	strb r0, [r7, 0x1D]
	strb r1, [r7, 0x1E]
;set number of frames before thunder hits
	mov r0, 0x20
	strb r0, [r7, 0x1C]
	add sp, 0x1C
	pop r4-r7, r15

pikachu_fly_update_thunder:
	push r4-r7, r14
	ldrb r0, [r7, 0x1C]
	sub r0, 0x01
	strb r0, [r7, 0x1C]
	lsr r1, r0, 0x03
	bcs @@no_panel_highlight
	ldrb r0, [r7, 0x1D]
	ldrb r1, [r7, 0x1E]
	bl object_highlight_panel
@@no_panel_highlight:
	ldrb r0, [r7, 0x1C]
	cmp r0, 0x00
	bgt @@endroutine
	ldrb r0, [r7, 0x1D]
	ldrb r1, [r7, 0x1E]
	mov r2, AttackElement_Elec
	mov r3, 0x00
	mov r4, 0x00
	ldr r6, =(0x000A << 0x10) | (PIKACHU_THUNDER_DAMAGE)
	bl thunderbolt_object_spawn
	bl pikachu_fly_reset_thunder
@@endroutine:
	pop r4-r7, r15

pikachu_fly_air_idle:
	push r4-r7, r14
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
	mov r0, 0x20
	strh r0, [r7, 0x10]
	b @@endroutine
@@step_initialized:
	bl pikachu_fly_update_thunder
	ldrh r0, [r7, 0x10]
	sub r0, 0x01
	strh r0, [r7, 0x10]
	bgt @@endroutine
	mov r0, @PIKACHU_FLY_STATE_AIR_MOVE
	strh r0, [r7, 0x00]
@@endroutine:
	pop r4-r7, r15

pikachu_fly_air_move:
	push r4-r7,r14
	add sp, -0x1C
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
;set timer for phase
	mov r0, 0x40
	strh r0, [r7, 0x10]
;Find an adjacent panel to fly to
	ldrb r0, [r5, 0x16]
	ldr r3, =pikachu_fly_air_panel_parameters
	lsl r0, r0, 0x03
	add r3, r3, r0
	ldr r2, [r3, 0x00]
	ldr r3, [r3, 0x04]
	ldrb r0, [r5, 0x12]
	ldrb r1, [r5, 0x13]
	mov r4, 0x10
	ldrb r6, [r5, 0x16]
	push r7
	add r7, sp, 0x04
	bl object_get_panel_region
	pop r7
	tst r0, r0
	bne @@valid_panel
	mov r0, @PIKACHU_FLY_STATE_LAND
	strh r0, [r7, 0x00]
	b @@endroutine
@@valid_panel:
	mov r1, r0
	mov r2, r0
	mov r0, sp
	bl list_shuffle_byte
	mov r0, sp
	ldrb r0, [r0, 0x00]
	lsr r1, r0, 0x04
	lsl r0, r0, 32 - 4
	lsr r0, r0, 32 - 4
	strb r0, [r7, 0x14]
	strb r1, [r7, 0x15]
	bl object_reserve_panel
	ldrb r0, [r7, 0x14]
	ldrb r1, [r7, 0x15]
	bl object_get_coordinates_for_panels
	ldr r3, [r5, 0x34]
	ldr r4, [r5, 0x38]
;get distance between current coordinates and target
;and set x and y velocity so pikachu reaches the target in a constant number of frames
	sub r0, r0, r3
	sub r1, r1, r4
	push r1
	mov r1, 0x40
	swi 6;DIV
	str r0, [r5, 0x40]
	pop r0
	mov r1, 0x40
	swi 6;DIV
	str r0, [r5, 0x44]
@@step_initialized:
	bl pikachu_fly_update_thunder
;update coordinates based on velocity
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
;Update timer
	ldrh r0, [r7,0x10]
	sub r0, 0x01
	strh r0, [r7,0x10]
	bgt @@endroutine
	mov r0, @PIKACHU_FLY_STATE_LAND
	strh r0, [r7, 0x00]
@@endroutine:
	add sp, 0x1C
	pop r4-r7, r15

pikachu_fly_land:
	push r4,r14
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
;using this function to make the landing look a bit more interesting
;land speed increases slightly over time
	bl object_set_coordinates_from_panels
;reset z coordinate
	ldr r0, =0x00200000
	str r0, [r5, 0x3C]
	ldr r1, [r5, 0x34]
	ldr r2, [r5, 0x38]
	mov r3, 0x00
	mov r4, 0x30
	ldr r6,=0x00000800
	mov r0, 0x34
	add r0, r0, r5
	bl math_get_thow_speeds
	str r2, [r5, 0x48]
	strh r4, [r7,0x10]
;start landing sound
	mov r0, 0xEA
	bl sfx_play
	b @@endroutine
@@step_initialized:
	bl pikachu_fly_update_thunder
;update Z position
	ldr r0, [r5, 0x3C]
	ldr r1, [r5, 0x48]
	add r0, r0, r1
	str r0, [r5, 0x3C]
;update z velocity by acceleration
	ldr r0, =0x00000800
	add r1, r1, r0
	str r1, [r5, 0x48]
;Update timer
	ldrh r0, [r7,0x10]
	sub r0, 0x01
	strh r0, [r7,0x10]
	bgt @@endroutine
	mov r0, @PIKACHU_FLY_STATE_THUNDERBALL
	strh r0, [r7, 0x00]
	ldrb r0, [r7, 0x14]
	ldrb r1, [r7, 0x15]
	bl object_remove_panel_reserve
@@endroutine:
	pop r4, r15

pikachu_fly_land_thunderball:
	push r4-r7, r14
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
;use a timer so pikachu idles on the panel before moving
	mov r0, 0x20
	strh r0, [r7, 0x10]
;after landing pikachu can be hit
	mov r0, 0x01
	bl object_set_collision_region
	bl object_get_front_direction
	ldrb r1, [r5, 0x12]
	add r0, r1, r0
	ldrb r1, [r5, 0x13]
	mov r2, AttackElement_Elec
	mov r3, 0x0A
	lsl r3, 0x10;thunderball z coordinate
	;thunder ball parameters
	;01 = controls speed
	;04 = number of panels to move
	;10 = status effect on collision
	;00 = cause bug on collision
	ldr r4, =0x00100401
	ldr r6,= (0x0A << 0x10) | (PIKACHU_THUNDERBALL_DAMAGE)
	mov r7, 0x00
	bl thunderball_object_spawn
	b @@endroutine
@@step_initialized:
	ldrh r0, [r7, 0x10]
	sub r0, 0x01
	strh r0, [r7, 0x10]
	bgt @@endroutine
	mov r0, @PIKACHU_FLY_STATE_LAND_MOVE
	strh r0, [r7, 0x00]
@@endroutine:
	pop r4-r7, r15

pikachu_fly_land_move:
	push r4-r7,r14
	add sp, -0x1C
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
;set timer for phase
	mov r0, 0x40
	strh r0, [r7, 0x10]
;Find an adjacent panel to fly to
	ldrb r0, [r5, 0x16]
	ldr r3, =pikachu_fly_land_panel_parameters
	lsl r0, r0, 0x03
	add r3, r3, r0
	ldr r2, [r3, 0x00]
	ldr r3, [r3, 0x04]
	ldrb r0, [r5, 0x12]
	ldrb r1, [r5, 0x13]
	mov r4, 0x0A
	ldrb r6, [r5, 0x16]
	push r7
	add r7, sp, 0x04
	bl object_get_panel_region
	pop r7
	tst r0, r0
	bne @@valid_panel
	mov r0, @PIKACHU_FLY_STATE_RESTART_FLOAT
	strh r0, [r7, 0x00]
	;mov r0, PIKACHU_ANIMATION_FLY
	;strb r0, [r5, 0x10]
	b @@endroutine
@@valid_panel:
	mov r1, r0
	mov r2, r0
	mov r0, sp
	bl list_shuffle_byte
	mov r0, sp
	ldrb r0, [r0, 0x00]
	lsr r1, r0, 0x04
	lsl r0, r0, 32 - 4
	lsr r0, r0, 32 - 4
	strb r0, [r7, 0x14]
	strb r1, [r7, 0x15]
	bl object_reserve_panel
	ldrb r0, [r7, 0x14]
	ldrb r1, [r7, 0x15]
	bl object_get_coordinates_for_panels
	ldr r3, [r5, 0x34]
	ldr r4, [r5, 0x38]
	sub r0, r0, r3
	sub r1, r1, r4
	push r1
	mov r1, 0x40
	swi 6
	str r0, [r5, 0x40]
	pop r0
	mov r1, 0x40
	swi 6
	str r0, [r5, 0x44]
@@step_initialized:
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
;Update timer
	ldrh r0, [r7,0x10]
	sub r0, 0x01
	strh r0, [r7,0x10]
	bgt @@endroutine
	ldrb r0, [r7, 0x14]
	ldrb r1, [r7, 0x15]
	bl object_remove_panel_reserve
	mov r0, @PIKACHU_FLY_STATE_RESTART_FLOAT
	strh r0, [r7, 0x00]
@@endroutine:
	add sp, 0x1C
	pop r4-r7, r15

pikachu_fly_restart_float:
	push r4,r14
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
	bl object_clear_collision_region
	bl object_set_coordinates_from_panels
	mov r0, 0x00
	str r0, [r5, 0x3C]
	ldr r1, [r5, 0x34]
	ldr r2, [r5, 0x38]
	ldr r3, =0x00200000
	mov r4, 0x30
	ldr r6,=0xFFFFF800
	mov r0, 0x34
	add r0, r0, r5
	bl math_get_thow_speeds
	str r2, [r5, 0x48]
	strh r4, [r7,0x10]
	mov r0, 0x168 - 0xFF
	add r0, 0xFF
	bl sfx_play
	b @@endroutine
@@step_initialized:
	bl pikachu_fly_update_thunder
;update Z position
	ldr r0, [r5, 0x3C]
	ldr r1, [r5, 0x48]
	add r0, r0, r1
	str r0, [r5, 0x3C]
;update z velocity by acceleration
	ldr r0, =0xFFFFF800
	add r1, r1, r0
	str r1, [r5, 0x48]
;Update timer
	ldrh r0, [r7,0x10]
	sub r0, 0x01
	strh r0, [r7,0x10]
	bgt @@endroutine
;check if pikachu has landed enough times
	ldrb r0, [r7, 0x0F]
	sub r0, 0x01
	strb r0, [r7, 0x0F]
	bgt @@continue_attack
	mov r0, @PIKACHU_FLY_STATE_RETURN
	strh r0, [r7, 0x00]
	b @@endroutine
@@continue_attack:
	mov r0, @PIKACHU_FLY_STATE_AIR_IDLE
	strh r0, [r7, 0x00]
@@endroutine:
	pop r4, r15
.pool
pikachu_fly_return:
	push r4-r7,r14
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
	bl object_get_coordinates_for_panels
	mov r4, 0x40
	ldrb r0, [r5,0x14]
	ldrb r1, [r5,0x12]
	sub r0,r0,r1
	add r0,0x01
	bmi @@normalspeed
	cmp r0,0x03
	bge @@normalspeed
	ldrb r0, [r5,0x15]
	ldrb r1, [r5,0x13]
	sub r0,r0,r1
	add r0,0x01
	bmi @@normalspeed
	cmp r0,0x03
	bge @@normalspeed
@@fastmove:
	lsr r4, r4, 0x01
@@normalspeed:
	strh r4, [r7, 0x10]
	ldrb r0, [r5, 0x14]
	ldrb r1, [r5, 0x15]
	bl object_get_coordinates_for_panels
	mov r2, r1
	mov r1, r0
	mov r3, 0x00
	mov r0, 0x34
	add r0, r0, r5
	mov r6, 0x00
	bl math_get_thow_speeds
	str r0, [r5, 0x40]
	str r1, [r5, 0x44]
	str r2, [r5, 0x48]
	mov r0, 0xEA
	bl sfx_play
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
;Update timer
	ldrh r0, [r7,0x10]
	sub r0, 0x01
	strh r0, [r7,0x10]
	bgt @@endroutine
	ldrb r0, [r5, 0x14]
	ldrb r1, [r5, 0x15]
	strb r0, [r5, 0x12]
	strb r1, [r5, 0x13]
	bl object_remove_panel_reserve
	mov r0, 0x01
	bl object_set_collision_region
	bl object_set_coordinates_from_panels
	bl object_update_collision_panels
	mov r0, @PIKACHU_FLY_STATE_END_IDLE
	strh r0, [r7, 0x00]
@@endroutine:
	pop r4-r7, r15

pikachu_fly_end_idle:
	push r4-r7, r14
	ldrb r0, [r7, 0x01]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r7, 0x01]
	mov r0, PIKACHU_ANIMATION_FLY_END
	strb r0, [r5, 0x10]
	mov r0, PIKACHU_ANIMATION_BALLOON_DEFLATE
	ldr r1, [r5, 0x4C]
	cmp r1, 0x00
	beq @@no_balloon
	strb r0, [r1, 0x10]
@@no_balloon:
	mov r0, 0x20
	strh r0, [r7, 0x10]
	b @@endroutine
@@step_initialized:
	ldrh r0, [r7, 0x10]
	sub r0, 0x01
	strh r0, [r7, 0x10]
	bgt @@endroutine
	mov r0, PIKACHU_ANIMATION_IDLE
	strb r0, [r5, 0x10]
;causes balloon to delete itself
	mov r0, 0x00
	str r0, [r5, 0x4C]
	bl object_exit_attack_state
@@endroutine:
	pop r4-r7, r15