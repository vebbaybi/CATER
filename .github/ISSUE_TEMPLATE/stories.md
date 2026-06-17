# C.A.T.E.R. Agile Backlog

## Project Context

C.A.T.E.R. is the pet feeder hardware project. DAISY is the Arduino firmware that controls the feeder behavior.

Current project stage: **Hardware Prototype Integration and Mechanical Fit-Test**.

The MVP uses:

* Arduino Uno
* Servo-controlled rolling gate
* Cardboard body
* 2L bottle gravity-fed hopper
* Food bowl area
* Ultrasonic sensor for bowl fill detection
* PIR sensor for cat approach detection
* LCD display
* Keypad
* Enclosed internal Arduino bay

RFID collar detection, feeding history logging, mobile app work, low hopper detection, and water dispensing are not part of the MVP. They remain in the icebox until the food dispenser MVP is mechanically stable and tested.

## Current Blocker

The rolling gate works from the servo side, but the opposite side is not fixed properly yet. Sometimes the cardboard gate halves close unevenly or collapse because only one side moves well.

The next blocker is to stabilize, glue, or lock the gate halves at their meeting point and support the non-servo side so both sides rotate together.

---

# Project Operations

**Track:** Project Operations

**Stage name:** Backlog and Kanban Foundation

**Why this is separate from product priority:** GitHub labels, milestones, and the project board are needed from the beginning to manage the work. They support the current hardware fit-test stage, but they do not represent a feeder feature or a release milestone by themselves.

## Story Titles

1. Set up GitHub labels, milestones, and project board

## Story: Set up GitHub labels, milestones, and project board

As a **project maintainer**,
I want GitHub labels, milestones, and a project board for C.A.T.E.R.,
so that hardware, firmware, testing, documentation, and future features can be managed professionally from the start.

### Acceptance Criteria

* Labels exist for firmware, hardware, docs, safety, testing, sensors, servo, UI, MVP, and icebox.
* Milestones exist for repository foundation, hardware prototype, firmware MVP, testing, and public MVP release.
* Project board status options match the CATER project: User Stories, Product Backlog, Ice Box, Ready, In progress, In review, and Done.
* The board supports the current Hardware Prototype Integration and Mechanical Fit-Test stage.
* User stories are added as GitHub issues only when the maintainer is ready to create issues.
* Icebox items are clearly separated from MVP work.
* The workflow is documented when the maintainer is ready to publish process notes.

---

# P0: Critical MVP Foundation

**Agile rank:** P0

**Sprint/stage name:** Hardware Prototype Integration and Mechanical Fit-Test

**Why this group comes at this stage:** The feeder cannot safely move into firmware behavior, sensor logic, or food testing until the physical body, electronics protection, and rolling gate mechanics are stable. The rolling gate is the current blocker because unsafe movement can collapse the mechanism, scrape the chamber, or make servo testing unreliable.

## Story Titles

1. Build the main C.A.T.E.R. cardboard body
2. Protect the internal Arduino electronics bay
3. Fix rolling gate opposite-side alignment

## Story: Build the main C.A.T.E.R. cardboard body

As a **maker**,
I want to build the main cardboard enclosure for C.A.T.E.R.,
so that the feeder has a stable physical structure for the hopper, bowl, sensors, controls, and electronics.

### Acceptance Criteria

* The body stands upright without support.
* The body includes a top hopper zone.
* The body includes a middle dispensing zone.
* The body includes a lower bowl zone.
* The body includes space for the LCD and keypad.
* The body includes an internal protected electronics bay.
* The body allows access for maintenance and rewiring.
* The Arduino is not mounted openly on the outside.
* The design is documented with dimensions, notes, photos, or sketches.

## Story: Protect the internal Arduino electronics bay

As a **maker**,
I want the Arduino and wiring protected inside an internal electronics bay,
so that the system can run without exposing the board to the cat, food, or accidental contact.

### Acceptance Criteria

* The Arduino Uno fits inside the electronics bay.
* The bay separates electronics from the hopper, chute, gate, and bowl area.
* The bay has practical access for upload, debugging, and rewiring.
* Wires are routed through controlled openings.
* The bay does not block the hopper, chute, gate, servo, keypad, or LCD.
* The Arduino is not exposed on the outside of the feeder.

## Story: Fix rolling gate opposite-side alignment

As a **maker**,
I want the rolling gate halves to stay aligned and rotate together,
so that the feeder can open and close safely before servo and food testing continue.

### Notes

The servo side currently moves, but the opposite side needs support. The gate halves may need to be glued, locked, reinforced, or joined at their meeting point. The non-servo side may need a bearing surface, axle support, guide, or chamber reinforcement so the gate rotates instead of folding inward.

