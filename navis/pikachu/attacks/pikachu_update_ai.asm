;AI struct layout
;r6 + 0x00 - high/low hp AI
;r6 + 0x01 - timesMoved
;r6 + 0x02 - attackPoints1
;r6 + 0x03 - attackPoints2
;r6 + 0x04 - bigAttackSwap

pikachu_update_ai:
	push r4, r6, r14
	ldrb r0, [r6, 0x00]
	ldr r1, =@@pikachu_update_ai_pool
	ldr r0, [r1, r0]
	mov r14, r15
	bx r0
	pop r4, r6, r15
	.pool
@@pikachu_update_ai_pool:
	.word pikachu_update_ai_high_hp|1;00
	.word pikachu_update_ai_low_hp|1;04

pikachu_update_ai_high_hp:
	push r4-r7, r14
;Find the opponent every time just in case
	ldrb r0, [r5, 0x16]
	mov r1, 0x01
	eor r0, r1
	bl battle_find_player
	str r0, [r7,0x2C];set found enemy megaman
	ldrb r0, [r6, 0x01]
	cmp r0, 0x02
	bge @@check_high_tier_attack
;add 0-7 attack points, which will determine the tier of attack
	bl rng1_get_int
	mov r1, 0x07
	and r0, r1
	ldrb r1, [r6, 0x02]
	add r1, r1, r0
	strb r1, [r6, 0x02]
	ldrb r0, [r6, 0x01]
	add r0, 0x01
	strb r0, [r6, 0x01]
	mov r0, PIKACHU_ATTACK_MOVE
	bl object_setattack0
	b @@endroutine
@@check_high_tier_attack:
;reset times moved when attacking
	mov r0, 0x00
	strb r0, [r6, 0x01]
	ldrb r0, [r6, 0x03]
	cmp r0, 3
	blt @@check_mid_tier_attack
;reset both attack points after highest tier attack
	mov r0, 0x00
	strh r0, [r6, 0x02]
	mov r0, PIKACHU_ATTACK_SURF
	bl object_setattack0
	b @@endroutine
@@check_mid_tier_attack:
	ldrb r0, [r6, 0x02]
	cmp r0, 25
	blt @@check_low_tier_attack
;lose a couple points but maintain progress towards high tier
	sub r0, 13
	strb r0, [r6, 0x02]
;increase progress towards high tier attack
	ldrb r0, [r6, 0x03]
	add r0, 0x01
	strb r0, [r6,0x03]
	bl rng1_get_int
	mov r1, 0x0F
	and r0, r1
	cmp r0, 0x09
	blt @@iron_tail
	mov r0, PIKACHU_ATTACK_QUICK_ATTACK
	bl object_setattack0
	b @@real_endroutine
@@iron_tail:
	bl pikachu_set_attack_iron_tail
	b @@endroutine
@@check_low_tier_attack:
	bl rng1_get_int
	mov r1, 0x0F
	and r0, r1
	cmp r0, 0x08
	blt @@thunder
	mov r0, PIKACHU_ATTACK_THUNDERBALL
	bl object_setattack0
	b @@endroutine
@@thunder:
	mov r0, PIKACHU_ATTACK_THUNDER
	bl object_setattack0
@@endroutine:
;If less than half HP start using low HP AI
	ldrh r0, [r5, 0x26]
	lsr r0, 0x01
	ldrh r1, [r5, 0x24]
	cmp r0, r1
	blt @@real_endroutine
	mov r0, 0x04
	str r0, [r6, 0x00]
@@real_endroutine:
	pop r4-r7, r15

pikachu_update_ai_low_hp:
	push r4-r7, r14
;Find the opponent every time just in case
	ldrb r0, [r5, 0x16]
	mov r1, 0x01
	eor r0, r1
	bl battle_find_player
	str r0, [r7,0x2C];set found target
	ldrb r0, [r6, 0x01]
	cmp r0, 0x02
	bge @@check_high_tier_attack
;add 0-7 attack points, which will determine the tier of attack
	bl rng1_get_int
	mov r1, 0x07
	and r0, r1
	add r0, r0, 0x01
	ldrb r1, [r6, 0x02]
	add r1, r1, r0
	strb r1, [r6, 0x02]
	ldrb r0, [r6, 0x01]
	add r0, 0x01
	strb r0, [r6, 0x01]
	mov r0, PIKACHU_ATTACK_MOVE
	bl object_setattack0
	b @@endroutine
