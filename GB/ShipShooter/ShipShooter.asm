
.include "../gbdefs.h"

.section .bss

# Background/Window palette will usually be 0, 3, 1, 2
# Enemies and ship get OBP0
# (Ship gets palette entry 2, enemies gets palette entry 1).
# OBP1 goes unused 
.comm game_palettes, 3, 4
.set default_bg_palette, 0x63
.set bg_palette_idx, 0
.set default_entity_palette, 0xCC
.set entity_palette_idx, 1

.section .text

_start:

.macro vector_call hname=unexpected_handler
  PUSH HL
  LD HL, \hname
  JP vector_handler
  NOP
.endm

rst0:
  vector_call 
rst8:
  vector_call
rst10:
  vector_call
rst18:
  vector_call
rst20:
  vector_call
rst28:
  vector_call
rst30:
  vector_call
rst38:
  vector_call

vblank_intr:
  vector_call vblank_isr

lcd_intr:
  vector_call

timer_ovflow:
  vector_call

serial_link:
  vector_call

joypad_press:
  vector_call

vector_handler:
  PUSH BC
  PUSH DE
  PUSH AF
  LD BC, vector_cleanup
  PUSH BC
  JP (HL)
vector_cleanup:
  POP AF
  POP DE
  POP BC
  POP HL
  RETI

vector_padding:
  .skip 0x100 - (. - _start)

header:
  NOP
  NOP
  JR gb_entry

nintendo_logo:
  .skip 0x30

game_title:
  .ascii "ASTEROIDS"
  .skip 0xF - (. - game_title), 0

cgb_flag:
  .byte 0

new_licensee_code:
  .byte 0, 0

sgb_flag:
  .byte 0

cartridge_type:
  .byte 0

rom_size:
  .byte 0

exram_size:
  .byte 0

dest_code:
  .byte 1

old_licensee_code:
  .byte 0x33

mask_rom_version:
  .byte 0

header_checksum:
  .byte 0

global_checksum:
  .byte 0, 0

gb_entry:
  LD SP, 0xFFFC
  EI
  LD HL, IOHI|IELO
  LD (HL), VBLANK_IE
  LD L, LCDCLO
  HALT
  LD (HL), LCD_ENABLE|OBJ_ENABLE|OBJ_SIZE
  LD HL, game_palettes
  LD A, default_bg_palette
  LD (HL+), A
  LD A, default_entity_palette
  LD (HL+), A
  XOR A
  LD (HL+), A
load_patterns:
  LD HL, OBJVRAMLO
  LD BC, ship_patterns_data
  LD D, ship_patterns_tile_length 
.load_ship_patterns_loop:
  LD E, 8
.load_ship_tile_loop:
  XOR A
  LD (HL+), A
  LD A, (BC)
  INC BC
  LD (HL+), A
  DEC E
  JR NZ, .load_ship_tile_loop
  DEC D
  JR NZ, .load_ship_patterns_loop
  

main_loop:
vblank_wait:
  HALT
  CALL initialize_ship
main_update:
  LD HL, IOHI|BGPLO
  LD BC, game_palettes
  LD E, 3
.palette_copy:
  LD A, (BC)
  LD (HL+), A
  INC C
  DEC E
  JR NZ, .palette_copy
  JR main_loop

# This is a bit absurd, but this is
# just for example
initialize_ship:
  LD HL, OAM
  LD A, 0x80
  LD (HL+), A
  LD (HL+), A
  LD A, upward_ship_tile_ofs
  LD (HL+), A
  XOR A
  LD (HL+), A
  LD A, 0x80
  LD (HL+), A
  LD A, 0x88
  LD (HL+), A
  LD A, upward_ship_tile_ofs+2
  LD (HL+), A
  XOR A
  LD (HL), A
  RET

unexpected_handler:
  HALT
  JR unexpected_handler

vblank_isr:
empty_isr:
  RET

# Pattern data which can fit all in VRAM
# Ship patterns first, then asteroids, then text, then background.
patterns_data:
ship_patterns_data:
  .byte 0, 0, 0, 0, 0, 0, 0, 0
  .byte 0, 0, 0, 0, 0, 0, 0, 0
upward_ship_pattern:
  .set upward_ship_tile_ofs, (. - patterns_data) / 8
  .byte 0, 0, 0, 0, 0x1, 0x3, 0x7, 0xF
  .byte 0x1F, 0x3F, 0x7F, 0x7F, 0, 0, 0, 0
  .byte 0, 0, 0, 0, 0x80, 0xC0, 0xE0, 0xF0
  .byte 0xF8, 0xFC, 0xFE, 0xFE, 0, 0, 0, 0

.set ship_patterns_tile_length, (. - ship_patterns_data) / 8
