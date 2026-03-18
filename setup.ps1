# =============================================================
#  Antigravity Gemini 3 Flash Ultimate Tuner - 安装脚本
#  Version: 2026.03.18 - v2 (PowerShell 重写版)
#  修复：乱码、xcopy循环复制、路径识别、全局Skills路径
# =============================================================

param(
    [switch]$Silent,      # 静默安装（跳过交互）
    [switch]$GlobalOnly,  # 仅全局安装
    [switch]$Check        # 仅运行检测（不安装）
)

$VERSION = "2026.03.18"
$REPO_NAME = "antigravity-gemini-flash-ultimate-tuner"

# ── 颜色输出辅助 ──────────────────────────────────────────────
function Write-Ok($msg)   { Write-Host "  [✅] $msg" -ForegroundColor Green }
function Write-Err($msg)  { Write-Host "  [❌] $msg" -ForegroundColor Red }
function Write-Warn($msg) { Write-Host "  [⚠️ ] $msg" -ForegroundColor Yellow }
function Write-Info($msg) { Write-Host "  [ℹ️ ] $msg" -ForegroundColor Cyan }
function Write-Sep()      { Write-Host ("─" * 60) -ForegroundColor DarkGray }

# ── 仅检测模式：跳转到检测脚本 ──────────────────────────────
if ($Check) {
    $checkScript = Join-Path $PSScriptRoot "tools\tuner_check.ps1"
    if (Test-Path $checkScript) {
        & $checkScript
    } else {
        Write-Err "检测脚本不存在：$checkScript"
    }
    exit 0
}

# ── Banner ────────────────────────────────────────────────────
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Antigravity Gemini 3 Flash Ultimate Tuner              ║" -ForegroundColor Cyan
Write-Host "║   Version: $VERSION - Ultimate Edition                 ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$PROJECT_DIR = $PSScriptRoot
$GLOBAL_GEMINI_DIR = Join-Path $env:USERPROFILE ".gemini"
$GLOBAL_AG_DIR = Join-Path $env:USERPROFILE ".gemini\antigravity"
$BACKUP_DIR = Join-Path $PROJECT_DIR ".tuner-backup"
$SRC_SKILLS = Join-Path $PROJECT_DIR ".agent\skills"
$SRC_GEMINI = Join-Path $PROJECT_DIR "GEMINI.md"

# ── 验证源文件 ────────────────────────────────────────────────
Write-Host "[准备] 验证安装源..." -ForegroundColor White
if (-not (Test-Path $SRC_GEMINI)) {
    Write-Err "找不到 GEMINI.md，请确保从仓库根目录运行此脚本"
    Write-Info "当前目录：$PROJECT_DIR"
    exit 1
}
if (-not (Test-Path $SRC_SKILLS)) {
    Write-Err "找不到 .agent\skills 目录，请确保从仓库根目录运行此脚本"
    exit 1
}
$skillCount = (Get-ChildItem $SRC_SKILLS -Directory).Count
Write-Ok "源文件就绪：GEMINI.md + $skillCount 个 Skills"
Write-Host ""

# ── 路径检测：.agent 还是 .agents ────────────────────────────
Write-Host "[路径] 自动识别 Antigravity 目录格式..." -ForegroundColor White
$AGENT_DIR = $null
$AGENT_FORMAT = $null

if (Test-Path (Join-Path $PROJECT_DIR ".agents")) {
    $AGENT_DIR = Join-Path $PROJECT_DIR ".agents"
    $AGENT_FORMAT = ".agents"
    Write-Ok "检测到 .agents 目录（官方新标准）"
} elseif (Test-Path (Join-Path $PROJECT_DIR ".agent")) {
    $AGENT_DIR = Join-Path $PROJECT_DIR ".agent"
    $AGENT_FORMAT = ".agent"
    Write-Ok "检测到 .agent 目录（兼容格式）"
} else {
    Write-Warn "未检测到现有 .agent 或 .agents 目录"
    if ($Silent) {
        $AGENT_DIR = Join-Path $PROJECT_DIR ".agent"
        $AGENT_FORMAT = ".agent"
        Write-Info "静默模式：使用默认格式 .agent"
    } else {
        Write-Host ""
        Write-Host "  请选择要使用的格式：" -ForegroundColor White
        Write-Host "    [1] .agents  （推荐，Antigravity 官方新标准 2026.01+）"
        Write-Host "    [2] .agent   （兼容，适用于旧版 Antigravity）"
        Write-Host ""
        $choice = Read-Host "  请输入选项 [1/2]"
        if ($choice -eq "2") {
            $AGENT_DIR = Join-Path $PROJECT_DIR ".agent"
            $AGENT_FORMAT = ".agent"
        } else {
            $AGENT_DIR = Join-Path $PROJECT_DIR ".agents"
            $AGENT_FORMAT = ".agents"
        }
        Write-Ok "已选择：$AGENT_FORMAT 格式"
    }
}
Write-Host ""

# ── 冲突检测 ──────────────────────────────────────────────────
Write-Host "[冲突] 检查 GEMINI.md 冲突..." -ForegroundColor White
$globalGemini = Join-Path $env:USERPROFILE ".gemini\GEMINI.md"
if (Test-Path $globalGemini) {
    $existingContent = Get-Content $globalGemini -Raw -Encoding UTF8 2>$null
    if ($existingContent -match "Ultimate Gemini 3 Flash Rules") {
        Write-Ok "全局 GEMINI.md 已是本工具 Rules，无冲突"
    } else {
        Write-Warn "全局 GEMINI.md 已存在（可能被其他工具写入），将在安装时覆盖"
    }
} else {
    Write-Info "全局 GEMINI.md 不存在，无冲突"
}
Write-Host ""

