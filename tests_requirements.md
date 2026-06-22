# C.A.T.E.R. Test Requirements

## Purpose

This document is the authoritative master test requirements document for C.A.T.E.R.

It defines the testing backlog across physical hardware, electrical systems, DAISY firmware, the servo-driven rolling-gate dispenser, documentation, DevOps, tooling, sensors, UI, calibration, release work, future app work, and icebox features.

The goal is not only to prove that code compiles. C.A.T.E.R. is a pet-adjacent hardware project with food, electronics, cardboard, moving parts, and calibration claims. Testing must prove that the project is safe, repeatable, honest about limitations, and releasable through a professional DevOps workflow.

This document must distinguish between:

* A requirement being written.
* A procedure, sketch, template, or workflow being implemented.
* A sketch compiling.
* A sketch uploading to Arduino.
* Serial communication working.
* Physical hardware testing being executed.
* Physical pass/fail results being assigned.

## Source Context

These requirements are based on the current repository content:

* `README.md` - project scope, MVP stack, DevOps culture, safety principles, suggested repo structure, planned features, release expectations.
* `mine/user_stories.ps1` - MVP user stories, labels, epics, acceptance criteria, and icebox boundaries.
* `mine/measurements.md` - cardboard prototype measurements, rolling gate zone, hopper dimensions, and clearance rules.
* `tests/hardware/rolling_gate/` - focused rolling-gate hardware test package.
* `tests/hardware/rolling_gate/rolling_gate_servo_test/rolling_gate_servo_test.ino` - rolling-gate Arduino test sketch.
* `tests/hardware/rolling_gate/rolling_gate_servo_test/rolling_gate_test_config.h` - rolling-gate test configuration and safety lockout constants.
* `tests/hardware/rolling_gate/TEST_PLAN.md` - rolling-gate physical test plan.
* `tests/hardware/rolling_gate/RESULTS_TEMPLATE.md` - rolling-gate physical result template.
* `Fix-CaterKanban-Direct.ps1` - current issue and milestone organization, including the rolling-gate alignment blocker.

Repository inspection on 2026-06-22 found:

* `.github/ISSUE_TEMPLATE/` exists.
* `.github/workflows/` does not exist.
* `firmware/` does not exist.
* `docs/` does not exist.
* `hardware/` does not exist.
* `tools/` does not exist.
* `app/` does not exist.
* `releases/` does not exist.
* No DAISY production firmware exists in the repository yet.
* No wiring guide, safety guide, build guide, calibration guide, or release checklist exists yet.

## Testing Principles

* Safety gates come before feature gates.
* C.A.T.E.R. is the feeder hardware and project system.
* DAISY is the Arduino firmware.
* The current dispenser is a servo-driven rolling gate that rotates and indexes. It is not a sliding gate or flap gate.
* Manual gate movement does not count as a servo-driven test cycle.
* Hardware behavior must be physically observed and recorded; firmware must not claim to detect conditions it cannot sense.
* Test code existing does not mean the test has been executed.
* A compile pass does not mean upload, Serial, servo movement, or physical safety passed.
* CI supports bench testing, but CI does not replace physical hardware testing.
* Physical behavior cannot be inferred from repository files.
* MVP tests must focus on dry food feeding, safe startup, servo-driven dispensing, calibration, wiring, documentation, and release readiness.
* Exact calorie claims are outside the MVP.
* RFID, Wi-Fi, cloud sync, mobile control, NFT access, computer vision, weight sensors, and advanced sensing remain post-MVP unless explicitly moved into active scope.
* Future features must not block the current hardware MVP.
* The feeder must not be described as safe for unattended pet use before repeated physical tests pass.
* Every test should define preconditions, procedure, expected result, pass/fail criteria, evidence, and owner.
* Every change should be traceable from user story or requirement to test case to result.

## Test ID Scheme

Use stable IDs when creating issues, commits, result files, and release notes.

| Prefix | Area |
|---|---|
| `TR-DEV` | DevOps, repo structure, CI, release process |
| `TR-DOC` | Documentation and templates |
| `TR-HW` | Mechanical hardware and cardboard prototype |
| `TR-ELEC` | Electrical wiring, power, USB recognition, and pin validation |
| `TR-FW` | DAISY firmware build, upload, Serial, and behavior |
| `TR-RG` | Rolling-gate dispenser-specific tests |
| `TR-FEED` | Feeding, calibration, portion estimation, and kibble behavior |
| `TR-SENSOR` | Ultrasonic, PIR, and future sensor tests |
| `TR-UI` | LCD, keypad, LED, buzzer, and local interface tests |
| `TR-TOOL` | Python and repository support tools |
| `TR-APP` | Future mobile app tests |
| `TR-ICEBOX` | Future features that should not block MVP |

## Priority Definitions

| Priority | Meaning |
|---|---|
| `P0` | Immediate safety requirement, active blocker, required hardware validation gate, or required MVP release gate |
| `P1` | Core MVP behavior required after the immediate blocker chain |
| `P2` | Important quality, documentation, calibration, reproducibility, or CI improvement |
| `P3` | MVP-adjacent enhancement |
| `P4` | Post-MVP or icebox feature |

Priority rules:

* Keep immediate Arduino USB, electrical safety, rolling-gate movement, structural stability, reset, abort, dry feeding, and loaded feeding gates as `P0`.
* Use `P1` for core DAISY firmware behaviors after the current hardware blocker chain is cleared.
* Use `P2` for documentation, CI maturity, calibration tooling, and reproducibility improvements that matter but do not unblock the immediate bench test.
* Use `P4` for mobile, RFID, cloud, NFT, computer vision, weight sensors, and other post-MVP work.

## Automation Definitions

| Level | Meaning |
|---|---|
| `CI` | Fully automated in GitHub Actions or local command once the workflow/script exists |
| `Semi` | Script-assisted but requires operator review, hardware setup, or captured logs |
| `Manual` | Physical observation or human review required |
| `Manual/Semi` | Can start as a physical/manual diagnostic and later gain script support |
| `Future` | Do not build until the feature exists or enters active scope |

## Lifecycle Status Definitions

| Status | Definition |
|---|---|
| `Planned` | Requirement exists, but the test implementation, workflow, procedure, or target feature does not exist yet. |
| `Implemented` | Test script, procedure, template, sketch, or workflow exists but has not been fully validated or executed through its full target environment. |
| `Ready` | Preconditions are satisfied and the test can be executed now. |
| `Blocked` | The test cannot begin or continue because a named dependency, missing tool, hardware fault, wiring uncertainty, configuration uncertainty, or access problem exists. A blocked test is not a failure of the feature under test. |
| `Executing` | Test execution has begun but no final result exists. |
| `Passed` | Test was executed and all pass criteria were met with evidence. |
| `Conditional Pass` | Test completed without a critical failure but requires tuning, reinforcement, calibration, or retesting. |
| `Failed` | Test was executed and one or more failure criteria occurred. |
| `Not Applicable` | Requirement genuinely does not apply to the current supported scope, hardware revision, or feature set. Do not use this to avoid testing an unfinished requirement. |

