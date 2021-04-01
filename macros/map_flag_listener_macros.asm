.macro FL_JUMP,jump_address
.byte 0x01
  .word jump_address
.endmacro

.macro FL_JUMP_IF_PROGRESS_BETWEEN,progress_low,progress_high,jump_address
.byte 0x02, progress_low, progress_high
  .word jump_address
.endmacro

.macro FL_JUMP_IF_FLAG_NOT_ON,flag,jump_address
.byte 0x05, 0xFF
  .halfword flag
  .word jump_address
.endmacro

.macro FL_JUMP_IF_PREVIOUS_BATTLE_OUTCOME_NOT_EQUAL,battle_outcome,jump_address
.byte 0x0B, battle_outcome
  .word jump_address
.endmacro

.macro FL_START_CUTSCENE,cutscene_offset,parameter
.byte 0x26
  .word cutscene_offset
  .word parameter
.endmacro
;eof