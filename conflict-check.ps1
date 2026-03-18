# conflict-check.ps1
# Antigravity Gemini 3 Flash Ultimate Tuner - 冲突检测脚本
# 用于检测 GEMINI.md 是否被 Gemini CLI 或其他工具覆盖
# 使用方式：右键 → 用 PowerShell 运行，或在 PS 终端执行 .\conflict-check.ps1

Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host " Antigravity Tuner - 冲突检测报告" -ForegroundColor Cyan
Write-Host " 时间：$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host ""

$projectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$agentGemini = Join-Path $projectDir ".agent\GEMINI.md"
$globalGemini = Join-Path $env:USERPROFILE ".gemini\GEMINI.md"
$globalAntigravityGemini = Join-Path $env:USERPROFILE ".gemini\antigravity\GEMINI.md"

# ── 检测项目级 Rules ──────────────────────────────────────────
Write-Host "[1] 项目级 GEMINI.md 检测..." -ForegroundColor White
if (Test-Path $agentGemini) {
    $content = Get-Content $agentGemini -Raw
    if ($content -match "Ultimate Gemini 3 Flash Rules") {
        Write-Host "    ✅ 项目级 GEMINI.md 存在，内容为本工具 Rules（最高优先级）" -ForegroundColor Green
    } else {
        Write-Host "    ⚠️  项目级 GEMINI.md 存在，但内容不是本工具 Rules，可能被覆盖" -ForegroundColor Yellow
        Write-Host "    → 建议：重新运行 setup.bat 以恢复" -ForegroundColor Yellow
    }
} else {
    Write-Host "    ❌ 项目级 GEMINI.md 不存在！" -ForegroundColor Red
    Write-Host "    → 请运行 setup.bat 进行安装" -ForegroundColor Red
}

Write-Host ""

# ── 检测全局 Rules ────────────────────────────────────────────
Write-Host "[2] 全局 GEMINI.md 检测 (~/.gemini/GEMINI.md)..." -ForegroundColor White
if (Test-Path $globalGemini) {
    $content = Get-Content $globalGemini -Raw
    if ($content -match "Ultimate Gemini 3 Flash Rules") {
        Write-Host "    ✅ 全局 GEMINI.md 也是本工具 Rules" -ForegroundColor Green
    } else {
        Write-Host "    ⚠️  全局 GEMINI.md 存在，但内容不是本工具 Rules" -ForegroundColor Yellow
        Write-Host "    → 可能被 Gemini CLI 覆盖，项目级 Rules 仍优先生效" -ForegroundColor Yellow
    }
} else {
    Write-Host "    ℹ️  全局 GEMINI.md 不存在（正常，使用项目级即可）" -ForegroundColor Gray
}

Write-Host ""

# ── 检测 Skills 完整性 ────────────────────────────────────────
Write-Host "[3] Skills 完整性检测..." -ForegroundColor White
$skillsDir = Join-Path $projectDir ".agent\skills"
$requiredSkills = @(
    "Best-Practice-Researcher",
    "Architect-Dialogue",
    "Code-Reviewer-Debugger",
    "Tester",
    "Tuner-Update"
)

$allOk = $true
foreach ($skill in $requiredSkills) {
    $skillPath = Join-Path $skillsDir "$skill\SKILL.md"
    if (Test-Path $skillPath) {
        Write-Host "    ✅ $skill" -ForegroundColor Green
    } else {
        Write-Host "    ❌ $skill 缺失！" -ForegroundColor Red
        $allOk = $false
    }
}

Write-Host ""

# ── 总结 ──────────────────────────────────────────────────────
Write-Host "=======================================================" -ForegroundColor Cyan
if ($allOk -and (Test-Path $agentGemini)) {
    Write-Host " ✅ 整体状态：正常，调教配置完整有效" -ForegroundColor Green
} else {
    Write-Host " ⚠️  整体状态：存在问题，请根据上述提示修复" -ForegroundColor Yellow
    Write-Host " → 解决方案：重新运行 setup.bat" -ForegroundColor Yellow
}
Write-Host "=======================================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
