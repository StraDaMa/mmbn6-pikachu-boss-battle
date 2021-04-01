;add pikachu chip object to list of navi chip objects
.org 0x0802CDA4
	.word pikachu_chip_object_spawn|1;0x12

.org 0x08024FAC
	.db ChipCode_P;chipcode1
	.db ChipCode_Star;chipcode2
	.db ChipCode_NONE;chipcode3
	.db ChipCode_NONE;chipcode4
	.db 0x03;attack elementflags
	.db 0x04;rarity
	.db 0x02;element icon
	.db Library_Mega;library
	.db 25;mb
	.db ChipEffect_ShowAttack | ChipEffect_AppearsInLibrary;efect flags
	.db 0x00;counter
	.db 0x1B;attacktype
	.db 0x12;Level
	.db 0xFF;byteD
	.db 0x00;byteE
	.db 0x00;lockon enable
	.db 0x00;attack parameter 1
	.db 0x00;attack parameter 2
	.db 0x00;attack parameter 3
	.db 0x00;attack parameter 4
	.db 0x00;use delay
	.db 0x48;library number
	.db LibraryFlags_Secret;LibraryFlags
	.db 0x00;lockontype
	.dh 0;ABC sort order
	.dh 250;attack power
	.dh 0;ID sort order
	.db 0x01;byte1e
	.db 0xFF;byte1f
	.dw 0x0872BE14;Chip Icon
	.dw pikachu_chip_image;Chip Image
	.dw pikachu_chip_image_pal;ChipImagePalette
;eof