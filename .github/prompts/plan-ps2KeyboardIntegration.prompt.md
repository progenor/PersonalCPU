# Plan: PS2 Keyboard Integration for PersonalCPU

## TL;DR

You'll adapt the Diakoknak PS2 debouncing & interrupt logic to your custom 16-bit CPU by: (1) creating a dedicated PS2 controller module that debounces signals and detects falling edges, (2) integrating interrupt generation into your toplevel, (3) mapping PS2 data reads to a new port (0x01), and (4) writing firmware assembly code to capture raw scancodes via interrupt handler. The 16-bit data width is handled by using only lower 8 bits for PS2 compatibility. Scancodes stay raw—your firmware will handle ASCII conversion later.

---

## Implementation Steps

### 1. Create PS2 Controller Module (`PS2_Controller.vhd`)

- Dual debounce filters (5-bit counters) for PS2 clock and data, adapted from reference design
- Falling-edge detector on `ps2_clk_clean` to generate `interrupt_req` pulse
- **Outputs:**
  - `ps2_data_debounced`: debounced PS2 data line
  - `ps2_clk_debounced`: debounced PS2 clock line
  - `interrupt_req`: pulse on clock falling edge
- **Inputs:**
  - `ps2_data`, `ps2_clk`: raw signals from board pins
  - `clk`: system clock (125 MHz)
  - `reset`: active high reset

### 2. Modify `toplevel.vhd`

- Instantiate `PS2_Controller` and wire to PS2 pins (W14=data, T11=clock from constraints)
- Route `interrupt_req` → CPU `interrupt` port (replacing current `btn(0)`)
- Add input port mux for PS2 data reads at port address `0x01`:
  - When `Rd_strobe='1'` and `PortID=0x01`, drive `PortDataIn[7:0]` with `ps2_data_debounced` packed at bit 7
  - Maintain existing button/LED mappings at ports 0x05/0x06

### 3. Adapt `PortLogic.vhd` (Optional)

- No explicit changes required—16-bit width already accommodates 8-bit PS2 data
- Padding handled in toplevel mux logic

### 4. Create Assembly Interrupt Handler (`ps2_isr.asm`)

- Entry point: interrupt vector address (check current ROM interrupt vector, likely 0x3FF for 2K ROM)
- **Functionality:**
  - Read port 0x01 to sample PS2 data bit on each clock pulse
  - Implement 11-bit shift register (1 start + 8 data + 1 parity + 1 stop)
  - When all 11 bits received, extract 8-bit scancode
  - Store scancode in RAM buffer for main firmware
  - Optional: validate parity bit
  - Return from interrupt with `RETURNI`

### 5. Update `memoria.vhd` (Verify)

- Confirm ROM size supports ISR at interrupt vector address
- Verify scratchpad/RAM available for scancode buffering
- u can verify but dont edit, i will write the memory code myself then generate using a translator, the current code its for sure not correct

no test required

## Design Decisions

| Decision                  | Choice                                                     | Rationale                                                             |
| ------------------------- | ---------------------------------------------------------- | --------------------------------------------------------------------- |
| **PS2 Port Address**      | 0x01                                                       | Avoids collision with button (0x05) and LED (0x06) ports              |
| **Data Format**           | PS2 bit at `PortDataIn[7]`, bits [6:0] = `0`               | Matches reference design; upper bits reserved for future use          |
| **Scancode Storage**      | Raw 8-bit bytes (no ASCII conversion in hardware)          | Reduces hardware complexity; firmware handles translation table       |
| **Debounce Window**       | 32 system clocks (5-bit counter at 0x1F)                   | Standard for PS2 clock/data glitch filtering                          |
| **Interrupt Trigger**     | Rising-edge of PS2 clock cleanup; triggers on falling edge | Synchronous, clean sampling                                           |
| **Interrupt Vector**      | Assume 0x3FF (2K ROM standard); **verify in memoria.vhd**  | Standard for KCPSM6-compatible designs; confirm before implementation |
| **Buffer Management**     | Simple circular buffer (wrap on overflow) or pause-on-full | TBD based on firmware requirements                                    |
| **Architecture Strategy** | Keep custom CPU; adapt reference logic                     | Preserves existing work; reuses proven patterns                       |

---

## Verification Checklist

### Simulation

- [ ] PS2 controller debounce filters reduce glitches
- [ ] Falling-edge detector fires interrupt_req at correct clock transition
- [ ] Interrupt handler captures all 11 bits correctly over multiple cycles
- [ ] Scancode extracted matches test vector
- [ ] Parity validation (if enabled) passes/fails as expected

### Hardware

- [ ] Press keys on attached PS2 keyboard
- [ ] Interrupt LED (if available) blinks during key press
- [ ] Scancodes visible on output LEDs or UART display
- [ ] Multiple keypresses captured without loss
- [ ] Key release (make/break codes) detected but filtered out (future feature)

### Firmware

- [ ] Interrupt handler executes without crashing
- [ ] Scancode buffer filled incrementally over ~11 clock cycles per key
- [ ] Main loop reads buffer correctly
- [ ] Output (LED/display) reflects captured scancodes

---

## Files to Create / Modify

| File                  | Action                                                 | Status  |
| --------------------- | ------------------------------------------------------ | ------- |
| `PS2_Controller.vhd`  | Create new                                             | Pending |
| `toplevel.vhd`        | Modify (instantiate PS2_Controller, interrupt routing) | Pending |
| `system.xdc`          | Verify (PS2 pins W14, T11 should already exist)        | Pending |
| `ps2_isr.asm`         | Create new (assembly interrupt handler)                | Pending |
| `memoria.vhd`         | Verify (interrupt vector address, ROM size)            | Pending |
| `toplevel_tb_ps2.vhd` | Create new (testbench)                                 | Pending |

---

## Open Questions

1. **Interrupt Vector Address**: Where in your 2K ROM should the PS2 ISR reside?
   - Standard: 0x3FF (end of memory, reserved interrupt vector)
   - Verify in [memoria.vhd](PersonalCPU.srcs/sources_1/new/memoria.vhd)

2. **Parity Error Handling**:
   - Hardware parity check + firmware flag?
   - Ignore bad parity and buffer anyway?
   - Discard entire byte on parity mismatch?

3. **Buffer Behavior on Overflow**:
   - Wrap-around (oldest scancode discarded)?
   - Pause new captures (stop interrupt handler)?
   - Report overflow condition to firmware?

4. **Scancode Filtering**:
   - Capture make + break codes (0xF0 prefix)?
   - Filter breaks at hardware level or in firmware?

5. **LCD Integration** (future):
   - Should architecture now be LCD-ready, or PS2-only for this phase?

---

## Reference Materials Location

- **PS2 Debouncing Logic**: `FromOthers/Diakoknak/Kod/ps2toplevel.vhd` (lines 175–224)
- **KCPSM6 Interrupt Patterns**: `FromOthers/KCPSM6_Release9_30Sept14/kcpsm6_design_template.vhd`
- **PS2 Full Example**: `FromOthers/Ps_2-20260421T072547Z-3-001/Ps_2/Ps_2.srcs/sources_1/imports/Downloads/ps2_lcd_toplevel.vhd`
- **Your Current Architecture**: `PersonalCPU.srcs/sources_1/new/toplevel.vhd`, `PortLogic.vhd`
- **Board Constraints**: `PersonalCPU.srcs/constrs_1/new/system.xdc`
- **Interrupt JSON Example**: `Lectures/PS2_InteruptHandle.json`
