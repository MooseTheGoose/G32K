
MEMORY {
  ROM(rx) : ORIGIN = 0,LENGTH = 0x8000
  EXRAM(rw) : ORIGIN = 0xA000,LENGTH = 0x2000 
  RAM(rwx) : ORIGIN = 0xC000,LENGTH = 0x2000
}

OUTPUT_ARCH(gbz80)

SECTIONS {
  .text : {
    *(.text)
  } >ROM
  .exbss (NOLOAD) : {
  } >EXRAM
  .bss (NOLOAD) : {
  } >RAM
}