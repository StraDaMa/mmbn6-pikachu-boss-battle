.gba
.relativeinclude on

.open "input.gba", "MEGAMAN6_FXX_BR6E00.gba", 0x08000000
	.include "defines.asm"

	.include "macros/attack_macros.asm"
	.include "macros/npc_macros.asm"
	.include "macros/map_flag_listener_macros.asm"
	.include "macros/map_cutscene_macros.asm"
	.include "macros/chip_macros.asm"

;Routines here
.org 0x081CA740;ProtoSoul sprite sheet
	.area 0x5460+0x58C0
	.include "navis/navis_code.asm"
	.include "sprite/sprite_code.asm"
	.include "objects/objects_code.asm"
	.include "map/map_code.asm"
	.include "chips/chips_code.asm"
	.pool
	.endarea

;General writes here
	.include "navis/navis.asm"
	.include "sprite/sprite.asm"
	.include "objects/objects.asm"
	.include "map/map.asm"
	.include "chips/chips.asm"
	.include "text/text.asm"

;End of ROM freespace writes
.org 0x087FE380
	.include "navis/navis_freespace.asm"
	.include "sprite/sprite_freespace.asm"
	.include "objects/objects_freespace.asm"
	.include "map/map_freespace.asm"
	.include "chips/chips_freespace.asm"
	.include "text/text_freespace.asm"
.close
;eof