## Current Test Status

This section describes current repository and hardware test status. It must not be read as a physical validation of the feeder.

| Item | Status | Evidence / Notes |
|---|---|---|
| Master test requirements document | Implemented | `tests_requirements.md` exists and is the authoritative master test requirements document. Do not mark it `Passed` until it is reviewed against its own acceptance criteria. |
| Rolling-gate test README | Implemented | `tests/hardware/rolling_gate/README.md` exists. |
| Rolling-gate test plan | Implemented | `tests/hardware/rolling_gate/TEST_PLAN.md` exists. |
| Rolling-gate results template | Implemented | `tests/hardware/rolling_gate/RESULTS_TEMPLATE.md` exists. |
| Rolling-gate test firmware | Implemented | `tests/hardware/rolling_gate/rolling_gate_servo_test/rolling_gate_servo_test.ino` exists. |
| Rolling-gate test configuration | Implemented | `rolling_gate_test_config.h` exists and still has confirmation flags set to `false`. |
| Rolling-gate compile result | Passed | Local command `arduino-cli compile --warnings all --fqbn arduino:avr:uno tests/hardware/rolling_gate/rolling_gate_servo_test` passed on 2026-06-22. This is build evidence only. Evidence saved in `tests/results/2026-06-22/TR-RG-001-rolling-gate-compile.md`. |
| Arduino CLI and Uno core | Implemented | `arduino-cli`, `arduino:avr`, and Servo library are available in the local environment. |
| Box stability and structural support | Blocked | Box still requires structural support and stability evidence before powered servo movement. See `TR-HW-010`. |
| Arduino USB recognition | Blocked | User reports Windows shows the official Arduino as an unrecognized USB device and no new Arduino COM port appears. `arduino-cli board list` showed `COM3` and `COM4` as unknown serial ports in this session, but neither was verified as the official Arduino. |
| Arduino firmware upload | Blocked | Blocked by Arduino USB recognition and missing verified board COM port. No upload has been completed. |
| Serial communication test | Blocked | Blocked by failed/unknown Arduino USB recognition and no confirmed uploaded diagnostic sketch. |
| Rolling-gate lockout upload validation | Blocked | Blocked by Arduino USB recognition, upload, and Serial validation. |
| Servo signal pin confirmation | Blocked | No authoritative production pin map exists, and physical wiring has not been confirmed in this document. |
| Servo resting position confirmation | Blocked | Physical angle and mechanical limits have not been confirmed. |
| Servo direction confirmation | Blocked | Physical rotation direction has not been confirmed. |
| Single dry servo-driven cycle | Blocked | No uploaded test sketch, no confirmed Serial, no confirmed servo configuration, and no physical run. |
| Repeated dry servo-driven cycles | Blocked | Depends on single dry cycle and current USB/upload/Serial blocker chain. |
| Single loaded kibble cycle | Blocked | Depends on successful dry cycle tests. No loaded cycle has been completed. |
| Repeated loaded kibble cycles | Blocked | Depends on successful repeated dry cycle and single loaded cycle. |
| Abort and reset physical validation | Blocked | Requires uploaded test firmware, Serial, and physical test execution. |
| Rolling-gate physical classification | Blocked | No physical pass, conditional pass, or fail classification has been assigned. |
| Rolling-gate epic | Blocked | Incomplete. Do not mark complete until physical tests and required corrections are finished. |

## Active Blockers

### Active Blocker: Arduino USB Recognition

Current condition:

* The official Arduino board is not assigned a confirmed new COM port when connected.
* User reports `arduino-cli board list` remains unchanged whether the Arduino is connected or disconnected.
* Windows reports an unrecognized USB device.
* Arduino CLI and the `arduino:avr` core are installed.
* The blocker occurs before firmware upload and before servo movement testing.
* `arduino-cli board list` in this session showed `COM3` and `COM4` as unknown serial ports, but neither was verified as the official Arduino board.

Blocked tests include at minimum:

* `TR-ELEC-011`
* `TR-ELEC-012`
* `TR-FW-016`
* `TR-FW-017`
* `TR-RG-002` through `TR-RG-016` where uploaded-firmware or physical execution is required

Do not mark these tests failed merely because the USB connection is blocked.

### Active Blocker: Rolling Gate Physical Validation Incomplete

Current condition:

* Rolling-gate test package exists.
* Rolling-gate test sketch compiles.
* Rolling-gate test sketch has not been uploaded to the Arduino.
* No servo-driven dry cycle has been completed.
* No loaded kibble cycle has been completed.
* No abort or reset behavior has been physically confirmed.
* No physical safety classification has been assigned.
* Manual turning does not count as a completed servo-driven test cycle.

## Test Readiness Definition

A test is ready to execute when:

* The requirement has a stable test ID.
* The target feature or artifact exists.
* Required test implementation exists.
* Required configuration values are documented.
* Required hardware and wiring preconditions are satisfied.
* The active blocker chain has been cleared for that test.
* Safety preconditions are documented.
* Expected results are clear.
* Evidence format is defined.
* The test can produce `Passed`, `Conditional Pass`, `Failed`, `Blocked`, or `Not Applicable`.

## Test Done Definition

A test is done when:

* Procedure has been executed exactly or any deviation is recorded.
* Results are stored in a repo-friendly artifact, such as Markdown, CSV, screenshot reference, photo reference, video reference, Serial log, upload log, or CI log.
* Pass/fail or blocked decision is recorded.
* Known limitations are documented.
* Required follow-up issues are created or linked.
* Retest requirements are identified.
* For release gates, the release checklist references the result.

## Result Classification

| Classification | Use When |
|---|---|
| `Passed` | The test was executed and all pass criteria were met with evidence. |
| `Conditional Pass` | The test completed without a critical safety or structural failure, but tuning, reinforcement, calibration, documentation, or retesting is still required. |
| `Failed` | The test was executed and one or more failure criteria occurred. |
| `Blocked` | Execution cannot begin or continue because a dependency, missing tool, hardware fault, wiring uncertainty, configuration uncertainty, or access problem exists. The blocker must be named and linked where possible. |
| `Not Applicable` | The requirement genuinely does not apply to the current supported scope, hardware revision, or feature set. Do not use this for unfinished work. |

## Evidence Requirements

