.macro NPC_JUMP, jump_address
.byte 0x02
  .word jump_address
.endmacro

.macro NPC_MAKE_VISIBLE
.byte 0x08
.endmacro

.macro NPC_WAIT, frames
.byte 0x10, frames
.endmacro

.macro NPC_NO_TURN_ON_INTERACT
.byte 0x13
.endmacro

.macro NPC_SET_POSITION, x, y, z
.byte 0x14
  .halfword x
  .halfword y
  .halfword z
.endmacro

.macro NPC_SET_ANIMATION, animation
.byte 0x16, animation
.endmacro

.macro NPC_SET_SPRITE_CHAR, sprite_index
.byte 0x17, sprite_index
.endmacro

.macro NPC_JUMP_LINKED, jump_address
.byte 0x36
  .word jump_address
.endmacro

.macro NPC_SET_DIALOG2, message_index
.byte 0x4C, message_index
.endmacro
;eof