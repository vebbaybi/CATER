# C.A.T.E.R. User Stories

## Project Context

C.A.T.E.R. is a cardboard-based Arduino automatic cat feeder. DAISY is the Arduino firmware that controls the feeder behavior.

The MVP uses:

* Arduino Uno
* Servo-controlled dispensing gate
* Cardboard body
* 2L bottle gravity-fed hopper
* Food bowl area
* Ultrasonic sensor for bowl fill detection
* PIR sensor for cat approach detection
* LCD display
* Keypad
* Enclosed internal Arduino bay

RFID collar detection and water dispensing are not part of the MVP. They belong in the icebox.

---

# INVEST Standard Used

Each user story should be:

* **Independent**: Can be worked on without depending heavily on another story.
* **Negotiable**: Details can be refined during build and testing.
* **Valuable**: Delivers clear project value.
* **Estimable**: Small enough to estimate.
* **Small**: Can fit into a practical development task.
* **Testable**: Has clear acceptance criteria.

---

# EPIC 1: Cardboard Hardware Build

## User Story 1: Build the main C.A.T.E.R. cardboard body

### User Story Template

As a **maker**,
I want to build the main cardboard enclosure for C.A.T.E.R.,
so that the feeder has a stable physical structure for the hopper, bowl, sensors, controls, and electronics.

### Assumptions

* Cardboard is the primary MVP material.
* The feeder must be tall enough to allow gravity-fed food movement.
* The Arduino should not be exposed externally.
* The bowl should be accessible from the front.
* The body should be stable enough not to tip easily during testing.

### Acceptance Criteria

* The cardboard body can stand upright without support.
* The body includes a top hopper zone.
* The body includes a middle dispensing zone.
* The body includes a lower bowl zone.
* The body includes space for the LCD and keypad.
* The body includes an internal protected electronics bay.
* The body allows access for maintenance and rewiring.
* The Arduino is not mounted openly on the outside.
* The design is documented with dimensions or build notes.
* A photo or diagram of the completed body is added to the project.

### INVEST Check

* Independent: Can be built before firmware is complete.
* Negotiable: Dimensions can change after testing.
* Valuable: Provides the physical foundation.
* Estimable: Can be estimated as a hardware build task.
* Small: One body prototype.
* Testable: Stability and layout can be checked.

---

## User Story 2: Build the 2L bottle gravity-fed hopper

### User Story Template

As a **pet owner**,
I want the feeder to store dry cat food in a gravity-fed 2L bottle hopper,
so that food can naturally move toward the rolling gate without manual pushing.

### Assumptions

* The MVP uses dry kibble only.
* Wet food is not supported.
* The gravity hopper will use a clean 2L plastic bottle instead of a fully cardboard funnel.
* The cardboard body will provide the bottle holder, bottle neck guide, and support frame.
* The bottle will be mounted upside down, with the bottle neck pointing toward the rolling gate input area.
* The bottle bottom may be cut open to create a refill opening.
* The bottle neck and chute must not interfere with the rolling gate, servo, axle, or linkage.
* Food flow will be validated with real kibble before trusting the feeder.

### Acceptance Criteria

* A clean 2L plastic bottle is selected and prepared as the gravity hopper.
* The bottle bottom is safely cut or opened for refilling.
* The bottle is mounted upside down inside the feeding chamber.
* A cardboard support frame holds the bottle body firmly in place.
* A bottle neck guide plate keeps the outlet centered above the rolling gate input area.
* The bottle neck points directly toward the rolling gate without blocking the servo or linkage.
* Dry kibble can move from the bottle into the rolling gate using gravity.
* The hopper does not collapse, slip, tilt, or fall during test loading.
* The outlet path is wide enough to reduce jamming risk.
* The hopper can be refilled without dismantling the full feeder.
* The hopper is isolated from the Arduino, wiring, LCD, keypad, and electronics bay.
* Food flow test results are documented with notes on jams, blockage, and refill behavior.

### INVEST Check