| Evidence Type | Required For |
|---|---|
| Arduino compile log | Firmware sketches and hardware test sketches |
| Arduino upload log | Any upload validation |
| Device Manager observation or screenshot reference | USB recognition and COM-port tests |
| Serial log | Startup, lockout, feed cycle, sensor, calibration, abort, and reset tests |
| Completed Markdown result template | Hardware, safety, calibration, and release tests |
| Photo or video reference | Mechanical motion, wiring, build, and loaded feeding tests |
| Measurement table | Body, hopper, gate, clearance, and calibration tests |
| CI job log | Automated build, lint, docs, and tool tests |
| Manual reviewer sign-off | Safety checklist and release readiness |

Recommended result path:

```text
tests/results/YYYY-MM-DD/<test-id>-<short-name>.md
```

Every result artifact must include:

* Test ID
* Test title
* Status
* Priority
* Date
* Tester
* Hardware revision
* Firmware version
* Git commit
* Branch
* Board target
* COM port, where applicable
* Power configuration
* Configuration values
* Preconditions
* Procedure followed
* Deviations
* Expected result
* Actual result
* Evidence references
* Covered test IDs
* Blocker, when blocked
* Final classification
* Follow-up issue
* Retest requirement
* Sign-off

## Shared Evidence And Test Coverage

One test execution may satisfy multiple requirements when the result artifact explicitly lists all covered test IDs.

For example, a single repeated dry-cycle execution may provide evidence for:

* Rolling-gate synchronization.
* Servo-mount stability.
* Wiring clearance.
* Gate deformation.
* Repeated movement reliability.
* Servo temperature observation.
* Abort behavior if exercised during that run.

The result document must include:

* Primary test ID.
* Additional covered test IDs.
* Hardware revision.
* Firmware version.
* Configuration values.
* Procedure deviations.
* Observations.
* Final result for each covered requirement.

Do not require the same 20-cycle test to be physically repeated separately for every overlapping test ID unless a hardware, firmware, wiring, or configuration change requires retesting.

## Test Implementation Versus Test Execution

Do not treat these states as interchangeable:

1. Requirement written.
2. Test procedure written.
3. Test firmware written.
4. Test firmware compiled.
5. Test firmware uploaded.
6. Serial communication confirmed.
7. Physical test started.
8. Physical test completed.
9. Evidence recorded.
10. Result classified.
11. Follow-up issue created.
12. Retest completed.

The current rolling-gate package has reached requirement, procedure, firmware, template, and compile stages. It has not reached upload, Serial confirmation, physical execution, evidence recording, or physical result classification.

## Dependency Chain

Tests later in this chain must be marked `Blocked` when an earlier `P0` dependency has not passed.

1. Stable box with required structural support (`TR-HW-010`) and rolling-gate structure.
2. Safe and confirmed wiring plan.
3. Arduino recognized by Windows.
4. Usable Arduino COM port assigned.
5. Test sketch compiles.
6. Lockout or diagnostic sketch uploads.
7. Serial communication works.
8. Rolling-gate test configuration is reviewed.
9. Servo power and shared ground are confirmed.
10. Test firmware uploads in lockout mode.
11. Lockout behavior is validated.
12. Servo resting-position command is tested.
13. One dry cycle is tested.
14. Repeated dry cycles are tested.
15. One loaded cycle is tested.
16. Repeated loaded cycles are tested.
17. Abort and reset behavior are tested.
18. Results are classified.
19. Required corrections are completed.
20. Any affected tests are rerun.

## DevOps And CI Strategy

### Local Developer Preflight

Run before opening a PR when the relevant tools exist:

* Arduino compile check for changed sketches.
* Markdown lint or formatting check for changed docs.
* Link check for changed docs when practical.
* PowerShell parse check for changed `.ps1` scripts.
* Python tests for changed Python tools once those tools exist.
* Confirm no generated build artifacts are committed accidentally.

### Pull Request Gate

Required checks should eventually include:

* `docs-ci`: Markdown lint, link check, required-document validation.
* `firmware-ci`: Arduino CLI or PlatformIO compile for supported board targets.
* `tools-ci`: Python lint and tests for tooling.
* `repo-ci`: folder structure and template validation.
* `release-ci`: release checklist validation on release branches.

Current status: `.github/workflows/` does not exist, so these CI jobs are planned and not implemented.

### Hardware Bench Gate

Manual sign-off is required for:

* Rolling-gate motion and synchronization.
* Servo power safety.
* Startup and reset behavior.
* Abort behavior.
* Dry and loaded feeding tests.
* Calibration trials.
* Power loss behavior.
* Pet-adjacent safety review.

### Release Gate

A public MVP release should not ship unless:

* Firmware compiles for Arduino Uno R3 compatible target.
* Hardware test results exist for the supported hardware revision.
* Safety checklist is complete.
* Calibration notes are complete.
* Known limitations are documented.
* Release notes identify firmware version, supported board, supported hardware revision, required parts, setup steps, calibration notes, safety notes, and known issues.

## Test Case Backlog

### DevOps, Repository, And Release Tests

| ID | Priority | Automation | Build When | Status | Dependency / Blocked By | Requirement |
|---|---:|---|---|---|---|---|
| TR-DEV-001 | P2 | CI | Now | Planned | Structure validator missing | Validate the repository keeps required top-level structure as it grows: README, docs, firmware, hardware, tools, tests, releases, and app areas where applicable. |
| TR-DEV-002 | P2 | CI | Now | Planned | Markdown lint workflow missing | Validate Markdown documents parse cleanly and do not contain obvious broken table syntax. |
| TR-DEV-003 | P2 | CI | Now | Planned | Link checker missing | Validate internal Markdown links and referenced local files. |
| TR-DEV-004 | P2 | CI | Now | Planned | Template validator missing | Validate required test result templates exist for hardware and calibration procedures. |
| TR-DEV-005 | P2 | Semi | Now | Planned | Branch/release policy not encoded | Validate branch and PR workflow expectations: feature branches into develop, release branches into main, tagged releases for stable public builds. |
| TR-DEV-006 | P1 | CI | When workflows exist | Planned | `.github/workflows/` missing | Run Arduino compile checks on all supported firmware and hardware test sketches. |
| TR-DEV-007 | P2 | CI | When PlatformIO exists | Planned | PlatformIO config missing | Run PlatformIO build checks for DAISY firmware. |
| TR-DEV-008 | P2 | CI | When Python tools exist | Planned | Python tools missing | Run Python lint, unit tests, and packaging checks for calibration/report tools. |
| TR-DEV-009 | P2 | Semi | Now | Ready | PowerShell available; formal analyzer optional | Validate PowerShell scripts parse and include safe failure behavior before they touch GitHub state. |
| TR-DEV-010 | P2 | Manual | Now | Ready | Requires human review before running scripts | Review GitHub issue, milestone, and label updates before running scripts that mutate GitHub Projects. |
| TR-DEV-011 | P1 | CI | Before release | Planned | Release checklist missing | Validate release checklist is complete and references required test results. |
| TR-DEV-012 | P1 | Manual | Before release | Planned | Release notes template missing | Confirm release notes include known limitations and do not overclaim physical reliability. |

