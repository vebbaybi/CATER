# ============================================================
# C.A.T.E.R. GitHub User Story Issue Creator
# Creates MVP and Icebox user stories for C.A.T.E.R. / DAISY
# Run from the repository root.
# Requires: gh CLI authenticated with repo access.
# ============================================================

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[SKIP] $Message" -ForegroundColor Yellow
}

function Require-Command {
    param([string]$CommandName)

    $command = Get-Command $CommandName -ErrorAction SilentlyContinue
    if (-not $command) {
        throw "Required command not found: $CommandName"
    }
}

function Invoke-GhJson {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $output = & gh @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "gh command failed: gh $($Arguments -join ' ')"
    }

    if ([string]::IsNullOrWhiteSpace($output)) {
        return $null
    }

    return $output | ConvertFrom-Json
}

function Ensure-Label {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$Color,

        [Parameter(Mandatory = $true)]
        [string]$Description,

        [Parameter(Mandatory = $true)]
        [array]$ExistingLabels
    )

    $found = $ExistingLabels | Where-Object { $_.name -eq $Name } | Select-Object -First 1

    if ($found) {
        Write-Success "Label exists: $Name"
        return
    }

    & gh label create $Name --color $Color --description $Description | Out-Null

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create label: $Name"
    }

    Write-Success "Created label: $Name"
}

function New-UserStoryBody {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Epic,

        [Parameter(Mandatory = $true)]
        [string]$Role,

        [Parameter(Mandatory = $true)]
        [string]$Want,

        [Parameter(Mandatory = $true)]
        [string]$Benefit,

        [Parameter(Mandatory = $true)]
        [string[]]$Assumptions,

        [Parameter(Mandatory = $true)]
        [string[]]$AcceptanceCriteria,

        [Parameter(Mandatory = $true)]
        [string[]]$InvestCheck
    )

    $assumptionText = ($Assumptions | ForEach-Object { "- $_" }) -join "`n"
    $criteriaText = ($AcceptanceCriteria | ForEach-Object { "- [ ] $_" }) -join "`n"
    $investText = ($InvestCheck | ForEach-Object { "- $_" }) -join "`n"

    return @"
## Epic

$Epic

## User Story

As a **$Role**,
I want $Want,
so that $Benefit.

## Assumptions

$assumptionText

## Acceptance Criteria

$criteriaText

## INVEST Check

$investText

## Notes

C.A.T.E.R. is the feeder hardware and project system.

DAISY is the Arduino firmware.

RFID collar detection is not part of the MVP unless this issue is explicitly marked as icebox.

"@
}

function Create-IssueIfMissing {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,

        [Parameter(Mandatory = $true)]
        [string]$Body,

        [Parameter(Mandatory = $true)]
        [string[]]$Labels,

        [Parameter(Mandatory = $true)]
        [array]$ExistingIssues
    )

    $existing = $ExistingIssues | Where-Object { $_.title -eq $Title } | Select-Object -First 1

    if ($existing) {
        Write-Warn "Issue already exists: #$($existing.number) $Title"
        return
    }

    $tempFile = New-TemporaryFile
    try {
        Set-Content -Path $tempFile.FullName -Value $Body -Encoding UTF8

        $args = @(
            "issue",
            "create",
            "--title",
            $Title,
            "--body-file",
            $tempFile.FullName
        )

        foreach ($label in $Labels) {
            $args += @("--label", $label)
        }

        $createdUrl = & gh @args

        if ($LASTEXITCODE -ne 0) {
            throw "Failed to create issue: $Title"
        }

        Write-Success "Created issue: $Title"
        if (-not [string]::IsNullOrWhiteSpace($createdUrl)) {
            Write-Host $createdUrl
        }
    }
    finally {
        Remove-Item -Path $tempFile.FullName -Force -ErrorAction SilentlyContinue
    }
}

Write-Step "Checking required tools"
Require-Command "gh"
Require-Command "git"
Write-Success "Required tools found"

Write-Step "Checking GitHub authentication"
& gh auth status | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "GitHub CLI is not authenticated. Run gh auth login first."
}
Write-Success "GitHub CLI is authenticated"

Write-Step "Resolving repository"
$repoInfo = Invoke-GhJson @("repo", "view", "--json", "nameWithOwner")
$repoName = $repoInfo.nameWithOwner
if ([string]::IsNullOrWhiteSpace($repoName)) {
    throw "Could not resolve GitHub repository. Run this script inside the repo root."
}
Write-Success "Repository: $repoName"

Write-Step "Reading existing labels"
$existingLabels = Invoke-GhJson @("label", "list", "--limit", "1000", "--json", "name")

