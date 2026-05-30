#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <filename>"
    echo "Example: $0 receiver"
    exit 1
fi

# Get program name
NAME="$1"
ADDR=0400

# CMOC translation to assembler
cmoc -S --void-target -nodefaultlibs --no-relocate --org="0x${ADDR}" "${NAME}.c"

# Remove top 20 lines
sed -i '1,20d' "${NAME}.s"

# Create object file
lwasm --obj -o "${NAME}.o" "${NAME}.s"

# Link to SREC
lwlink "${NAME}.o" --format=srec --entry=_main --section-base=code="${ADDR}" --output="${NAME}.s19"

# Run the compiled program in the 6809sbc emulator
/z/6809sbc/Debug/6809sbc --load "${NAME}.s19" --load-addr "0x${ADDR}" --rom /z/AC6309/ROMs/combined.bin