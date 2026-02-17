## How it works

This project implements a fully digital clock with alarm functionality using synchronous logic and a finite state machine (FSM).

The system is composed of the following main blocks:

- A clock prescaler (`clck_psc`) that generates a 1 Hz tick from the system clock.
- A time module (`time_mod`) that keeps track of hours and minutes (24-hour format).
- A comparator (`compare`) that checks when the current time matches the configured alarm time.
- An alarm finite state machine (`alarm_fsm`) that controls the alarm behavior.
- A seconds indicator LED that toggles every second.

When the current time matches the configured alarm time, a single-cycle pulse is generated. This pulse activates the FSM, which turns on the alarm output. The alarm remains active until the user presses the silence button.

The design is fully synchronous and uses only synthesizable Verilog constructs, making it suitable for ASIC implementation on the Sky130 process.

---

## How to test

The project uses the TinyTapeout standard interface:

Inputs:
- `ui[0]` → Reset button (active high)
- `ui[1]` → Silence alarm button

Outputs:
- `uo[0]` → Alarm LED
- `uo[1]` → Seconds LED (toggles every second)

### Test procedure:

1. Apply reset by setting `ui[0] = 1` momentarily.
2. Release reset (`ui[0] = 0`).
3. Observe that `uo[1]` toggles at 1 Hz (seconds indicator).
4. When the internal time matches the alarm time, `uo[0]` turns ON.
5. Press `ui[1]` to silence the alarm.
6. The alarm LED should turn OFF and return to the idle state.

The alarm time and initial time are defined using parameters in the top module.

---

## External hardware

No external hardware is required.

The design only uses:
- Standard clock input
- Two digital input pins
- Two digital output pins

The original FPGA version included a 7-segment display for visualization, but the TinyTapeout version uses only LEDs for output indication.
