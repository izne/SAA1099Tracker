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

/**
 * Hardware:
 *   6850 ACIA at 0xA000  (status/control @ 0xA000, data @ 0xA001)
 *   SAA1099 at 0xB000    (register select @ 0xB001, data write @ 0xB000)
 *
 * Protocol: [0xFF sync][32 bytes R00-R1F][XOR checksum]
 * Baud:     115200 8N1
 */

#ifndef RECEIVER_H
#define RECEIVER_H

/* ---- SAA1099 test pattern toggle --------------------------------------- */
/* Set to 1 to play a tone sweep on all 6 channels at startup.
 * Set to 0 to go straight to receive mode.                             */
#define RUN_TEST_PATTERN  1

/* ---- Debug output toggle ---------------------------------------------- */
/* Set to 1 for verbose per-frame hex dump on the terminal (for testing).
 * Set to 0 for minimal output (frame count every 64 frames only).       */
#define DEBUG_TX  1

/* ---- SAA1099 ---------------------------------------------------------- */

#define NUM_REGS  32

/* ---- Forward declarations -------------------------------------------- */

int main(void);
static void testPattern(void);
static unsigned char readByte(void);
static void writeByte(unsigned char c);
static void writeString(const char *s);
static void writeRegister(unsigned char reg, unsigned char value);
static void writeAllRegisters(unsigned char *regs);
static unsigned char hexNibble(unsigned char v);
static void writeHex(unsigned char v);
static void writeHex16(unsigned int v);

#endif /* RECEIVER_H */
