;include macros for pikachu for easier coding
	.include "pikachu_macros.asm"
;pikachu attacks
	.include "attacks/pikachu_update_ai.asm"
	.include "attacks/pikachu_move.asm"
	.include "attacks/pikachu_thunderball.asm"
	.include "attacks/pikachu_iron_tail.asm"
	.include "attacks/pikachu_thunder.asm"
	.include "attacks/pikachu_quick_attack.asm"
	.include "attacks/pikachu_surf.asm"
	.include "attacks/pikachu_fly.asm"
	.include "attacks/pikachu_volt_tackle.asm"

;reset a bunch of stuff that might have changed during an attack
;just in case it got interrupted by damage
pikachu_on_damage:
	push r14
;reset collision properties
;this also resets the damage
	mov r1, 0x10
	mov r2, 0x02
	mov r3, 0x03
	bl 0x0801A082
;reset collision shape
	mov r0, 0x01
	bl object_set_collision_region
;get attack state (r7 during attacks)
	ldr r2, [r5,0x58]
	add r2, 0xA0
;remove panels temporarily reserved during attacks
	ldrb r0, [r2, 0x14]
	ldrb r1, [r2, 0x15]
	bl object_remove_panel_reserve
	pop r15

;decompress DiveMan's sprite because it will be needed for surf
pikachu_decompress_diveman:
	push r14
	mov r0, 0x08
	mov r1, 0x0D
	bl sprite_decompress
	pop r15
;eof