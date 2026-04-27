# UART Integration Summary for PersonalCPU

## Integration Complete: PS2 + LCD + UART

This document summarizes the UART integration into PersonalCPU with PS2 keyboard and LCD display support.

---

## New Hardware Modules Created

### 1. **UART_BaudRate_Gen.vhd**

- Location: `PersonalCPU.srcs/sources_1/new/UART_BaudRate_Gen.vhd`
- Purpose: Generates 16x baud strobe for 115200 baud at 125 MHz clock
- Divisor: 67 (125,000,000 / (115200 \* 16) ≈ 67)
- Output: `en_16_x_baud` pulse (one cycle per 16x baud period)

### 2. **UART_Controller.vhd**

- Location: `PersonalCPU.srcs/sources_1/new/UART_Controller.vhd`
- Purpose: Wrapper around uart_tx6 and uart_rx6 with status/control logic
- Handles TX/RX FIFOs, status flags, and simple port I/O interface
- Status outputs: rx_data_present, tx_full

### 3. **uart_tx6.vhd & uart_rx6.vhd**

- Source: Xilinx KCPSM6 reference design
- Copied to: `PersonalCPU.srcs/sources_1/new/`
- Features: 16-byte FIFO buffers, 8 bit, 1 stop bit, no parity, 115200 baud

---

## Updated Hardware Files

### **toplevel.vhd**

Modified to include:

- Entity ports: `uart_tx`, `uart_rx` added
- Component declarations for UART modules
- Signal declarations for UART control and status
- Port I/O logic for UART (see port mapping below)
- Instantiation of UART_BaudRate_Gen and UART_Controller

### **system.xdc** (Pin Constraints)

Added UART pin mapping on PmodC:

```
uart_tx: Package Pin J19 (jc_p[1])
uart_rx: Package Pin J18 (jc_n[1])
```

---

## PersonalCPU Port I/O Mapping

| Port | Direction | Function       | Details                                           |
| ---- | --------- | -------------- | ------------------------------------------------- |
| 0x01 | Input     | PS/2 Data      | Bit 0 = PS2 data (from PS/2 controller)           |
| 0x02 | Output    | LCD Command    | 8-bit command (Rs=0)                              |
| 0x03 | Output    | LCD Data       | 8-bit data (Rs=1)                                 |
| 0x04 | Output    | UART Tx        | 8-bit data to transmit                            |
| 0x05 | Input     | Button         | 4-bit button input                                |
| 0x06 | Output    | LED            | 4-bit LED output                                  |
| 0x07 | Input     | UART Status/Rx | Bit 0=rx_present, Bit 1=tx_full; Bits 7-0=Rx data |

---

## Adapted Firmware

### **PS2_LCD_UART_PersonalCPU.psm**

- Location: `PersonalCPU.srcs/utils_1/PS2_LCD_UART_PersonalCPU.psm`
- Features:
  - **PS/2 Keyboard**: Captures scancodes via interrupt at 0x3FF
  - **LCD Display**: Supports 16x2 display with character positioning
  - **UART**: Transmits characters to serial terminal at 115200 baud
  - **Full Integration**:
    - PS2 key press → ASCII conversion → LCD display + UART echo
    - UART Rx → Display on LCD + Echo back to UART
    - Escape key: Clear screen
    - Enter key: Move to next line (with wraparound)
    - Backspace: Delete character and move cursor back

### Port I/O in Firmware

```assembly
INPUT  data, 0x01  ; Read PS/2 data
OUTPUT cmd, 0x02   ; Write LCD command
OUTPUT data, 0x03  ; Write LCD data
OUTPUT data, 0x04  ; Write UART Tx
INPUT  status, 0x07 ; Read button (when needed)
INPUT  status, 0x07 ; Read UART status: bit 0=rx_present, bit 1=tx_full
INPUT  data, 0x07  ; Read UART Rx data
```

---

## Next Steps: Generate Memory ROM

### 1. **Prepare the Assembly Code**

You need to assemble the PS2_LCD_UART_PersonalCPU.psm file using KCPSM6 assembler to generate memoria.vhd.

### 2. **Run KCPSM6 Assembler** (Windows batch or GUI)

```bash
kcpsm6 PS2_LCD_UART_PersonalCPU.psm -o PS2_LCD_UART_PersonalCPU.hex
```

This generates:

- `.hex` file (hexadecimal memory dump)
- `PS2_LCD_UART_PersonalCPU.axi` file (annotation)

### 3. **Generate VHDL Memory File**

The KCPSM6 assembler also processes `ROM_form.vhd` template to create `memoria.vhd`:

