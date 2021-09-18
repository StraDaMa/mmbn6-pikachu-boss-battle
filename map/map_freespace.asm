.if _version == 1
	@LANS_ROOM_FL_UPDATE_RESUME1 equ 0x080511E3
	@LANS_ROOM_FL_UPDATE_RESUME2 equ 0x080511BB
	@LANS_ROOM_FL_UPDATE_END equ 0x080513A3
	@LANS_ROOM_FL_INIT_RESUME1 equ 0x08050F81
	@LANS_ROOM_FL_INIT_RESUME2 equ 0x08050F67
	@LANS_ROOM_FL_INIT_END equ 0x080511B3
.else
	@LANS_ROOM_FL_UPDATE_RESUME1 equ 0x0804F773
	@LANS_ROOM_FL_UPDATE_RESUME2 equ 0x0804F74B
	@LANS_ROOM_FL_UPDATE_END equ 0x0804F933
	@LANS_ROOM_FL_INIT_RESUME1 equ 0x0804F511
	@LANS_ROOM_FL_INIT_RESUME2 equ 0x0804F4F7
	@LANS_ROOM_FL_INIT_END equ 0x0804F743
.endif

.align 4
lans_room_npc_list:
	.vword 0x08051B64, 0x080535CC
	.word lans_room_pikachu_npc
	.word 0x000000FF

.align 4
lans_room_cutscene_text:
	.vimport "../temp/lans_room.msg", "../temp/lans_room_jp.msg"

lans_room_pikachu_npc:
	NPC_MAKE_VISIBLE
	NPC_SET_SPRITE_CHAR PIKACHU_OW_SPRITE_INDEX
	NPC_SET_ANIMATION 0x00
	NPC_SET_DIALOG2 0x01
	NPC_SET_POSITION 32, -8, 0x0000
	NPC_NO_TURN_ON_INTERACT
	NPC_JUMP_LINKED @lans_room_pikachu_npc_loop
@lans_room_pikachu_npc_loop:
	NPC_WAIT 0x01
	NPC_JUMP @lans_room_pikachu_npc_loop

lans_room_flag_listener_hook:
	FL_JUMP_IF_FLAG_NOT_ON 0x130F, @@no_pikachu_battle
	FL_START_CUTSCENE lans_room_pikachu_cutscene, 0x00000000
	FL_JUMP @LANS_ROOM_FL_UPDATE_END
@@no_pikachu_battle:
;return to regular code
	FL_JUMP_IF_PROGRESS_BETWEEN 0x00, 0x0F, @LANS_ROOM_FL_UPDATE_RESUME1
	FL_JUMP @LANS_ROOM_FL_UPDATE_RESUME2

lans_room_pikachu_cutscene:
	CS_LOCK_PLAYER
	CS_WAIT_FOR_UNPAUSE
	CS_WAIT_FOR_SCREEN_TRANSITION
	CS_WAIT 0x1E
	CS_CALL_ASM lans_room_start_pikachu_battle|1
	CS_UNLOCK_PLAYER
	CS_END

.if _version == 1
	@LANS_ROOM_CS_TEXT_OFFSET equ 0x02030004
.else
	@LANS_ROOM_CS_TEXT_OFFSET equ 0x0202FA04
.endif

lans_room_after_battle_pikachu_cutscene:
	CS_LOCK_PLAYER
	CS_DECOMPRESS_TEXT @LANS_ROOM_CS_TEXT_OFFSET
	CS_WAIT 0x1E
	CS_SET_SCREEN_TRANSITION 0x08, 0x08
	CS_WAIT_FOR_SCREEN_TRANSITION
	CS_WAIT 0x1E
	CS_START_MESSAGE_VAR 0x04
	CS_WAIT_FOR_MESSAGE_PARAMETER 0x80
	CS_UNLOCK_PLAYER
	CS_END

.align 4
lans_room_pikachu_battle:
	.byte 0x00 ;Battlefield
	.byte 0x00 ;byte1
	.byte 0x15 ;Music
	.byte 0x00 ;Battle Mode
	.byte 0x04 ;Background (Sky HP)
	.byte 0x00 ;Battle Count
	.byte 0x38 ;Panel pattern
	.byte 0x00 ;byte7
	.word 0x004198D7
	.word lans_room_pikachu_battle_layout

.align 4
lans_room_pikachu_battle_layout:
;player
	.byte 0x00, 0x22 :: .halfword 0x0000
;pikachu
	.byte 0x11, 0x25 :: .halfword 0x0161
	.byte 0xF0

lans_room_init_flag_listener_hook:
	FL_JUMP_IF_FLAG_NOT_ON 0x130F, @@no_pikachu_battle
	FL_JUMP_IF_PREVIOUS_BATTLE_OUTCOME_NOT_EQUAL 0x01, @@failedBattle
	FL_START_CUTSCENE lans_room_after_battle_pikachu_cutscene, 0x00000003
	FL_JUMP @LANS_ROOM_FL_INIT_END
@@failedBattle:
	FL_START_CUTSCENE lans_room_after_battle_pikachu_cutscene, 0x00000004
	FL_JUMP @LANS_ROOM_FL_INIT_END
@@no_pikachu_battle:
;return to regular code
	FL_JUMP_IF_PROGRESS_BETWEEN 0x00, 0x0F, @LANS_ROOM_FL_INIT_RESUME1
	FL_JUMP @LANS_ROOM_FL_INIT_RESUME2
;eof