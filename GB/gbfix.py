import sys

INITIAL_CHECKSUM_LEN = 0x134
HEADER_CHECKSUM_LEN = 0x19
CHECKSUM_FIXUP_LOC = 0x14D

NINTENDO_LOGO = bytes([
 0xCE, 0xED, 0x66, 0x66, 0xCC, 0x0D, 0x00, 0x0B, 0x03, 0x73, 0x00, 0x83, 0x00, 0x0C, 0x00, 0x0D,
 0x00, 0x08, 0x11, 0x1F, 0x88, 0x89, 0x00, 0x0E, 0xDC, 0xCC, 0x6E, 0xE6, 0xDD, 0xDD, 0xD9, 0x99,
 0xBB, 0xBB, 0x67, 0x63, 0x6E, 0x0E, 0xEC, 0xCC, 0xDD, 0xDC, 0x99, 0x9F, 0xBB, 0xB9, 0x33, 0x3E
])
NINTENDO_LOGO_LOC = 0x104

class GBChecksum:
    def __init__(self):
        self.global_checksum = 0
        self.header_checksum = 0

    def update_global(self, updatebytes):
        for i in range(len(updatebytes)):
            self.global_checksum = (self.global_checksum + updatebytes[i]) & 0xFFFF

    def update_header(self, updatebytes):
        for i in range(len(updatebytes)):
            self.header_checksum = (self.header_checksum + updatebytes[i]) & 0xFF

def fix_rom(fname):
    with open(fname, 'r+b') as fp:
        chksum = GBChecksum()
        currbytes = fp.read(INITIAL_CHECKSUM_LEN)
        chksum.update_global(currbytes)
        currbytes = fp.read(HEADER_CHECKSUM_LEN)
        chksum.update_global(currbytes)
        chksum.update_header(currbytes)
        currbytes = fp.read()
        chksum.update_global(currbytes)
        fp.seek(NINTENDO_LOGO_LOC)
        fp.write(NINTENDO_LOGO)
        fp.seek(CHECKSUM_FIXUP_LOC)
        fp.write(bytes([
            chksum.header_checksum & 0xFF,
            chksum.global_checksum >> 8 & 0xFF,
            chksum.global_checksum & 0xFF]))
    print('"{}" ROM fixed'.format(fname))

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python3 {} <romfile>".format(sys.argv[0]), file=sys.stderr)
        sys.exit(-1)
    fix_rom(sys.argv[1])