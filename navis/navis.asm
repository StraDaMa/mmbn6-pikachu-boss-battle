.include "pikachu/pikachu.asm"

;Write character parameters
.org 0x080182C4 + (0x0161 * 3)
;level, virus/navi, aiIndex
.byte 0x00, 0x01, 0x11; 0161

;navi struct1
.org 0x080F24D8 + (0x11 * 4)
.word pikachu_ai_struct1

;navi struct2
.org 0x080F253C + (0x11 * 4)
.word pikachu_ai_struct2

;battle drops
.org 0x080AE5D0
@@PIKA_P_CHIPID equ (0x123 | (ChipCode_P << 0x09))
;High HP
.halfword @@PIKA_P_CHIPID, @@PIKA_P_CHIPID, @@PIKA_P_CHIPID, @@PIKA_P_CHIPID, @@PIKA_P_CHIPID, @@PIKA_P_CHIPID, @@PIKA_P_CHIPID, @@PIKA_P_CHIPID, @@PIKA_P_CHIPID, @@PIKA_P_CHIPID
;Low HP
.halfword @@PIKA_P_CHIPID, @@PIKA_P_CHIPID, @@PIKA_P_CHIPID, @@PIKA_P_CHIPID, @@PIKA_P_CHIPID, @@PIKA_P_CHIPID, @@PIKA_P_CHIPID, @@PIKA_P_CHIPID, @@PIKA_P_CHIPID, @@PIKA_P_CHIPID

;chip pool
.org 0x080AEE0C + (0x11 * 4)
.word pikachu_chip_pool

;starting subobject spawn
.org 0x08010EA4 + (0x11 * 4)
.word 0x080114D5;Generic nop

;update 1
.org 0x080F2410 + (0x11 * 4)
.word 0x0801AAC1;Generic nop

;update 2
.org 0x080F2474 + (0x11 * 4)
.word 0x080F28C1;Generic nop

;update 3
.org 0x080F25A0 + (0x11 * 4)
.word 0x080F28C1;Generic nop

;attack pool
.org 0x080F23AC + (0x11 * 4)
.word pikachu_attack_pool

;battle start function 1
.org 0x080F2604 + (0x11 * 4)
.word pikachu_decompress_diveman|1;Generic nop

;battle start function 2
.org 0x080F2668 + (0x11 * 4)
.word 0x080F28C1;Generic nop

;on delete routine
.org 0x080110F4 + (0x11 * 4)
.word pikachu_on_damage|1

;on paralyze routine
.org 0x080F26CC + (0x11 * 4)
.word pikachu_on_damage|1

;on damage overlay routine
.org 0x08011470 + (0x11 * 4)
.word 0x080C44D3;Generic

;on damage routine
.org 0x080F27F8 + (0x11 * 4)
.word pikachu_on_damage|1

;on push routine
.org 0x080F285C + (0x11 * 4)
.word pikachu_on_damage|1

;on freeze routine
.org 0x080F2730 + (0x11 * 4)
.word pikachu_on_damage|1

;on bubble routine
.org 0x080F2794 + (0x11 * 4)
.word pikachu_on_damage|1
;eof