### Documentation Tests

| ID | Priority | Automation | Build When | Status | Dependency / Blocked By | Requirement |
|---|---:|---|---|---|---|---|
| TR-DOC-001 | P1 | Manual | Now | Planned | Safety guide/checklist missing | Safety checklist exists, is linked from README, and covers power, servo movement, exposed wires, food contamination, cardboard stability, manual food access, and repeated-cycle testing. |
| TR-DOC-002 | P0 | Manual | Now | Blocked | Wiring guide and confirmed pin map missing | Wiring guide identifies Arduino Uno, servo signal, servo power, ground, shared-ground rule, and warns not to assume Arduino 5V can power the loaded servo. |
| TR-DOC-003 | P1 | Manual | Now | Planned | Build guide missing | Build guide explains body, hopper, rolling gate/dispenser, bowl area, electronics bay, and sensor placement. |
| TR-DOC-004 | P1 | Manual | Now | Planned | Calibration guide missing | Calibration guide explains repeated trials, food type, kibble size, servo timing, approximate output, jams, leakage, and adjustment notes. |
| TR-DOC-005 | P1 | Manual | When DAISY exists | Planned | `firmware/` missing | Firmware README documents supported board, libraries, pin configuration, configurable values, upload process, Serial diagnostics, startup safety, and limitations. |
| TR-DOC-006 | P2 | CI | Now | Ready | Requires document review/lint criteria | README does not claim production safety or exact calories. |
| TR-DOC-007 | P2 | Manual | Now | Ready | Requires manual scope review | Documentation clearly separates MVP scope from icebox features. |
| TR-DOC-008 | P2 | Manual | Now | Planned | Troubleshooting guide missing | Troubleshooting guide covers servo chatter, power brownouts, gate binding, kibble jams, leakage, reset behavior, and upload failures. |
| TR-DOC-009 | P2 | Manual | Before release | Planned | Release notes template missing | Release notes template includes firmware version, board, hardware revision, setup, calibration, safety, known issues, and upgrade notes. |
| TR-DOC-010 | P2 | Semi | Before release | Planned | Build/wiring docs missing | Another builder can follow the build and wiring docs without hidden assumptions. |

### Mechanical Hardware Tests

| ID | Priority | Automation | Build When | Status | Dependency / Blocked By | Requirement |
|---|---:|---|---|---|---|---|
| TR-HW-001 | P1 | Manual | Now | Planned | Measurement result artifact missing | Confirm outer body dimensions against `mine/measurements.md`: 13 in wide, 16.25 in high, 13 in deep. |
| TR-HW-002 | P1 | Manual | Now | Planned | Measurement result artifact missing | Confirm inner chamber dimensions and vertical zones: bowl/plate area, rolling gate zone, and gravity hopper zone. |
| TR-HW-003 | P0 | Manual | Now | Planned | Rolling-gate measurement result missing | Confirm rolling gate zone height, rolling gate diameter, center height, and clearance above rolling gate. |
| TR-HW-004 | P0 | Manual | Now | Planned | Hopper/gate clearance result missing | Confirm hopper outlet dimensions and clearance over rolling gate. |
| TR-HW-005 | P0 | Manual | Now | Blocked | Rolling-gate structure and physical observation incomplete | Confirm hopper does not touch or obstruct the rolling gate during movement. |
| TR-HW-006 | P0 | Manual | Now | Blocked | Active rolling-gate opposite-side alignment blocker | Confirm rolling gate opposite-side alignment: both sides rotate together without collapse, folding, twist, or separation. |
| TR-HW-007 | P0 | Manual | Now | Blocked | Requires servo-driven dry movement; blocked by Arduino USB recognition | Confirm servo mount remains rigid during repeated dry movement. |
| TR-HW-008 | P0 | Manual | Now | Blocked | Requires wiring plan and servo-driven movement | Confirm wiring does not catch, pull, rub, or enter the rolling mechanism. |
| TR-HW-009 | P1 | Manual | Now | Planned | Electronics bay inspection result missing | Confirm electronics bay is isolated from food path, hopper, bowl, and pet contact. |
| TR-HW-010 | P0 | Manual | Now | Blocked | Box still requires structural support and stability evidence before powered servo movement | Confirm cardboard body resists tipping during normal bench operation. |
| TR-HW-011 | P1 | Manual | Now | Planned | Manual access inspection result missing | Confirm manual access to food remains available if electronics fail. |
| TR-HW-012 | P1 | Manual | Now | Planned | Food-contact review result missing | Confirm food contact surfaces are cleanable and do not shed unsafe material into food during tests. |
| TR-HW-013 | P1 | Manual | Now | Planned | Hardware revision log missing | Confirm mechanical adjustments are recorded with date, hardware revision, and retest requirement. |
| TR-HW-014 | P2 | Manual | Before release | Planned | Build guide and independent rebuild missing | Confirm another builder can reproduce the cardboard prototype from the build guide and measurements. |

### Electrical And Power Tests

| ID | Priority | Automation | Build When | Status | Dependency / Blocked By | Requirement |
|---|---:|---|---|---|---|---|
| TR-ELEC-001 | P0 | Manual | Now | Blocked | Confirmed wiring/power plan missing | Confirm servo power arrangement before movement testing. |
| TR-ELEC-002 | P0 | Manual | Now | Ready | Requires bench observation/signoff | Confirm loaded servo is not assumed safe on Arduino 5V. |
| TR-ELEC-003 | P0 | Manual | Now | Blocked | External servo supply/wiring not confirmed | Confirm Arduino ground and external servo power ground are shared when external servo power is used. |
| TR-ELEC-004 | P0 | Manual | Now | Ready | Requires operator signoff | Confirm power is disconnected before changing servo wiring. |
| TR-ELEC-005 | P0 | Manual | Now | Blocked | Authoritative pin map and wiring guide missing | Confirm servo signal pin matches firmware configuration and wiring guide. |
| TR-ELEC-006 | P0 | Manual | Now | Blocked | Wiring plan not confirmed | Confirm wiring polarity before powering servo. |
| TR-ELEC-007 | P0 | Manual | Now | Blocked | Requires repeated dry/loaded servo cycles | Observe servo temperature during repeated dry and loaded cycles. |
| TR-ELEC-008 | P0 | Manual | Now | Blocked | Requires powered movement test | Stop and fail test if servo stalls, overheats, chatters continuously, or causes brownout resets. |
| TR-ELEC-009 | P0 | Manual | Before firmware MVP | Blocked | Requires Arduino upload and physical reset/power test | Test power loss and reset behavior with no unexpected dispensing. |
| TR-ELEC-010 | P1 | Manual | Before release | Planned | Wiring route/protection inspection missing | Confirm strain relief or protected routing for pet-adjacent wires. |
| TR-ELEC-011 | P0 | Semi | Now | Blocked | Active Arduino USB recognition blocker | Confirm Windows recognizes the official Arduino board through USB and that connecting or disconnecting the board creates or removes the expected device or COM-port entry. Evidence must include Device Manager name/status/error code, cable, USB port, connected/disconnected comparison, screenshot or written observation, and assigned COM port when successful. |
| TR-ELEC-012 | P0 | Manual/Semi | Now | Blocked | Active Arduino USB recognition blocker | Diagnose the unrecognized official Arduino USB connection before servo testing, distinguishing data-cable failure, USB-port failure, Windows device-enumeration failure, USB driver failure, official Uno USB-interface firmware failure, and physical board or connector failure without assuming the result. |

