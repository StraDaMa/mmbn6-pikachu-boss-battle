.vorg 0x08031DA4 + (PIKACHU_SPRITE_INDEX * 4), 0x08032D60 + (PIKACHU_SPRITE_INDEX * 4)
	.word sprite_pikachu
.vorg 0x08032194 + (PIKACHU_OW_SPRITE_INDEX * 4), 0x08033150 + (PIKACHU_OW_SPRITE_INDEX * 4)
	.word sprite_pikachu_ow

.vorg 0x08367848, 0x08371060
	.area 0x170B
	.import "bin/sprite_firewave.bin"
	.endarea
;eof