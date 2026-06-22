# Rolling Gate Servo Hardware Test Results

## Test Metadata

| Field | Value |
|---|---|
| Test date | |
| Tester | |
| Hardware revision | |
| Firmware test version | |
| Arduino board | Arduino Uno R3 compatible |
| Servo model | |
| Servo type | |
| Servo signal pin | |
| Power source | |
| Shared-ground confirmation | |
| Resting position setting | |
| Dispensing position setting | |
| Rotation direction setting | |
| Movement timing | |
| Dry cycle count | |
| Kibble cycle count | |
| Kibble type | |
| Kibble size notes | |
| Video or photo evidence references | |

## Electrical Safety Check

| Check | Pass/Fail/Notes |
|---|---|
| Servo power arrangement confirmed before testing | |
| Arduino 5V pin not assumed safe for loaded servo power | |
| External servo supply ground shared with Arduino ground, if used | |
| Power disconnected before changing servo wiring | |
| Hands kept clear while powered | |
| Dry test completed before loaded test | |
| Test stopped on stall, overheating, continuous chatter, or binding | |

## Phase 1: Startup Safety

| Observation | Result/Notes |
|---|---|
| Configuration values printed | |
| Invalid configuration blocks movement | |
| Servo initializes at or moves to resting position where hardware allows | |
| No dispensing cycle begins automatically after reset | |
| Unexpected servo jump observed | |
| Reset behavior safe | |

## Phase 2: Single Dry Cycle

| Observation | Result/Notes |
|---|---|
| Begins from resting position | |
| Both gate sides remain synchronized | |
| No twisting, separation, collapse, or folding | |
| No repeated scraping | |
| Wiring remains clear | |
| Servo mount remains secure | |
| Dispensing movement reached | |
| Return/indexed resting position reached | |
| No hand assistance used | |
| Overall single dry-cycle result | |

## Phase 3: Repeated Dry-Cycle Test

| Metric | Value/Notes |
|---|---|
| Configured dry cycles | |
| Successful cycles | |
| Failed cycles | |
| Failure cycle numbers | |
| Incomplete rotations | |
| Scraping observations | |
| Gate separation observations | |
| Servo mount observations | |
| Wiring observations | |
| Abnormal noise observations | |
| Servo stall observations | |
| Servo temperature observations | |
| Abort behavior, if used | |
| Overall repeated dry-cycle result | |

## Phase 4: Single Loaded Cycle

| Observation | Result/Notes |
|---|---|
| Kibble remains in hopper while stationary | |
| Gate receives kibble during servo-driven movement | |
| Gate carries kibble toward discharge side | |
| Kibble drops into feeding plate | |
| Return/indexed resting position reached | |
| Stationary leakage observations | |
| Jam observations | |
| Kibble trapped inside gate | |
| No hand assistance used | |
| Overall single loaded-cycle result | |

## Phase 5: Repeated Loaded Test

| Metric | Value/Notes |
|---|---|
| Configured kibble cycles | |
| Successful dispensing cycles | |
| Missed dispensing cycles | |
| Partial dispensing cycles | |
| Failed cycles | |
| Failure cycle numbers | |
| Jam observations | |
| Leakage observations | |
| Incomplete rotation observations | |
| Kibble trapped inside gate | |
| Servo stall observations | |
| Gate deformation observations | |
| Gate alignment observations | |
| Servo temperature observations | |
| Servo mount observations | |
| Wiring observations | |
| Approximate portion consistency | |
| Configuration adjustments made | |
| Overall repeated loaded-cycle result | |

## Phase 6: Reset and Abort Recovery

| Observation | Result/Notes |
|---|---|
| Reset does not start a cycle automatically | |
| Abort stops further test cycles | |
| Test reports aborted status | |
| Test does not silently resume after abort | |
| Operator can command gate back to resting position | |
| Restart requires explicit command and confirmation | |
| Final Serial summary copied or referenced | |

## Final Classification

Select one:

* Pass
* Conditional Pass
* Fail

| Field | Value/Notes |
|---|---|
| Final classification | |
| Required corrections | |
| Retest required | |
| Tester sign-off | |

## Notes

Record any observations that are not represented above. Do not mark the physical mechanism as passed unless the servo-driven dry and loaded tests were physically observed and recorded.