### Rolling Gate Dispenser Tests

The rolling gate is the current dispenser mechanism under active validation. Use the existing `tests/hardware/rolling_gate/` package as the first implementation.

| ID | Priority | Automation | Build When | Status | Dependency / Blocked By | Requirement |
|---|---:|---|---|---|---|---|
| TR-RG-001 | P0 | CI | Now | Passed | None; compile is software-only | Compile rolling gate servo hardware test sketch for Arduino Uno. Evidence: `tests/results/2026-06-22/TR-RG-001-rolling-gate-compile.md`. |
| TR-RG-002 | P0 | Manual/Semi | Now | Blocked | `TR-ELEC-011`, `TR-FW-016`, `TR-FW-017` | Validate test sketch startup safety: configuration printed, invalid config blocks movement, no automatic cycle after reset. |
| TR-RG-003 | P0 | Manual | Now | Blocked | `TR-RG-016`, servo configuration not confirmed | Validate configured resting position does not create unsafe movement at startup. |
| TR-RG-004 | P0 | Manual | Now | Blocked | `TR-RG-003` | Run one dry servo-driven cycle from resting position to dispensing position and back/indexed rest. |
| TR-RG-005 | P0 | Manual | Now | Blocked | `TR-RG-004` | Run at least 20 automatic dry cycles with no hand assistance. |
| TR-RG-006 | P0 | Manual | Now | Blocked | `TR-RG-004` | Verify both sides of the rolling gate stay synchronized during servo-driven cycles. |
| TR-RG-007 | P0 | Manual | Now | Blocked | `TR-RG-004` | Verify gate does not scrape repeatedly, bind, collapse, twist, separate, or fold. |
| TR-RG-008 | P0 | Manual | Now | Blocked | `TR-RG-004`, wiring plan not confirmed | Verify wiring and servo mount remain clear and secure during movement. |
| TR-RG-009 | P0 | Manual | Now | Blocked | `TR-RG-005` | Run one loaded kibble cycle and confirm kibble is carried to discharge and drops into feeding plate. |
| TR-RG-010 | P0 | Manual | Now | Blocked | `TR-RG-009` | Run at least 10 automatic loaded kibble cycles. |
| TR-RG-011 | P0 | Manual | Now | Blocked | `TR-RG-009`, `TR-RG-010` | Record missed dispensing, partial dispensing, jams, leakage, trapped kibble, and failure cycle numbers. |
| TR-RG-012 | P0 | Manual/Semi | Now | Blocked | `TR-RG-002` and uploaded firmware required | Validate abort command stops future cycles and reports aborted status. |
| TR-RG-013 | P0 | Manual/Semi | Now | Blocked | `TR-RG-002` and uploaded firmware required | Validate reset does not start a cycle and restart requires explicit command. |
| TR-RG-014 | P1 | Manual/Semi | Now | Blocked | `TR-FW-017`, uploaded test sketch required | Validate `SUMMARY` output matches observed completed servo-driven cycles. |
| TR-RG-015 | P1 | Manual | After relevant hardware or configuration change | Not Applicable | Not required for the current immediate run unless hopper, gate support, servo mount, axle support, wiring route, or related configuration changes | Retest dry and loaded cycles after changing hopper clearance, gate support, servo mount, axle support, wiring route, or related configuration. |
| TR-RG-016 | P0 | Semi | After USB, upload, and Serial validation pass | Blocked | `TR-ELEC-011`, `TR-FW-016`, `TR-FW-017` | Confirm the rolling-gate test sketch can be uploaded in configuration-lockout mode and refuses movement while critical servo configuration values remain unconfirmed. This must happen before any servo-powered movement. |

### DAISY Firmware Build, Upload, And Configuration Tests

The main DAISY firmware does not exist yet. Diagnostic upload and Serial tests are still required before servo movement.

| ID | Priority | Automation | Build When | Status | Dependency / Blocked By | Requirement |
|---|---:|---|---|---|---|---|
| TR-FW-001 | P1 | CI | When firmware exists | Planned | `firmware/` missing | DAISY firmware compiles for Arduino Uno R3 compatible target. |
| TR-FW-002 | P1 | CI | When config exists | Planned | Firmware config missing | Firmware configuration values compile and are centralized in a documented config file. |
| TR-FW-003 | P1 | CI/Semi | When config exists | Planned | Firmware config missing | Invalid servo angle, duration, cooldown, or pin values are rejected or safely bounded. |
| TR-FW-004 | P0 | Semi | When firmware exists | Planned | DAISY firmware missing | Startup commands dispenser to safe resting state and does not run a feed cycle automatically. |
| TR-FW-005 | P0 | Semi | When firmware exists | Planned | DAISY firmware missing | Reset behavior is safe across multiple resets. |
| TR-FW-006 | P0 | Semi | When firmware exists | Planned | DAISY firmware missing | Firmware prevents endless dispensing and uses finite feed cycle timing. |
| TR-FW-007 | P1 | CI | When modules exist | Planned | Servo module missing | Servo control module has unit tests for command sequencing, rest target, dispense target, timing, and cooldown state. |
| TR-FW-008 | P1 | CI | When modules exist | Planned | Feed controller missing | Feed controller has unit tests for idle, feeding, cooldown, blocked, and error states. |
| TR-FW-009 | P1 | Semi | When manual feed exists | Planned | Manual feed feature missing | Manual feed command triggers exactly one configured feed cycle. |
| TR-FW-010 | P1 | Semi | When manual feed exists | Planned | Manual feed and cooldown missing | Repeated manual feed commands during cooldown are blocked and logged. |
| TR-FW-011 | P1 | CI/Semi | When button exists | Planned | Button input feature missing | Button debounce prevents repeated accidental feeds. |
| TR-FW-012 | P1 | Semi | When Serial diagnostics exist | Planned | DAISY Serial diagnostics missing | Serial output reports startup, feed start, feed complete, cooldown, blocked states, and errors. |
| TR-FW-013 | P1 | Semi | When scheduling exists | Planned | Scheduling feature missing | Timed feed cycle runs only when scheduled and respects cooldown and safety blocks. |
| TR-FW-014 | P2 | CI | When event format exists | Planned | Event format missing | Feeding event format includes event ID, device ID, timestamp source, feed type, portion config, calibration profile, and result status where supported. |
| TR-FW-015 | P2 | Semi | When firmware exists | Planned | Firmware README and DAISY firmware missing | Firmware behavior is documented in firmware README and matches actual Serial behavior. |
| TR-FW-016 | P0 | Semi | Now | Blocked | `TR-ELEC-011`, `TR-ELEC-012`; diagnostic sketch not uploaded | Compile and upload a minimal diagnostic or lockout firmware sketch to the Arduino before connecting the rolling-gate servo for movement testing. Evidence must include exact compile command/result, upload command/result, board target, COM port, and firmware version or sketch identifier. |
| TR-FW-017 | P0 | Semi | After successful upload | Blocked | `TR-FW-016` | Confirm Serial communication between the computer and Arduino using a finite diagnostic sketch that prints a known startup message and does not activate the servo. Evidence must include baud rate, expected startup text, actual Serial output, reset behavior, and timestamped log or screenshot. |

