# TR-RG-001 Rolling Gate Compile Evidence

| Field | Value |
|---|---|
| Test ID | TR-RG-001 |
| Test title | Compile rolling gate servo hardware test sketch for Arduino Uno |
| Status | Passed |
| Priority | P0 |
| Date | 2026-06-22 |
| Tester | Codex |
| Hardware revision | Not applicable for compile-only validation |
| Firmware version | rolling-gate-servo-test-0.1.0 |
| Git commit | Not recorded; working tree contains untracked test files |
| Branch | main |
| Board target | arduino:avr:uno |
| COM port | Not applicable; no upload performed |
| Power configuration | Not applicable; no hardware powered by this test |
| Configuration values | Compile used repository sketch and `rolling_gate_test_config.h` as present on 2026-06-22 |
| Preconditions | Arduino CLI, `arduino:avr` core, and Servo library available locally |
| Procedure followed | Ran Arduino CLI compile with warnings enabled |
| Deviations | None |
| Expected result | Sketch compiles for Arduino Uno without errors |
| Actual result | Sketch compiled successfully |
| Evidence references | Command output below |
| Covered test IDs | TR-RG-001 |
| Blocker, when blocked | None |
| Final classification | Passed |
| Follow-up issue | None |
| Retest requirement | Retest after sketch, config, library, board target, or Arduino CLI/toolchain changes |
| Sign-off | Compile-only software validation; no upload, Serial, or physical motion was tested |

Command:

```powershell
arduino-cli compile --warnings all --fqbn arduino:avr:uno tests/hardware/rolling_gate/rolling_gate_servo_test
```

Output:

```text
Sketch uses 11074 bytes (34%) of program storage space. Maximum is 32256 bytes.
Global variables use 416 bytes (20%) of dynamic memory, leaving 1632 bytes for local variables. Maximum is 2048 bytes.
```
