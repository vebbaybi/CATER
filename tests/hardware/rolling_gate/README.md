# Rolling Gate Servo Hardware Test

This directory contains a dedicated C.A.T.E.R. hardware test for the servo-driven rolling gate dispenser. It is not the main DAISY firmware and it does not exercise PIR, ultrasonic, LCD, keypad, mobile, RFID, storage, water dispenser, or unrelated subsystems.

The repository currently documents an Arduino Uno R3 compatible board, the Arduino Servo library, a metal gear servo, an external regulated 5V servo supply, and a shared ground between the Arduino and servo power supply. The README also describes servo calibration in angle terms, so this test is written for a positional servo controlled by commanded angles. If the physical servo is actually continuous-rotation, do not upload this sketch until the test is redesigned for that hardware.

## Files

* `rolling_gate_servo_test/rolling_gate_servo_test.ino` - Arduino test sketch.
* `rolling_gate_servo_test/rolling_gate_test_config.h` - all test constants and confirmation flags.
* `TEST_PLAN.md` - physical test procedure and pass/conditional pass/fail rules.
* `RESULTS_TEMPLATE.md` - structured template for recording actual outcomes.

## Required Confirmation Before Upload

The repo does not contain an authoritative rolling-gate servo signal pin, safe resting angle, dispensing angle, or physical travel limit. The config header therefore defaults to safe lockout.

Before uploading, edit `rolling_gate_servo_test/rolling_gate_test_config.h`:

* Set `SERVO_SIGNAL_PIN` to the confirmed Arduino Uno digital signal pin.
* Set `RESTING_POSITION_DEGREES` to the safest stationary/indexed rolling-gate position.
* Set `DISPENSING_POSITION_DEGREES` to the commanded angle that carries the loaded rolling-gate section to the discharge side.
* Set `GATE_ROTATION_DIRECTION` to `1` when dispensing is reached by increasing the commanded angle, or `-1` when it is reached by decreasing the commanded angle.
* Tune `MOVEMENT_STEP_DEGREES`, `MOVEMENT_STEP_DELAY_MS`, `DISPENSING_DWELL_MS`, `RETURN_INDEX_DWELL_MS`, and `REST_BETWEEN_CYCLES_MS`.
* Keep `DRY_CYCLE_COUNT` at least `20` and `KIBBLE_CYCLE_COUNT` at least `10` unless a shorter bench check is being run before the required test.
* Change `SERVO_SIGNAL_PIN_CONFIRMED`, `SERVO_POSITION_LIMITS_CONFIRMED`, and `SERVO_DIRECTION_CONFIRMED` to `true` only after physical confirmation.

If any critical value is invalid or unconfirmed, the sketch prints configuration errors and refuses movement commands.

## Electrical Safety

Confirm the servo power arrangement before testing. Do not assume the Arduino 5V pin can safely power the servo under load. Use a shared ground between the Arduino and external servo power where external power is used.

Disconnect power before changing servo wiring. Keep hands clear of the rolling mechanism while powered. Begin without kibble before running loaded tests. Stop immediately if the servo stalls, overheats, chatters continuously, or the gate binds.

## Compile

Arduino CLI:

```powershell
arduino-cli compile --fqbn arduino:avr:uno tests/hardware/rolling_gate/rolling_gate_servo_test
```

Arduino IDE:

1. Open `tests/hardware/rolling_gate/rolling_gate_servo_test/rolling_gate_servo_test.ino`.
2. Select an Arduino Uno compatible board.
3. Verify the sketch before uploading.

## Upload

Replace `COMx` with the actual Arduino serial port:

```powershell
arduino-cli upload -p COMx --fqbn arduino:avr:uno tests/hardware/rolling_gate/rolling_gate_servo_test
```

## Serial Setup

Open Serial Monitor at the configured baud rate, currently `115200`. Set line ending to newline or both NL and CR.

The sketch prints the firmware test version and configuration at startup. No test cycle starts automatically after reset. If configuration is valid, the sketch attaches the servo and commands the resting position. If configuration is invalid or unconfirmed, the servo is not attached and movement commands are locked out.

## Commands

Movement commands are staged first and require `CONFIRM` before motion starts.

| Command | Action |
|---|---|
| `HELP` or `H` | Display command help |
| `CONFIG` or `C` | Display current configuration and validation |
| `DRY1` or `D1` | Stage one dry servo-driven cycle |
| `DRY` or `D` | Stage the configured repeated dry-cycle test |
| `KIBBLE1` or `K1` | Stage one kibble cycle |
| `KIBBLE` or `K` | Stage the configured repeated kibble-cycle test |
| `REST` or `R` | Stage return to the resting position |
| `CONFIRM` | Run the staged movement command |
| `ABORT` or `A` | Abort the active test or cancel a staged command |
| `SUMMARY` or `S` | Display active or final test summary |

Manual turning of the rolling gate must not be counted as a completed cycle. Only servo-driven cycles reported by the sketch count toward dry or loaded test totals.

## Hardware Limits

This sketch commands servo positions only. It does not detect jams, measure current, read an encoder, sense gate position, or prove that kibble dispensed. All physical observations must be made by the operator and recorded in `RESULTS_TEMPLATE.md`.