Important limitation:

Do not add firmware tests that assert automatic jam detection, current sensing, encoder feedback, or position feedback unless the hardware and code actually exist.

### Feeding And Calibration Tests

| ID | Priority | Automation | Build When | Status | Dependency / Blocked By | Requirement |
|---|---:|---|---|---|---|---|
| TR-FEED-001 | P0 | Manual | Now | Blocked | `TR-RG-004` | Dry feed mechanism test completes before any loaded kibble test. |
| TR-FEED-002 | P0 | Manual | Now | Blocked | `TR-RG-009` | Loaded test uses real dry kibble and records food type and size notes. |
| TR-FEED-003 | P0 | Manual | Now | Blocked | `TR-RG-009` | Stationary leakage is tested before and after servo-driven loaded cycles. |
| TR-FEED-004 | P0 | Manual | Now | Blocked | `TR-RG-005`, `TR-RG-010` | Failed cycles, partial cycles, jams, and mechanical adjustments are recorded honestly. |
| TR-FEED-005 | P1 | Manual | When feed cycle exists | Planned | Feed cycle execution missing | Calibration procedure runs multiple trials for a single configuration and records approximate output. |
| TR-FEED-006 | P1 | Manual | When feed cycle exists | Planned | Calibration guide/result template missing | Calibration records servo positions or dispense timing, cooldown, cycle count, food type, and hardware revision. |
| TR-FEED-007 | P1 | Manual | When feed cycle exists | Planned | Repeated loaded feed trials missing | Portion consistency is measured across repeated trials and classified as acceptable, needs tuning, or fail. |
| TR-FEED-008 | P1 | Manual | When feed cycle exists | Planned | Mechanical change log missing | Calibration is repeated after mechanical changes to hopper, gate, chute, or servo mount. |
| TR-FEED-009 | P2 | Semi | When Python tools exist | Planned | Python calibration analyzer missing | Calibration analyzer reads trial data and calculates average output, variation, failed-cycle count, and notes. |
| TR-FEED-010 | P2 | Manual | Before release | Planned | Calibration guide missing | README and calibration guide state portions are estimated rations, not exact calories. |
| TR-FEED-011 | P2 | Manual | Before release | Planned | Loaded food trials missing | Known unsupported foods or kibble sizes are documented. |

Suggested calibration evidence:

| Field | Description |
|---|---|
| Hardware revision | Cardboard/gate/hopper version tested |
| Firmware version | DAISY or hardware test sketch version |
| Servo settings | Resting position, dispensing position, duration, step timing |
| Food | Brand/type, kibble size notes, dry condition |
| Trial count | Number of repeated cycles |
| Output | Approximate amount dispensed per trial |
| Failure data | Jams, leakage, missed cycles, partial cycles |
| Result | Passed, Conditional Pass, Failed, Blocked, or Not Applicable |

### Sensor Integration Tests

Sensors are planned for the MVP/user stories, but they should not be used to bypass mechanical safety validation. The PIR and ultrasonic sensor are physically mounted; the missing work is pin-map confirmation, wiring validation, firmware integration, and test evidence.

| ID | Priority | Automation | Build When | Status | Dependency / Blocked By | Requirement |
|---|---:|---|---|---|---|---|
| TR-SENSOR-001 | P3 | Semi | When sensor pin map is defined | Planned | Ultrasonic sensor mounted; pin map, wiring validation, firmware integration, and test evidence missing | Ultrasonic sensor wiring matches wiring guide and firmware pin config. |
| TR-SENSOR-002 | P3 | Semi | When ultrasonic firmware exists | Planned | Ultrasonic sensor mounted; firmware integration and test evidence missing | Firmware reads distance values and prints raw/processed values to Serial. |
| TR-SENSOR-003 | P3 | Semi | When ultrasonic firmware exists | Planned | Ultrasonic sensor mounted; bowl-state logic and test evidence missing | Bowl state classification covers empty, partial, full, and unknown/error. |
| TR-SENSOR-004 | P3 | Semi | When ultrasonic firmware exists | Planned | Ultrasonic sensor mounted; bowl-full block logic and test evidence missing | Bowl-full state blocks feeding and reports blocked state. |
| TR-SENSOR-005 | P3 | Semi | When sensor config exists | Planned | Sensors mounted; thresholds, pin map, firmware integration, and test evidence missing | Thresholds are configurable and documented. |
| TR-SENSOR-006 | P3 | Manual | When ultrasonic bench setup is ready | Planned | Ultrasonic sensor mounted; wiring validation, bench setup, and test evidence missing | Empty and filled bowl test objects produce expected classifications under repeat trials. |
| TR-SENSOR-007 | P3 | Semi | When sensor pin map is defined | Planned | PIR sensor mounted; pin map, wiring validation, firmware integration, and test evidence missing | PIR wiring matches wiring guide and firmware pin config. |
| TR-SENSOR-008 | P3 | Semi | When PIR firmware exists | Planned | PIR sensor mounted; firmware integration and test evidence missing | PIR motion events are read and logged without bypassing cooldown. |
| TR-SENSOR-009 | P3 | Semi | When PIR behavior is defined | Planned | PIR sensor mounted; behavior definition, firmware integration, and test evidence missing | PIR-triggered behavior is configurable or limited to status/wake behavior by default. |
| TR-SENSOR-010 | P3 | Manual | When PIR bench setup is ready | Planned | PIR sensor mounted; false-trigger test evidence missing | False trigger limitations are documented. |
| TR-SENSOR-011 | P3 | CI | When sensor modules exist | Planned | Sensors mounted; firmware modules and automated test evidence missing | Sensor logic unit tests cover thresholds, debounce/filtering, blocked states, and unknown readings. |

