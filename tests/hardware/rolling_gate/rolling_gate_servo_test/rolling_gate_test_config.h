#ifndef ROLLING_GATE_TEST_CONFIG_H
#define ROLLING_GATE_TEST_CONFIG_H

#include <Arduino.h>

namespace RollingGateTestConfig {

// C.A.T.E.R. rolling-gate servo hardware test firmware.
// Version is printed at startup and should be copied into test records.
constexpr char FIRMWARE_TEST_VERSION[] = "rolling-gate-servo-test-0.1.0";

// The repository does not currently define an authoritative rolling-gate
// servo signal pin or mechanically validated angle limits. Confirm these
// values on the physical Arduino Uno before changing the *_CONFIRMED flags.
constexpr uint8_t SERVO_SIGNAL_PIN = 9;
constexpr bool SERVO_SIGNAL_PIN_CONFIRMED = false;

// Positional servo angle commands for the rolling gate.
// RESTING_POSITION_DEGREES is the safe stationary/indexed position.
// DISPENSING_POSITION_DEGREES is the commanded position where the loaded
// chamber or carrying section reaches the discharge side.
constexpr uint8_t RESTING_POSITION_DEGREES = 90;
constexpr uint8_t DISPENSING_POSITION_DEGREES = 140;
constexpr bool SERVO_POSITION_LIMITS_CONFIRMED = false;

// Use +1 when the dispensing position is reached by increasing the commanded
// angle from rest. Use -1 when it is reached by decreasing the commanded angle.
constexpr int8_t GATE_ROTATION_DIRECTION = 1;
constexpr bool SERVO_DIRECTION_CONFIRMED = false;

// Movement pacing. Keep this slow enough that the operator can abort and watch
// for scraping, twisting, wiring interference, or servo strain.
constexpr uint8_t MOVEMENT_STEP_DEGREES = 2;
constexpr uint16_t MOVEMENT_STEP_DELAY_MS = 35;
constexpr uint16_t DISPENSING_DWELL_MS = 800;
constexpr uint16_t RETURN_INDEX_DWELL_MS = 800;
constexpr uint16_t REST_BETWEEN_CYCLES_MS = 1200;

// Required automatic cycle counts.
constexpr uint16_t DRY_CYCLE_COUNT = 20;
constexpr uint16_t KIBBLE_CYCLE_COUNT = 10;

// Serial test interface.
constexpr unsigned long SERIAL_BAUD_RATE = 115200UL;
constexpr unsigned long COMMAND_CONFIRMATION_TIMEOUT_MS = 30000UL;

// Printed at startup to show whether the default test assumption is dry or
// loaded. Individual Serial commands still choose the run type explicitly.
constexpr bool DEFAULT_RUN_USES_KIBBLE = false;

// Validation limits. These are command limits only; they are not proof that the
// physical rolling gate can safely travel the full range.
constexpr uint8_t MIN_ALLOWED_SERVO_DEGREES = 0;
constexpr uint8_t MAX_ALLOWED_SERVO_DEGREES = 180;
constexpr uint16_t MAX_ALLOWED_TEST_CYCLES = 100;
constexpr uint16_t MAX_ALLOWED_DWELL_MS = 60000;
constexpr uint16_t MIN_ALLOWED_MOVEMENT_DELAY_MS = 10;
constexpr uint16_t MAX_ALLOWED_MOVEMENT_DELAY_MS = 2000;

}  // namespace RollingGateTestConfig

#endif  // ROLLING_GATE_TEST_CONFIG_H
