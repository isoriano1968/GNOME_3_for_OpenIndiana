#!/usr/bin/python3 -I
"""xwd2png.py -- convert an X window dump (xwd -root, ZPixmap, TrueColor,
16/24/32 bits per pixel) to PNG with Pillow; both byte orders, so dumps from
big-endian SPARC X servers convert with the right colours.

  tools/xwd2png.py IN.xwd OUT.png
"""
import struct
import sys

from PIL import Image

data = open(sys.argv[1], "rb").read()
hsize, = struct.unpack(">I", data[:4])
f = struct.unpack(">25I", data[:100])
(header_size, version, pixmap_format, depth, width, height, xoff, byte_order,
 bitmap_unit, bit_order, bitmap_pad, bpp, bytes_per_line, visual_class,
 rmask, gmask, bmask, bits_per_rgb, cmap_entries, ncolors) = f[:20]
if version != 7 or pixmap_format != 2 or bpp not in (16, 24, 32):
    sys.exit("unsupported xwd: version %d format %d bpp %d" % (version, pixmap_format, bpp))
off = header_size + ncolors * 12
img = data[off:off + bytes_per_line * height]
end = ">" if byte_order == 1 else "<"


def shift(mask):
    s = 0
    while mask and not (mask >> s) & 1:
        s += 1
    return s, mask >> s


rs, rm = shift(rmask)
gs, gm = shift(gmask)
bs, bm = shift(bmask)
out = bytearray(width * height * 3)
step = bpp // 8
o = 0
for y in range(height):
    row = img[y * bytes_per_line:(y + 1) * bytes_per_line]
    for x in range(width):
        p = row[x * step:x * step + step]
        if step == 4:
            v, = struct.unpack(end + "I", p)
        elif step == 2:
            v, = struct.unpack(end + "H", p)
        else:
            v = int.from_bytes(p, "big" if byte_order == 1 else "little")
        out[o] = ((v >> rs) & rm) * 255 // rm
        out[o + 1] = ((v >> gs) & gm) * 255 // gm
        out[o + 2] = ((v >> bs) & bm) * 255 // bm
        o += 3
Image.frombytes("RGB", (width, height), bytes(out)).save(sys.argv[2])
print("%s: %dx%d, %d bpp, %s-endian" % (sys.argv[2], width, height, bpp,
                                       "big" if byte_order == 1 else "little"))
