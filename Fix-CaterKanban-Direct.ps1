# ============================================================
# C.A.T.E.R. Direct Kanban Reorganization Script
#
# Run from the CATER repository root.
#
# This script:
# - Resolves the current GitHub repo from the folder
# - Uses the repo owner as the GitHub Project owner
# - Targets GitHub Project v2 number 13 directly
# - Creates missing labels
# - Creates missing milestones
# - Creates or updates the rolling gate blocker issue
# - Closes duplicate water dispenser issue #28 if it exists
# - Adds issues to Project #13
# - Sets Project Status values
#
# It does not:
# - Search for project titles
# - Guess alternate projects
# - Use gh issue view
# - Use gh label view
# - Use temporary JSON request files
# ============================================================

$ErrorActionPreference = "Stop"

$ProjectNumber = 13

$ExpectedStatuses = @(
    "User Stories",
    "Product Backlog",
    "Ice Box",
    "Ready",
    "In progress",
    "In review",
    "Done"
)

$Milestones = @(
    "Repository Foundation",
    "Hardware Prototype",
    "DAISY Firmware MVP",
    "Testing",
    "Public MVP Release"
)

$Labels = @(
    @{ name = "project-operations"; color = "5319e7"; description = "Project board, labels, milestones, and workflow setup" },
    @{ name = "priority-p0"; color = "b60205"; description = "Critical MVP foundation or active blocker" },
    @{ name = "priority-p1"; color = "d93f0b"; description = "Core DAISY firmware MVP" },
    @{ name = "priority-p2"; color = "fbca04"; description = "Sensor integration work" },
    @{ name = "priority-p3"; color = "1d76db"; description = "LCD and keypad user interface work" },
    @{ name = "priority-p4"; color = "0e8a16"; description = "Calibration, reliability testing, and safety validation" },
    @{ name = "priority-p5"; color = "5319e7"; description = "Documentation and MVP release preparation" },
    @{ name = "hardware"; color = "c5def5"; description = "Physical feeder body, hopper, gate, bowl, and enclosure work" },
    @{ name = "hardware-blocker"; color = "e11d21"; description = "Mechanical or physical build issue blocking firmware or testing" },
    @{ name = "firmware"; color = "0052cc"; description = "DAISY Arduino firmware work" },
    @{ name = "sensor"; color = "fbca04"; description = "Ultrasonic, PIR, and future sensing work" },
    @{ name = "ui"; color = "1d76db"; description = "LCD, keypad, and local feeder controls" },
    @{ name = "testing"; color = "0e8a16"; description = "Calibration, QA, safety, and validation work" },
    @{ name = "documentation"; color = "bfdadc"; description = "Build, wiring, firmware, and release documentation" },
    @{ name = "safety"; color = "d93f0b"; description = "Safety checks and pet-adjacent prototype risk control" },
    @{ name = "mvp"; color = "0e8a16"; description = "Required for the food-only MVP" },
    @{ name = "icebox"; color = "ededed"; description = "Valid future idea outside the current food-only MVP" }
)