### Acceptance Criteria

* Servo side and opposite side rotate together.
* Gate halves do not fold inward.
* Gate does not scrape the chamber wall.
* Gate completes at least 20 manual open/close rotations.
* Gate completes at least 10 servo-assisted open/close rotations.
* Hopper stays above the intake without touching the rotating gate.

---

# P1: Core DAISY Firmware

**Agile rank:** P1

**Sprint/stage name:** DAISY Component Control

**Why this group comes at this stage:** Firmware should begin after the gate can move safely. These stories define the minimum DAISY behaviors needed to operate the feeder deliberately: safe startup, manual feeding, estimated portion timing, and cooldown protection.

## Story Titles

1. Initialize DAISY in a safe startup state
2. Run a manual feed cycle
3. Control food portion using servo open duration
4. Add feed cooldown protection

## Story: Initialize DAISY in a safe startup state

As a **pet owner**,
I want DAISY to start with the dispensing gate closed,
so that food does not accidentally dump when the Arduino powers on or resets.

### Acceptance Criteria

* On startup, DAISY moves the servo to the closed position.
* DAISY does not trigger a feed cycle during startup.
* Startup status is printed to Serial.
* LCD shows a safe ready state after initialization when the LCD is connected.
* Startup behavior is tested through multiple resets.

## Story: Run a manual feed cycle

As a **pet owner**,
I want to trigger a manual feed cycle,
so that I can release food immediately when needed.

### Acceptance Criteria

* A manual feed command can be triggered from the keypad or test input.
* DAISY opens the servo gate for a configured duration.
* DAISY closes the servo gate after the feed duration.
* DAISY shows feeding status on the LCD when connected.
* DAISY prints manual feed status to Serial.
* Manual feed does not run while the system is in a blocked safety state.

## Story: Control food portion using servo open duration

As a **pet owner**,
I want DAISY to control feeding amount by adjusting how long the gate stays open,
so that C.A.T.E.R. can dispense estimated portions.

### Acceptance Criteria

* DAISY supports configurable dispense duration.
* DAISY supports at least one default portion setting.
* DAISY closes the gate after the configured duration.
* DAISY prevents continuous open-gate behavior.
* Serial output shows the selected portion duration.
* Documentation states that portions are estimated and must be calibrated with the actual kibble.

## Story: Add feed cooldown protection

As a **pet owner**,
I want DAISY to apply a cooldown after feeding,
so that the feeder does not dispense food repeatedly by accident.

### Acceptance Criteria

* DAISY starts a cooldown after every successful feed.
* DAISY blocks new feed cycles during cooldown.
* LCD shows cooldown or wait status when connected.
* Serial output reports when feeding is blocked by cooldown.
* Cooldown duration is configurable.
* Cooldown applies to manual and sensor-triggered feed attempts.

---

# P2: Sensor Integration

**Agile rank:** P2

**Sprint/stage name:** Bowl and Presence Sensing

**Why this group comes at this stage:** Sensors should be integrated after the core gate and feed cycle work. The ultrasonic sensor and PIR sensor add safety and context, but they must not bypass cooldown, bowl protection, or mechanical limits.

## Story Titles

1. Detect bowl fill level with ultrasonic sensor
2. Detect cat approach with PIR sensor

## Story: Detect bowl fill level with ultrasonic sensor

As a **pet owner**,
I want C.A.T.E.R. to detect whether the bowl already has food,
so that DAISY can avoid overfilling the bowl.

### Acceptance Criteria

* The ultrasonic sensor is wired to the Arduino.
* DAISY reads distance values from the ultrasonic sensor.
* DAISY classifies bowl state as empty, partial, or full.
* DAISY blocks feeding when the bowl is considered full.
* LCD shows bowl full status when feeding is blocked.
* Serial output reports measured distance and bowl state.
* Thresholds are configurable and tested with an empty bowl and a filled bowl.

## Story: Detect cat approach with PIR sensor

As a **pet owner**,
I want C.A.T.E.R. to detect when my cat approaches,
so that DAISY can respond to presence near the feeder.

### Acceptance Criteria

* The PIR sensor is wired to the Arduino.
* DAISY reads PIR motion state.
* LCD can show motion detected when PIR is active.
* Serial output reports PIR events.
* PIR detection does not bypass cooldown.
* PIR detection does not bypass bowl-full protection.
* PIR-triggered behavior is configurable or clearly documented.

---

# P3: User Interface

**Agile rank:** P3

**Sprint/stage name:** Local Feeder Controls