Do not test:

* Exact food weight from ultrasonic alone.
* Pet identity from PIR alone.
* Jam detection unless actual jam detection hardware or logic exists.

### Local UI Tests

The LCD and keypad are physically installed; the missing work is pin-map confirmation, wiring validation, firmware integration, documented key/message behavior, and test evidence.

| ID | Priority | Automation | Build When | Status | Dependency / Blocked By | Requirement |
|---|---:|---|---|---|---|---|
| TR-UI-001 | P3 | Semi | When LCD firmware exists | Planned | LCD mounted; pin map, wiring validation, firmware integration, and test evidence missing | LCD initializes successfully during startup. |
| TR-UI-002 | P3 | Semi | When LCD firmware exists | Planned | LCD mounted; state mapping, firmware integration, and test evidence missing | LCD shows ready, feeding, cooldown, bowl full, motion detected, blocked, and error states where implemented. |
| TR-UI-003 | P3 | Semi | When LCD firmware exists | Planned | LCD mounted; firmware integration and normal-feed test evidence missing | LCD does not freeze during normal feed testing. |
| TR-UI-004 | P3 | Manual | When LCD message map exists | Planned | LCD mounted; message documentation and readability evidence missing | LCD messages are readable on 16x2 display and documented. |
| TR-UI-005 | P3 | Semi | When keypad firmware exists | Planned | Keypad mounted; pin map, wiring validation, firmware integration, and test evidence missing | Keypad input is read and logged. |
| TR-UI-006 | P3 | Semi | When keypad and manual feed firmware exist | Planned | Keypad mounted; manual feed firmware integration and safety evidence missing | Manual feed key triggers one feed cycle only when safety state allows. |
| TR-UI-007 | P3 | Semi | When keypad firmware exists | Planned | Keypad mounted; invalid-key handling evidence missing | Invalid keys do not crash firmware or trigger unexpected movement. |
| TR-UI-008 | P3 | Semi | When keypad and safety block logic exist | Planned | Keypad mounted; safety block integration and test evidence missing | Keypad input does not bypass cooldown or bowl-full protection. |
| TR-UI-009 | P3 | Manual | When keypad map exists | Planned | Keypad mounted; key mapping documentation and behavior evidence missing | Key mappings are documented and match firmware behavior. |
| TR-UI-010 | P3 | Semi | When LED/buzzer exists | Planned | Optional LED/buzzer feature missing | Optional LED and buzzer indicate ready, feeding, blocked, and error states without confusing the operator. |

### Python Tooling Tests

Python is planned for support tools, not Arduino firmware.

| ID | Priority | Automation | Build When | Status | Dependency / Blocked By | Requirement |
|---|---:|---|---|---|---|---|
| TR-TOOL-001 | P2 | CI | When Python exists | Planned | Python tools missing | Python tools have isolated unit tests. |
| TR-TOOL-002 | P2 | CI | When Python exists | Planned | Python tools missing | Python tools accept sample input files and produce deterministic output. |
| TR-TOOL-003 | P2 | CI | When calibration analyzer exists | Planned | Calibration analyzer missing | Calibration analyzer handles missing fields, failed cycles, and mixed pass/fail trial data. |
| TR-TOOL-004 | P2 | CI | When test report generator exists | Planned | Test report generator missing | Test report generator creates Markdown reports from result templates without overwriting source data. |
| TR-TOOL-005 | P2 | CI | When release packager exists | Planned | Release packager missing | Release packager includes required docs, firmware, calibration notes, known issues, and excludes development-only files. |
| TR-TOOL-006 | P2 | CI | When template validator exists | Planned | Template validator missing | Template validator checks required headings and fields in test result templates. |

### Mobile App And Data Tests

The mobile app is not MVP-blocking. Build these tests only when app work enters active scope.

| ID | Priority | Automation | Build When | Status | Dependency / Blocked By | Requirement |
|---|---:|---|---|---|---|---|
| TR-APP-001 | P4 | Future | When app exists | Planned | `app/` missing; post-MVP scope | App stores pets, food profiles, feeding events, and calibration profiles locally. |
| TR-APP-002 | P4 | Future | When app exists | Planned | `app/` missing; post-MVP scope | SQLite schema migration tests preserve existing local data. |
| TR-APP-003 | P4 | Future | When app exists | Planned | `app/` missing; post-MVP scope | Feeding history screens correctly display DAISY event records. |
| TR-APP-004 | P4 | Future | When app exists | Planned | `app/` missing; post-MVP scope | Calibration profile UI clearly labels portions as estimated. |
| TR-APP-005 | P4 | Future | When app exists | Planned | `app/` missing; post-MVP scope | App does not imply remote control exists unless connected-device control is implemented and tested. |
| TR-APP-006 | P4 | Future | When app exists | Planned | `app/` missing; post-MVP scope | App handles offline-first behavior without cloud dependency. |
| TR-APP-007 | P4 | Future | When app exists | Planned | `app/` missing; post-MVP scope | App privacy and local data handling are documented. |

### Icebox And Post-MVP Tests

Do not build these until the feature is moved from icebox into active scope.

| ID | Priority | Automation | Build When | Status | Dependency / Blocked By | Requirement |
|---|---:|---|---|---|---|---|
| TR-ICEBOX-001 | P4 | Future | If RFID enters scope | Planned | RFID is post-MVP/icebox | RFID known/unknown tag tests, denied access behavior, and identity limitations. |
| TR-ICEBOX-002 | P4 | Future | If Wi-Fi enters scope | Planned | Wi-Fi is post-MVP/icebox | Wi-Fi connection, offline fallback, reconnect, and credential handling tests. |
| TR-ICEBOX-003 | P4 | Future | If cloud sync enters scope | Planned | Cloud sync is post-MVP/icebox | Cloud sync conflict, retry, offline queue, and privacy tests. |
| TR-ICEBOX-004 | P4 | Future | If RTC enters scope | Planned | RTC is post-MVP/icebox | Timekeeping, schedule persistence, daylight saving/timezone behavior, and power-loss tests. |
| TR-ICEBOX-005 | P4 | Future | If EEPROM enters scope | Planned | EEPROM is post-MVP/icebox | Settings persistence, corruption defaults, and write-frequency tests. |
| TR-ICEBOX-006 | P4 | Future | If weight sensors enter scope | Planned | Weight sensors are post-MVP/icebox | Load cell calibration, tare, drift, serving weight feedback, and failure mode tests. |
| TR-ICEBOX-007 | P4 | Future | If computer vision enters scope | Planned | Computer vision is post-MVP/icebox | Image privacy, false classification, lighting variation, and no-camera fallback tests. |
| TR-ICEBOX-008 | P4 | Future | If NFT/token access enters scope | Planned | NFT/token access is post-MVP/icebox | Access verification, fallback, expired/invalid token, and non-blocking public MVP behavior tests. |