$IssuePlan = @{
    3  = @{ status = "In progress";     labels = @("priority-p0", "hardware", "mvp"); milestone = "Hardware Prototype" }
    6  = @{ status = "Ready";           labels = @("priority-p0", "hardware", "safety", "mvp"); milestone = "Hardware Prototype" }

    7  = @{ status = "Product Backlog"; labels = @("priority-p1", "firmware", "safety", "mvp"); milestone = "DAISY Firmware MVP" }
    8  = @{ status = "Product Backlog"; labels = @("priority-p1", "firmware", "mvp"); milestone = "DAISY Firmware MVP" }
    9  = @{ status = "Product Backlog"; labels = @("priority-p1", "firmware", "mvp"); milestone = "DAISY Firmware MVP" }
    10 = @{ status = "Product Backlog"; labels = @("priority-p1", "firmware", "safety", "mvp"); milestone = "DAISY Firmware MVP" }

    11 = @{ status = "Product Backlog"; labels = @("priority-p2", "sensor", "safety", "mvp"); milestone = "DAISY Firmware MVP" }
    12 = @{ status = "Product Backlog"; labels = @("priority-p2", "sensor", "mvp"); milestone = "DAISY Firmware MVP" }

    13 = @{ status = "Product Backlog"; labels = @("priority-p3", "ui", "mvp"); milestone = "DAISY Firmware MVP" }
    14 = @{ status = "Product Backlog"; labels = @("priority-p3", "ui", "mvp"); milestone = "DAISY Firmware MVP" }

    15 = @{ status = "Product Backlog"; labels = @("priority-p4", "testing", "mvp"); milestone = "Testing" }
    16 = @{ status = "Product Backlog"; labels = @("priority-p4", "testing", "hardware", "mvp"); milestone = "Testing" }
    17 = @{ status = "Product Backlog"; labels = @("priority-p4", "testing", "safety", "mvp"); milestone = "Testing" }

    18 = @{ status = "Product Backlog"; labels = @("priority-p5", "documentation", "mvp"); milestone = "Public MVP Release" }
    19 = @{ status = "Product Backlog"; labels = @("priority-p5", "documentation", "hardware", "mvp"); milestone = "Public MVP Release" }
    20 = @{ status = "Product Backlog"; labels = @("priority-p5", "documentation", "firmware", "mvp"); milestone = "Public MVP Release" }

    21 = @{ status = "Done";            labels = @("project-operations"); milestone = "Repository Foundation" }

    22 = @{ status = "Product Backlog"; labels = @("priority-p5", "documentation", "testing", "mvp"); milestone = "Public MVP Release" }

    23 = @{ status = "Ice Box";         labels = @("icebox", "sensor"); milestone = $null }
    24 = @{ status = "Ice Box";         labels = @("icebox", "firmware"); milestone = $null }
    25 = @{ status = "Ice Box";         labels = @("icebox"); milestone = $null }
    26 = @{ status = "Ice Box";         labels = @("icebox", "sensor"); milestone = $null }
    27 = @{ status = "Ice Box";         labels = @("icebox", "safety"); milestone = $null }
}

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-Ok {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Skip {
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
        [string[]]$Arguments,

        [switch]$AllowFailure
    )

    $output = & gh @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    $text = ($output | Out-String).Trim()

    if ($exitCode -ne 0) {
        if ($AllowFailure) {
            return $null
        }

        throw "gh command failed: gh $($Arguments -join ' ')`n$text"
    }

    if ([string]::IsNullOrWhiteSpace($text)) {
        return $null
    }

    try {
        return $text | ConvertFrom-Json
    }
    catch {
        throw "Could not parse JSON from: gh $($Arguments -join ' ')`n$text"
    }
}

function Invoke-GhGraphQL {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Query,

        [Parameter(Mandatory = $false)]
        [hashtable]$Variables = @{}
    )

    $arguments = @("api", "graphql", "-f", "query=$Query")

    foreach ($key in $Variables.Keys) {
        $value = $Variables[$key]

        if ($null -eq $value) {
            continue
        }

        if ($value -is [int] -or $value -is [long] -or $value -is [bool]) {
            $arguments += @("-F", "$key=$value")
        }
        else {
            $arguments += @("-f", "$key=$value")
        }
    }

    $result = Invoke-GhJson -Arguments $arguments

    if ($null -ne $result.errors) {
        $errorText = $result.errors | ConvertTo-Json -Depth 20
        throw "GitHub GraphQL returned errors:`n$errorText"
    }

    return $result
}

function Resolve-Repository {
    $repoInfo = Invoke-GhJson -Arguments @("repo", "view", "--json", "nameWithOwner")
    $repoName = $repoInfo.nameWithOwner

    if ([string]::IsNullOrWhiteSpace($repoName)) {
        throw "Could not resolve GitHub repository. Run this script from the repo root."
    }

    $parts = $repoName.Split("/")
    if ($parts.Count -ne 2) {
        throw "Repository name must be in owner/name format. Got: $repoName"
    }

    return @{
        FullName = $repoName
        Owner = $parts[0]
        Name = $parts[1]
    }
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
        Write-Skip "Label exists: $Name"
        return
    }

    Invoke-GhJson -Arguments @(
        "api",
        "--method", "POST",
        "repos/$($script:Repo.Owner)/$($script:Repo.Name)/labels",
        "-f", "name=$Name",
        "-f", "color=$Color",
        "-f", "description=$Description"
    ) | Out-Null

    Write-Ok "Created label: $Name"
}

function Add-IssueLabels {
    param(
        [Parameter(Mandatory = $true)]
        [int]$IssueNumber,

        [Parameter(Mandatory = $true)]
        [string[]]$LabelsToAdd
    )

    foreach ($label in $LabelsToAdd) {
        Invoke-GhJson -Arguments @(
            "api",
            "--method", "POST",
            "repos/$($script:Repo.Owner)/$($script:Repo.Name)/issues/$IssueNumber/labels",
            "-f", "labels[]=$label"
        ) | Out-Null
    }
}

