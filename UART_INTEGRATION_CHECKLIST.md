# UART Integration - Quick Start Checklist

## ✅ Hardware Integration Complete

The following has been implemented in PersonalCPU:

### New Files Created:

- [x] `UART_BaudRate_Gen.vhd` - 115200 baud rate generator
- [x] `UART_Controller.vhd` - UART TX/RX wrapper with status logic
- [x] `uart_tx6.vhd` - Xilinx UART transmitter (16-byte FIFO)
- [x] `uart_rx6.vhd` - Xilinx UART receiver (16-byte FIFO)
- [x] `PS2_LCD_UART_PersonalCPU.psm` - Combined PS2+LCD+UART firmware

### Files Modified:

- [x] `toplevel.vhd` - Added UART entity ports and instantiations
- [x] `system.xdc` - Added UART pin constraints (PmodC: J18/J19)

### Port I/O Setup:

- [x] Port 0x04: UART Transmit data
- [x] Port 0x07: UART Receive (data + status flags)
- [x] UART Status: Bit 0 = rx_data_present, Bit 1 = tx_full

---

## 🔧 Next: Generate Memory ROM

### Required Tool:

- **KCPSM6 Assembler** (from: `FromOthers/KCPSM6_Release9_30Sept14/`)

### Step 1: Assemble PSM to HEX

```bash
cd PersonalCPU\PersonalCPU.srcs\utils_1\
kcpsm6 PS2_LCD_UART_PersonalCPU.psm
```

### Step 2: Generate VHDL Memory File

The assembler automatically generates `memoria.vhd` or process the .hex through ROM_form template.

### Step 3: Copy to Project

```
Replace: PersonalCPU\PersonalCPU.srcs\sources_1\new\memoria.vhd
With:    Newly generated memoria.vhd from Step 2
```

### Step 4: Verify Program Size

- Open new `memoria.vhd`
- Confirm: Program is <= 2048 instructions (2K × 18-bit)
- Confirm: All PS2+LCD+UART functions included

---

## 🚀 Build & Program

### In Vivado:

1. **Refresh Sources** - Reload memoria.vhd
2. **Synthesis** - Generate bitstream (ignore non-critical warnings)
3. **Implementation** - Route design
4. **Generate Bitstream** - Create .bit file
5. **Program FPGA** - Download to PYNQ-Z2

### Hardware Connections:

- **PS/2 Keyboard**: Digilent PS2 Pmod on PmodB (connected via Digilent adapter)
- **LCD Display**: Digilent PmodCLP on PmodA (16x2 HD44780)
- **UART**: USB-Serial adapter on PmodC (115200, 8N1)
  - UART_TX → PmodC J19 (pin 1)
  - UART_RX → PmodC J18 (pin 2)
  - GND → PmodC GND

---

## 🧪 Test After Programming

### Test PS/2 Keyboard:

```
1. Press keys 0-9 → Should display on LCD and echo to UART
2. Press A-Z → Should display on LCD and echo to UART
3. Try Escape → LCD should clear
4. Try Enter → Cursor should move to row 2
5. Try Backspace → Character should be deleted
```

### Test UART Receive:

```
1. Open terminal: PuTTY, Teraterm, etc (115200, 8N1)
2. Type characters in terminal
3. Characters should appear on LCD
4. Characters should echo back to terminal
```

### Test Display Wraparound:

```
1. Type > 16 characters → Should wrap to row 2
2. Type > 32 characters → Should wrap back to row 1, overwriting old text
```

---

## 📋 Port I/O Reference

For future modifications, use these port addresses:

```assembly
; PS/2 Input (existing)
INPUT  ps2_bit, 0x01      ; Read PS/2 data bit at bit 0

; LCD Output (existing)
OUTPUT cmd, 0x02          ; Write LCD command (Rs=0)
OUTPUT data, 0x03         ; Write LCD data (Rs=1)

; UART Output (NEW)
OUTPUT tx_char, 0x04      ; Write character to UART Tx

; Button Input (existing)
INPUT  btn_val, 0x05      ; Read 4-bit button value

; LED Output (existing)
OUTPUT led_val, 0x06      ; Write 4-bit LED value

; UART Status & Receive (NEW)
INPUT  status, 0x07       ; Bit 0=rx_present, Bit 1=tx_full
INPUT  rx_char, 0x07      ; Read character from UART Rx
```

---

## ⚙️ Firmware Features

The `PS2_LCD_UART_PersonalCPU.psm` includes:

### Character Input:

- Numbers: 0-9 → 0x30-0x39
- Letters: A-Z → 0x61-0x7A (lowercase)
- Space: 0x20
- Backspace: 0x08
- Enter: 0x0D
- Escape: 0x1B

### LCD Control:

- 16×2 display with automatic line wrap
- Cursor position tracking (0-31: row 0 cols 0-15, row 1 cols 0-15)
- Auto-scroll when reaching screen end
- Clear display on Escape key

### UART Integration:

- **Transmit**: All PS/2 characters sent to serial terminal
- **Receive**: Characters from serial terminal displayed on LCD and echoed back

### Interrupt Handling:

- PS/2 ISR at address 0x3FF
- Captures 11-bit frames (1 start + 8 data + 1 parity + 1 stop bit)
- Implements break code detection for key release

---

## 📁 File Locations Summary

```
PersonalCPU/
├── PersonalCPU.srcs/
│   ├── sources_1/new/
│   │   ├── toplevel.vhd              ← UPDATED
│   │   ├── UART_BaudRate_Gen.vhd     ← NEW
│   │   ├── UART_Controller.vhd       ← NEW
│   │   ├── uart_tx6.vhd              ← NEW
│   │   ├── uart_rx6.vhd              ← NEW
│   │   ├── memoria.vhd               ← REPLACE WITH NEW
│   │   ├── PS2_Controller.vhd        (existing)
│   │   └── LCD_Controller.vhd        (existing)
│   ├── utils_1/
│   │   └── PS2_LCD_UART_PersonalCPU.psm  ← NEW (assemble this!)
│   └── constrs_1/new/
│       └── system.xdc                ← UPDATED
├── UART_INTEGRATION_SUMMARY.md       ← Documentation
└── UART_INTEGRATION_CHECKLIST.md     ← This file
```

---

## ❓ Troubleshooting

| Problem                               | Solution                                                    |
| ------------------------------------- | ----------------------------------------------------------- |
| Bitstream fails: "Unconstrained port" | Check all ports in system.xdc match toplevel.vhd            |
| UART shows garbage                    | Check baud rate: terminal must be 115200, 8N1               |
| LCD doesn't update                    | Verify LCD_Controller.vhd E pulse (8ns × 40 cycles = 320ns) |
| PS/2 not working                      | Check PS2_Controller.vhd interrupt reaching CPU             |
| memoria.vhd won't compile             | Verify KCPSM6 assembler generated valid VHDL syntax         |
| Terminal shows nothing                | Check UART TX pin (J19) connected to USB adapter RX         |

---

## 📞 Support

All modules integrated and ready. The only remaining manual step is:

1. Run KCPSM6 assembler on `PS2_LCD_UART_PersonalCPU.psm`
2. Replace `memoria.vhd` with generated version
3. Synthesize and program FPGA

Good luck! 🎉
