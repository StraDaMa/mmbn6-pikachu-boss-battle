;add some sprites to temp attack object
.org 0x080b8e88
	.word temp_attack_object_list

.org 0x080b8e9c
	.word temp_attack_object_list

;add the pikachu chip object to object list
.org 0x08003CE0
	.word pikachu_chip_object_main | 1
;eof