function Get-MilestoneNumber {
    param([string]$Title)

    $milestones = Invoke-GhJson -Arguments @(
        "api",
        "repos/$($script:Repo.Owner)/$($script:Repo.Name)/milestones?state=all&per_page=100"
    )

    $found = $milestones | Where-Object { $_.title -eq $Title } | Select-Object -First 1

    if ($found) {
        return [int]$found.number
    }

    return $null
}

function Ensure-Milestone {
    param([string]$Title)

    $existing = Get-MilestoneNumber -Title $Title

    if ($null -ne $existing) {
        Write-Skip "Milestone exists: $Title"
        return $existing
    }

    $created = Invoke-GhJson -Arguments @(
        "api",
        "--method", "POST",
        "repos/$($script:Repo.Owner)/$($script:Repo.Name)/milestones",
        "-f", "title=$Title",
        "-f", "state=open"
    )

    Write-Ok "Created milestone: $Title"
    return [int]$created.number
}

function Set-IssueMilestone {
    param(
        [Parameter(Mandatory = $true)]
        [int]$IssueNumber,

        [AllowNull()]
        [string]$MilestoneTitle
    )

    if ([string]::IsNullOrWhiteSpace($MilestoneTitle)) {
        Invoke-GhJson -Arguments @(
            "api",
            "--method", "PATCH",
            "repos/$($script:Repo.Owner)/$($script:Repo.Name)/issues/$IssueNumber",
            "-F", "milestone=null"
        ) | Out-Null

        return
    }

    $milestoneNumber = Get-MilestoneNumber -Title $MilestoneTitle

    if ($null -eq $milestoneNumber) {
        $milestoneNumber = Ensure-Milestone -Title $MilestoneTitle
    }

    Invoke-GhJson -Arguments @(
        "api",
        "--method", "PATCH",
        "repos/$($script:Repo.Owner)/$($script:Repo.Name)/issues/$IssueNumber",
        "-F", "milestone=$milestoneNumber"
    ) | Out-Null
}

function Get-Issue {
    param([int]$IssueNumber)

    return Invoke-GhJson -Arguments @(
        "api",
        "repos/$($script:Repo.Owner)/$($script:Repo.Name)/issues/$IssueNumber"
    ) -AllowFailure
}

