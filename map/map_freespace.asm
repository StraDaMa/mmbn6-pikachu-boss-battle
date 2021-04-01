.align 4
lans_room_npc_list:
	.word 0x08051B64
	.word lans_room_pikachu_npc
	.word 0x000000FF

.align 4
lans_room_cutscene_text:
	.import "../temp/lans_room.msg"

lans_room_pikachu_npc:
	NPC_MAKE_VISIBLE
	NPC_SET_SPRITE_CHAR 0x34
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
	FL_JUMP 0x0804F933
@@no_pikachu_battle:
;return to regular code
	FL_JUMP_IF_PROGRESS_BETWEEN 0x00, 0x0F, 0x0804F773
	FL_JUMP 0x0804F74B

lans_room_pikachu_cutscene:
	CS_LOCK_PLAYER
	CS_WAIT_FOR_UNPAUSE
	CS_WAIT_FOR_SCREEN_TRANSITION
	CS_WAIT 0x1E
	CS_CALL_ASM lans_room_start_pikachu_battle|1
	CS_UNLOCK_PLAYER
	CS_END

lans_room_after_battle_pikachu_cutscene:
	CS_LOCK_PLAYER
	CS_DECOMPRESS_TEXT 0x0202FA04
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
	FL_JUMP 0x0804F743
@@failedBattle:
	FL_START_CUTSCENE lans_room_after_battle_pikachu_cutscene, 0x00000004
	FL_JUMP 0x0804F743
@@no_pikachu_battle:
;return to regular code
	FL_JUMP_IF_PROGRESS_BETWEEN 0x00, 0x0F, 0x0804F511
	FL_JUMP 0x0804F4F7

;eof