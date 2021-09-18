.gba
.relativeinclude on

.if _version == 1
	@INPUT_ROM equ "input_jp.gba"
	@OUTPUT_ROM equ "ROCKEXE6_FXX_BR6J00.gba"
;Count's sprite
	@CODE_FREESPACE_START equ 0x082EFE48
	@CODE_FREESPACE_SIZE equ 0x082F3224 - 0x082EFE48
.else
	@INPUT_ROM equ "input_us.gba"
	@OUTPUT_ROM equ "MEGAMAN6_FXX_BR6E00.gba"
;Unused Proto Soul sprite sheet
	@CODE_FREESPACE_START equ 0x081CA740
	@CODE_FREESPACE_SIZE equ 0x5460+0x58C0
.endif

.open @INPUT_ROM, @OUTPUT_ROM, 0x08000000

	.include "macros/version_macros.asm"
	.include "macros/attack_macros.asm"
	.include "macros/npc_macros.asm"
	.include "macros/map_flag_listener_macros.asm"
	.include "macros/map_cutscene_macros.asm"
	.include "macros/chip_macros.asm"

	.include "defines.asm"

;Routines here
.org @CODE_FREESPACE_START
	.area @CODE_FREESPACE_SIZE
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
.vorg 0x087FE380, 0x087FF500
	.include "navis/navis_freespace.asm"
	.include "sprite/sprite_freespace.asm"
	.include "objects/objects_freespace.asm"
	.include "map/map_freespace.asm"
	.include "chips/chips_freespace.asm"
	.include "text/text_freespace.asm"
.close
;eof