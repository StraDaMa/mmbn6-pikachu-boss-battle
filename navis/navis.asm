.include "pikachu/pikachu.asm"

;Write character parameters
.vorg 0x080182C4 + (PIKACHU_ENEMY_ID * 3), 0x08018844 + (PIKACHU_ENEMY_ID * 3)
;level, virus/navi, aiIndex
	.byte 0x00, 0x01, PIKACHU_AI_ID; 0161

;navi struct1
.vorg 0x080F24D8 + (PIKACHU_AI_ID * 4), 0x080F7E80 + (PIKACHU_AI_ID * 4)
	.word pikachu_ai_struct1

;navi struct2
.vorg 0x080F253C + (PIKACHU_AI_ID * 4), 0x080F7EE4 + (PIKACHU_AI_ID * 4)
	.word pikachu_ai_struct2

;battle drops
@PIKA_P_CHIPID equ (PIKACHU_CHIP_ID | (ChipCode_P << 0x09))
.vorg 0x080AAEA8 + (0x28 * PIKACHU_ENEMY_ID), 0x080AD3D8 + (0x28 * PIKACHU_ENEMY_ID)
;High HP
	.halfword @PIKA_P_CHIPID, @PIKA_P_CHIPID, @PIKA_P_CHIPID, @PIKA_P_CHIPID, @PIKA_P_CHIPID, @PIKA_P_CHIPID, @PIKA_P_CHIPID, @PIKA_P_CHIPID, @PIKA_P_CHIPID, @PIKA_P_CHIPID
;Low HP
	.halfword @PIKA_P_CHIPID, @PIKA_P_CHIPID, @PIKA_P_CHIPID, @PIKA_P_CHIPID, @PIKA_P_CHIPID, @PIKA_P_CHIPID, @PIKA_P_CHIPID, @PIKA_P_CHIPID, @PIKA_P_CHIPID, @PIKA_P_CHIPID

;chip pool
.vorg 0x080AEE0C + (PIKACHU_AI_ID * 4), 0x080B133C + (PIKACHU_AI_ID * 4)
	.word pikachu_chip_pool

;starting subobject spawn
.vorg 0x08010EA4 + (PIKACHU_AI_ID * 4), 0x080114AC + (PIKACHU_AI_ID * 4)
	.vword 0x080114D5, 0x08011571;Generic nop

;update 1
.vorg 0x080F2410 + (PIKACHU_AI_ID * 4), 0x080F7DB8 + (PIKACHU_AI_ID * 4)
	.vword 0x0801AAC1, 0x0801AF29;Generic

;update 2
.vorg 0x080F2474 + (PIKACHU_AI_ID * 4), 0x080F7E1C + (PIKACHU_AI_ID * 4)
	.vword 0x080F28C1, 0x080F82D9;Generic nop

;update 3
.vorg 0x080F25A0 + (PIKACHU_AI_ID * 4), 0x080F7F48 + (PIKACHU_AI_ID * 4)
	.vword 0x080F28C1, 0x080F82D9;Generic nop

;attack pool
.vorg 0x080F23AC + (PIKACHU_AI_ID * 4), 0x080F7D54 + (PIKACHU_AI_ID * 4)
	.word pikachu_attack_pool

;battle start function 1
.vorg 0x080F2604 + (PIKACHU_AI_ID * 4), 0x080F7FAC + (PIKACHU_AI_ID * 4)
	.word pikachu_decompress_diveman|1;Generic nop

;battle start function 2
.vorg 0x080F2668 + (PIKACHU_AI_ID * 4), 0x080F8010 + (PIKACHU_AI_ID * 4)
	.vword 0x080F28C1, 0x080F82D9;Generic nop

;on delete routine
.vorg 0x080110F4 + (PIKACHU_AI_ID * 4), 0x080116FC + (PIKACHU_AI_ID * 4)
	.word pikachu_on_damage|1

;on paralyze routine
.vorg 0x080F26CC + (PIKACHU_AI_ID * 4), 0x080F8074 + (PIKACHU_AI_ID * 4)
	.word pikachu_on_damage|1

;on damage overlay routine
.vorg 0x08011470 + (PIKACHU_AI_ID * 4), 0x08011A78 + (PIKACHU_AI_ID * 4)
	.vword 0x080C44D3, 0x080c7413;Generic

;on damage routine
.vorg 0x080F27F8 + (PIKACHU_AI_ID * 4), 0x080F81A0 + (PIKACHU_AI_ID * 4)
	.word pikachu_on_damage|1

;on push routine
.vorg 0x080F285C + (PIKACHU_AI_ID * 4), 0x080F8204 + (PIKACHU_AI_ID * 4)
	.word pikachu_on_damage|1

;on freeze routine
.vorg 0x080F2730 + (PIKACHU_AI_ID * 4), 0x080F80D8 + (PIKACHU_AI_ID * 4)
	.word pikachu_on_damage|1

;on bubble routine
.vorg 0x080F2794 + (PIKACHU_AI_ID * 4), 0x080F813C + (PIKACHU_AI_ID * 4)
	.word pikachu_on_damage|1
;eof