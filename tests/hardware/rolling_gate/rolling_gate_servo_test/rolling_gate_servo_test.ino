#include <Arduino.h>
#include <Servo.h>
#include <string.h>

#include "rolling_gate_test_config.h"

using namespace RollingGateTestConfig;

namespace {

constexpr uint8_t INPUT_BUFFER_LENGTH = 32;
constexpr uint8_t UNO_MIN_SAFE_SIGNAL_PIN = 2;
constexpr uint8_t UNO_MAX_DIGITAL_PIN = 13;
constexpr uint16_t STARTUP_LOG_DELAY_MS = 250;

enum RunMode : uint8_t {
  RUN_MODE_NONE,
  RUN_MODE_DRY,
  RUN_MODE_KIBBLE
};

enum RunState : uint8_t {
  RUN_STATE_IDLE,
  RUN_STATE_MANUAL_RETURN,
  RUN_STATE_PREPARE_REST,
  RUN_STATE_MOVE_TO_DISPENSE,
  RUN_STATE_DISPENSE_DWELL,
  RUN_STATE_RETURN_TO_REST,
  RUN_STATE_RETURN_DWELL,
  RUN_STATE_REST_BETWEEN_CYCLES,
  RUN_STATE_ABORT_RETURN
};

enum PendingAction : uint8_t {
  PENDING_NONE,
  PENDING_ONE_DRY,
  PENDING_DRY_TEST,
  PENDING_ONE_KIBBLE,
  PENDING_KIBBLE_TEST,
  PENDING_RETURN_REST
};

struct TestRun {
  bool active;
  RunMode mode;
  RunState state;
  uint16_t requestedCycles;
  uint16_t completedCycles;
  bool aborted;
  unsigned long stateStartedAt;
};

struct RunSummary {
  bool available;
  RunMode mode;
  uint16_t requestedCycles;
  uint16_t completedCycles;
  bool aborted;
};

Servo gateServo;
bool servoAttached = false;
bool configurationValid = false;
uint8_t currentCommandedPosition = RESTING_POSITION_DEGREES;
unsigned long lastMovementStepAt = 0;

char inputBuffer[INPUT_BUFFER_LENGTH];
uint8_t inputLength = 0;

PendingAction pendingAction = PENDING_NONE;
unsigned long pendingActionStartedAt = 0;

TestRun activeRun = {false, RUN_MODE_NONE, RUN_STATE_IDLE, 0, 0, false, 0};
RunSummary lastSummary = {false, RUN_MODE_NONE, 0, 0, false};

bool hasElapsed(unsigned long startedAt, unsigned long durationMs) {
  return (millis() - startedAt) >= durationMs;
}

bool isCommandSpace(char value) {
  return value == ' ' || value == '\t';
}

void trimAndUppercase(char *text) {
  const uint8_t length = static_cast<uint8_t>(strlen(text));
  uint8_t start = 0;
  while (start < length && isCommandSpace(text[start])) {
    start++;
  }

  uint8_t end = length;
  while (end > start && isCommandSpace(text[end - 1])) {
    end--;
  }

  uint8_t outputIndex = 0;
  for (uint8_t inputIndex = start; inputIndex < end && outputIndex < INPUT_BUFFER_LENGTH - 1; inputIndex++) {
    char value = text[inputIndex];
    if (value >= 'a' && value <= 'z') {
      value = static_cast<char>(value - ('a' - 'A'));
    }
    text[outputIndex++] = value;
  }
  text[outputIndex] = '\0';
}

bool commandIs(const char *command, const char *expected) {
  return strcmp(command, expected) == 0;
}

void printBool(bool value) {
  Serial.println(value ? F("true") : F("false"));
}

void printNameValue(const __FlashStringHelper *name, long value) {
  Serial.print(F("  "));
  Serial.print(name);
  Serial.print(F(": "));
  Serial.println(value);
}

void printNameBool(const __FlashStringHelper *name, bool value) {
  Serial.print(F("  "));
  Serial.print(name);
  Serial.print(F(": "));
  printBool(value);
}

void printRunMode(RunMode mode) {
  switch (mode) {
    case RUN_MODE_DRY:
      Serial.print(F("dry"));
      break;
    case RUN_MODE_KIBBLE:
      Serial.print(F("kibble"));
      break;
    default:
      Serial.print(F("none"));
      break;
  }
}

void printlnRunMode(RunMode mode) {
  printRunMode(mode);
  Serial.println();
}

void printPendingAction(PendingAction action) {
  switch (action) {
    case PENDING_ONE_DRY:
      Serial.print(F("one dry cycle"));
      break;
    case PENDING_DRY_TEST:
      Serial.print(F("configured dry-cycle test"));
      break;
    case PENDING_ONE_KIBBLE:
      Serial.print(F("one kibble cycle"));
      break;
    case PENDING_KIBBLE_TEST:
      Serial.print(F("configured kibble-cycle test"));
      break;
    case PENDING_RETURN_REST:
      Serial.print(F("return gate to resting position"));
      break;
    default:
      Serial.print(F("none"));
      break;
  }
}

void printMovementState(RunState state) {
  Serial.print(F("Commanded movement state: "));
  switch (state) {
    case RUN_STATE_MANUAL_RETURN:
      Serial.println(F("returning to resting position by operator command"));
      break;
    case RUN_STATE_PREPARE_REST:
      Serial.println(F("preparing at resting position before cycle 1"));
      break;
    case RUN_STATE_MOVE_TO_DISPENSE:
      Serial.println(F("rotating toward dispensing position"));
      break;
    case RUN_STATE_DISPENSE_DWELL:
      Serial.println(F("dwelling at dispensing position"));
      break;
    case RUN_STATE_RETURN_TO_REST:
      Serial.println(F("returning/indexing to resting position"));
      break;
    case RUN_STATE_RETURN_DWELL:
      Serial.println(F("dwelling after return/indexing"));
      break;
    case RUN_STATE_REST_BETWEEN_CYCLES:
      Serial.println(F("resting between cycles"));
      break;
    case RUN_STATE_ABORT_RETURN:
      Serial.println(F("abort recovery: returning to resting position"));
      break;
    default:
      Serial.println(F("idle"));
      break;
  }
}

void printConfigError(const __FlashStringHelper *message) {
  Serial.print(F("CONFIG ERROR: "));
  Serial.println(message);
}

void printConfiguration() {
  Serial.println();
  Serial.println(F("Rolling gate servo test configuration"));
  Serial.print(F("  FIRMWARE_TEST_VERSION: "));
  Serial.println(FIRMWARE_TEST_VERSION);
  printNameValue(F("SERVO_SIGNAL_PIN"), SERVO_SIGNAL_PIN);
  printNameBool(F("SERVO_SIGNAL_PIN_CONFIRMED"), SERVO_SIGNAL_PIN_CONFIRMED);
  printNameValue(F("RESTING_POSITION_DEGREES"), RESTING_POSITION_DEGREES);
  printNameValue(F("DISPENSING_POSITION_DEGREES"), DISPENSING_POSITION_DEGREES);
  printNameBool(F("SERVO_POSITION_LIMITS_CONFIRMED"), SERVO_POSITION_LIMITS_CONFIRMED);
  printNameValue(F("GATE_ROTATION_DIRECTION"), GATE_ROTATION_DIRECTION);
  printNameBool(F("SERVO_DIRECTION_CONFIRMED"), SERVO_DIRECTION_CONFIRMED);
  printNameValue(F("MOVEMENT_STEP_DEGREES"), MOVEMENT_STEP_DEGREES);
  printNameValue(F("MOVEMENT_STEP_DELAY_MS"), MOVEMENT_STEP_DELAY_MS);
  printNameValue(F("DISPENSING_DWELL_MS"), DISPENSING_DWELL_MS);
  printNameValue(F("RETURN_INDEX_DWELL_MS"), RETURN_INDEX_DWELL_MS);
  printNameValue(F("REST_BETWEEN_CYCLES_MS"), REST_BETWEEN_CYCLES_MS);
  printNameValue(F("DRY_CYCLE_COUNT"), DRY_CYCLE_COUNT);
  printNameValue(F("KIBBLE_CYCLE_COUNT"), KIBBLE_CYCLE_COUNT);
  printNameValue(F("SERIAL_BAUD_RATE"), SERIAL_BAUD_RATE);
  printNameBool(F("DEFAULT_RUN_USES_KIBBLE"), DEFAULT_RUN_USES_KIBBLE);
  printNameValue(F("MIN_ALLOWED_SERVO_DEGREES"), MIN_ALLOWED_SERVO_DEGREES);
  printNameValue(F("MAX_ALLOWED_SERVO_DEGREES"), MAX_ALLOWED_SERVO_DEGREES);
  printNameValue(F("MAX_ALLOWED_TEST_CYCLES"), MAX_ALLOWED_TEST_CYCLES);
  printNameValue(F("COMMAND_CONFIRMATION_TIMEOUT_MS"), COMMAND_CONFIRMATION_TIMEOUT_MS);
  Serial.println();
}

bool validateConfiguration(bool verbose) {
  bool valid = true;

  if (!SERVO_SIGNAL_PIN_CONFIRMED) {
    valid = false;
    if (verbose) {
      printConfigError(F("SERVO_SIGNAL_PIN_CONFIRMED is false. Confirm the Uno signal pin before movement."));
    }
  }

  if (!SERVO_POSITION_LIMITS_CONFIRMED) {
    valid = false;
    if (verbose) {
      printConfigError(F("SERVO_POSITION_LIMITS_CONFIRMED is false. Confirm resting and dispensing positions before movement."));
    }
  }

  if (!SERVO_DIRECTION_CONFIRMED) {
    valid = false;
    if (verbose) {
      printConfigError(F("SERVO_DIRECTION_CONFIRMED is false. Confirm the commanded rotation direction before movement."));
    }
  }

  if (SERVO_SIGNAL_PIN < UNO_MIN_SAFE_SIGNAL_PIN || SERVO_SIGNAL_PIN > UNO_MAX_DIGITAL_PIN) {
    valid = false;
    if (verbose) {
      printConfigError(F("SERVO_SIGNAL_PIN must be an Arduino Uno digital pin from D2 through D13."));
    }
  }

  if (MIN_ALLOWED_SERVO_DEGREES >= MAX_ALLOWED_SERVO_DEGREES || MAX_ALLOWED_SERVO_DEGREES > 180) {
    valid = false;
    if (verbose) {
      printConfigError(F("Allowed servo degree range must be increasing and no greater than 180."));
    }
  }

  if (RESTING_POSITION_DEGREES < MIN_ALLOWED_SERVO_DEGREES || RESTING_POSITION_DEGREES > MAX_ALLOWED_SERVO_DEGREES) {
    valid = false;
    if (verbose) {
      printConfigError(F("RESTING_POSITION_DEGREES is outside the allowed servo range."));
    }
  }

  if (DISPENSING_POSITION_DEGREES < MIN_ALLOWED_SERVO_DEGREES || DISPENSING_POSITION_DEGREES > MAX_ALLOWED_SERVO_DEGREES) {
    valid = false;
    if (verbose) {
      printConfigError(F("DISPENSING_POSITION_DEGREES is outside the allowed servo range."));
    }
  }

  if (RESTING_POSITION_DEGREES == DISPENSING_POSITION_DEGREES) {
    valid = false;
    if (verbose) {
      printConfigError(F("RESTING_POSITION_DEGREES and DISPENSING_POSITION_DEGREES must be different."));
    }
  }

  if (GATE_ROTATION_DIRECTION != 1 && GATE_ROTATION_DIRECTION != -1) {
    valid = false;
    if (verbose) {
      printConfigError(F("GATE_ROTATION_DIRECTION must be +1 or -1."));
    }
  }

  if (GATE_ROTATION_DIRECTION == 1 && DISPENSING_POSITION_DEGREES <= RESTING_POSITION_DEGREES) {
    valid = false;
    if (verbose) {
      printConfigError(F("Direction +1 requires dispensing position to be greater than resting position."));
    }
  }

  if (GATE_ROTATION_DIRECTION == -1 && DISPENSING_POSITION_DEGREES >= RESTING_POSITION_DEGREES) {
    valid = false;
    if (verbose) {
      printConfigError(F("Direction -1 requires dispensing position to be less than resting position."));
    }
  }

  if (MOVEMENT_STEP_DEGREES == 0 || MOVEMENT_STEP_DEGREES > 20) {
    valid = false;
    if (verbose) {
      printConfigError(F("MOVEMENT_STEP_DEGREES must be from 1 through 20."));
    }
  }

  if (MOVEMENT_STEP_DELAY_MS < MIN_ALLOWED_MOVEMENT_DELAY_MS || MOVEMENT_STEP_DELAY_MS > MAX_ALLOWED_MOVEMENT_DELAY_MS) {
    valid = false;
    if (verbose) {
      printConfigError(F("MOVEMENT_STEP_DELAY_MS is outside the allowed timing range."));
    }
  }

  if (DISPENSING_DWELL_MS > MAX_ALLOWED_DWELL_MS ||
      RETURN_INDEX_DWELL_MS > MAX_ALLOWED_DWELL_MS ||
      REST_BETWEEN_CYCLES_MS > MAX_ALLOWED_DWELL_MS) {
    valid = false;
    if (verbose) {
      printConfigError(F("A dwell/rest timing value is above MAX_ALLOWED_DWELL_MS."));
    }
  }

  if (DRY_CYCLE_COUNT == 0 || DRY_CYCLE_COUNT > MAX_ALLOWED_TEST_CYCLES) {
    valid = false;
    if (verbose) {
      printConfigError(F("DRY_CYCLE_COUNT must be from 1 through MAX_ALLOWED_TEST_CYCLES."));
    }
  }

  if (KIBBLE_CYCLE_COUNT == 0 || KIBBLE_CYCLE_COUNT > MAX_ALLOWED_TEST_CYCLES) {
    valid = false;
    if (verbose) {
      printConfigError(F("KIBBLE_CYCLE_COUNT must be from 1 through MAX_ALLOWED_TEST_CYCLES."));
    }
  }

  if (SERIAL_BAUD_RATE == 0) {
    valid = false;
    if (verbose) {
      printConfigError(F("SERIAL_BAUD_RATE must be greater than zero."));
    }
  }

  if (verbose) {
    Serial.print(F("Configuration validation: "));
    Serial.println(valid ? F("PASS") : F("FAIL - movement commands are locked out"));
  }

  return valid;
}

bool attachServoIfNeeded() {
  if (servoAttached) {
    return true;
  }

  if (!configurationValid) {
    Serial.println(F("Servo was not attached because configuration validation failed."));
    return false;
  }

  currentCommandedPosition = RESTING_POSITION_DEGREES;
  gateServo.write(currentCommandedPosition);
  gateServo.attach(SERVO_SIGNAL_PIN);
  gateServo.write(currentCommandedPosition);
  servoAttached = true;

  Serial.print(F("Servo attached on Uno pin D"));
  Serial.print(SERVO_SIGNAL_PIN);
  Serial.print(F(" and commanded to resting position "));
  Serial.print(currentCommandedPosition);
  Serial.println(F(" degrees."));
  return true;
}

void enterRunState(RunState state) {
  activeRun.state = state;
  activeRun.stateStartedAt = millis();
  lastMovementStepAt = millis() - MOVEMENT_STEP_DELAY_MS;
  printMovementState(state);
}

bool stepTowardPosition(uint8_t targetPosition) {
  if (currentCommandedPosition == targetPosition) {
    return true;
  }

  if (!hasElapsed(lastMovementStepAt, MOVEMENT_STEP_DELAY_MS)) {
    return false;
  }

  lastMovementStepAt = millis();

  int nextPosition = currentCommandedPosition;
  if (targetPosition > currentCommandedPosition) {
    nextPosition += MOVEMENT_STEP_DEGREES;
    if (nextPosition > targetPosition) {
      nextPosition = targetPosition;
    }
  } else {
    nextPosition -= MOVEMENT_STEP_DEGREES;
    if (nextPosition < targetPosition) {
      nextPosition = targetPosition;
    }
  }

  currentCommandedPosition = static_cast<uint8_t>(nextPosition);
  gateServo.write(currentCommandedPosition);

  Serial.print(F("Commanded servo position: "));
  Serial.print(currentCommandedPosition);
  Serial.println(F(" degrees"));

  return currentCommandedPosition == targetPosition;
}

void printCycleHeader() {
  Serial.println();
  Serial.print(F("Cycle "));
  Serial.print(activeRun.completedCycles + 1);
  Serial.print(F(" of "));
  Serial.print(activeRun.requestedCycles);
  Serial.print(F(" | mode: "));
  printlnRunMode(activeRun.mode);
  Serial.println(F("Operator reminder: manual gate movement does not count as a completed cycle."));
}

void beginNextCycle() {
  printCycleHeader();
  enterRunState(RUN_STATE_MOVE_TO_DISPENSE);
}

void saveRunSummary(bool aborted) {
  if (activeRun.mode == RUN_MODE_NONE) {
    return;
  }

  lastSummary.available = true;
  lastSummary.mode = activeRun.mode;
  lastSummary.requestedCycles = activeRun.requestedCycles;
  lastSummary.completedCycles = activeRun.completedCycles;
  lastSummary.aborted = aborted;
}

void printSummary() {
  Serial.println();
  Serial.println(F("Rolling gate test summary"));

  if (activeRun.active && activeRun.mode != RUN_MODE_NONE) {
    Serial.println(F("  Status: active"));
    Serial.print(F("  Mode: "));
    printlnRunMode(activeRun.mode);
    printNameValue(F("Requested cycles"), activeRun.requestedCycles);
    printNameValue(F("Completed servo-driven cycles"), activeRun.completedCycles);
    printNameBool(F("Aborted"), activeRun.aborted);
    Serial.println();
    return;
  }

  if (!lastSummary.available) {
    Serial.println(F("  No completed or aborted test run has been recorded since reset."));
    Serial.println();
    return;
  }

  Serial.print(F("  Status: "));
  Serial.println(lastSummary.aborted ? F("aborted") : F("completed"));
  Serial.print(F("  Mode: "));
  printlnRunMode(lastSummary.mode);
  printNameValue(F("Requested cycles"), lastSummary.requestedCycles);
  printNameValue(F("Completed servo-driven cycles"), lastSummary.completedCycles);
  printNameBool(F("Aborted"), lastSummary.aborted);
  Serial.println(F("  Physical observations must be recorded in RESULTS_TEMPLATE.md."));
  Serial.println();
}

void finishActiveRun(bool aborted) {
  saveRunSummary(aborted);

  Serial.println();
  Serial.println(aborted ? F("TEST ABORTED") : F("TEST COMPLETE"));
  Serial.print(F("Completed servo-driven cycles: "));
  Serial.print(activeRun.completedCycles);
  Serial.print(F(" of "));
  Serial.println(activeRun.requestedCycles);
  Serial.print(F("Final commanded position: "));
  Serial.print(currentCommandedPosition);
  Serial.println(F(" degrees"));

  activeRun.active = false;
  activeRun.state = RUN_STATE_IDLE;
  activeRun.mode = RUN_MODE_NONE;

  printSummary();
}

void completeCycle() {
  activeRun.completedCycles++;
  Serial.print(F("Cycle complete. Completed servo-driven cycles: "));
  Serial.print(activeRun.completedCycles);
  Serial.print(F(" of "));
  Serial.println(activeRun.requestedCycles);

  if (activeRun.completedCycles >= activeRun.requestedCycles) {
    finishActiveRun(false);
    return;
  }

  enterRunState(RUN_STATE_REST_BETWEEN_CYCLES);
}

void updateActiveRun() {
  if (!activeRun.active) {
    return;
  }

  switch (activeRun.state) {
    case RUN_STATE_MANUAL_RETURN:
      if (stepTowardPosition(RESTING_POSITION_DEGREES)) {
        Serial.println(F("Manual return complete. Gate is commanded to the resting position."));
        activeRun.active = false;
        activeRun.state = RUN_STATE_IDLE;
        activeRun.mode = RUN_MODE_NONE;
      }
      break;

    case RUN_STATE_PREPARE_REST:
      if (stepTowardPosition(RESTING_POSITION_DEGREES)) {
        Serial.println(F("Startup for run: gate is commanded to the resting position."));
        beginNextCycle();
      }
      break;

    case RUN_STATE_MOVE_TO_DISPENSE:
      if (stepTowardPosition(DISPENSING_POSITION_DEGREES)) {
        Serial.println(F("Dispensing position reached."));
        enterRunState(RUN_STATE_DISPENSE_DWELL);
      }
      break;

    case RUN_STATE_DISPENSE_DWELL:
      if (hasElapsed(activeRun.stateStartedAt, DISPENSING_DWELL_MS)) {
        enterRunState(RUN_STATE_RETURN_TO_REST);
      }
      break;

    case RUN_STATE_RETURN_TO_REST:
      if (stepTowardPosition(RESTING_POSITION_DEGREES)) {
        Serial.println(F("Resting/indexed position reached."));
        enterRunState(RUN_STATE_RETURN_DWELL);
      }
      break;

    case RUN_STATE_RETURN_DWELL:
      if (hasElapsed(activeRun.stateStartedAt, RETURN_INDEX_DWELL_MS)) {
        completeCycle();
      }
      break;

    case RUN_STATE_REST_BETWEEN_CYCLES:
      if (hasElapsed(activeRun.stateStartedAt, REST_BETWEEN_CYCLES_MS)) {
        beginNextCycle();
      }
      break;

    case RUN_STATE_ABORT_RETURN:
      if (stepTowardPosition(RESTING_POSITION_DEGREES)) {
        Serial.println(F("Abort recovery complete. Gate is commanded to the resting position."));
        finishActiveRun(true);
      }
      break;

    default:
      break;
  }
}

void startRun(RunMode mode, uint16_t cycles) {
  configurationValid = validateConfiguration(true);
  if (!configurationValid) {
    Serial.println(F("Movement refused. Fix configuration before running this test."));
    return;
  }

  if (activeRun.active) {
    Serial.println(F("Movement refused. A test or return command is already active."));
    return;
  }

  if (!attachServoIfNeeded()) {
    return;
  }

  activeRun.active = true;
  activeRun.mode = mode;
  activeRun.state = RUN_STATE_PREPARE_REST;
  activeRun.requestedCycles = cycles;
  activeRun.completedCycles = 0;
  activeRun.aborted = false;
  activeRun.stateStartedAt = millis();

  Serial.println();
  Serial.println(F("TEST STARTED"));
  Serial.print(F("Run mode: "));
  printlnRunMode(mode);
  Serial.print(F("Requested cycles: "));
  Serial.println(cycles);
  Serial.println(F("No automatic retries are enabled."));
  enterRunState(RUN_STATE_PREPARE_REST);
}

void startManualReturnToRest() {
  configurationValid = validateConfiguration(true);
  if (!configurationValid) {
    Serial.println(F("Return refused. Fix configuration before commanding movement."));
    return;
  }

  if (activeRun.active) {
    Serial.println(F("Return refused. A test or return command is already active."));
    return;
  }

  if (!attachServoIfNeeded()) {
    return;
  }

  activeRun.active = true;
  activeRun.mode = RUN_MODE_NONE;
  activeRun.state = RUN_STATE_MANUAL_RETURN;
  activeRun.requestedCycles = 0;
  activeRun.completedCycles = 0;
  activeRun.aborted = false;
  activeRun.stateStartedAt = millis();

  Serial.println(F("Manual return command started."));
  enterRunState(RUN_STATE_MANUAL_RETURN);
}

void requestAbort() {
  if (pendingAction != PENDING_NONE) {
    pendingAction = PENDING_NONE;
    Serial.println(F("Staged movement command canceled."));
    return;
  }

  if (!activeRun.active) {
    Serial.println(F("No active test or return command to abort."));
    return;
  }

  if (activeRun.state == RUN_STATE_ABORT_RETURN) {
    Serial.println(F("Abort recovery is already in progress."));
    return;
  }

  activeRun.aborted = true;
  Serial.println(F("ABORT requested. No further cycles will start."));
  enterRunState(RUN_STATE_ABORT_RETURN);
}

void stageAction(PendingAction action) {
  if (activeRun.active) {
    Serial.println(F("Command refused. A test or return command is already active."));
    return;
  }

  pendingAction = action;
  pendingActionStartedAt = millis();

  Serial.println();
  Serial.print(F("Movement request staged: "));
  printPendingAction(action);
  Serial.println();
  Serial.println(F("Confirm the test area is clear, keep hands away, then type CONFIRM within the timeout."));
  Serial.println(F("Type ABORT to cancel the staged request."));
}

void executePendingAction() {
  if (pendingAction == PENDING_NONE) {
    Serial.println(F("No staged movement command is waiting for confirmation."));
    return;
  }

  if (!hasElapsed(pendingActionStartedAt, COMMAND_CONFIRMATION_TIMEOUT_MS + 1)) {
    PendingAction action = pendingAction;
    pendingAction = PENDING_NONE;

    switch (action) {
      case PENDING_ONE_DRY:
        startRun(RUN_MODE_DRY, 1);
        break;
      case PENDING_DRY_TEST:
        startRun(RUN_MODE_DRY, DRY_CYCLE_COUNT);
        break;
      case PENDING_ONE_KIBBLE:
        startRun(RUN_MODE_KIBBLE, 1);
        break;
      case PENDING_KIBBLE_TEST:
        startRun(RUN_MODE_KIBBLE, KIBBLE_CYCLE_COUNT);
        break;
      case PENDING_RETURN_REST:
        startManualReturnToRest();
        break;
      default:
        break;
    }
    return;
  }

  pendingAction = PENDING_NONE;
  Serial.println(F("Staged movement command expired. Re-enter the command when ready."));
}

void updatePendingActionTimeout() {
  if (pendingAction == PENDING_NONE) {
    return;
  }

  if (hasElapsed(pendingActionStartedAt, COMMAND_CONFIRMATION_TIMEOUT_MS)) {
    pendingAction = PENDING_NONE;
    Serial.println(F("Staged movement command expired. No movement started."));
  }
}

void printHelp() {
  Serial.println();
  Serial.println(F("Rolling gate servo test commands"));
  Serial.println(F("  HELP or H       - display this help"));
  Serial.println(F("  CONFIG or C     - display configuration and validation"));
  Serial.println(F("  DRY1 or D1      - stage one dry servo-driven cycle"));
  Serial.println(F("  DRY or D        - stage configured dry-cycle test"));
  Serial.println(F("  KIBBLE1 or K1   - stage one kibble cycle"));
  Serial.println(F("  KIBBLE or K     - stage configured kibble-cycle test"));
  Serial.println(F("  REST or R       - stage return to resting position"));
  Serial.println(F("  CONFIRM         - run the staged movement command"));
  Serial.println(F("  ABORT or A      - abort active test or cancel staged command"));
  Serial.println(F("  SUMMARY or S    - display active or final summary"));
  Serial.println();
  Serial.println(F("Movement commands are two-step: command first, CONFIRM second."));
  Serial.println(F("Set the Serial Monitor line ending to newline or both NL and CR."));
  Serial.println();
}

void handleCommand(char *command) {
  trimAndUppercase(command);
  if (command[0] == '\0') {
    return;
  }

  if (commandIs(command, "HELP") || commandIs(command, "H") || commandIs(command, "?")) {
    printHelp();
  } else if (commandIs(command, "CONFIG") || commandIs(command, "C")) {
    printConfiguration();
    configurationValid = validateConfiguration(true);
  } else if (commandIs(command, "DRY1") || commandIs(command, "D1") || commandIs(command, "ONE-DRY")) {
    stageAction(PENDING_ONE_DRY);
  } else if (commandIs(command, "DRY") || commandIs(command, "D")) {
    stageAction(PENDING_DRY_TEST);
  } else if (commandIs(command, "KIBBLE1") || commandIs(command, "K1") || commandIs(command, "ONE-KIBBLE")) {
    stageAction(PENDING_ONE_KIBBLE);
  } else if (commandIs(command, "KIBBLE") || commandIs(command, "K")) {
    stageAction(PENDING_KIBBLE_TEST);
  } else if (commandIs(command, "REST") || commandIs(command, "R")) {
    stageAction(PENDING_RETURN_REST);
  } else if (commandIs(command, "CONFIRM")) {
    executePendingAction();
  } else if (commandIs(command, "ABORT") || commandIs(command, "A")) {
    requestAbort();
  } else if (commandIs(command, "SUMMARY") || commandIs(command, "S")) {
    printSummary();
  } else {
    Serial.print(F("Unknown command: "));
    Serial.println(command);
    Serial.println(F("Type HELP for the supported command list."));
  }
}

void processSerialInput() {
  while (Serial.available() > 0) {
    const char input = static_cast<char>(Serial.read());

    if (input == '\r') {
      continue;
    }

    if (input == '\n') {
      inputBuffer[inputLength] = '\0';
      handleCommand(inputBuffer);
      inputLength = 0;
      continue;
    }

    if (inputLength >= INPUT_BUFFER_LENGTH - 1) {
      inputLength = 0;
      Serial.println(F("ERROR: Command too long. Buffer cleared."));
      continue;
    }

    inputBuffer[inputLength++] = input;
  }
}

void printStartupBanner() {
  Serial.println();
  Serial.println(F("C.A.T.E.R. rolling gate servo hardware test"));
  Serial.println(F("Dedicated test sketch only. Main DAISY firmware is not running."));
  Serial.println(F("No dispensing test starts automatically after reset."));
  Serial.println(F("Type HELP for commands."));
}

}  // namespace

void setup() {
  Serial.begin(SERIAL_BAUD_RATE);
  delay(STARTUP_LOG_DELAY_MS);

  printStartupBanner();
  printConfiguration();
  configurationValid = validateConfiguration(true);

  if (configurationValid) {
    attachServoIfNeeded();
  } else {
    Serial.println(F("Startup safety: servo is not attached and movement commands are locked out."));
  }
}

void loop() {
  processSerialInput();
  updatePendingActionTimeout();
  updateActiveRun();
}