@@check_high_tier_attack:
;reset times moved when attacking
	mov r0, 0x00
	strb r0, [r6, 0x01]
	ldrb r0, [r6, 0x03]
	cmp r0, 3
	blt @@check_mid_tier_attack
	ldrb r0, [r6, 0x03]
	sub r0, 0x02
	strb r0, [r6, 0x03]
	mov r0, 12
	strb r0, [r6, 0x02]
;alternate big attack
	ldrb r0, [r6, 0x04]
	mov r1, 0x01
	eor r1, r0
	strb r1, [r6, 0x04]
	tst r0, r0
	bne @@use_fly
	mov r0, PIKACHU_ATTACK_VOLT_TACKLE
	bl object_setattack0
	b @@real_endroutine
@@use_fly:
	mov r0, PIKACHU_ATTACK_FLY
	bl object_setattack0
	b @@endroutine
@@check_mid_tier_attack:
	ldrb r0, [r6, 0x02]
	cmp r0, 25
	blt @@check_low_tier_attack
;lose a couple points but maintain progress towards high tier
	sub r0, 10
	strb r0, [r6, 0x02]
;increase progress towards high tier attack
	ldrb r0, [r6, 0x03]
	add r0, 0x01
	strb r0, [r6,0x03]
	bl rng1_get_int
	mov r1, 0x0F
	and r0, r1
	cmp r0, 0x0C
	blt @@iron_tail
	mov r0, PIKACHU_ATTACK_SURF
	bl object_setattack0
	b @@real_endroutine
@@iron_tail:
	bl pikachu_set_attack_iron_tail
	b @@endroutine
@@check_low_tier_attack:
	bl rng1_get_int
	mov r1, 0x0F
	and r0, r1
	cmp r0, 0x06
	blt @@thunder
	mov r0, PIKACHU_ATTACK_THUNDERBALL
	bl object_setattack0
	b @@endroutine
@@thunder:
	mov r0, PIKACHU_ATTACK_THUNDER
	bl object_setattack0
@@endroutine:
;Return to normal AI if pikachu somehow recovers HP
	ldrh r0, [r5, 0x26]
	lsr r0, 0x01
	ldrh r1, [r5, 0x24]
	cmp r0, r1
	bgt @@real_endroutine
	mov r0, 0x00
	str r0, [r6, 0x00]
@@real_endroutine:
	pop r4-r7, r15

pikachu_set_attack_iron_tail:
	push r4-r7, r14
	add sp, -0x1C
;Get move parameters based on which side pikachu is on
	ldr r2, [r7, 0x2C]
	ldrb r0, [r2, 0x12]
	ldrb r1, [r2, 0x13]
	bl pikachu_check_iron_tail_panel
	bne @@validpanel
;if no player is found target any support objects
	ldr r2, =0x00800000
	mov r3, 0x00
	push r7
	add r7, sp, 0x04
	bl object_get_panels_filtered
	pop r7
	tst r0,r0
	beq @@use_thunder
	sub r2, r0, 0x01
	mov r3, sp
@@loop:
	ldrb r0, [r3, r2]
	lsr r1, r0, 0x04
	lsl r0, r0, 32-4
	lsr r0, r0, 32-4
	bl pikachu_check_iron_tail_panel
	bne @@validpanel
	sub r2, 0x01
	bgt @@loop
	b @@use_thunder
@@validpanel:
;if the panel in front of the opponent is clear just jump to that
	strb r0, [r7, 0x14]
	strb r1, [r7, 0x15]
	mov r0, PIKACHU_ATTACK_IRON_TAIL
	bl object_setattack0
	b @@endroutine
@@use_thunder:
;no alt targets found, just use thunder instead
	mov r0, PIKACHU_ATTACK_THUNDER
	bl object_setattack0
@@endroutine:
	add sp, 0x1C
	pop r4-r7, r15

pikachu_check_iron_tail_panel:
	push r2-r7, r14
	ldrb r2, [r5, 0x16]
	ldrb r3, [r5, 0x17]
	eor r2, r3
	lsl r2, 0x01
	sub r2, 0x01
	add r0, r0, r2
	ldr r3, =pikachu_iron_tail_jump_panel_parameters
	ldr r2, [r3, 0x00]
	ldr r3, [r3, 0x04]
	push r0, r1
	bl object_check_panel_parameters
	tst r0, r0
	pop r0, r1
	pop r2-r7, r15
	.pool
;eof