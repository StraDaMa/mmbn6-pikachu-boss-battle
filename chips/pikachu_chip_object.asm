pikachu_chip_object_main:
	push r14
	ldr r1, =@@pikachu_chip_object_main_pool
	ldrb r0, [r5, 0x08]
	ldr r1, [r1, r0]
	mov r14, r15
	bx r1
	pop r15
	.pool
@@pikachu_chip_object_main_pool:
	.word pikachu_chip_object_init|1;0
	.word pikachu_chip_object_update|1;4
	.word object_generic_destroy|1;8

pikachu_chip_object_init:
	push r14
;make visable
	ldrb r0, [r5]
	mov r1,0x02
	orr r0,r1
	strb r0, [r5]

	mov r0,0x80
	mov r1, PIKACHU_SPRITE_CATEGORY
	mov r2, PIKACHU_SPRITE_INDEX
	bl sprite_load
	bl sprite_load_animation_data
	bl sprite_has_shadow
	bl object_set_coordinates_from_panels
	mov r0,0x00
	str r0, [r5, 0x3C]
	strh r0, [r5,0x10]
	bl sprite_set_animation
	bl sprite_load_animation_data

	mov r0,0x04
	str r0, [r5,0x08]
;set flip
	bl object_get_flip
	bl sprite_set_flip
	bl pikachu_chip_object_update
	pop r15

pikachu_chip_object_update:
	push r14
	ldrb r0, [r5, 0x0A]
	ldr r1, =@@pikachu_chip_object_update_pool
	ldr r1, [r1, r0]
	mov r14, r15
	bx r1
	bl object_update_sprite_timestop
	pop r15
	.pool
@@pikachu_chip_object_update_pool:
	.word pikachu_chip_object_update_appear|1;00
	.word pikachu_chip_object_update_idle|1;04
	.word pikachu_chip_object_update_begin|1;08
	.word pikachu_chip_object_update_charge|1;0C
	.word pikachu_chip_object_update_attack|1;10
	.word pikachu_chip_object_update_end|1;14

;00
pikachu_chip_object_update_appear:
	push r14
	ldrb r0, [r5, 0x0B]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r5, 0x0B]
	mov r0, PIKACHU_ANIMATION_MOVE_IN
	strb r0, [r5, 0x10]
	mov r0, 0x04
	strh r0, [r5, 0x20]
	mov r0, 0x94
	bl sfx_play
@@step_initialized:
	ldrh r0, [r5, 0x20]
	sub r0, 0x1
	strh r0, [r5, 0x20]
	bgt @@endroutine
	mov r0, 0x04
	strh r0, [r5, 0x0A]
@@endroutine:
	pop r15

;04
pikachu_chip_object_update_idle:
	push r14
	ldrb r0, [r5, 0x0B]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r5, 0x0B]
	mov r0, PIKACHU_ANIMATION_IDLE
	strb r0, [r5, 0x10]
	mov r0, 0x10
	strh r0, [r5, 0x20]
@@step_initialized:
	ldrh r0, [r5, 0x20]
	sub r0, 0x1
	strh r0, [r5, 0x20]
	bgt @@endroutine
	mov r0, 0x08
	strh r0, [r5, 0x0A]
@@endroutine:
	pop r15

;08
pikachu_chip_object_update_begin:
	push r14
	ldrb r0, [r5, 0x0B]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r5, 0x0B]
	mov r0, PIKACHU_ANIMATION_VOLT_TACKLE_BEGIN
	strb r0, [r5, 0x10]
	mov r0, 0x0C
	strh r0, [r5, 0x20]
@@step_initialized:
	ldrh r0, [r5, 0x20]
	sub r0, 0x1
	strh r0, [r5, 0x20]
	bgt @@endroutine
	mov r0, 0x0C
	strh r0, [r5, 0x0A]
;initialize timer used for yellowing
	mov r0, 0x08
	str r0, [r5, 0x64]
@@endroutine:
	pop r15

;0C
pikachu_chip_object_update_charge:
	push r4-r7, r14
	ldrb r0, [r5, 0x0B]
	tst r0, r0
	bne @@state_initialized
	mov r0, 0x04
	strb r0, [r5, 0x0B]
	mov r0, PIKACHU_ANIMATION_THUNDER_ATTACK
	strb r0, [r5, 0x10]
	mov r0, 48
	strh r0, [r5, 0x20]
	mov r0, 0x01
	strh r0, [r5, 0x22]
	mov r0, 0xC6
	bl sfx_play
@@state_initialized:
	ldr r0, [r5, 0x64]
	add r0, 0x01
	cmp r0, 0x1F
	ble @@no_reset
	mov r0, 0x08