$labelsToEnsure = @(
    @{ Name = "user-story"; Color = "7057ff"; Description = "User story issue using role, value, assumptions, acceptance criteria, and INVEST" },
    @{ Name = "mvp"; Color = "0e8a16"; Description = "Required for the first usable C.A.T.E.R. MVP" },
    @{ Name = "icebox"; Color = "c5def5"; Description = "Future feature not required for the MVP" },
    @{ Name = "hardware"; Color = "fbca04"; Description = "Physical feeder body, cardboard, mechanism, sensors, wiring, or parts" },
    @{ Name = "firmware"; Color = "1d76db"; Description = "DAISY Arduino firmware behavior and control logic" },
    @{ Name = "daisy"; Color = "bfd4f2"; Description = "DAISY firmware identity and Arduino control behavior" },
    @{ Name = "servo"; Color = "f9d0c4"; Description = "Servo motor and dispensing gate behavior" },
    @{ Name = "sensor"; Color = "5319e7"; Description = "PIR, ultrasonic, and future sensing behavior" },
    @{ Name = "lcd"; Color = "006b75"; Description = "LCD status display behavior" },
    @{ Name = "keypad"; Color = "d4c5f9"; Description = "Keypad input and feeder controls" },
    @{ Name = "safety"; Color = "b60205"; Description = "Pet safety, electronics protection, power safety, and feeding safeguards" },
    @{ Name = "testing"; Color = "0e8a16"; Description = "Hardware, firmware, calibration, and validation testing" },
    @{ Name = "documentation"; Color = "0075ca"; Description = "README, wiring guide, build guide, firmware docs, and safety docs" },
    @{ Name = "project-management"; Color = "c2e0c6"; Description = "GitHub board, labels, milestones, workflow, and release planning" },
    @{ Name = "demo"; Color = "fbca04"; Description = "Demo photos, videos, proof, and release showcase" },
    @{ Name = "mobile-app"; Color = "0052cc"; Description = "Future mobile app dashboard and tracking work" },
    @{ Name = "rfid"; Color = "d93f0b"; Description = "RFID collar detection and access control" },
    @{ Name = "data-logging"; Color = "5319e7"; Description = "Feeding event records, logs, reports, and tracking data" }
)

foreach ($label in $labelsToEnsure) {
    Ensure-Label `
        -Name $label.Name `
        -Color $label.Color `
        -Description $label.Description `
        -ExistingLabels $existingLabels
}

Write-Step "Reading existing issues"
$existingIssues = Invoke-GhJson @("issue", "list", "--state", "all", "--limit", "1000", "--json", "number,title,state,url")

