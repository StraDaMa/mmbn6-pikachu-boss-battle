
pikachu_fly_thunder_shape_table:
	.byte 0x01, 0x10, 0x09, 0x0C

.align 4
pikachu_ai_struct1:
	.byte PIKACHU_SPRITE_CATEGORY;sprite_category
	.byte PIKACHU_SPRITE_INDEX;sprite_index
	.byte 0x01;palettes_per_version
	.byte 0x01;enemy_type
	.byte 0x00;collision_damage
	.byte AttackElement_Elec;element
	.byte 0x00;secondary_element
	.byte 0x01;has_shadow

.align 4
pikachu_ai_struct2:
	.halfword (AttackElement_Elec << 12) | 2500;hp + element
	.byte 0x00;version
	.byte 0x00;collision_flags
	.halfword 0x000A;collision_damage

.align 4
pikachu_chip_pool:
	.import "chippool.bin"

.align 4
pikachu_attack_pool:
;first 8 pointers are usually the same for every navi
	.vword 0x08016381, 0x08016981;0
	.vword 0x08017889, 0x08017E19;1
	.vword 0x080170C5, 0x08017655;2
	.vword 0x080174FF, 0x08017A8F;3
	.vword 0x080175B9, 0x08017B49;4
	.vword 0x080178B7, 0x08017E47;5
	.vword 0x08017689, 0x08017C19;6
	.vword 0x08017769, 0x08017CF9;7
	.word pikachu_update_ai|1;8
	.word pikachu_move|1;9
	.word pikachu_thunderball|1;A
	.word pikachu_iron_tail|1;B
	.word pikachu_thunder|1;C
	.word pikachu_volt_tackle_quick_attack|1;D
	.word pikachu_surf|1;E
	.word pikachu_fly|1;F

.align 4
pikachu_quick_attack_collision_checks:
	.word 0x05800000
	.word 0x0A800000

.align 4
pikachu_iron_tail_jump_panel_parameters:
	.word 0x00000010
	.word 0x0F880080

.align 4
pikachu_move_parameters:
	.word 0x00000010
	.word 0x0F8800A0
	.word 0x00000030
	.word 0x0F880080

.align 4
pikachu_thunder_panel_parameters:
	.word 0x00000020
	.word 0x00000000
	.word 0x00000000
	.word 0x00000020

.align 4
pikachu_surf_panel_parameters:
	.word 0x00000010
	.word 0x0B800000
	.word 0x00000010
	.word 0x07800000

.align 4
pikachu_fly_air_panel_parameters:
	.word 0x00000000
	.word 0x00000020
	.word 0x00000020
	.word 0x00000000

.align 4
pikachu_fly_land_panel_parameters:
	.word 0x00000000
	.word 0x0F8800A0
	.word 0x00000020
	.word 0x0F880080
;eof