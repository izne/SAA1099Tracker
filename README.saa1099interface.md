# SAA1099 Hardware Interface via USB-Serial

This document describes the serial interface between **SAA1099Tracker** (running in a browser) and external hardware that drives a real Philips SAA1099 sound chip — such as an **Arduino** or a **6809 single-board computer**.

## Overview

SAA1099Tracker can stream live register frames over Web Serial API to a microcontroller or SBC connected via USB-to-serial. The receiving device parses the frames and writes the register values directly to the SAA1099 chip.

Three streaming modes are supported:

| Mode | Emulation | Hardware |
|------|-----------|----------|
| `software` | Yes | No |
| `hardware` | No | Yes |
| `both` | Yes | Yes |

## Protocol Specification

| Field | Offset | Size | Description |
|-------|--------|------|-------------|
| Sync | 0 | 1 byte | Always `0xFF` |
| Registers | 1 | 32 bytes | SAA1099 register values R00–R1F (addresses 0x00–0x1F) |
| Checksum | 33 | 1 byte | XOR of all 32 register bytes |

- **Baud rate:** 115200
- **Data bits:** 8
- **Parity:** None
- **Stop bits:** 1
- **Total packet size:** 34 bytes

### Checksum

```
checksum = 0
for each of the 32 register bytes:
    checksum ^= register_byte
```

### Synchronisation

The receiver should scan for the `0xFF` sync byte. Once found, read exactly 32 register bytes then the checksum byte. If the checksum fails, discard the frame and scan for the next `0xFF`.

## Register Map (R00–R1F)

| Reg | Address | Function | Bits |
|-----|---------|----------|------|
| R00 | 0x00 | Amplitude channel 0 | 7–4: right, 3–0: left |
| R01 | 0x01 | Amplitude channel 1 | 7–4: right, 3–0: left |
| R02 | 0x02 | Amplitude channel 2 | 7–4: right, 3–0: left |
| R03 | 0x03 | Amplitude channel 3 | 7–4: right, 3–0: left |
| R04 | 0x04 | Amplitude channel 4 | 7–4: right, 3–0: left |
| R05 | 0x05 | Amplitude channel 5 | 7–4: right, 3–0: left |
| R06 | 0x06 | (reserved) | — |
| R07 | 0x07 | (reserved) | — |
| R08 | 0x08 | Frequency channel 0 | 8-bit value (0–255) |
| R09 | 0x09 | Frequency channel 1 | 8-bit value (0–255) |
| R0A | 0x0A | Frequency channel 2 | 8-bit value (0–255) |
| R0B | 0x0B | Frequency channel 3 | 8-bit value (0–255) |
| R0C | 0x0C | Frequency channel 4 | 8-bit value (0–255) |
| R0D | 0x0D | Frequency channel 5 | 8-bit value (0–255) |
| R0E | 0x0E | (reserved) | — |
| R0F | 0x0F | (reserved) | — |
| R10 | 0x10 | Octave select ch0–1 | x,ch1,x,ch0 |
| R11 | 0x11 | Octave select ch2–3 | x,ch3,x,ch2 |
| R12 | 0x12 | Octave select ch4–5 | x,ch5,x,ch4 |
| R13 | 0x13 | (reserved) | — |
| R14 | 0x14 | Frequency enable | x,x,ch5–ch0 (1=on) |
| R15 | 0x15 | Noise enable | x,x,ch5–ch0 (1=on) |
| R16 | 0x16 | Noise generator control | x,x,NG1,x,x,NG0 |
| R17 | 0x17 | (reserved) | — |
| R18 | 0x18 | Envelope generator 0 | See datasheet |
| R19 | 0x19 | Envelope generator 1 | See datasheet |
| R1A | 0x1A | (reserved) | — |
| R1B | 0x1B | (reserved) | — |
| R1C | 0x1C | Reset & Sound Enable | x,x,x,x,x,x,R,SE |
| R1D | 0x1D | (reserved) | — |
| R1E | 0x1E | (reserved) | — |
| R1F | 0x1F | (reserved) | — |

See `doc/philips_saa1099_details.txt` for full register bit-field descriptions.

### SAA1099 Write Sequence

The SAA1099 has a single address pin (A0):

| A0 | Function |
|----|----------|
| 0  | Data write |
| 1  | Register select |

To write a register:

1. Write register address (0x00–0x1F) with A0=1 → **register select**
2. Write register value with A0=0 → **data write**

Chip Select (/CS) must be low during both writes. Write Strobe (/WR) is pulsed low on each write.

## Host Side (Browser/Tracker)

### SerialStreamer (`src/commons/SerialStreamer.ts`)

The `SerialStreamer` class manages the browser-to-hardware link:

- **Connect:** Uses `navigator.serial.requestPort()` to let the user pick a device, opens at 115200 baud
- **Auto-reconnect:** Saves USB VID/PID to `localStorage`; on next open tries to reconnect automatically
- **Send frame:** Builds the 34-byte packet from the `SAASoundRegisters` object and writes it to the serial port
- **Mode:** Selectable via UI — software-only, hardware-only, or both
- **Notifications:** Registers `connect`/`disconnect` event handlers on `navigator.serial`