* Independent: Can be tested without full DAISY firmware.
* Negotiable: Bottle size, holder style, and neck guide shape can change after testing.
* Valuable: Enables gravity-fed dispensing with better flow than a full cardboard hopper.
* Estimable: A clear hardware build task using one bottle and cardboard supports.
* Small: One bottle hopper prototype.
* Testable: Food flow, refill access, stability, and rolling gate alignment can be tested.

---

## User Story 3: Build a simple servo-controlled dispensing gate

### User Story Template

As a **pet owner**,
I want C.A.T.E.R. to use a servo-controlled gate,
so that DAISY can release food only when feeding is allowed.

### Assumptions

* The MVP should avoid a complex rotating ration wheel.
* A simple sliding gate or flap gate is preferred.
* The servo should move the gate, not carry the full hopper weight.
* The gate should fail closed where possible.
* Some portion variation is acceptable in MVP.

### Acceptance Criteria

* A servo is mounted securely near the chute outlet.
* The gate opens when the servo moves to the open position.
* The gate closes when the servo moves to the closed position.
* The gate blocks food when closed.
* The gate releases food when open.
* The gate can complete repeated open and close cycles.
* The mechanism does not require hand assistance during normal testing.
* The mechanism is documented with photos or diagrams.
* Any jam points or leakage issues are recorded.

### INVEST Check

* Independent: Can be tested with servo sweep code.
* Negotiable: Gate style can be slider or flap.
* Valuable: Core feeding function.
* Estimable: Clear mechanism build.
* Small: One dispenser mechanism.
* Testable: Open, close, and food release can be tested.

---

## User Story 4: Protect the internal Arduino electronics bay

### User Story Template

As a **maker**,
I want the Arduino and wiring protected inside an internal electronics bay,
so that the system can run safely without exposing the board to the cat, food, or accidental contact.

### Assumptions

* The Arduino Uno is required for the MVP.
* The Arduino must not be mounted openly on the outside.
* The bay should allow access for debugging and maintenance.
* The bay should separate electronics from food.
* Wires should be routed cleanly.

### Acceptance Criteria

* The Arduino Uno fits inside the internal electronics bay.
* The bay has a removable or openable access panel.
* The Arduino is protected from direct contact with food.
* The Arduino is protected from direct contact with the cat.
* Wires are routed through controlled openings.
* The bay does not block the hopper or dispenser.
* The bay allows USB access or practical upload access.
* The internal bay is labeled in documentation.
* The design shows how the Arduino remains part of the system without being exposed.

### INVEST Check

* Independent: Can be built before final firmware.
* Negotiable: Bay position can change.
* Valuable: Improves safety and professionalism.
* Estimable: Clear enclosure task.
* Small: One bay feature.
* Testable: Arduino fit and access can be checked.

---

# EPIC 2: DAISY Firmware MVP

## User Story 5: Initialize DAISY in a safe startup state

### User Story Template

As a **pet owner**,
I want DAISY to start with the dispensing gate closed,
so that food does not accidentally dump when the Arduino powers on or resets.

### Assumptions

* Servo close position will be configurable.
* Startup behavior must be predictable.
* Power resets may happen during testing.
* The feeder must not dispense food automatically during boot unless intentionally scheduled.

### Acceptance Criteria

* On startup, DAISY moves the servo to the closed position.
* DAISY does not trigger a feed cycle during startup.
* Startup status is printed to Serial.
* LCD shows a safe ready state after initialization.
* If the servo is unavailable or not responding, the system reports an error state where possible.
* The behavior is tested through multiple resets.
* Startup behavior is documented in the README or firmware notes.

### INVEST Check

* Independent: Can be implemented before sensors.
* Negotiable: Exact messages can change.
* Valuable: Prevents unsafe food dumping.
* Estimable: Clear firmware behavior.
* Small: One startup behavior.
* Testable: Reset tests verify it.

---

## User Story 6: Run a manual feed cycle

### User Story Template

As a **pet owner**,
I want to trigger a manual feed cycle,
so that I can release food immediately when needed.

### Assumptions

