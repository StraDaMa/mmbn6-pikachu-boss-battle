.macro CS_END
.byte 0x00
.endmacro

.macro CS_WAIT, frames
.byte 0x02, 0xFF, frames
.endmacro

.macro CS_WAIT_FOR_MESSAGE_PARAMETER, message_parameter
.byte 0x04, message_parameter
.endmacro

.macro CS_WAIT_FOR_SCREEN_TRANSITION
.byte 0x07
.endmacro

.macro CS_WAIT_FOR_UNPAUSE
.byte 0x0C
.endmacro

.macro CS_SET_SCREEN_TRANSITION, p0, p1
.byte 0x27, 0xFF, p0, p1
.endmacro

.macro CS_START_MESSAGE_VAR, parameter
.byte 0x3A, parameter
.endmacro

.macro CS_DECOMPRESS_TEXT, bin_address
.byte 0x3E
  .word bin_address
.endmacro

.macro CS_LOCK_PLAYER
.byte 0x3F, 0x00
.endmacro

.macro CS_UNLOCK_PLAYER
.byte 0x3F, 0x04
.endmacro

.macro CS_CALL_ASM, routine_address
.byte 0x4B
  .word routine_address
.endmacro
;eof