### Integration Points

| File | Purpose |
|------|---------|
| `src/commons/SerialStreamer.ts` | Core class |
| `src/tracker/controls.ts` | UI event handlers (`onCmdHardwareSerial`, `updateSerialPanel`, `updateSerialPortList`) |
| `templates/dlg-serial.html` | Hardware Output dialog |
| `src/libs/SAASound/SAASound.ts` | Calls `serialStreamer.sendFrame()` on every register update |
| `src/tracker/index.ts` | Instantiates `SerialStreamer` and wires it to `SAASound` |

## 6809 SBC Firmware

### Memory Map

| Address | Device |
|---------|--------|
| `$A000` | 6850 ACIA — status/control register |
| `$A001` | 6850 ACIA — data register |
| `$B000` | SAA1099 — data write (A0=0) |
| `$B001` | SAA1099 — register select (A0=1) |

The 6809 SBC runs ASSIST09 in ROM at `$E000`–`$FFFF`. The receiver program is loaded via `LOAD` (S19 records) into RAM and run with `GO`. It takes over the single ACIA, reconfigures it, and listens for incoming frames.

### Building with CMOC

```bash
cmoc -c receiver.c               # compile to 6809 assembly
lwasm -9 -b receiver.s -o receiver.bin   # assemble to binary
```

To generate S19 records for ASSIST09:

```bash
lwasm -9 -f srec -o receiver.s19 receiver.s
```

### Build prerequisites

- [CMOC](http://perso.b2b2c.ca/~sarrazip/dev/cmoc.html) — C-Minus compiler for 6809
- [LWTOOLS](http://www.lwtools.ca/) — 6809 assembler/linker (includes `lwasm`)

### Register Write Routine (6809)

The SAA1099 write sequence in 6809 assembly (called from C):

```asm
; Write register A to SAA1099
; Before call: A = register address
STA  >$B001      ; register select (A0=1)
; After call: A = value to write
STA  >$B000      ; data write (A0=0)
```

### Receiver Source

See `firmware/6809/receiver.c` for the complete CMOC receiver program.

## Arduino Firmware

### Wiring

| Arduino Pin | SAA1099 Pin | Function |
|-------------|-------------|----------|
| D2–D7 | D0–D5 | Address lines A0–A5 |
| D8–D15 | D0–D7 | Data lines D0–D7 |
| D16 | /WR (pin 1) | Write strobe |
| D17 | /CS (pin 2) | Chip select |
| — | CLK (pin 13) | 8 MHz clock input |
| — | Iref (pin 6) | 47 kΩ resistor to GND |
| — | OutL (pin 5) | Audio output (left) |
| — | OutR (pin 4) | Audio output (right) |

> **Note:** On Arduino Uno/Mega, D8–D15 correspond to PORTB/PORTH. For Mega2560 use the full 8-bit port on PORTA (A0–A7 = D22–D29) or PORTC.

### Write Sequence (Arduino)

```cpp
void writeRegister(uint8_t reg, uint8_t value) {
    // Set address lines (A0–A5)
    PORTA = (PORTA & 0xC0) | (reg & 0x3F);
    // Set data lines
    PORTC = value;
    // Strobe /CS and /WR low then high
    digitalWrite(CS_PIN, LOW);
    digitalWrite(WR_PIN, LOW);
    // Small delay if needed for timing
    asm volatile("nop");
    digitalWrite(WR_PIN, HIGH);
    digitalWrite(CS_PIN, HIGH);
}
```

## Troubleshooting

### No serial port found
- Ensure the device is connected via USB
- Chrome/Edge requires **HTTPS** or **localhost** (not plain HTTP on network)
- Open the browser console (`F12`) — look for Web Serial errors

### Frames not reaching hardware
- Verify baud rate matches (115200)
- Check checksum implementation on the receiver
- Add a test pattern (e.g., sweep all amplitudes) to isolate the issue

### Garbage / missed sync bytes
- The ACIA may need a master reset at startup
- Ensure the sender and receiver agree on the `DIV` rate for the ACIA clock
- The receiver should discard bytes until it sees `0xFF`

### Debug output
- In the SAA1099Tracker dialog, enable the debug log panel
- On 6809, the receiver can echo frames back over the same ACIA (toggle `DEBUG_TX` in `receiver.c`)

## References

- `doc/philips_saa1099_details.txt` — Full SAA1099 register documentation
- `src/commons/SerialStreamer.ts` — Host-side serial implementation
- `firmware/6809/receiver.c` — 6809 SBC receiver program (CMOC)
- [CMOC Homepage](http://perso.b2b2c.ca/~sarrazip/dev/cmoc.html)
- [LWTOOLS](http://www.lwtools.ca/)
- [Web Serial API Spec](https://wicg.github.io/serial/)

---

Copyright (c) 2026 Dimitar Angelov