# ══════════════════════════════════════════════════════════════
# 步骤 1：创建目录结构
# ══════════════════════════════════════════════════════════════
Write-Host "[1/4] 创建目录结构..." -ForegroundColor White
New-Item -ItemType Directory -Force -Path $AGENT_DIR | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $AGENT_DIR "skills") | Out-Null
Write-Ok "目录就绪：$AGENT_DIR"
Write-Host ""

# ══════════════════════════════════════════════════════════════
# 步骤 2：部署 GEMINI.md
# ══════════════════════════════════════════════════════════════
Write-Host "[2/4] 部署 Rules (GEMINI.md)..." -ForegroundColor White
$dstGemini = Join-Path $AGENT_DIR "GEMINI.md"
if (Test-Path $dstGemini) {
    New-Item -ItemType Directory -Force -Path $BACKUP_DIR | Out-Null
    Copy-Item $dstGemini (Join-Path $BACKUP_DIR "GEMINI.md.bak") -Force
    Write-Info "原 GEMINI.md 已备份 → .tuner-backup\"
}
Copy-Item $SRC_GEMINI $dstGemini -Force
Write-Ok "GEMINI.md 已部署 → $dstGemini"
Write-Host ""

# ══════════════════════════════════════════════════════════════
# 步骤 3：部署 Skills（使用 robocopy 替代 xcopy，避免循环复制）
# ══════════════════════════════════════════════════════════════
Write-Host "[3/4] 部署 Skills..." -ForegroundColor White
$dstSkills = Join-Path $AGENT_DIR "skills"

# 使用 PowerShell Copy-Item（完全避免 xcopy 循环复制问题）
$skills = Get-ChildItem $SRC_SKILLS -Directory
$successCount = 0
foreach ($skill in $skills) {
    $dstSkillDir = Join-Path $dstSkills $skill.Name
    New-Item -ItemType Directory -Force -Path $dstSkillDir | Out-Null
    $skillFile = Join-Path $skill.FullName "SKILL.md"
    if (Test-Path $skillFile) {
        Copy-Item $skillFile (Join-Path $dstSkillDir "SKILL.md") -Force
        Write-Ok $skill.Name
        $successCount++
    } else {
        Write-Warn "$($skill.Name) - 找不到 SKILL.md，跳过"
    }
}
Write-Host "  共部署 $successCount 个 Skills" -ForegroundColor Gray
Write-Host ""

# ══════════════════════════════════════════════════════════════
# 步骤 4：全局安装（写入 ~/.gemini/GEMINI.md + 全局 skills 路径）
# ══════════════════════════════════════════════════════════════
Write-Host "[4/4] 全局安装..." -ForegroundColor White

$doGlobal = $false
if ($Silent -or $GlobalOnly) {
    $doGlobal = $true
} else {
    $ans = Read-Host "  是否同时安装到全局目录（所有 Antigravity 项目共享）？[Y/N]"
    $doGlobal = ($ans -match '^[Yy]')
}

if ($doGlobal) {
    # 2-A：写全局 GEMINI.md（~/.gemini/GEMINI.md）
    New-Item -ItemType Directory -Force -Path $GLOBAL_GEMINI_DIR | Out-Null
    if (Test-Path $globalGemini) {
        New-Item -ItemType Directory -Force -Path $BACKUP_DIR | Out-Null
        Copy-Item $globalGemini (Join-Path $BACKUP_DIR "GLOBAL_GEMINI.md.bak") -Force
        Write-Info "原全局 GEMINI.md 已备份 → .tuner-backup\"
    }
    Copy-Item $SRC_GEMINI $globalGemini -Force
    Write-Ok "全局 GEMINI.md → $globalGemini"

    # 2-B：写 Antigravity 全局 skills（~/.gemini/antigravity/skills/）
    # 这是 Antigravity 实际读取全局 Skills 的路径
    $globalSkillsDir = Join-Path $GLOBAL_AG_DIR "skills"
    New-Item -ItemType Directory -Force -Path $globalSkillsDir | Out-Null
    foreach ($skill in $skills) {
        $skillFile = Join-Path $skill.FullName "SKILL.md"
        if (Test-Path $skillFile) {
            $dstGlobalSkill = Join-Path $globalSkillsDir $skill.Name
            New-Item -ItemType Directory -Force -Path $dstGlobalSkill | Out-Null
            Copy-Item $skillFile (Join-Path $dstGlobalSkill "SKILL.md") -Force
            Write-Ok "全局 $($skill.Name)"
        }
    }
    Write-Ok "全局安装完成 → $globalSkillsDir"
} else {
    Write-Info "跳过全局安装（仅项目级 $AGENT_FORMAT 生效）"
}
Write-Host ""

# ══════════════════════════════════════════════════════════════
# 安装完成
# ══════════════════════════════════════════════════════════════
Write-Sep
Write-Host " 安装完成！" -ForegroundColor Green
Write-Sep
Write-Host " 项目级 Rules  → $dstGemini"
Write-Host " 项目级 Skills → $dstSkills"
if ($doGlobal) {
    Write-Host " 全局 GEMINI   → $globalGemini"
    Write-Host " 全局 Skills   → $(Join-Path $GLOBAL_AG_DIR 'skills')"
}
Write-Host ""
Write-Host " ▶ 下一步：" -ForegroundColor White
Write-Host "   1. 重启 Antigravity Agent Manager"
Write-Host "   2. 在聊天框输入：测试调教状态"
Write-Host "   3. 确认 Rules 和 Skills 已加载"
Write-Host ""
Write-Host " 💡 运行部署检测：双击 tools\tuner_check.bat" -ForegroundColor DarkCyan
Write-Sep
Write-Host ""

if (-not $Silent) {
    Write-Host "按任意键关闭..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}