function Find-IssueByTitle {
    param([string]$Title)

    $query = "repo:$($script:Repo.FullName) is:issue in:title `"$Title`""
    $encoded = [System.Uri]::EscapeDataString($query)

    $result = Invoke-GhJson -Arguments @(
        "api",
        "search/issues?q=$encoded&per_page=100"
    ) -AllowFailure

    if ($null -eq $result -or $null -eq $result.items) {
        return $null
    }

    return $result.items | Where-Object { $_.title -eq $Title } | Select-Object -First 1
}

function Ensure-RollingGateIssue {
    $title = "Fix rolling gate opposite-side alignment"

    $body = @"
## Epic
Epic 1: Cardboard Hardware Build

## User Story
As a **maker**,
I want the rolling gate halves to stay aligned and rotate together,
so that the feeder can open and close safely before servo and food testing continue.

## Current Problem
The rolling gate works from the servo side, but the opposite side is not fixed properly yet. Sometimes the cardboard gate halves close unevenly or collapse because only one side moves well.

## Notes
The gate halves may need to be stabilized, glued, locked, reinforced, or joined at their meeting point. The non-servo side may need a bearing surface, axle support, guide, or chamber reinforcement so the gate rotates instead of folding inward.

## Acceptance Criteria
- Servo side and opposite side rotate together.
- Gate halves do not fold inward.
- Gate does not scrape the chamber wall.
- Gate completes at least 20 manual open/close rotations.
- Gate completes at least 10 servo-assisted open/close rotations.
- Hopper stays above the intake without touching the rotating gate.
"@

    $existing = Find-IssueByTitle -Title $title

    if ($null -eq $existing) {
        $created = Invoke-GhJson -Arguments @(
            "api",
            "--method", "POST",
            "repos/$($script:Repo.Owner)/$($script:Repo.Name)/issues",
            "-f", "title=$title",
            "-f", "body=$body",
            "-f", "labels[]=priority-p0",
            "-f", "labels[]=hardware",
            "-f", "labels[]=hardware-blocker",
            "-f", "labels[]=mvp"
        )

        Write-Ok "Created rolling gate blocker: #$($created.number)"
        return [int]$created.number
    }

    if ($existing.state -eq "closed") {
        Invoke-GhJson -Arguments @(
            "api",
            "--method", "PATCH",
            "repos/$($script:Repo.Owner)/$($script:Repo.Name)/issues/$($existing.number)",
            "-f", "state=open"
        ) | Out-Null
    }

    Invoke-GhJson -Arguments @(
        "api",
        "--method", "PATCH",
        "repos/$($script:Repo.Owner)/$($script:Repo.Name)/issues/$($existing.number)",
        "-f", "body=$body"
    ) | Out-Null

    Add-IssueLabels -IssueNumber ([int]$existing.number) -LabelsToAdd @("priority-p0", "hardware", "hardware-blocker", "mvp")

    Write-Ok "Updated rolling gate blocker: #$($existing.number)"
    return [int]$existing.number
}

function Close-DuplicateWaterIssue {
    $issue = Get-Issue -IssueNumber 28

    if ($null -eq $issue) {
        Write-Skip "Issue #28 not found"
        return
    }

    if ($issue.state -ne "open") {
        Write-Skip "Issue #28 already closed"
        return
    }

    Invoke-GhJson -Arguments @(
        "api",
        "--method", "POST",
        "repos/$($script:Repo.Owner)/$($script:Repo.Name)/issues/28/comments",
        "-f", "body=Closing as duplicate of #27. Keeping #27 as the active Ice Box water dispenser story."
    ) | Out-Null

    Invoke-GhJson -Arguments @(
        "api",
        "--method", "PATCH",
        "repos/$($script:Repo.Owner)/$($script:Repo.Name)/issues/28",
        "-f", "state=closed",
        "-f", "state_reason=not_planned"
    ) | Out-Null

    Write-Ok "Closed duplicate issue #28"
}

function Get-ProjectData {
    $query = @'
query($login: String!, $number: Int!) {
  user(login: $login) {
    projectV2(number: $number) {
      id
      title
      number
      fields(first: 50) {
        nodes {
          ... on ProjectV2Field {
            id
            name
          }
          ... on ProjectV2SingleSelectField {
            id
            name
            options {
              id
              name
            }
          }
        }
      }
      items(first: 100) {
        nodes {
          id
          content {
            ... on Issue {
              id
              number
              title
            }
          }
        }
      }
    }
  }
}
'@

    $result = Invoke-GhGraphQL -Query $query -Variables @{
        login = $script:Repo.Owner
        number = [int]$ProjectNumber
    }

    $project = $result.data.user.projectV2

    if ($null -eq $project) {
        throw "Project #$ProjectNumber was not found under owner '$($script:Repo.Owner)'."
    }

    return $project
}

function Get-StatusField {
    param([object]$Project)

    $field = $Project.fields.nodes | Where-Object { $_.name -eq "Status" } | Select-Object -First 1

    if ($null -eq $field) {
        throw "Project #$ProjectNumber does not have a Status field."
    }

    if ($null -eq $field.options) {
        throw "Project #$ProjectNumber Status field has no options."
    }

    return $field
}

function Get-StatusOptionMap {
    param([object]$StatusField)

    $map = @{}

    foreach ($option in $StatusField.options) {
        $map[$option.name] = $option.id
    }

    foreach ($required in $ExpectedStatuses) {
        if (-not $map.ContainsKey($required)) {
            $available = ($map.Keys | Sort-Object) -join ", "
            throw "Missing Project Status option '$required'. Available options: $available"
        }
    }

    return $map
}

function Get-IssueNodeId {
    param([int]$IssueNumber)

    $query = @'
query($owner: String!, $repo: String!, $number: Int!) {
  repository(owner: $owner, name: $repo) {
    issue(number: $number) {
      id
      number
      title
    }
  }
}
'@

    $result = Invoke-GhGraphQL -Query $query -Variables @{
        owner = $script:Repo.Owner
        repo = $script:Repo.Name
        number = [int]$IssueNumber
    }

    if ($null -eq $result.data.repository.issue) {
        throw "Issue #$IssueNumber not found in $($script:Repo.FullName)."
    }

    return $result.data.repository.issue.id
}

function Ensure-ProjectItem {
    param(
        [object]$Project,
        [int]$IssueNumber
    )

    $existingItem = $Project.items.nodes |
        Where-Object { $null -ne $_.content -and $_.content.number -eq $IssueNumber } |
        Select-Object -First 1

    if ($existingItem) {
        return $existingItem.id
    }

    $issueNodeId = Get-IssueNodeId -IssueNumber $IssueNumber

    $mutation = @'
mutation($projectId: ID!, $contentId: ID!) {
  addProjectV2ItemById(input: { projectId: $projectId, contentId: $contentId }) {
    item {
      id
    }
  }
}
'@

    $result = Invoke-GhGraphQL -Query $mutation -Variables @{
        projectId = $Project.id
        contentId = $issueNodeId
    }

    return $result.data.addProjectV2ItemById.item.id
}

function Set-ProjectItemStatus {
    param(
        [string]$ProjectId,
        [string]$ItemId,
        [string]$StatusFieldId,
        [string]$OptionId
    )

    $mutation = @'
mutation($projectId: ID!, $itemId: ID!, $fieldId: ID!, $optionId: String!) {
  updateProjectV2ItemFieldValue(
    input: {
      projectId: $projectId
      itemId: $itemId
      fieldId: $fieldId
      value: { singleSelectOptionId: $optionId }
    }
  ) {
    projectV2Item {
      id
    }
  }
}
'@

    Invoke-GhGraphQL -Query $mutation -Variables @{
        projectId = $ProjectId
        itemId = $ItemId
        fieldId = $StatusFieldId
        optionId = $OptionId
    } | Out-Null
}

function Apply-IssuePlan {
    param(
        [hashtable]$Plan,
        [object]$Project,
        [object]$StatusField,
        [hashtable]$StatusOptions
    )

    foreach ($issueKey in ($Plan.Keys | Sort-Object)) {
        $issueNumber = [int]$issueKey
        $issue = Get-Issue -IssueNumber $issueNumber

        if ($null -eq $issue) {
            Write-Skip "Issue #$issueNumber missing"
            continue
        }

        $entry = $Plan[$issueKey]

        Add-IssueLabels -IssueNumber $issueNumber -LabelsToAdd $entry.labels
        Set-IssueMilestone -IssueNumber $issueNumber -MilestoneTitle $entry.milestone

        $freshProject = Get-ProjectData
        $itemId = Ensure-ProjectItem -Project $freshProject -IssueNumber $issueNumber

        Set-ProjectItemStatus `
            -ProjectId $freshProject.id `
            -ItemId $itemId `
            -StatusFieldId $StatusField.id `
            -OptionId $StatusOptions[$entry.status]

        Write-Ok "Issue #$issueNumber moved to $($entry.status)"
    }
}

Write-Step "Checking required tools"
Require-Command "gh"
Require-Command "git"
Write-Ok "Required tools found"

Write-Step "Checking GitHub authentication"
& gh auth status | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "GitHub CLI is not authenticated. Run gh auth login first."
}
Write-Ok "GitHub CLI is authenticated"

Write-Step "Resolving repository"
$script:Repo = Resolve-Repository
Write-Ok "Repository: $($script:Repo.FullName)"
Write-Ok "Project target: $($script:Repo.Owner) Project #$ProjectNumber"

Write-Step "Reading existing labels"
$existingLabels = Invoke-GhJson -Arguments @("label", "list", "--limit", "1000", "--json", "name")

Write-Step "Creating missing labels"
foreach ($label in $Labels) {
    Ensure-Label `
        -Name $label.name `
        -Color $label.color `
        -Description $label.description `
        -ExistingLabels $existingLabels
}

Write-Step "Creating milestones"
foreach ($milestone in $Milestones) {
    Ensure-Milestone -Title $milestone | Out-Null
}

Write-Step "Creating or updating rolling gate blocker"
$rollingGateIssueNumber = Ensure-RollingGateIssue

$IssuePlan[$rollingGateIssueNumber] = @{
    status = "In progress"
    labels = @("priority-p0", "hardware", "hardware-blocker", "mvp")
    milestone = "Hardware Prototype"
}

Write-Step "Closing duplicate water issue if needed"
Close-DuplicateWaterIssue

Write-Step "Loading GitHub Project #$ProjectNumber"
$project = Get-ProjectData
$statusField = Get-StatusField -Project $project
$statusOptions = Get-StatusOptionMap -StatusField $statusField
Write-Ok "Loaded Project #$($project.number): $($project.title)"

Write-Step "Applying issue statuses"
Apply-IssuePlan `
    -Plan $IssuePlan `
    -Project $project `
    -StatusField $statusField `
    -StatusOptions $statusOptions

Write-Host ""
Write-Host "C.A.T.E.R. Kanban board has been reorganized." -ForegroundColor Green
Write-Host "Active work is focused on Hardware Prototype Integration and Mechanical Fit-Test."
Write-Host "Current active blocker: Fix rolling gate opposite-side alignment."
Write-Host "Do not begin main DAISY firmware until rolling gate, hopper, chute, servo mount, keypad, LCD, Arduino bay, and wiring path are stable."