* Manual feed may be triggered through the keypad.
* The feed cycle uses the servo gate.
* Manual feeding must respect safety rules.
* Bowl-full detection may block manual feeding when enabled.

### Acceptance Criteria

* A manual feed command can be triggered from the keypad.
* DAISY opens the servo gate for a configured duration.
* DAISY closes the servo gate after the feed duration.
* DAISY shows feeding status on the LCD.
* DAISY prints manual feed status to Serial.
* DAISY prevents repeated accidental manual feeds.
* Manual feed does not run if the system is in a blocked safety state.
* Manual feed behavior is documented.

### INVEST Check

* Independent: Can be tested without full scheduling.
* Negotiable: Keypad command can change.
* Valuable: Gives immediate user control.
* Estimable: Clear firmware task.
* Small: One feed action.
* Testable: Press command, observe cycle.

---

## User Story 7: Control food portion using servo open duration

### User Story Template

As a **pet owner**,
I want DAISY to control feeding amount by adjusting how long the gate stays open,
so that C.A.T.E.R. can dispense estimated portions.

### Assumptions

* MVP portions are estimated, not exact grams.
* Kibble size affects portion output.
* Servo open duration is the primary MVP control.
* Later versions may use better calibration or weight sensors.

### Acceptance Criteria

* DAISY supports configurable dispense duration.
* DAISY supports at least one default portion setting.
* DAISY closes the gate after the configured duration.
* DAISY prevents continuous open-gate behavior.
* Portion timing values are easy to adjust in firmware configuration.
* Serial output shows selected portion duration.
* Test notes record approximate food output for several trials.
* Documentation clearly states that portions are estimated.

### INVEST Check

* Independent: Can be tested with servo and kibble.
* Negotiable: Portion sizes can change after calibration.
* Valuable: Enables controlled rationing.
* Estimable: Firmware configuration task.
* Small: One portion-control behavior.
* Testable: Timed gate opening can be measured.

---

## User Story 8: Add feed cooldown protection

### User Story Template

As a **pet owner**,
I want DAISY to apply a cooldown after feeding,
so that the feeder does not dispense food repeatedly by accident.

### Assumptions

* PIR motion may trigger repeated detection.
* Keypad input may bounce or be pressed multiple times.
* Cooldown protects against overfeeding.
* Cooldown duration should be configurable.

### Acceptance Criteria

* DAISY starts a cooldown after every successful feed.
* DAISY blocks new feed cycles during cooldown.
* LCD shows cooldown or wait status.
* Serial output reports when feeding is blocked by cooldown.
* Cooldown duration is configurable.
* Cooldown applies to manual and sensor-triggered feed attempts.
* Cooldown behavior is tested with repeated feed attempts.

### INVEST Check

* Independent: Can be added after manual feed.
* Negotiable: Cooldown duration can change.
* Valuable: Prevents overfeeding.
* Estimable: Clear state-management task.
* Small: One safety behavior.
* Testable: Repeated commands can verify it.

---

# EPIC 3: Sensor Integration

## User Story 9: Detect bowl fill level with ultrasonic sensor

### User Story Template

As a **pet owner**,
I want C.A.T.E.R. to detect whether the bowl already has food,
so that DAISY can avoid overfilling the bowl.

### Assumptions

* The ultrasonic sensor is mounted above or near the bowl.
* Distance readings may need calibration.
* The MVP can use simple threshold states.
* The sensor does not measure exact food weight.

### Acceptance Criteria

* The ultrasonic sensor is wired to the Arduino.
* DAISY reads distance values from the ultrasonic sensor.
* DAISY classifies bowl state as empty, partial, or full.
* DAISY blocks feeding when the bowl is considered full.
* LCD shows bowl full status when feeding is blocked.
* Serial output reports measured distance and bowl state.
* Thresholds are configurable.
* Sensor readings are tested with an empty bowl and a filled bowl.
* Limitations are documented.

### INVEST Check

* Independent: Can be tested separately from PIR.
* Negotiable: Threshold values can change.
* Valuable: Prevents overfilling.
* Estimable: Sensor integration task.
* Small: One sensor behavior.
* Testable: Distances can be measured.

