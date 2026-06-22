# Rolling Gate Servo Hardware Test Plan

## Purpose

Prove that the C.A.T.E.R. rolling gate can be operated reliably by the servo before it is integrated into the full DAISY firmware.

This procedure tests only the rolling-gate servo movement. Do not connect or activate unrelated subsystems for this test phase.

## Preconditions

* Arduino Uno R3 compatible board is available.
* Positional metal gear servo type is physically confirmed.
* Servo signal pin is confirmed and copied into `rolling_gate_test_config.h`.
* Resting position, dispensing position, and rotation direction are physically confirmed at low risk.
* Servo has an appropriate power source for load testing.
* Arduino ground and external servo power ground are shared when external servo power is used.
* Rolling gate, hopper, servo mount, and wiring are visible during testing.
* Hands, tools, wires, and loose material are clear of the rolling mechanism.
* Test starts dry, without kibble.

## Test Firmware Safety Behavior

The test sketch must:

* Print configuration at startup.
* Refuse movement when critical configuration is invalid or unconfirmed.
* Never begin a cycle automatically after reset.
* Require a movement command followed by `CONFIRM`.
* Run a finite number of cycles.
* Accept `ABORT` during an active test.
* Stop starting new cycles after abort.
* Command the gate back to the configured resting position during abort recovery where mechanically possible.
* Print cycle numbers, commanded movement states, completion status, and abort status.

## Phase 1: Startup Safety

1. Confirm the sketch is configured but do not place kibble in the hopper.
2. Power the Arduino and servo according to the wiring plan.
3. Open Serial Monitor at the configured baud rate.
4. Observe startup logs and configuration validation.
5. Confirm no dispensing cycle begins automatically.
6. If configuration is intentionally invalid, confirm the sketch refuses movement and does not attach the servo.
7. With valid configuration, confirm the servo commands the rolling gate to the resting position without an uncontrolled full-range jump where the hardware allows.

Record:

* Startup position behavior.
* Any unexpected servo jump.
* Configuration validation result.
* Whether reset remains safe.

## Phase 2: Single Dry Cycle

1. Send `DRY1`.
2. Confirm the area is clear.
3. Send `CONFIRM`.
4. Watch the entire servo-driven cycle.
5. Do not help the rolling gate by hand.

Verify:

* Servo begins from the resting position.
* Both sides of the rolling gate move together.
* Gate does not twist, separate, collapse, or fold.
* Gate does not scrape the chamber walls.
* Wiring does not catch or pull.
* Servo mount remains secure.
* Gate reaches the configured dispensing movement.
* Gate returns to or indexes at the configured resting position.
* No hand assistance is used.

## Phase 3: Repeated Dry-Cycle Test

1. Send `DRY`.
2. Confirm the area is clear.
3. Send `CONFIRM`.
4. Run at least 20 automatic servo-driven cycles without kibble.
5. Use `ABORT` immediately if binding, stalling, overheating, twisting, gate separation, wiring interference, or unsafe motion occurs.

Record:

* Successful cycles.
* Incomplete rotations.
* Scraping.
* Gate separation.
* Servo mount movement.
* Wire interference.
* Abnormal noise.
* Servo stalls.
* Failure cycle number.
* Abort behavior.

Manual gate rotation must not count toward the 20 cycles.

## Phase 4: Single Loaded Cycle

1. Add a small controlled amount of dry kibble.
2. Send `KIBBLE1`.
3. Confirm the area is clear.
4. Send `CONFIRM`.
5. Watch the entire servo-driven cycle.

Verify:

* Kibble remains in the hopper while the gate is stationary.
* The rolling gate receives kibble during servo-driven movement.
* The gate carries kibble toward the discharge side.
* Kibble drops into the feeding plate.
* The gate returns to or indexes at the resting position.
* Uncontrolled leakage is not observed.
* No hand assistance is used.

## Phase 5: Repeated Loaded Test

1. Add a controlled amount of dry kibble.
2. Send `KIBBLE`.
3. Confirm the area is clear.
4. Send `CONFIRM`.
5. Run at least 10 automatic servo-driven dispensing cycles with kibble.
6. Use `ABORT` immediately if unsafe behavior occurs.

Record:

* Successful dispensing cycles.
* Missed dispensing cycles.
* Partial dispensing.
* Jams.
* Leakage while stationary.
* Incomplete rotation.
* Kibble trapped inside the gate.
* Servo stalls.
* Gate deformation.
* Failure cycle number.
* Approximate portion consistency.
* Any configuration adjustment made.

## Phase 6: Reset and Abort Recovery

Reset test:

1. Reset the Arduino while no test should be active.
2. Confirm no cycle starts automatically.
3. Confirm restart requires a new command and `CONFIRM`.

Abort test:

1. Start a dry or loaded repeated test.
2. Send `ABORT` during a movement or dwell phase.
3. Confirm no further cycles start.
4. Confirm the test reports `TEST ABORTED`.
5. Confirm the gate is commanded back to the resting position where mechanically possible.
6. Send `SUMMARY` and record completed servo-driven cycles.
7. Confirm a new test requires a new command and `CONFIRM`.

## Result Classification

### Pass

A test passes only when:

* All required servo-driven cycles complete.
* No hand assistance is used.
* Both sides of the gate remain synchronized.
* No gate collapse or separation occurs.
* No repeated scraping occurs.
* Servo mount remains secure.
* Wiring remains clear.
* Gate consistently reaches its intended positions.
* Kibble is transported and discharged during loaded testing.
* No unacceptable stationary leakage occurs.
* Abort and reset behavior are safe.

### Conditional Pass

Use only when:

* The mechanism completes the test.
* Configuration tuning, minor reinforcement, or portion calibration is still required.
* No immediate safety or structural failure exists.

### Fail

The test fails when any of the following occurs:

* Gate collapses, twists, separates, or folds.
* One side moves without the other.
* Servo repeatedly stalls.
* Gate cannot reach the required position.
* Gate requires hand assistance.
* Wiring interferes with movement.
* Hopper obstructs the gate.
* Kibble does not load or discharge.
* Uncontrolled kibble leakage occurs.
* Servo mount becomes loose.
* Test cannot be aborted safely.
* Reset causes unexpected dispensing.

## Safety Stop Conditions

Stop immediately if:

* Servo stalls.
* Servo overheats.
* Servo chatters continuously.
* Gate binds, scrapes heavily, or deforms.
* Wiring catches or pulls.
* Hopper shifts into the rolling gate.
* Kibble jams in a way that strains the mechanism.
* Any movement becomes unsafe to observe.

This firmware does not include automatic jam detection, current sensing, encoder feedback, or position feedback. The operator must observe and record physical behavior.