## Suggested Test Folder Structure

As the project grows, use this structure:

```text
tests/
  README.md
  results/
    YYYY-MM-DD/
  hardware/
    rolling_gate/
    hopper/
    body/
    wiring/
    power_loss/
  firmware/
    unit/
    integration/
    compile/
  calibration/
    templates/
    sample-data/
  docs/
    link-check/
    required-docs/
  tools/
    python/
  release/
    checklist/
```

Current implemented starting point:

```text
tests/hardware/rolling_gate/
```

## Minimum MVP Test Suite

The minimum suite is dependency-aware. It does not require future app, cloud, RFID, NFT, computer vision, weight sensor, or advanced sensor tests for the current hardware MVP.

### Immediate Hardware Validation Gate

Only tests required to make the current rolling-gate prototype safe and testable:

| Gate Area | Required Tests |
|---|---|
| Box stability | `TR-HW-010` |
| Structure and clearance | `TR-HW-003` through `TR-HW-008` |
| Electrical and USB readiness | `TR-ELEC-001` through `TR-ELEC-009`, `TR-ELEC-011`, `TR-ELEC-012` |
| Diagnostic upload and Serial | `TR-FW-016`, `TR-FW-017` |
| Rolling-gate lockout and movement | `TR-RG-001` through `TR-RG-016` |
| Dry and loaded feeding evidence | `TR-FEED-001` through `TR-FEED-004` |

Current status: blocked by Arduino USB recognition and incomplete physical rolling-gate validation.

### DAISY Firmware MVP Gate

Required after the main DAISY firmware exists:

| Gate Area | Required Tests |
|---|---|
| Firmware compile/config | `TR-FW-001` through `TR-FW-003` |
| Safe startup/reset/endless-dispense prevention | `TR-FW-004` through `TR-FW-006` |
| Core feed behavior | `TR-FW-007` through `TR-FW-013` |
| Firmware docs/diagnostics | `TR-FW-015` |

Current status: planned because `firmware/` does not exist.

### Documentation And Reproducibility Gate

Required before another builder can reproduce the prototype:

| Gate Area | Required Tests |
|---|---|
| Safety and wiring docs | `TR-DOC-001`, `TR-DOC-002` |
| Build and calibration docs | `TR-DOC-003`, `TR-DOC-004` |
| Scope honesty | `TR-DOC-006`, `TR-DOC-007` |
| Troubleshooting and builder reproduction | `TR-DOC-008`, `TR-DOC-010` |
| Reproducible hardware build | `TR-HW-014` |

Current status: planned/blocked because `docs/` does not exist.

### Release Gate

Required before a public MVP release:

| Gate Area | Required Tests |
|---|---|
| Repository and CI readiness | `TR-DEV-001` through `TR-DEV-006`, `TR-DEV-011`, `TR-DEV-012` |
| Release notes/checklist | `TR-DOC-009` |
| Safety, calibration, known limitations | `TR-DOC-001`, `TR-DOC-004`, `TR-FEED-010`, `TR-FEED-011` |
| Physical rolling-gate results | All `P0` `TR-RG` tests with physical scope |
| Power/reset/abort evidence | `TR-ELEC-009`, `TR-RG-012`, `TR-RG-013` |

Current status: planned/blocked. No public MVP release should be cut from the current state.

## Dependency-Aware Recommended Build Order

1. Resolve official Arduino USB recognition.
2. Identify a known-good data cable, USB port, driver state, board state, and COM port.
3. Compile and upload a minimal diagnostic or lockout sketch.
4. Confirm Serial communication with known startup text.
5. Review rolling-gate test configuration while confirmation flags remain locked out.
6. Upload rolling-gate test sketch in lockout mode and confirm it refuses movement.
7. Confirm safe wiring, servo power, and shared ground.
8. Confirm box stability and required structural support.
9. Confirm rolling-gate structure and opposite-side alignment.
10. Confirm servo pin, resting position, dispensing position, and rotation direction.
11. Test the resting-position command.
12. Run one dry servo-driven cycle.
13. Run repeated dry cycles.
14. Run one loaded kibble cycle.
15. Run repeated loaded kibble cycles.
16. Test abort and reset recovery.
17. Record and classify results.
18. Complete required mechanical, wiring, configuration, or documentation corrections.
19. Rerun affected tests after corrections.
20. Add DAISY firmware skeleton and compile tests only after the dispenser hardware is safe enough to integrate.
21. Add docs, CI, calibration, and release gates before public MVP release.

## Known Gaps To Track

* Official Arduino USB recognition is currently blocked.
* Box stability still requires structural support and test evidence before powered servo movement.
* No confirmed Arduino COM port for the official board is available.
* No firmware upload has succeeded.
* No Serial communication test has passed.
* No servo-driven rolling-gate dry cycle has been completed.
* No loaded kibble cycle has been completed.
* No rolling-gate physical classification has been assigned.
* Rolling-gate epic remains incomplete.
* No main DAISY firmware exists yet.
* No authoritative production pin map exists yet.
* No full wiring guide exists yet.
* No build guide, safety guide, calibration guide, troubleshooting guide, release checklist, or release notes template exists yet.
* No GitHub Actions workflows exist yet.
* No Python tools exist yet.
* No mobile app exists yet.
* Physical pass/fail status cannot be inferred from repository files alone.

## Non-Negotiable Release Rules

* Do not mark the feeder safe for normal pet use until repeated dry and loaded tests pass.
* Do not claim exact calories in the MVP.
* Do not trust the prototype as the only food source until reliability is physically demonstrated over time.
* Do not let future app, RFID, cloud, NFT, computer vision, weight sensors, or advanced sensor work block the hardware MVP.
* Do not hide failed cycles, jams, leakage, servo stalls, wiring interference, upload failures, Serial failures, or reset problems.
* Do not replace physical safety testing with CI. CI supports the bench; it does not replace it.
* Do not mark the rolling-gate epic complete until physical tests pass or required corrections and retests are completed.