---

## User Story 10: Detect cat approach with PIR sensor

### User Story Template

As a **pet owner**,
I want C.A.T.E.R. to detect when my cat approaches,
so that DAISY can respond to presence near the feeder.

### Assumptions

* PIR detects motion, not identity.
* PIR should not automatically feed every time by default unless configured.
* PIR may be used to wake the system, display status, or enable a feed condition.
* Random motion may cause false triggers.

### Acceptance Criteria

* The PIR sensor is wired to the Arduino.
* DAISY reads PIR motion state.
* LCD can show cat detected or motion detected.
* Serial output reports PIR events.
* PIR detection does not bypass cooldown.
* PIR detection does not bypass bowl-full protection.
* PIR-triggered behavior is configurable or clearly documented.
* False trigger limitations are recorded.

### INVEST Check

* Independent: Can be tested with motion only.
* Negotiable: PIR action can be wake, status, or feed condition.
* Valuable: Adds smart interaction.
* Estimable: Clear sensor task.
* Small: One sensor feature.
* Testable: Motion tests verify it.

---

# EPIC 4: User Interface

## User Story 11: Display feeder status on LCD

### User Story Template

As a **pet owner**,
I want the LCD to show C.A.T.E.R. status,
so that I can understand what DAISY is doing without opening the electronics bay.

### Assumptions

* The project has a 16x2 LCD.
* Messages must be short and readable.
* LCD should show useful system states.
* Serial output still exists for developer debugging.

### Acceptance Criteria

* LCD initializes successfully during startup.
* LCD shows a ready state.
* LCD shows feeding state.
* LCD shows bowl full state.
* LCD shows cooldown state.
* LCD shows motion detected state when PIR is active.
* LCD shows error or blocked state where applicable.
* LCD messages are documented.
* LCD display does not freeze during normal feed testing.

### INVEST Check

* Independent: Can be implemented with mock states.
* Negotiable: Exact wording can change.
* Valuable: Improves usability.
* Estimable: Clear UI task.
* Small: One display layer.
* Testable: States can be triggered.

---

## User Story 12: Use keypad for basic feeder control

### User Story Template

As a **pet owner**,
I want to control basic feeder actions from the keypad,
so that I can interact with C.A.T.E.R. without editing firmware code.

### Assumptions

* The keypad is available in the parts kit.
* MVP commands should remain simple.
* Key mappings should be documented.
* Keypad control must respect safety rules.

### Acceptance Criteria

* Keypad input is read by DAISY.
* A key can trigger manual feed.
* A key can show current status.
* A key can cycle portion setting or mode if implemented.
* Invalid keys do not crash the firmware.
* Keypad input does not bypass cooldown.
* Keypad input does not bypass bowl-full protection.
* Key mappings are documented.
* Serial output reports keypad actions.

### INVEST Check

* Independent: Can be tested before advanced settings.
* Negotiable: Key mappings can change.
* Valuable: Gives direct control.
* Estimable: Clear interface task.
* Small: One input feature.
* Testable: Each key action can be checked.

---

# EPIC 5: Calibration and Testing

## User Story 13: Calibrate estimated feeding portions

### User Story Template

As a **maker**,
I want to calibrate C.A.T.E.R. using repeated food-dispensing tests,
so that the project can estimate ration output responsibly.

### Assumptions

* The feeder cannot guarantee exact calorie control in MVP.
* Food type affects output.
* Multiple test runs are needed.
* Calibration values may change after mechanical adjustments.

### Acceptance Criteria

* A calibration procedure is documented.
* The procedure includes multiple feed trials.
* The procedure records servo open duration.
* The procedure records approximate dispensed amount.
* The procedure records food type or kibble size.
* The procedure records jam or leakage observations.
* Calibration results are stored in documentation or a test log.
* README clearly states that portions are estimated.

### INVEST Check