```bash
kcpsm6 PS2_LCD_UART_PersonalCPU.psm -o memoria.vhd
```

Or manually process the .hex file through the ROM_form converter.

### 4. **Replace Old memoria.vhd**

```
OLD: PersonalCPU.srcs/sources_1/new/memoria.vhd
NEW: PersonalCPU.srcs/sources_1/new/memoria.vhd
```

Replace the entire file with the newly generated memoria.vhd.

### 5. **Verify Memory Generation**

The new memoria.vhd should:

- Contain the PS/2+LCD+UART program
- Have the same generic parameters (C_FAMILY='7S', C_RAM_SIZE_KWORDS=2)
- Fit within 2K instructions (4096 bytes)

---

## Hardware Testing Checklist

After synthesizing and programming the FPGA:

- [ ] **PS/2 Keyboard**: Press keys 0-9, A-Z, verify display on LCD
- [ ] **LCD Display**: Verify 16x2 character display, line wrapping at column 16
- [ ] **UART Output**: Connect serial terminal (115200, 8N1) to PmodC pins
  - Verify: Each key press displays on LCD and echoes to terminal
  - Verify: Each terminal input displays on LCD
- [ ] **Special Keys**:
  - Escape: Clear screen
  - Enter: Move to next line
  - Backspace: Delete character
- [ ] **Line Wrap**: Type > 16 characters, verify automatic wrap to row 2
- [ ] **Screen Wrap**: Type > 32 characters, verify wrap back to row 1

---

## Baud Rate Calculation

For 115200 baud at 125 MHz clock:

- Divisor = System_Clock / (Baud_Rate \* 16_x_oversampling)
- Divisor = 125,000,000 / (115200 \* 16) = 67.13 ≈ 67

Actual baud rate achieved: 125,000,000 / (67 \* 16) = 115,191 baud (error: 0.008%)

---

## File Locations

```
PersonalCPU.srcs/sources_1/new/
├── toplevel.vhd                    (UPDATED: UART instantiation)
├── UART_BaudRate_Gen.vhd          (NEW)
├── UART_Controller.vhd            (NEW)
├── uart_tx6.vhd                   (NEW: from KCPSM6 ref design)
├── uart_rx6.vhd                   (NEW: from KCPSM6 ref design)
├── PS2_Controller.vhd             (existing)
├── LCD_Controller.vhd             (existing)
└── memoria.vhd                    (REPLACE with new version)

PersonalCPU.srcs/utils_1/
├── PS2_LCD_UART_PersonalCPU.psm  (NEW: adapted firmware)
└── PS2_LCD_UART.psm              (old version, keep for reference)

PersonalCPU.srcs/constrs_1/new/
└── system.xdc                     (UPDATED: added UART pins)
```

---

## Known Limitations

1. **No Flow Control**: UART is simple blocking transmit (waits if buffer full)
2. **Fixed Baud Rate**: 115200 baud only (set by divisor in UART_BaudRate_Gen)
3. **Limited Scancode Map**: Only 0-9, A-Z, Space, Backspace, Enter, Escape
4. **2x16 LCD Only**: Hardcoded for 2-line, 16-character display
5. **No Parity**: 8 bits, 1 stop bit, no parity check

---

## Troubleshooting

**Issue**: Bitstream generation fails with DRC errors

- **Solution**: Ensure all ports in toplevel.vhd entity are listed in system.xdc

**Issue**: UART characters not received

- **Check**:
  - PmodC pins J18/J19 are connected to USB-serial adapter RX/TX
  - Serial terminal baud rate set to 115200
  - Drivers installed for USB-serial adapter

**Issue**: LCD display shows garbage

- **Check**:
  - Contrast pin on PmodCLP LCD (pin 3) properly connected
  - LCD initialization commands (0x38, 0x0F, 0x01, 0x06) execute without errors
  - HD44780 E pulse timing is correct (40-250ns minimum)

**Issue**: PS/2 keyboard not responding

- **Check**:
  - PS/2 clock pulls low properly (open-drain)
  - Rising edge detection in PS2_Controller.vhd working
  - ISR at 0x3FF being called

---

## References

- **KCPSM6**: Xilinx PicoBlaze processor documentation
- **HD44780**: LCD controller datasheet (enable pulse timing critical)
- **PS/2**: Keyboard protocol (fall-to-rise edge detection)
- **UART TX6/RX6**: Xilinx reference design for 115200 baud FIFO-based UART

---

**Status**: Ready for memoria.vhd generation and FPGA programming
**Date**: 2024
