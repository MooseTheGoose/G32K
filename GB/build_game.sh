
PREFIX=z80-none-elf
ASMC=$PREFIX-as
ASMLD=$PREFIX-ld

$ASMC -march=gbz80  *.asm -o gbrom.o
$ASMLD --oformat=binary -T../gb-linker.ld  gbrom.o -o gbrom.temp.bin || exit 1
cat gbrom.temp.bin /dev/zero | dd if=/dev/stdin of=gbrom.gb bs=32768 count=1 
rm gbrom.temp.bin

python3 ../gbfix.py gbrom.gb
