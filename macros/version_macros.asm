.macro .vorg, usOffset, jpOffset
	.if _version == 1
		.org jpOffset
	.else
		.org usOffset
	.endif
.endmacro

.macro .vword, usWord, jpWord
	.if _version == 1
		.word jpWord
	.else
		.word usWord
	.endif
.endmacro

.macro .vimport, usFile, jpFile
	.if _version == 1
		.import jpFile
	.else
		.import usFile
	.endif
.endmacro

.macro .vdefinelabel, labelName, usOffset, jpOffset
	.if _version == 1
		.definelabel labelName, jpOffset
	.else
		.definelabel labelName, usOffset
	.endif
.endmacro
;eof