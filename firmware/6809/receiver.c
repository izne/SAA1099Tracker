/**
 * SAA1099Tracker Serial Stream Receiver for 6809 SBC
 *
 * Copyright (c) 2026 Dimitar Angelov
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom
 * the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
 * OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
 * OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
//---------------------------------------------------------------------------------------

#include "receiver.h"

/* ---- Main ------------------------------------------------------------- */

int main(void)
{
    unsigned char i;
    unsigned char regs[NUM_REGS];
    unsigned char byte;
    unsigned char checksum;
    unsigned char calc;
    unsigned int frameCount = 0;

    /* ---- Initialise ACIA ---- */
    *(unsigned char *)0xA000 = 0x03;   /* master reset (two writes) */
    *(unsigned char *)0xA000 = 0x03;
    *(unsigned char *)0xA000 = 0x14;   /* 8N1, +1 divider */

    /* ---- Startup banner ---- */
    writeString("\r\nSAA1099 Receiver v1.0\r\n");
    writeString("Waiting for frames...\r\n");

#if RUN_TEST_PATTERN
    testPattern();
#endif

    /* ---- Main receive loop ---- */
    while (1) {

        /* 1. Synchronise on 0xFF sync byte */
        do {
            byte = readByte();
        } while (byte != 0xFF);

        /* 2. Read 32 register bytes */
        for (i = 0; i < NUM_REGS; i++) {
            regs[i] = readByte();
        }

        /* 3. Read checksum byte */
        checksum = readByte();

        /* 4. Validate XOR checksum */
        calc = 0;
        for (i = 0; i < NUM_REGS; i++) {
            calc ^= regs[i];
        }

        if (calc == checksum) {
            frameCount++;

            /* 5. Write all registers to SAA1099 */
            writeAllRegisters(regs);

#if DEBUG_TX
            /* Verbose: dump every frame as hex on the terminal */
            writeString("\rFrame ");
            writeHex16(frameCount);
            writeString(": ");
            for (i = 0; i < NUM_REGS; i++) {
                writeHex(regs[i]);
                writeByte(' ');
            }
#else
            /* Quiet: frame count every 64 frames */
            if ((frameCount & 0x3F) == 0) {
                writeString("\rFrames: ");
                writeHex16(frameCount);
            }
#endif
        }
        /* else: checksum mismatch — discard silently */

    }

    asm("swi");
    return 0;
}

/* ---- SAA1099 test pattern ------------------------------------------- */

static void testPattern(void)
{
    unsigned char ch;
    unsigned char freq;
    unsigned char octave;
    unsigned char bit;
    unsigned int d;

    writeString("SAA1099: C-E-G-C-E-G sweep\r\n");

    /* Reset chip, then enable sound */
    writeRegister(0x1C, 0x02);
    writeRegister(0x1C, 0x01);
    writeRegister(0x14, 0x00);

    for (ch = 0; ch < 6; ch++) {
        if (ch == 0)      { freq = 33;  octave = 3; bit = 0x01; }
        else if (ch == 1) { freq = 132; octave = 3; bit = 0x02; }
        else if (ch == 2) { freq = 192; octave = 3; bit = 0x04; }
        else if (ch == 3) { freq = 33;  octave = 4; bit = 0x08; }
        else if (ch == 4) { freq = 132; octave = 4; bit = 0x10; }
        else              { freq = 192; octave = 4; bit = 0x20; }

        writeRegister(0x14, bit);
        writeRegister(ch, 0xFF);
        writeRegister(0x08 + ch, freq);

        if (ch & 1)
            writeRegister(0x10 + (ch >> 1), octave * 16);
        else
            writeRegister(0x10 + (ch >> 1), octave);

        writeString(" Ch");
        writeHex(ch);
        writeString(" on\r\n");

        for (d = 0; d < 30000; d++) { }

        writeRegister(ch, 0x00);
    }

    writeRegister(0x14, 0x00);
    writeRegister(0x1C, 0x00);

    writeString("Test complete.\r\n");
}

/* ---- ACIA low-level helpers ------------------------------------------- */

static unsigned char readByte(void)
{
    while (!(*(unsigned char *)0xA000 & 1)) { }
    return *(unsigned char *)0xA001;
}

static void writeByte(unsigned char c)
{
    while (!(*(unsigned char *)0xA000 & 2)) { }
    *(unsigned char *)0xA001 = c;
}

static void writeString(const char *s)
{
    while (*s) {
        writeByte(*s++);
    }
}

/* ---- SAA1099 helpers -------------------------------------------------- */

static void writeRegister(unsigned char reg, unsigned char value)
{
    *(unsigned char *)0xB001 = reg;   /* latch register address (A0=1) */
    asm("nop");
    asm("nop");
    asm("nop");
    *(unsigned char *)0xB000 = value; /* write data          (A0=0) */
}

static void writeAllRegisters(unsigned char *regs)
{
    unsigned char i;
    for (i = 0; i < NUM_REGS; i++) {
        writeRegister(i, regs[i]);
    }
}

/* ---- Hex output helpers (for debug TX) -------------------------------- */

static unsigned char hexNibble(unsigned char v)
{
    v &= 0x0F;
    if (v < 10)
        return '0' + v;
    return 'A' + v - 10;
}

static void writeHex(unsigned char v)
{
    writeByte(hexNibble(v >> 4));
    writeByte(hexNibble(v));
}

static void writeHex16(unsigned int v)
{
    writeHex((unsigned char)(v >> 8));
    writeHex((unsigned char)v);
}
