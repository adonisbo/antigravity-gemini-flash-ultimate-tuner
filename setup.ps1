# =============================================================
#  Antigravity Ultimate Tuner - Setup Script
#  Version: 2026.03.20
#  Compatible: PowerShell 5.1+ (Windows default)
#  Fixed: UTF-8 BOM encoding, removed ?. operator, all-English
# =============================================================

param(
    [switch]$Silent,
    [switch]$GlobalOnly,
    [switch]$Check,
    [switch]$SwitchMode
)

$VERSION = "2026.03.20"

function Write-Ok($msg)   { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Write-Err($msg)  { Write-Host "  [!!] $msg" -ForegroundColor Red }
function Write-Warn($msg) { Write-Host "  [??] $msg" -ForegroundColor Yellow }
function Write-Info($msg) { Write-Host "  [ii] $msg" -ForegroundColor Cyan }
function Write-Sep()      { Write-Host ("-" * 62) -ForegroundColor DarkGray }

# Safe Resolve-Path for PS5.1 (avoids ?. operator which requires PS7+)
function Safe-ResolvePath($p) {
    if (Test-Path $p) {
        return (Resolve-Path $p).Path
    }
    return $null
}

# ── Model Mode Switch ─────────────────────────────────────────
function Invoke-ModelSwitch {
    param([string]$GeminiPath)

    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Magenta
    Write-Host "  Model Mode Switch - Adjust Rules for your current model" -ForegroundColor Magenta
    Write-Host "==========================================================" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "  Rules file: $GeminiPath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Select your current model in Antigravity:" -ForegroundColor White
    Write-Host ""
    Write-Host "  [1] Gemini 3 Flash / GPT-OSS 120B  -> LITE MODE" -ForegroundColor Green
    Write-Host "      Force Research+Reflection, maximize weak model quality"
    Write-Host ""
    Write-Host "  [2] Claude Sonnet 4.6              -> STANDARD MODE" -ForegroundColor Yellow
    Write-Host "      Advisory constraints, balance efficiency and quality"
    Write-Host ""
    Write-Host "  [3] Gemini 3.1 Pro / Claude Opus   -> PRO MODE" -ForegroundColor Cyan
    Write-Host "      Minimal rules, no interference with strong models"
    Write-Host ""
    Write-Host "  [0] Cancel"
    Write-Host ""

    $choice = Read-Host "  Enter option [0/1/2/3]"

    if ($choice -eq '0' -or $choice -eq '') {
        Write-Info "Cancelled, Rules file unchanged"
        return
    }

    if (-not (Test-Path $GeminiPath)) {
        Write-Err "Rules file not found: $GeminiPath"
        Write-Info "Please run setup.bat first to install"
        return
    }

    if ($choice -notin @('1','2','3')) {
        Write-Err "Invalid option: $choice"
        return
    }

    $content = [IO.File]::ReadAllText($GeminiPath, [Text.Encoding]::UTF8)

    if ((-not ($content -match '\[LITE MODE\]')) -or (-not ($content -match '\[PRO MODE\]'))) {
        Write-Warn "Rules file is not latest version (missing mode blocks)"
        Write-Info "Please re-run setup.bat to update first"
        return
    }

    $modeNames = @{ '1' = 'LITE MODE'; '2' = 'STANDARD MODE'; '3' = 'PRO MODE' }
    $modeName = $modeNames[$choice]

    $backupPath = $GeminiPath + ".before_switch.bak"
    [IO.File]::WriteAllText($backupPath, $content, [Text.Encoding]::UTF8)
    Write-Info "Backed up current Rules -> $backupPath"

    $lines = $content -split "`n"
    $result = New-Object System.Collections.Generic.List[string]
    $zone = 'NONE'

    foreach ($line in $lines) {
        $t = $line.TrimEnd()

        if ($t -match '\[LITE MODE\]') {
            $zone = 'LITE'
            $result.Add($line)
            continue
        }
        if ($t -match '\[STANDARD MODE\]') {
            $zone = 'STANDARD'
            $result.Add($line)
            continue
        }
        if ($t -match '\[PRO MODE\]') {
            $zone = 'PRO'
            $result.Add($line)
            continue
        }
        if ($t -match '\[Common Rules\]') {
            $zone = 'COMMON'
            $result.Add($line)
            continue
        }
        if (($t -match '^# [━【]') -or ($t -eq '')) {
            $result.Add($line)
            continue
        }

        if (($zone -eq 'LITE') -or ($zone -eq 'STANDARD') -or ($zone -eq 'PRO')) {
            $isTarget = (($choice -eq '1') -and ($zone -eq 'LITE')) -or
                        (($choice -eq '2') -and ($zone -eq 'STANDARD')) -or
                        (($choice -eq '3') -and ($zone -eq 'PRO'))
            if ($isTarget) {
                if ($t -match '^# (.+)$') {
                    $result.Add($Matches[1])
                    continue
                }
            } else {
                if (-not ($t -match '^#')) {
                    $result.Add("# $t")
                    continue
                }
            }
        }
        $result.Add($line)
    }

    [IO.File]::WriteAllText($GeminiPath, ($result -join "`n"), [Text.Encoding]::UTF8)

    Write-Host ""
    Write-Sep
    Write-Host "  Switched to: $modeName" -ForegroundColor Green
    Write-Sep
    Write-Host "  Restart Antigravity Agent Manager for changes to take effect." -ForegroundColor Yellow
    Write-Host ""
}

# ── Check-only mode ───────────────────────────────────────────
if ($Check) {
    $cs = Join-Path $PSScriptRoot "tools\tuner_check.ps1"
    if (Test-Path $cs) {
        & $cs
    } else {
        Write-Err "Check script not found: $cs"
    }
    exit 0
}

# ── SwitchMode-only mode ──────────────────────────────────────
if ($SwitchMode) {
    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "  Antigravity Ultimate Tuner - Model Mode Switch" -ForegroundColor Cyan
    Write-Host "==========================================================" -ForegroundColor Cyan
    $globalGeminiSwitch = Join-Path $env:USERPROFILE ".gemini\GEMINI.md"
    Invoke-ModelSwitch -GeminiPath $globalGeminiSwitch
    if (-not $Silent) {
        Write-Host "Press any key to close..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    exit 0
}

# ── Banner ────────────────────────────────────────────────────
Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Antigravity Ultimate Tuner  v$VERSION" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$PROJECT_DIR    = $PSScriptRoot
$GLOBAL_GEM_DIR = Join-Path $env:USERPROFILE ".gemini"
$GLOBAL_AG_DIR  = Join-Path $env:USERPROFILE ".gemini\antigravity"
$BACKUP_DIR     = Join-Path $PROJECT_DIR ".tuner-backup"
$SRC_SKILLS     = Join-Path $PROJECT_DIR ".agent\skills"
$SRC_GEMINI     = Join-Path $PROJECT_DIR "GEMINI.md"

# ── Validate source files ─────────────────────────────────────
Write-Host "[Prep] Validating source files..." -ForegroundColor White
if (-not (Test-Path $SRC_GEMINI)) {
    Write-Err "GEMINI.md not found. Run from repo root directory."
    exit 1
}
if (-not (Test-Path $SRC_SKILLS)) {
    Write-Err ".agent\skills not found. Run from repo root directory."
    exit 1
}
$skillCount = (Get-ChildItem $SRC_SKILLS -Directory).Count
Write-Ok "Source ready: GEMINI.md + $skillCount Skills"
Write-Host ""

# ── Path detection ────────────────────────────────────────────
Write-Host "[Path] Detecting Antigravity directory format..." -ForegroundColor White
$AGENT_DIR = $null
$AGENT_FORMAT = $null

if (Test-Path (Join-Path $PROJECT_DIR ".agents")) {
    $AGENT_DIR = Join-Path $PROJECT_DIR ".agents"
    $AGENT_FORMAT = ".agents"
    Write-Ok "Detected .agents (new standard)"
} elseif (Test-Path (Join-Path $PROJECT_DIR ".agent")) {
    $AGENT_DIR = Join-Path $PROJECT_DIR ".agent"
    $AGENT_FORMAT = ".agent"
    Write-Ok "Detected .agent (compatible)"
} else {
    Write-Warn "No .agent or .agents directory found"
    if ($Silent) {
        $AGENT_DIR = Join-Path $PROJECT_DIR ".agent"
        $AGENT_FORMAT = ".agent"
        Write-Info "Silent mode: using default .agent"
    } else {
        Write-Host "  [1] .agents (recommended)  [2] .agent (compatible)"
        $fc = Read-Host "  Choose [1/2]"
        if ($fc -eq "2") {
            $AGENT_DIR = Join-Path $PROJECT_DIR ".agent"
            $AGENT_FORMAT = ".agent"
        } else {
            $AGENT_DIR = Join-Path $PROJECT_DIR ".agents"
            $AGENT_FORMAT = ".agents"
        }
        Write-Ok "Selected: $AGENT_FORMAT"
    }
}
Write-Host ""

# ── Conflict check ────────────────────────────────────────────
Write-Host "[Conflict] Checking GEMINI.md..." -ForegroundColor White
$globalGemini = Join-Path $env:USERPROFILE ".gemini\GEMINI.md"
if (Test-Path $globalGemini) {
    $ec = Get-Content $globalGemini -Raw -Encoding UTF8
    if (($ec -match "Antigravity.*Tuner") -or ($ec -match "Ultimate.*Tuner")) {
        Write-Ok "Global GEMINI.md is already this tool's Rules"
    } else {
        Write-Warn "Global GEMINI.md exists (will be overwritten)"
    }
} else {
    Write-Info "Global GEMINI.md not found, no conflict"
}
Write-Host ""

# ══ Step 1: Create directories ════════════════════════════════
Write-Host "[1/4] Creating directories..." -ForegroundColor White
New-Item -ItemType Directory -Force -Path $AGENT_DIR | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $AGENT_DIR "skills") | Out-Null
Write-Ok "Directories ready: $AGENT_DIR"
Write-Host ""

# ══ Step 2: Deploy GEMINI.md ══════════════════════════════════
Write-Host "[2/4] Deploying Rules (GEMINI.md)..." -ForegroundColor White
$dstGemini = Join-Path $AGENT_DIR "GEMINI.md"
if (Test-Path $dstGemini) {
    New-Item -ItemType Directory -Force -Path $BACKUP_DIR | Out-Null
    Copy-Item $dstGemini (Join-Path $BACKUP_DIR "GEMINI.md.bak") -Force
    Write-Info "Original GEMINI.md backed up -> .tuner-backup\"
}
Copy-Item $SRC_GEMINI $dstGemini -Force
Write-Ok "GEMINI.md deployed -> $dstGemini"
Write-Host ""

# ══ Step 3: Deploy Skills ═════════════════════════════════════
Write-Host "[3/4] Deploying Skills..." -ForegroundColor White
$dstSkills = Join-Path $AGENT_DIR "skills"

$srcR = Safe-ResolvePath $SRC_SKILLS
$dstR = Safe-ResolvePath $dstSkills

if (($srcR -ne $null) -and ($dstR -ne $null) -and ($srcR.TrimEnd('\') -eq $dstR.TrimEnd('\'))) {
    Write-Info "Source == Destination, skipping local copy (repo files used directly)"
    $skills = Get-ChildItem $SRC_SKILLS -Directory
    foreach ($sk in $skills) {
        Write-Ok "$($sk.Name) (already in place)"
    }
    $successCount = $skills.Count
} else {
    New-Item -ItemType Directory -Force -Path $dstSkills | Out-Null
    $skills = Get-ChildItem $SRC_SKILLS -Directory
    $successCount = 0
    foreach ($skill in $skills) {
        $sf = Join-Path $skill.FullName "SKILL.md"
        if (Test-Path $sf) {
            $dd = Join-Path $dstSkills $skill.Name
            New-Item -ItemType Directory -Force -Path $dd | Out-Null
            Copy-Item $sf (Join-Path $dd "SKILL.md") -Force
            Write-Ok $skill.Name
            $successCount++
        } else {
            Write-Warn "$($skill.Name) - SKILL.md missing, skipped"
        }
    }
}
Write-Host "  Total deployed: $successCount Skills" -ForegroundColor Gray
Write-Host ""

# ══ Step 4: Global install ════════════════════════════════════
Write-Host "[4/4] Global install..." -ForegroundColor White
$doGlobal = $false
if ($Silent -or $GlobalOnly) {
    $doGlobal = $true
} else {
    $ans = Read-Host "  Install to global directory (shared across all projects)? [Y/N]"
    $doGlobal = ($ans -match '^[Yy]')
}

if ($doGlobal) {
    New-Item -ItemType Directory -Force -Path $GLOBAL_GEM_DIR | Out-Null
    if (Test-Path $globalGemini) {
        New-Item -ItemType Directory -Force -Path $BACKUP_DIR | Out-Null
        Copy-Item $globalGemini (Join-Path $BACKUP_DIR "GLOBAL_GEMINI.md.bak") -Force
        Write-Info "Original global GEMINI.md backed up"
    }
    Copy-Item $SRC_GEMINI $globalGemini -Force
    Write-Ok "Global GEMINI.md -> $globalGemini"

    $globalSkillsDir = Join-Path $GLOBAL_AG_DIR "skills"
    New-Item -ItemType Directory -Force -Path $globalSkillsDir | Out-Null
    foreach ($skill in $skills) {
        $sf = Join-Path $skill.FullName "SKILL.md"
        if (Test-Path $sf) {
            $dg = Join-Path $globalSkillsDir $skill.Name
            New-Item -ItemType Directory -Force -Path $dg | Out-Null
            Copy-Item $sf (Join-Path $dg "SKILL.md") -Force
            Write-Ok "Global: $($skill.Name)"
        }
    }
    Write-Ok "Global install complete -> $globalSkillsDir"
} else {
    Write-Info "Skipped global install (project-level $AGENT_FORMAT only)"
}
Write-Host ""

# ══ Install complete ══════════════════════════════════════════
Write-Sep
Write-Host " Install Complete!" -ForegroundColor Green
Write-Sep
Write-Host " Project Rules  -> $dstGemini"
Write-Host " Project Skills -> $dstSkills"
if ($doGlobal) {
    Write-Host " Global GEMINI  -> $globalGemini"
    Write-Host " Global Skills  -> $(Join-Path $GLOBAL_AG_DIR 'skills')"
}
Write-Host ""

# ══ Post-install menu ═════════════════════════════════════════
if (-not $Silent) {
    $menuExit = $false
    while (-not $menuExit) {
        Write-Host ""
        Write-Host "==========================================================" -ForegroundColor DarkCyan
        Write-Host "  Post-Install Menu" -ForegroundColor DarkCyan
        Write-Host "==========================================================" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "  [1] Switch Model Mode  (Flash->LITE | Sonnet->STANDARD | Pro/Opus->PRO)" -ForegroundColor Green
        Write-Host "  [2] Run Deploy Check   (verify all files, save report to Desktop)" -ForegroundColor Yellow
        Write-Host "  [3] Run Conflict Check (check if GEMINI.md was overwritten)" -ForegroundColor Cyan
        Write-Host "  [0] Exit"
        Write-Host ""

        $mc = Read-Host "  Enter option [0/1/2/3]"

        if ($mc -eq '1') {
            $gt = if ($doGlobal) { $globalGemini } else { $dstGemini }
            Invoke-ModelSwitch -GeminiPath $gt
        } elseif ($mc -eq '2') {
            $cs = Join-Path $PSScriptRoot "tools\tuner_check.ps1"
            if (Test-Path $cs) {
                Write-Info "Running deploy check..."
                & $cs
            } else {
                Write-Err "Check script not found: $cs"
            }
        } elseif ($mc -eq '3') {
            $cf = Join-Path $PSScriptRoot "conflict-check.ps1"
            if (Test-Path $cf) {
                Write-Info "Running conflict check..."
                & $cf
            } else {
                Write-Err "Conflict check script not found: $cf"
            }
        } elseif ($mc -eq '0') {
            $menuExit = $true
        } else {
            Write-Warn "Invalid option, please enter 0/1/2/3"
        }
    }
}

Write-Host ""
Write-Sep
Write-Host " Next: Restart Antigravity Agent Manager, then type: check tuner status" -ForegroundColor White
Write-Host " Switch mode anytime: double-click tools\switch_mode.bat" -ForegroundColor DarkCyan
Write-Sep
Write-Host ""

if (-not $Silent) {
    Write-Host "Press any key to close..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