* Independent: Can be done after basic dispenser works.
* Negotiable: Calibration format can evolve.
* Valuable: Makes feeding claims honest.
* Estimable: Clear testing task.
* Small: One calibration workflow.
* Testable: Trial data confirms completion.

---

## User Story 14: Test the feeder with real kibble

### User Story Template

As a **maker**,
I want to test C.A.T.E.R. with real dry cat food,
so that I can confirm the cardboard mechanism works under realistic conditions.

### Assumptions

* Real kibble is irregular in shape and size.
* Cardboard friction may affect food flow.
* The dispenser may need physical adjustment.
* Testing must happen before trusting the feeder with a pet.

### Acceptance Criteria

* The hopper is filled with test kibble.
* The gate opens and closes repeatedly.
* Food falls into the bowl during successful feed cycles.
* Jam points are identified and documented.
* Leakage when closed is tested.
* At least several repeated feed cycles are tested.
* Failed cycles are recorded honestly.
* Mechanical adjustments are documented.
* The feeder is not marked MVP-ready until testing passes.

### INVEST Check

* Independent: Can be done without mobile app or RFID.
* Negotiable: Number of test cycles can be increased.
* Valuable: Validates the physical system.
* Estimable: Clear hardware test task.
* Small: One testing phase.
* Testable: Feed cycles can be observed.

---

## User Story 15: Create a safety checklist

### User Story Template

As a **pet owner**,
I want a safety checklist for C.A.T.E.R.,
so that I know what must be checked before using the feeder around a cat.

### Assumptions

* The MVP is a prototype, not a certified commercial product.
* Pets may chew, push, knock, or interfere with the feeder.
* Electronics must be protected.
* The feeder should not be trusted without repeated testing.

### Acceptance Criteria

* Safety checklist includes power safety.
* Safety checklist includes servo movement safety.
* Safety checklist includes exposed wire checks.
* Safety checklist includes food contamination checks.
* Safety checklist includes cardboard stability checks.
* Safety checklist includes manual access to food.
* Safety checklist includes repeated test cycle requirement.
* Safety checklist warns against relying on the prototype as the only food source too early.
* Safety checklist is linked from the README.

### INVEST Check

* Independent: Documentation task.
* Negotiable: Checklist can expand.
* Valuable: Protects pet and builder.
* Estimable: Clear docs task.
* Small: One checklist document.
* Testable: Checklist items can be reviewed.

---

# EPIC 6: Documentation

## User Story 16: Create a wiring guide

### User Story Template

As a **maker**,
I want a wiring guide for C.A.T.E.R.,
so that I can connect the Arduino, servo, ultrasonic sensor, PIR sensor, LCD, and keypad correctly.

### Assumptions

* Arduino Uno is the default board.
* Servo power should not rely only on Arduino 5V for final testing.
* Ground must be shared between Arduino and external servo power.
* Pin assignments may change during development.

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
* Wiring guide is linked from the README.

### INVEST Check

* Independent: Can be written alongside hardware.
* Negotiable: Pins can update.
* Valuable: Prevents wiring mistakes.
* Estimable: Clear docs task.
* Small: One wiring document.
* Testable: Wiring can be verified.

---

## User Story 17: Create a build guide for the cardboard body

### User Story Template

As a **maker**,
I want a step-by-step cardboard build guide,
so that I can recreate the C.A.T.E.R. prototype without guessing the structure.

### Assumptions

* First build is cardboard.
* Measurements may evolve.
* The guide should separate body, hopper, gate, bowl area, and electronics bay.
* Photos or diagrams are needed.

### Acceptance Criteria

* Build guide explains required materials.
* Build guide explains body assembly.
* Build guide explains hopper assembly.
* Build guide explains dispenser gate assembly.
* Build guide explains bowl placement.
* Build guide explains electronics bay placement.
* Build guide explains sensor placement.
* Build guide includes photos, diagrams, or sketches.
* Build guide records known limitations.
* Build guide is linked from the README.

### INVEST Check

* Independent: Documentation can start before final polish.
* Negotiable: Template can evolve.
* Valuable: Makes the project repeatable.
* Estimable: Clear documentation task.
* Small: One build guide.
* Testable: Another builder can follow it.