$stories = @(
    @{
        Title = "Build the main C.A.T.E.R. cardboard body"
        Epic = "Epic 1: Cardboard Hardware Build"
        Role = "maker"
        Want = "to build the main cardboard enclosure for C.A.T.E.R."
        Benefit = "the feeder has a stable physical structure for the hopper, bowl, sensors, controls, and electronics"
        Labels = @("user-story", "mvp", "hardware")
        Assumptions = @(
            "Cardboard is the primary MVP material.",
            "The feeder must be tall enough to allow gravity-fed food movement.",
            "The Arduino should not be exposed externally.",
            "The bowl should be accessible from the front.",
            "The body should be stable enough not to tip easily during testing."
        )
        Criteria = @(
            "The cardboard body can stand upright without support.",
            "The body includes a top hopper zone.",
            "The body includes a middle dispensing zone.",
            "The body includes a lower bowl zone.",
            "The body includes space for the LCD and keypad.",
            "The body includes an internal protected electronics bay.",
            "The body allows access for maintenance and rewiring.",
            "The Arduino is not mounted openly on the outside.",
            "The design is documented with dimensions or build notes.",
            "A photo or diagram of the completed body is added to the project."
        )
        Invest = @(
            "Independent: Can be built before firmware is complete.",
            "Negotiable: Dimensions can change after testing.",
            "Valuable: Provides the physical foundation.",
            "Estimable: Can be estimated as a hardware build task.",
            "Small: One body prototype.",
            "Testable: Stability and layout can be checked."
        )
    },
    @{
        Title = "Build the gravity-fed hopper"
        Epic = "Epic 1: Cardboard Hardware Build"
        Role = "pet owner"
        Want = "the feeder to store dry cat food in a gravity-fed hopper"
        Benefit = "food can naturally move toward the dispensing gate without manual pushing"
        Labels = @("user-story", "mvp", "hardware")
        Assumptions = @(
            "The MVP uses dry kibble only.",
            "Wet food is not supported.",
            "The hopper is made from cardboard.",
            "The hopper should avoid very narrow choke points.",
            "Food flow will be validated with real kibble."
        )
        Criteria = @(
            "The hopper can hold a test amount of dry cat food.",
            "The hopper slopes toward the dispensing outlet.",
            "Food can move toward the outlet using gravity.",
            "The hopper does not collapse under the test food load.",
            "The outlet is wide enough to reduce jamming risk.",
            "The hopper can be opened or accessed for refilling.",
            "The hopper is isolated from the electronics bay.",
            "Food flow test results are documented."
        )
        Invest = @(
            "Independent: Can be tested without full firmware.",
            "Negotiable: Hopper angle and outlet size can change.",
            "Valuable: Enables automatic dispensing.",
            "Estimable: A clear cardboard build task.",
            "Small: One hopper prototype.",
            "Testable: Food flow can be tested."
        )
    },
    @{
        Title = "Build a simple servo-controlled dispensing gate"
        Epic = "Epic 1: Cardboard Hardware Build"
        Role = "pet owner"
        Want = "C.A.T.E.R. to use a servo-controlled gate"
        Benefit = "DAISY can release food only when feeding is allowed"
        Labels = @("user-story", "mvp", "hardware", "servo")
        Assumptions = @(
            "The MVP should avoid a complex rotating ration wheel.",
            "A simple sliding gate or flap gate is preferred.",
            "The servo should move the gate, not carry the full hopper weight.",
            "The gate should fail closed where possible.",
            "Some portion variation is acceptable in MVP."
        )
        Criteria = @(
            "A servo is mounted securely near the chute outlet.",
            "The gate opens when the servo moves to the open position.",
            "The gate closes when the servo moves to the closed position.",
            "The gate blocks food when closed.",
            "The gate releases food when open.",
            "The gate can complete repeated open and close cycles.",
            "The mechanism does not require hand assistance during normal testing.",
            "The mechanism is documented with photos or diagrams.",
            "Any jam points or leakage issues are recorded."
        )
        Invest = @(
            "Independent: Can be tested with servo sweep code.",
            "Negotiable: Gate style can be slider or flap.",
            "Valuable: Core feeding function.",
            "Estimable: Clear mechanism build.",
            "Small: One dispenser mechanism.",
            "Testable: Open, close, and food release can be tested."
        )
    },
    @{
        Title = "Protect the internal Arduino electronics bay"
        Epic = "Epic 1: Cardboard Hardware Build"
        Role = "maker"
        Want = "the Arduino and wiring protected inside an internal electronics bay"
        Benefit = "the system can run safely without exposing the board to the cat, food, or accidental contact"
        Labels = @("user-story", "mvp", "hardware", "safety")
        Assumptions = @(
            "The Arduino Uno is required for the MVP.",
            "The Arduino must not be mounted openly on the outside.",
            "The bay should allow access for debugging and maintenance.",
            "The bay should separate electronics from food.",
            "Wires should be routed cleanly."
        )
        Criteria = @(
            "The Arduino Uno fits inside the internal electronics bay.",
            "The bay has a removable or openable access panel.",
            "The Arduino is protected from direct contact with food.",
            "The Arduino is protected from direct contact with the cat.",
            "Wires are routed through controlled openings.",
            "The bay does not block the hopper or dispenser.",
            "The bay allows USB access or practical upload access.",
            "The internal bay is labeled in documentation.",
            "The design shows how the Arduino remains part of the system without being exposed."
        )
        Invest = @(
            "Independent: Can be built before final firmware.",
            "Negotiable: Bay position can change.",
            "Valuable: Improves safety and professionalism.",
            "Estimable: Clear enclosure task.",
            "Small: One bay feature.",
            "Testable: Arduino fit and access can be checked."
        )
    },
    @{
        Title = "Initialize DAISY in a safe startup state"
        Epic = "Epic 2: DAISY Firmware MVP"
        Role = "pet owner"
        Want = "DAISY to start with the dispensing gate closed"
        Benefit = "food does not accidentally dump when the Arduino powers on or resets"
        Labels = @("user-story", "mvp", "firmware", "daisy", "safety")
        Assumptions = @(
            "Servo close position will be configurable.",
            "Startup behavior must be predictable.",
            "Power resets may happen during testing.",
            "The feeder must not dispense food automatically during boot unless intentionally scheduled."
        )
        Criteria = @(
            "On startup, DAISY moves the servo to the closed position.",
            "DAISY does not trigger a feed cycle during startup.",
            "Startup status is printed to Serial.",
            "LCD shows a safe ready state after initialization.",
            "If the servo is unavailable or not responding, the system reports an error state where possible.",
            "The behavior is tested through multiple resets.",
            "Startup behavior is documented in the README or firmware notes."
        )
        Invest = @(
            "Independent: Can be implemented before sensors.",
            "Negotiable: Exact messages can change.",
            "Valuable: Prevents unsafe food dumping.",
            "Estimable: Clear firmware behavior.",
            "Small: One startup behavior.",
            "Testable: Reset tests verify it."
        )
    },
    @{
        Title = "Run a manual feed cycle"
        Epic = "Epic 2: DAISY Firmware MVP"
        Role = "pet owner"
        Want = "to trigger a manual feed cycle"
        Benefit = "I can release food immediately when needed"
        Labels = @("user-story", "mvp", "firmware", "daisy", "servo")
        Assumptions = @(
            "Manual feed may be triggered through the keypad.",
            "The feed cycle uses the servo gate.",
            "Manual feeding must respect safety rules.",
            "Bowl-full detection may block manual feeding when enabled."
        )
        Criteria = @(
            "A manual feed command can be triggered from the keypad.",
            "DAISY opens the servo gate for a configured duration.",
            "DAISY closes the servo gate after the feed duration.",
            "DAISY shows feeding status on the LCD.",
            "DAISY prints manual feed status to Serial.",
            "DAISY prevents repeated accidental manual feeds.",
            "Manual feed does not run if the system is in a blocked safety state.",
            "Manual feed behavior is documented."
        )
        Invest = @(
            "Independent: Can be tested without full scheduling.",
            "Negotiable: Keypad command can change.",
            "Valuable: Gives immediate user control.",
            "Estimable: Clear firmware task.",
            "Small: One feed action.",
            "Testable: Press command, observe cycle."
        )
    },
    @{
        Title = "Control food portion using servo open duration"
        Epic = "Epic 2: DAISY Firmware MVP"
        Role = "pet owner"
        Want = "DAISY to control feeding amount by adjusting how long the gate stays open"
        Benefit = "C.A.T.E.R. can dispense estimated portions"
        Labels = @("user-story", "mvp", "firmware", "daisy", "servo")
        Assumptions = @(
            "MVP portions are estimated, not exact grams.",
            "Kibble size affects portion output.",
            "Servo open duration is the primary MVP control.",
            "Later versions may use better calibration or weight sensors."
        )
        Criteria = @(
            "DAISY supports configurable dispense duration.",
            "DAISY supports at least one default portion setting.",
            "DAISY closes the gate after the configured duration.",
            "DAISY prevents continuous open-gate behavior.",
            "Portion timing values are easy to adjust in firmware configuration.",
            "Serial output shows selected portion duration.",
            "Test notes record approximate food output for several trials.",
            "Documentation clearly states that portions are estimated."
        )
        Invest = @(
            "Independent: Can be tested with servo and kibble.",
            "Negotiable: Portion sizes can change after calibration.",
            "Valuable: Enables controlled rationing.",
            "Estimable: Firmware configuration task.",
            "Small: One portion-control behavior.",
            "Testable: Timed gate opening can be measured."
        )
    },
    @{
        Title = "Add feed cooldown protection"
        Epic = "Epic 2: DAISY Firmware MVP"
        Role = "pet owner"
        Want = "DAISY to apply a cooldown after feeding"
        Benefit = "the feeder does not dispense food repeatedly by accident"
        Labels = @("user-story", "mvp", "firmware", "daisy", "safety")
        Assumptions = @(
            "PIR motion may trigger repeated detection.",
            "Keypad input may bounce or be pressed multiple times.",
            "Cooldown protects against overfeeding.",
            "Cooldown duration should be configurable."
        )
        Criteria = @(
            "DAISY starts a cooldown after every successful feed.",
            "DAISY blocks new feed cycles during cooldown.",
            "LCD shows cooldown or wait status.",
            "Serial output reports when feeding is blocked by cooldown.",
            "Cooldown duration is configurable.",
            "Cooldown applies to manual and sensor-triggered feed attempts.",
            "Cooldown behavior is tested with repeated feed attempts."
        )
        Invest = @(
            "Independent: Can be added after manual feed.",
            "Negotiable: Cooldown duration can change.",
            "Valuable: Prevents overfeeding.",
            "Estimable: Clear state-management task.",
            "Small: One safety behavior.",
            "Testable: Repeated commands can verify it."
        )
    },
    @{
        Title = "Detect bowl fill level with ultrasonic sensor"
        Epic = "Epic 3: Sensor Integration"
        Role = "pet owner"
        Want = "C.A.T.E.R. to detect whether the bowl already has food"
        Benefit = "DAISY can avoid overfilling the bowl"
        Labels = @("user-story", "mvp", "firmware", "daisy", "sensor", "safety")
        Assumptions = @(
            "The ultrasonic sensor is mounted above or near the bowl.",
            "Distance readings may need calibration.",
            "The MVP can use simple threshold states.",
            "The sensor does not measure exact food weight."
        )
        Criteria = @(
            "The ultrasonic sensor is wired to the Arduino.",
            "DAISY reads distance values from the ultrasonic sensor.",
            "DAISY classifies bowl state as empty, partial, or full.",
            "DAISY blocks feeding when the bowl is considered full.",
            "LCD shows bowl full status when feeding is blocked.",
            "Serial output reports measured distance and bowl state.",
            "Thresholds are configurable.",
            "Sensor readings are tested with an empty bowl and a filled bowl.",
            "Limitations are documented."
        )
        Invest = @(
            "Independent: Can be tested separately from PIR.",
            "Negotiable: Threshold values can change.",
            "Valuable: Prevents overfilling.",
            "Estimable: Sensor integration task.",
            "Small: One sensor behavior.",
            "Testable: Distances can be measured."
        )
    },
    @{
        Title = "Detect cat approach with PIR sensor"
        Epic = "Epic 3: Sensor Integration"
        Role = "pet owner"
        Want = "C.A.T.E.R. to detect when my cat approaches"
        Benefit = "DAISY can respond to presence near the feeder"
        Labels = @("user-story", "mvp", "firmware", "daisy", "sensor")
        Assumptions = @(
            "PIR detects motion, not identity.",
            "PIR should not automatically feed every time by default unless configured.",
            "PIR may be used to wake the system, display status, or enable a feed condition.",
            "Random motion may cause false triggers."
        )
        Criteria = @(
            "The PIR sensor is wired to the Arduino.",
            "DAISY reads PIR motion state.",
            "LCD can show cat detected or motion detected.",
            "Serial output reports PIR events.",
            "PIR detection does not bypass cooldown.",
            "PIR detection does not bypass bowl-full protection.",
            "PIR-triggered behavior is configurable or clearly documented.",
            "False trigger limitations are recorded."
        )
        Invest = @(
            "Independent: Can be tested with motion only.",
            "Negotiable: PIR action can be wake, status, or feed condition.",
            "Valuable: Adds smart interaction.",
            "Estimable: Clear sensor task.",
            "Small: One sensor feature.",
            "Testable: Motion tests verify it."
        )
    },
    @{
        Title = "Display feeder status on LCD"
        Epic = "Epic 4: User Interface"
        Role = "pet owner"
        Want = "the LCD to show C.A.T.E.R. status"
        Benefit = "I can understand what DAISY is doing without opening the electronics bay"
        Labels = @("user-story", "mvp", "firmware", "daisy", "lcd")
        Assumptions = @(
            "The project has a 16x2 LCD.",
            "Messages must be short and readable.",
            "LCD should show useful system states.",
            "Serial output still exists for developer debugging."
        )
        Criteria = @(
            "LCD initializes successfully during startup.",
            "LCD shows a ready state.",
            "LCD shows feeding state.",
            "LCD shows bowl full state.",
            "LCD shows cooldown state.",
            "LCD shows motion detected state when PIR is active.",
            "LCD shows error or blocked state where applicable.",
            "LCD messages are documented.",
            "LCD display does not freeze during normal feed testing."
        )
        Invest = @(
            "Independent: Can be implemented with mock states.",
            "Negotiable: Exact wording can change.",
            "Valuable: Improves usability.",
            "Estimable: Clear UI task.",
            "Small: One display layer.",
            "Testable: States can be triggered."
        )
    },
    @{
        Title = "Use keypad for basic feeder control"
        Epic = "Epic 4: User Interface"
        Role = "pet owner"
        Want = "to control basic feeder actions from the keypad"
        Benefit = "I can interact with C.A.T.E.R. without editing firmware code"
        Labels = @("user-story", "mvp", "firmware", "daisy", "keypad")
        Assumptions = @(
            "The keypad is available in the parts kit.",
            "MVP commands should remain simple.",
            "Key mappings should be documented.",
            "Keypad control must respect safety rules."
        )
        Criteria = @(
            "Keypad input is read by DAISY.",
            "A key can trigger manual feed.",
            "A key can show current status.",
            "A key can cycle portion setting or mode if implemented.",
            "Invalid keys do not crash the firmware.",
            "Keypad input does not bypass cooldown.",
            "Keypad input does not bypass bowl-full protection.",
            "Key mappings are documented.",
            "Serial output reports keypad actions."
        )
        Invest = @(
            "Independent: Can be tested before advanced settings.",
            "Negotiable: Key mappings can change.",
            "Valuable: Gives direct control.",
            "Estimable: Clear interface task.",
            "Small: One input feature.",
            "Testable: Each key action can be checked."
        )
    },
    @{
        Title = "Calibrate estimated feeding portions"
        Epic = "Epic 5: Calibration and Testing"
        Role = "maker"
        Want = "to calibrate C.A.T.E.R. using repeated food-dispensing tests"
        Benefit = "the project can estimate ration output responsibly"
        Labels = @("user-story", "mvp", "testing", "safety")
        Assumptions = @(
            "The feeder cannot guarantee exact calorie control in MVP.",
            "Food type affects output.",
            "Multiple test runs are needed.",
            "Calibration values may change after mechanical adjustments."
        )
        Criteria = @(
            "A calibration procedure is documented.",
            "The procedure includes multiple feed trials.",
            "The procedure records servo open duration.",
            "The procedure records approximate dispensed amount.",
            "The procedure records food type or kibble size.",
            "The procedure records jam or leakage observations.",
            "Calibration results are stored in documentation or a test log.",
            "README clearly states that portions are estimated."
        )
        Invest = @(
            "Independent: Can be done after basic dispenser works.",
            "Negotiable: Calibration format can evolve.",
            "Valuable: Makes feeding claims honest.",
            "Estimable: Clear testing task.",
            "Small: One calibration workflow.",
            "Testable: Trial data confirms completion."
        )
    },
    @{
        Title = "Test the feeder with real kibble"
        Epic = "Epic 5: Calibration and Testing"
        Role = "maker"
        Want = "to test C.A.T.E.R. with real dry cat food"
        Benefit = "I can confirm the cardboard mechanism works under realistic conditions"
        Labels = @("user-story", "mvp", "hardware", "testing", "safety")
        Assumptions = @(
            "Real kibble is irregular in shape and size.",
            "Cardboard friction may affect food flow.",
            "The dispenser may need physical adjustment.",
            "Testing must happen before trusting the feeder with a pet."
        )
        Criteria = @(
            "The hopper is filled with test kibble.",
            "The gate opens and closes repeatedly.",
            "Food falls into the bowl during successful feed cycles.",
            "Jam points are identified and documented.",
            "Leakage when closed is tested.",
            "At least several repeated feed cycles are tested.",
            "Failed cycles are recorded honestly.",
            "Mechanical adjustments are documented.",
            "The feeder is not marked MVP-ready until testing passes."
        )
        Invest = @(
            "Independent: Can be done without mobile app or RFID.",
            "Negotiable: Number of test cycles can be increased.",
            "Valuable: Validates the physical system.",
            "Estimable: Clear hardware test task.",
            "Small: One testing phase.",
            "Testable: Feed cycles can be observed."
        )
    },
    @{
        Title = "Create a safety checklist"
        Epic = "Epic 5: Calibration and Testing"
        Role = "pet owner"
        Want = "a safety checklist for C.A.T.E.R."
        Benefit = "I know what must be checked before using the feeder around a cat"
        Labels = @("user-story", "mvp", "documentation", "safety")
        Assumptions = @(
            "The MVP is a prototype, not a certified commercial product.",
            "Pets may chew, push, knock, or interfere with the feeder.",
            "Electronics must be protected.",
            "The feeder should not be trusted without repeated testing."
        )
        Criteria = @(
            "Safety checklist includes power safety.",
            "Safety checklist includes servo movement safety.",
            "Safety checklist includes exposed wire checks.",
            "Safety checklist includes food contamination checks.",
            "Safety checklist includes cardboard stability checks.",
            "Safety checklist includes manual access to food.",
            "Safety checklist includes repeated test cycle requirement.",
            "Safety checklist warns against relying on the prototype as the only food source too early.",
            "Safety checklist is linked from the README."
        )
        Invest = @(
            "Independent: Documentation task.",
            "Negotiable: Checklist can expand.",
            "Valuable: Protects pet and builder.",
            "Estimable: Clear docs task.",
            "Small: One checklist document.",
            "Testable: Checklist items can be reviewed."
        )
    },
    @{
        Title = "Create a wiring guide"
        Epic = "Epic 6: Documentation"
        Role = "maker"
        Want = "a wiring guide for C.A.T.E.R."
        Benefit = "I can connect the Arduino, servo, ultrasonic sensor, PIR sensor, LCD, and keypad correctly"
        Labels = @("user-story", "mvp", "documentation", "hardware")
        Assumptions = @(
            "Arduino Uno is the default board.",
            "Servo power should not rely only on Arduino 5V for final testing.",
            "Ground must be shared between Arduino and external servo power.",
            "Pin assignments may change during development."
        )
        Criteria = @(
            "Wiring guide lists all connected components.",
            "Wiring guide includes Arduino pin assignments.",
            "Wiring guide explains servo signal, power, and ground.",
            "Wiring guide explains ultrasonic sensor wiring.",
            "Wiring guide explains PIR sensor wiring.",
            "Wiring guide explains LCD wiring.",
            "Wiring guide explains keypad wiring.",
            "Wiring guide includes the shared-ground rule.",
            "Wiring guide warns about servo power limits.",
            "Wiring guide is linked from the README."
        )
        Invest = @(
            "Independent: Can be written alongside hardware.",
            "Negotiable: Pins can update.",
            "Valuable: Prevents wiring mistakes.",
            "Estimable: Clear docs task.",
            "Small: One wiring document.",
            "Testable: Wiring can be verified."
        )
    },
    @{
        Title = "Create a build guide for the cardboard body"
        Epic = "Epic 6: Documentation"
        Role = "maker"
        Want = "a step-by-step cardboard build guide"
        Benefit = "I can recreate the C.A.T.E.R. prototype without guessing the structure"
        Labels = @("user-story", "mvp", "documentation", "hardware")
        Assumptions = @(
            "First build is cardboard.",
            "Measurements may evolve.",
            "The guide should separate body, hopper, gate, bowl area, and electronics bay.",
            "Photos or diagrams are needed."
        )
        Criteria = @(
            "Build guide explains required materials.",
            "Build guide explains body assembly.",
            "Build guide explains hopper assembly.",
            "Build guide explains dispenser gate assembly.",
            "Build guide explains bowl placement.",
            "Build guide explains electronics bay placement.",
            "Build guide explains sensor placement.",
            "Build guide includes photos, diagrams, or sketches.",
            "Build guide records known limitations.",
            "Build guide is linked from the README."
        )
        Invest = @(
            "Independent: Documentation can start before final polish.",
            "Negotiable: Template can evolve.",
            "Valuable: Makes the project repeatable.",
            "Estimable: Clear documentation task.",
            "Small: One build guide.",
            "Testable: Another builder can follow it."
        )
    },
    @{
        Title = "Create a DAISY firmware README"
        Epic = "Epic 6: Documentation"
        Role = "developer"
        Want = "a DAISY firmware README"
        Benefit = "I understand how the firmware is structured, configured, uploaded, and tested"
        Labels = @("user-story", "mvp", "documentation", "firmware", "daisy")
        Assumptions = @(
            "DAISY is the firmware name.",
            "C.A.T.E.R. is the feeder project and hardware name.",
            "Firmware should be reusable and organized.",
            "Arduino IDE or PlatformIO may be supported."
        )
        Criteria = @(
            "Firmware README identifies DAISY as the firmware.",
            "Firmware README explains supported board.",
            "Firmware README explains required libraries.",
            "Firmware README explains pin configuration.",
            "Firmware README explains configurable values.",
            "Firmware README explains upload process.",
            "Firmware README explains Serial diagnostics.",
            "Firmware README explains safe startup behavior.",
            "Firmware README explains known limitations.",
            "Firmware README is linked from the main README."
        )
        Invest = @(
            "Independent: Can be written before all features are complete.",
            "Negotiable: Tooling can change.",
            "Valuable: Helps development and onboarding.",
            "Estimable: Clear docs task.",
            "Small: One firmware guide.",
            "Testable: Setup steps can be followed."
        )
    },
    @{
        Title = "Set up GitHub labels, milestones, and project board"
        Epic = "Epic 7: Project Management and Release"
        Role = "project maintainer"
        Want = "GitHub labels, milestones, and a project board for C.A.T.E.R."
        Benefit = "hardware, firmware, testing, documentation, and future features can be managed professionally"
        Labels = @("user-story", "mvp", "project-management")
        Assumptions = @(
            "GitHub Issues will manage development.",
            "Work should not be pushed randomly to main.",
            "Issues should be grouped by MVP, testing, documentation, and icebox.",
            "Hardware tasks need their own workflow visibility."
        )
        Criteria = @(
            "GitHub labels exist for firmware, hardware, docs, safety, testing, sensors, servo, UI, MVP, and icebox.",
            "Milestones exist for repository foundation, hardware prototype, firmware MVP, testing, and public MVP release.",
            "Project board columns exist for backlog, ready, in progress, blocked, hardware test, review, done, and released.",
            "User stories are added as GitHub issues.",
            "Icebox items are clearly separated from MVP work.",
            "README or docs explain the workflow."
        )
        Invest = @(
            "Independent: Project management task.",
            "Negotiable: Board columns can change.",
            "Valuable: Organizes development.",
            "Estimable: Clear setup task.",
            "Small: One GitHub setup pass.",
            "Testable: Board and labels can be inspected."
        )
    },
    @{
        Title = "Prepare first MVP demo"
        Epic = "Epic 7: Project Management and Release"
        Role = "project maintainer"
        Want = "to prepare a first C.A.T.E.R. MVP demo"
        Benefit = "the project can prove the feeder body, DAISY firmware, sensors, display, keypad, and dispenser work together"
        Labels = @("user-story", "mvp", "demo", "testing")
        Assumptions = @(
            "Demo does not need mobile app or RFID.",
            "Demo should show real hardware behavior.",
            "Demo can be recorded as video.",
            "Demo should not hide failures or limitations."
        )
        Criteria = @(
            "Demo shows feeder powered on.",
            "Demo shows DAISY ready state.",
            "Demo shows manual feed command.",
            "Demo shows servo gate opening and closing.",
            "Demo shows food dropping into the bowl.",
            "Demo shows LCD status updates.",
            "Demo shows PIR detection.",
            "Demo shows ultrasonic bowl-full blocking if implemented.",
            "Demo shows Arduino protected inside the internal bay.",
            "Demo notes known limitations.",
            "Demo video or photos are added to the repository."
        )
        Invest = @(
            "Independent: Can be done after MVP integration.",
            "Negotiable: Demo script can evolve.",
            "Valuable: Proves project progress.",
            "Estimable: Clear release task.",
            "Small: One demo package.",
            "Testable: Demo either works or exposes issues."
        )
    },
    @{
        Title = "Add RFID collar detection"
        Epic = "Icebox: RFID and Access Control"
        Role = "pet owner"
        Want = "C.A.T.E.R. to identify my cat using an RFID collar tag"
        Benefit = "only an approved cat can trigger feeding"
        Labels = @("user-story", "icebox", "rfid", "sensor")
        Assumptions = @(
            "RFID is not part of the MVP.",
            "RFID requires stable feeder behavior first.",
            "The cat must safely wear a tag.",
            "Unauthorized tags should not trigger feeding."
        )
        Criteria = @(
            "RFID module reads tag IDs.",
            "Approved tag IDs can be configured.",
            "Unknown tags are rejected.",
            "LCD shows authorized or unauthorized status.",
            "RFID does not bypass cooldown.",
            "RFID does not bypass bowl-full protection.",
            "RFID behavior is documented.",
            "Feature is marked icebox until MVP is stable."
        )
        Invest = @(
            "Independent: Can be built after MVP.",
            "Negotiable: Tag storage can change.",
            "Valuable: Supports cat-specific access.",
            "Estimable: Clear sensor upgrade.",
            "Small: One identity feature.",
            "Testable: Known and unknown tags can be tested."
        )
    },
    @{
        Title = "Add feeding history logging"
        Epic = "Icebox: Data and Tracking"
        Role = "pet owner"
        Want = "C.A.T.E.R. to record feeding events"
        Benefit = "I can track when my cat was fed"
        Labels = @("user-story", "icebox", "data-logging")
        Assumptions = @(
            "MVP may only use Serial output.",
            "Structured logs come later.",
            "Storage may use EEPROM, SD card, mobile app, or connected device later.",
            "Exact calories are not guaranteed."
        )
        Criteria = @(
            "Feeding event format is defined.",
            "Event records include trigger type.",
            "Event records include estimated portion.",
            "Event records include success or blocked status.",
            "Event records include firmware version.",
            "Logging does not break feeding behavior.",
            "Logging path is documented."
        )
        Invest = @(
            "Independent: Can be planned before mobile app.",
            "Negotiable: Storage target can change.",
            "Valuable: Creates tracking foundation.",
            "Estimable: Clear data feature.",
            "Small: One logging foundation.",
            "Testable: Events can be printed or stored."
        )
    },
    @{
        Title = "Add mobile app feeding dashboard"
        Epic = "Icebox: Mobile App"
        Role = "pet owner"
        Want = "a mobile app dashboard for feeding data"
        Benefit = "I can track my cat's feeding behavior daily, weekly, monthly, and yearly"
        Labels = @("user-story", "icebox", "mobile-app")
        Assumptions = @(
            "Mobile app comes after hardware MVP.",
            "Local-first storage is preferred.",
            "App should not make medical claims.",
            "App may start with manual logs before device sync."
        )
        Criteria = @(
            "App supports pet profile.",
            "App supports food profile.",
            "App supports manual feeding log.",
            "App shows daily totals.",
            "App shows weekly totals.",
            "App shows monthly totals.",
            "App shows yearly totals.",
            "App uses local storage.",
            "App does not claim veterinary accuracy.",
            "App roadmap is documented."
        )
        Invest = @(
            "Independent: Can be started after data model planning.",
            "Negotiable: App stack can evolve.",
            "Valuable: Adds long-term product value.",
            "Estimable: Clear future app feature.",
            "Small: One dashboard foundation.",
            "Testable: Screens and stored records can be verified."
        )
    },
    @{
        Title = "Add low hopper detection"
        Epic = "Icebox: Advanced Sensing"
        Role = "pet owner"
        Want = "C.A.T.E.R. to detect when the hopper may be low"
        Benefit = "I know when to refill the feeder"
        Labels = @("user-story", "icebox", "sensor")
        Assumptions = @(
            "MVP may not include hopper-level sensing.",
            "Detection may use ultrasonic, weight, optical, or manual estimation later.",
            "False readings are possible.",
            "Warning should not claim exact food quantity unless measured."
        )
        Criteria = @(
            "Hopper low detection method is selected.",
            "DAISY reports low hopper warning.",
            "LCD shows low food warning.",
            "Feeding is not falsely marked successful if hopper is empty.",
            "Limitations are documented.",
            "Feature remains icebox until the core dispenser is reliable."
        )
        Invest = @(
            "Independent: Can be added after core feeding works.",
            "Negotiable: Sensor method can change.",
            "Valuable: Improves reliability and user trust.",
            "Estimable: Clear future sensing task.",
            "Small: One low-food feature.",
            "Testable: Empty and filled hopper states can be checked."
        )
    }
)

Write-Step "Creating user story issues"

foreach ($story in $stories) {
    $body = New-UserStoryBody `
        -Epic $story.Epic `
        -Role $story.Role `
        -Want $story.Want `
        -Benefit $story.Benefit `
        -Assumptions $story.Assumptions `
        -AcceptanceCriteria $story.Criteria `
        -InvestCheck $story.Invest

    Create-IssueIfMissing `
        -Title $story.Title `
        -Body $body `
        -Labels $story.Labels `
        -ExistingIssues $existingIssues
}

Write-Step "Refreshing issue list"
$updatedIssues = Invoke-GhJson @("issue", "list", "--state", "all", "--limit", "1000", "--json", "number,title,state,url")
$createdOrExisting = $updatedIssues | Where-Object {
    $title = $_.title
    $stories.Title -contains $title
} | Sort-Object number

Write-Host ""
Write-Host "C.A.T.E.R. user story issue sync complete." -ForegroundColor Green
Write-Host "Repository: $repoName"
Write-Host "Tracked user story issues: $($createdOrExisting.Count)"
Write-Host ""

$createdOrExisting | ForEach-Object {
    Write-Host ("#{0} {1} [{2}]" -f $_.number, $_.title, $_.state)
}