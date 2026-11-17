#!/usr/bin/env python3
# Inject an LC_LOAD_DYLIB into a Mach-O arm64/iOS executable.
import struct
import sys
import shutil


def align8(n):
    return (n + 7) & ~7


def patch(path, name, out=None):
    with open(path, "rb") as f:
        data = bytearray(f.read())

    magic, cpu, sub = struct.unpack_from("<Iii", data, 0)
    assert magic == 0xfeedfacf, "not a 64-bit Mach-O"
    ncmds, sizeofcmds = struct.unpack_from("<II", data, 16)
    hdr_end = 32 + sizeofcmds

    off = 32
    first_sec = None
    for _ in range(ncmds):
        cmd, sz = struct.unpack_from("<II", data, off)
        if cmd == 0x19:  # LC_SEGMENT_64
            nsects = struct.unpack_from("<I", data, off + 64)[0]
            section_off = off + 72
            for _ in range(nsects):
                file_off = struct.unpack_from("<I", data, section_off + 48)[0]
                if file_off > 0 and (first_sec is None or file_off < first_sec):
                    first_sec = file_off
                section_off += 80
        off += sz

    assert first_sec is not None, "no sections"
    name_bytes = name.encode() + b"\x00"
    cmdsize = align8(24 + len(name_bytes))
    if first_sec - hdr_end < cmdsize:
        raise SystemExit(
            f"not enough header space: need {cmdsize}, have {first_sec - hdr_end}"
        )

    load_cmd = bytearray(cmdsize)
    struct.pack_into("<II", load_cmd, 0, 0xC, cmdsize)  # LC_LOAD_DYLIB
    struct.pack_into("<IIII", load_cmd, 8, 24, 0, 0x10000, 0x10000)
    load_cmd[24:24 + len(name_bytes)] = name_bytes

    if out and out != path:
        shutil.copyfile(path, out)
        with open(out, "rb") as f:
            data = bytearray(f.read())
    else:
        out = path

    struct.pack_into("<II", data, 16, ncmds + 1, sizeofcmds + cmdsize)
    data[hdr_end:hdr_end + cmdsize] = load_cmd
    with open(out, "wb") as f:
        f.write(data)

    print(
        f"patched {out}: ncmds {ncmds}->{ncmds + 1}, "
        f"load {name}"
    )


if __name__ == "__main__":
    if len(sys.argv) not in (3, 4):
        raise SystemExit("usage: inject.py <Mach-O executable> <dylib-load-path> [output]")
    patch(sys.argv[1], sys.argv[2], sys.argv[3] if len(sys.argv) == 4 else None)