---

## User Story 18: Create a DAISY firmware README

### User Story Template

As a **developer**,
I want a DAISY firmware README,
so that I understand how the firmware is structured, configured, uploaded, and tested.

### Assumptions

* DAISY is the firmware name.
* C.A.T.E.R. is the feeder project/hardware name.
* Firmware should be reusable and organized.
* Arduino IDE or PlatformIO may be supported.

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
* Firmware README is linked from the main README.

### INVEST Check

* Independent: Can be written before all features are complete.
* Negotiable: Tooling can change.
* Valuable: Helps development and onboarding.
* Estimable: Clear docs task.
* Small: One firmware guide.
* Testable: Setup steps can be followed.

---

# EPIC 7: Project Management and Release

## User Story 19: Set up GitHub labels, milestones, and project board

### User Story Template

As a **project maintainer**,
I want GitHub labels, milestones, and a project board for C.A.T.E.R.,
so that hardware, firmware, testing, documentation, and future features can be managed professionally.

### Assumptions

* GitHub Issues will manage development.
* Work should not be pushed randomly to main.
* Issues should be grouped by MVP, testing, documentation, and icebox.
* Hardware tasks need their own workflow visibility.

### Acceptance Criteria

* GitHub labels exist for firmware, hardware, docs, safety, testing, sensors, servo, UI, MVP, and icebox.
* Milestones exist for repository foundation, hardware prototype, firmware MVP, testing, and public MVP release.
* Project board columns exist for backlog, ready, in progress, blocked, hardware test, review, done, and released.
* User stories are added as GitHub issues.
* Icebox items are clearly separated from MVP work.
* README or docs explain the workflow.

### INVEST Check

* Independent: Project management task.
* Negotiable: Board columns can change.
* Valuable: Organizes development.
* Estimable: Clear setup task.
* Small: One GitHub setup pass.
* Testable: Board and labels can be inspected.

---

## User Story 20: Prepare first MVP demo

### User Story Template

As a **project maintainer**,
I want to prepare a first C.A.T.E.R. MVP demo,
so that the project can prove the feeder body, DAISY firmware, sensors, display, keypad, and dispenser work together.

### Assumptions

* Demo does not need mobile app or RFID.
* Demo should show real hardware behavior.
* Demo can be recorded as video.
* Demo should not hide failures or limitations.

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
* Demo video or photos are added to the repository.

### INVEST Check

* Independent: Can be done after MVP integration.
* Negotiable: Demo script can evolve.
* Valuable: Proves project progress.
* Estimable: Clear release task.
* Small: One demo package.
* Testable: Demo either works or exposes issues.

---

# Icebox User Stories

## Icebox Story 1: Add RFID collar detection

### User Story Template

As a **pet owner**,
I want C.A.T.E.R. to identify my cat using an RFID collar tag,
so that only an approved cat can trigger feeding.

### Assumptions

* RFID is not part of the MVP.
* RFID requires stable feeder behavior first.
* The cat must safely wear a tag.
* Unauthorized tags should not trigger feeding.

### Acceptance Criteria

* RFID module reads tag IDs.
* Approved tag IDs can be configured.
* Unknown tags are rejected.
* LCD shows authorized or unauthorized status.
* RFID does not bypass cooldown.
* RFID does not bypass bowl-full protection.
* RFID behavior is documented.
* Feature is marked icebox until MVP is stable.

---

## Icebox Story 2: Add feeding history logging

### User Story Template

As a **pet owner**,
I want C.A.T.E.R. to record feeding events,
so that I can track when my cat was fed.

### Assumptions

* MVP may only use Serial output.
* Structured logs come later.
* Storage may use EEPROM, SD card, mobile app, or connected device later.
* Exact calories are not guaranteed.

### Acceptance Criteria

* Feeding event format is defined.
* Event records include trigger type.
* Event records include estimated portion.
* Event records include success or blocked status.
* Event records include firmware version.
* Logging does not break feeding behavior.
* Logging path is documented.

