;add some sprites to temp attack object
.vorg 0x080B8E88, 0x080BAF18
	.word temp_attack_object_list

.vorg 0x080B8E9C, 0x080BAF2C
	.word temp_attack_object_list

;add the pikachu chip object to object list
.vorg 0x08003C9C +  (PIKACHU_CHIP_OBJECT_ID * 4), 0x08003C80 + (PIKACHU_CHIP_OBJECT_ID * 4)
	.word pikachu_chip_object_main | 1
;eof
