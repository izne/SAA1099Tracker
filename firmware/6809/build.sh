#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <filename>"
    echo "Example: $0 receiver"
    exit 1
fi

NAME="$1"

cmoc.exe -S --void-target -nodefaultlibs --no-relocate --org=0x0400 "${NAME}.c"

sed -i '1,20d' "${NAME}.s"

lwasm --obj -o "${NAME}.o" "${NAME}.s"

lwlink "${NAME}.o" --format=srec --entry=_main --section-base=code=0400 --output="${NAME}.s19"

/z/6809sbc/Debug/6809sbc.exe --load "${NAME}.s19" --load-addr 0x0400 --rom /z/AC6309/ROMs/combined.bin