---

## Icebox Story 3: Add mobile app feeding dashboard

### User Story Template

As a **pet owner**,
I want a mobile app dashboard for feeding data,
so that I can track my cat’s feeding behavior daily, weekly, monthly, and yearly.

### Assumptions

* Mobile app comes after hardware MVP.
* Local-first storage is preferred.
* App should not make medical claims.
* App may start with manual logs before device sync.

### Acceptance Criteria

* App supports pet profile.
* App supports food profile.
* App supports manual feeding log.
* App shows daily totals.
* App shows weekly totals.
* App shows monthly totals.
* App shows yearly totals.
* App uses local storage.
* App does not claim veterinary accuracy.
* App roadmap is documented.

---

## Icebox Story 4: Add low hopper detection

### User Story Template

As a **pet owner**,
I want C.A.T.E.R. to detect when the hopper may be low,
so that I know when to refill the feeder.

### Assumptions

* MVP may not include hopper-level sensing.
* Detection may use ultrasonic, weight, optical, or manual estimation later.
* False readings are possible.
* Warning should not claim exact food quantity unless measured.

### Acceptance Criteria

* Hopper low detection method is selected.
* DAISY reports low hopper warning.
* LCD shows low food warning.
* Feeding is not falsely marked successful if hopper is empty.
* Limitations are documented.
* Feature remains icebox until the core dispenser is reliable.
---

## Icebox Story 5: Add separate water dispenser module

### User Story Template

As a **pet owner**,
I want C.A.T.E.R. to include a separate water dispenser module,
so that my cat can access water near the feeding station without mixing water with the dry food system.

### Assumptions

* Water dispensing is not part of the food-only MVP.
* Water must stay physically separated from the Arduino, wiring, LCD, keypad, servo, rolling gate, and dry food path.
* The first water module may be passive gravity-fed instead of Arduino-controlled.
* Any smart water version should use a water-safe pump system, preferably a peristaltic pump.
* Cardboard should not be relied on as the primary water-contact structure.
* A leak tray or waterproof barrier is required.
* Water must have a separate bowl from the dry food bowl.
* Cleaning and refill access must be considered before implementation.

### Acceptance Criteria

* Water module is physically separated from the dry food hopper and rolling gate.
* Water does not pass over or near exposed electronics.
* Water bowl is separate from the food bowl.
* Passive gravity-fed water option is documented as the first upgrade path.
* Smart pump-controlled water option is documented as a later upgrade path.
* Leak risk is documented.
* Cleaning and refill access are considered.
* Cardboard water exposure is avoided or protected with waterproof lining.
* Water module is marked as post-MVP or icebox until food dispensing is reliable.

### INVEST Check

* Independent: Can be designed after the food module works.
* Negotiable: Passive bottle or pump-based design can be selected later.
* Valuable: Adds pet-care usefulness without compromising the food MVP.
* Estimable: Clear hardware upgrade task.
* Small: One separate water module prototype.
* Testable: Water refill behavior, separation, and leak safety can be tested.

---

# Recommended MVP Issue Order

1. Build main cardboard body
2. Build 2L bottle gravity-fed hopper
3. Build simple servo-controlled dispensing gate
4. Protect internal Arduino electronics bay
5. Initialize DAISY in safe startup state
6. Run manual feed cycle
7. Control food portion using servo duration
8. Add feed cooldown protection
9. Display feeder status on LCD
10. Use keypad for basic feeder control
11. Detect bowl fill level with ultrasonic sensor
12. Detect cat approach with PIR sensor
13. Calibrate estimated feeding portions
14. Test feeder with real kibble
15. Create wiring guide
16. Create cardboard build guide
17. Create DAISY firmware README
18. Create safety checklist
19. Set up GitHub labels, milestones, and project board
20. Prepare first MVP demo


---

# Recommended Icebox Issue Order

1. Add RFID collar detection
2. Add feeding history logging
3. Add mobile app feeding dashboard
4. Add low hopper detection
5. Add separate water dispenser module