@@no_reset:
	str r0, [r5, 0x64]
	lsl r1, r0, 0x05
	orr r0,r1
	bl sprite_set_color_shader
	ldrh r0, [r5, 0x22]
	sub r0, 0x01
	strh r0, [r5, 0x22]
	bne @@no_spark
	mov r0, 0x0C
	strh r0, [r5, 0x22]
	bl rng1_get_int
	mov r4, 0x1F
	mov r6, 0x1F
	and r4, r0
	lsr r0, 0x08
	and r6, r0
	lsl r4, r4, 32-5
	asr r4, r4, 32-5 - 16
	lsl r6, r6, 0x10
	mov r0, 0x34
	add r0, r5, r0
	ldmia r0!, r1-r3
	add r1, r1, r4
	add r3, r3, r6
	mov r4, 0x0A
	bl effect_object_spawn
@@no_spark:
	ldrh r0, [r5, 0x20]
	sub r0, 0x01
	strh r0, [r5, 0x20]
	bgt @@endroutine
	mov r0, 0x10
	strh r0, [r5, 0x0A]
@@endroutine:
	pop r4-r7, r15

;10
pikachu_chip_object_update_attack:
	push r4-r7, r14
	ldrb r0, [r5, 0x0B]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r5, 0x0B]
	mov r0, PIKACHU_ANIMATION_QUICK_ATTACK
	strb r0, [r5, 0x10]
	bl object_get_front_direction
	ldr r1, =(0x00280000) / 6
	mul r0, r1
	str r0, [r5, 0x40]
	mov r0, 0x00
	strh r0, [r5, 0x20]
;clear previous panel
	mov r0, 0x00
	strh r0, [r5, 0x14]
	ldr r4, =0x00010035
	mov r7, r5
	add r7, 0x60
	bl temp_attack_object_spawn
	mov r0, 0xA1
	bl sfx_play
	b @@endroutine
@@step_initialized:
;Set this every frame so the wave stays slightly in front of pikachu
	bl object_get_front_direction
	mov r1, 0x08
	lsl r1, r1, 0x10
	mul r1, r0
	ldr r0, [r5, 0x60]
	str r1, [r0, 0x40]
	ldr r0, [r5, 0x64]
	add r0, 0x01
	cmp r0, 0x1F
	ble @@no_reset
	mov r0, 0x08
@@no_reset:
	str r0, [r5, 0x64]
	lsl r1, r0, 0x05
	orr r0,r1
	bl sprite_set_color_shader
	ldr r0, [r5, 0x34]
	ldr r2, [r5, 0x40]
	add r0, r0, r2
	str r0, [r5, 0x34]
	bl object_set_panels_from_coordinates
	ldrh r0, [r5, 0x12]
	ldrh r1, [r5, 0x14]
	cmp r0, r1
	beq @@samePanel
	strh r0, [r5, 0x14]
	ldrb r0, [r5, 0x12]
	ldrb r1, [r5, 0x13]
	mov r2, AttackElement_Elec
	mov r3, 0x00
	ldr r4,=0x30050301
	ldr r6, [r5, 0x2C]
	mov r7, 0x03
	bl collision_region_spawn_timefreeze
@@samePanel:
	ldrh r0, [r5, 0x20]
	add r0, r0, 0x01
	strh r0, [r5, 0x20]
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
	mov r0, 0x14
	strh r0, [r5, 0x0A]
@@endroutine:
	pop r4-r7, r15

;14
pikachu_chip_object_update_end:
	push r14
	ldrb r0, [r5, 0x0B]
	tst r0, r0
	bne @@step_initialized
	mov r0, 0x04
	strb r0, [r5, 0x0B]

	mov r0, PIKACHU_ANIMATION_MOVE_IN
	strb r0, [r5, 0x10]

;destroy thunder wave object
	mov r0, 0x00
	str r0, [r5, 0x60]

	mov r0, 0x34
	add r0, r5, r0
	ldmia r0!, r1-r3
	mov r4, 0x08
	lsl r4, r4, 0x10
	add r3, r3, r4
	mov r4, 0x14
	bl effect_object_spawn

	mov r0, 0x04
	strh r0, [r5, 0x20]
@@step_initialized:
	ldrh r0, [r5, 0x20]
	sub r0, 0x01
	strh r0, [r5, 0x20]
	bgt @@endroutine
	mov r0, 0x08
	str r0, [r5, 0x08]
@@endroutine:
	pop r15


pikachu_chip_object_spawn:
	push r14
	push r0-r2,r5
	;Was used for Count's chip
	mov r0, PIKACHU_CHIP_OBJECT_ID
	bl object_type1_allocate
	mov r0,r5
	pop r1-r3,r5
	beq @@endroutine
	strb r1, [r0,0x12]
	strb r2, [r0,0x13]
	strb r3, [r0,0x0E]
	str r5, [r0,0x4C]
	ldrh r1, [r5,0x16]
	strh r1, [r0,0x16]
	str r6, [r0,0x2C]
	str r7, [r0,0x54]
	mov r1,0x01
	strb r1, [r7]
@@endroutine:
	pop r15
.pool
;eof