**Why this group comes at this stage:** The LCD and keypad become useful after the basic hardware and DAISY feed behavior exist. This stage makes the prototype easier to test without opening the electronics bay or changing code for every action.

## Story Titles

1. Display feeder status on LCD
2. Use keypad for basic feeder control

## Story: Display feeder status on LCD

As a **pet owner**,
I want the LCD to show C.A.T.E.R. status,
so that I can understand what DAISY is doing without opening the electronics bay.

### Acceptance Criteria

* LCD initializes successfully during startup.
* LCD shows a ready state.
* LCD shows feeding state.
* LCD shows bowl full state.
* LCD shows cooldown state.
* LCD shows motion detected state when PIR is active.
* LCD shows error or blocked state where applicable.
* LCD messages are short enough for the display.

## Story: Use keypad for basic feeder control

As a **pet owner**,
I want to control basic feeder actions from the keypad,
so that I can interact with C.A.T.E.R. without editing firmware code.

### Acceptance Criteria

* Keypad input is read by DAISY.
* A key can trigger manual feed.
* A key can show current status.
* A key can cycle portion setting or mode if implemented.
* Invalid keys do not crash the firmware.
* Keypad input does not bypass cooldown.
* Keypad input does not bypass bowl-full protection.
* Key mappings are documented.

---

# P4: Calibration and Testing

**Agile rank:** P4

**Sprint/stage name:** Layered Hardware and Reliability Testing

**Why this group comes at this stage:** Testing should happen in layers as the prototype becomes stable. Mechanical fit testing starts now in P0. Component test code starts after the rolling gate can move safely. Kibble testing starts after the servo gate works. Full integration testing starts after sensors, LCD, keypad, DAISY, wiring, and the food path are connected.

## Story Titles

1. Calibrate estimated feeding portions
2. Test the feeder with real kibble
3. Create a safety checklist

## Story: Calibrate estimated feeding portions

As a **maker**,
I want to calibrate C.A.T.E.R. using repeated food-dispensing tests,
so that the project can estimate ration output responsibly.

### Acceptance Criteria

* A calibration procedure is documented.
* The procedure includes multiple feed trials.
* The procedure records servo open duration.
* The procedure records approximate dispensed amount.
* The procedure records food type or kibble size.
* The procedure records jam or leakage observations.
* Calibration results are stored in documentation or a test log.

## Story: Test the feeder with real kibble

As a **maker**,
I want to test C.A.T.E.R. with real dry cat food,
so that I can confirm the cardboard mechanism works under realistic conditions.

### Acceptance Criteria

* The hopper is filled with test kibble.
* The gate opens and closes repeatedly.
* Food falls into the bowl during successful feed cycles.
* Jam points are identified and documented.
* Leakage when closed is tested.
* Failed cycles are recorded honestly.
* Mechanical adjustments are documented.
* The feeder is not marked MVP-ready until repeated testing passes.

## Story: Create a safety checklist

As a **pet owner**,
I want a safety checklist for C.A.T.E.R.,
so that I know what must be checked before using the feeder around a cat.

### Acceptance Criteria

* Safety checklist includes power safety.
* Safety checklist includes servo movement safety.
* Safety checklist includes exposed wire checks.
* Safety checklist includes food contamination checks.
* Safety checklist includes cardboard stability checks.
* Safety checklist includes manual access to food.
* Safety checklist includes repeated test cycle requirements.
* Safety checklist warns against relying on the prototype as the only food source too early.

---

# P5: Documentation and MVP Release

**Agile rank:** P5

**Sprint/stage name:** MVP Documentation and Demo Preparation

**Why this group comes at this stage:** Documentation and release preparation should describe the working prototype accurately after the mechanical, firmware, sensor, and UI behavior has been proven. Release preparation should not replace hardware validation.

## Story Titles

1. Create a wiring guide
2. Create a build guide for the cardboard body
3. Create a DAISY firmware README
4. Prepare first MVP demo

## Story: Create a wiring guide

As a **maker**,
I want a wiring guide for C.A.T.E.R.,
so that I can connect the Arduino, servo, ultrasonic sensor, PIR sensor, LCD, and keypad correctly.

### Acceptance Criteria

* Wiring guide lists all connected components.
* Wiring guide includes Arduino pin assignments.
* Wiring guide explains servo signal, power, and ground.
* Wiring guide explains ultrasonic sensor wiring.
* Wiring guide explains PIR sensor wiring.
* Wiring guide explains LCD wiring.
* Wiring guide explains keypad wiring.
* Wiring guide includes the shared-ground rule.
* Wiring guide warns about servo power limits.

## Story: Create a build guide for the cardboard body

As a **maker**,
I want a step-by-step cardboard build guide,
so that I can recreate the C.A.T.E.R. prototype without guessing the structure.

### Acceptance Criteria

* Build guide explains required materials.
* Build guide explains body assembly.
* Build guide explains hopper assembly.
* Build guide explains rolling gate assembly.
* Build guide explains bowl placement.
* Build guide explains electronics bay placement.
* Build guide explains sensor placement.
* Build guide includes photos, diagrams, or sketches.
* Build guide records known limitations.

## Story: Create a DAISY firmware README

As a **developer**,
I want a DAISY firmware README,
so that I understand how the firmware is structured, configured, uploaded, and tested.

### Acceptance Criteria

* Firmware README identifies DAISY as the firmware.
* Firmware README explains supported board.
* Firmware README explains required libraries.
* Firmware README explains pin configuration.
* Firmware README explains configurable values.
* Firmware README explains upload process.
* Firmware README explains Serial diagnostics.
* Firmware README explains safe startup behavior.
* Firmware README explains known limitations.

## Story: Prepare first MVP demo

As a **project maintainer**,
I want to prepare a first C.A.T.E.R. MVP demo,
so that the project can prove the feeder body, DAISY firmware, sensors, display, keypad, and dispenser work together.

### Acceptance Criteria

* Demo shows feeder powered on.
* Demo shows DAISY ready state.
* Demo shows manual feed command.
* Demo shows servo gate opening and closing.
* Demo shows food dropping into the bowl.
* Demo shows LCD status updates.
* Demo shows PIR detection.
* Demo shows ultrasonic bowl-full blocking if implemented.
* Demo shows Arduino protected inside the internal bay.
* Demo notes known limitations.
* Demo video or photos are added to the repository when the maintainer is ready to publish them.

---

# Icebox

These stories are not part of the MVP. They should stay out of the active build until the cardboard feeder, rolling gate, hopper, DAISY firmware, sensors, keypad, LCD, and food path are stable.

## Story Titles

1. Add RFID collar detection
2. Add feeding history logging
3. Add mobile app feeding dashboard
4. Add low hopper detection
5. Add separate water dispenser module

## Story: Add RFID collar detection

As a **pet owner**,
I want C.A.T.E.R. to identify my cat using an RFID collar tag,
so that only an approved cat can trigger feeding.

### Icebox Notes

* RFID is not part of the MVP.
* RFID must not bypass cooldown or bowl-full protection.
* RFID should only be considered after the feeder is mechanically reliable.

## Story: Add feeding history logging

As a **pet owner**,
I want C.A.T.E.R. to record feeding events,
so that I can track when my cat was fed.

### Icebox Notes

* MVP diagnostics may use Serial output only.
* Structured logs can come later through EEPROM, SD card, connected storage, or another documented path.
* Logging must not break feeding behavior.

## Story: Add mobile app feeding dashboard

As a **pet owner**,
I want a mobile app dashboard for feeding data,
so that I can track feeding behavior over time.

### Icebox Notes

* Mobile app work comes after the hardware MVP.
* The app must not make veterinary or calorie-accuracy claims.
* Local-first storage may be considered when app work begins.

## Story: Add low hopper detection

As a **pet owner**,
I want C.A.T.E.R. to detect when the hopper may be low,
so that I know when to refill the feeder.

### Icebox Notes

* Low hopper detection is not required for MVP.
* Detection method may use ultrasonic, weight, optical, or manual estimation later.
* Warnings must not claim exact food quantity unless the project has a reliable measurement method.

## Story: Add separate water dispenser module

As a **pet owner**,
I want C.A.T.E.R. to include a separate water dispenser module,
so that my cat can access water near the feeding station without mixing water with the dry food system.

### Icebox Notes

* Water dispensing is not part of the food-only MVP.
* Water must stay physically separated from the Arduino, wiring, LCD, keypad, servo, rolling gate, and dry food path.
* Water should use a separate bowl from the dry food bowl.
* Cardboard should not be relied on as the primary water-contact structure.
* Leak risk, cleaning, and refill access must be handled before implementation.

---

# When Code Starts

Component test code starts after the rolling gate can move safely without collapsing.

Component tests include servo sweep, keypad read, LCD message test, ultrasonic read, PIR read, and cooldown timing.

Main DAISY firmware starts only after rolling gate, hopper, chute, servo mount, keypad, LCD, Arduino bay, and wiring path are physically stable.

Full integration testing starts after hardware, firmware, sensors, keypad, LCD, and food path are connected.
