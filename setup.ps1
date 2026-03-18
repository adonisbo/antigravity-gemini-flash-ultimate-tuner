# =============================================================
#  Antigravity Ultimate Tuner - 安装脚本
#  Version: 2026.03.19
#  新增：安装后菜单（模型档位切换、部署检测、冲突检测）
# =============================================================

param(
    [switch]$Silent,
    [switch]$GlobalOnly,
    [switch]$Check,
    [switch]$SwitchMode
)

$VERSION = "2026.03.19"

function Write-Ok($msg)   { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Write-Err($msg)  { Write-Host "  [!!] $msg" -ForegroundColor Red }
function Write-Warn($msg) { Write-Host "  [??] $msg" -ForegroundColor Yellow }
function Write-Info($msg) { Write-Host "  [ii] $msg" -ForegroundColor Cyan }
function Write-Sep()      { Write-Host ("-" * 62) -ForegroundColor DarkGray }

# ── 模型档位切换函数 ──────────────────────────────────────────
function Invoke-ModelSwitch {
    param([string]$GeminiPath)

    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "║   模型档位切换 - 根据当前使用的模型调整 Rules 强度       ║" -ForegroundColor Magenta
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "  Rules 路径：$GeminiPath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  请选择你当前在 Antigravity 中使用的模型：" -ForegroundColor White
    Write-Host ""
    Write-Host "  [1] Gemini 3 Flash / GPT-OSS 120B  -> LITE MODE" -ForegroundColor Green
    Write-Host "      强制 Research + Reflection，最大化弱模型输出质量"
    Write-Host ""
    Write-Host "  [2] Claude Sonnet 4.6              -> STANDARD MODE" -ForegroundColor Yellow
    Write-Host "      建议性约束，平衡效率与质量"
    Write-Host ""
    Write-Host "  [3] Gemini 3.1 Pro / Claude Opus   -> PRO MODE" -ForegroundColor Cyan
    Write-Host "      极简规则，不干扰强模型自主性"
    Write-Host ""
    Write-Host "  [0] 取消，不做修改"
    Write-Host ""

    $choice = Read-Host "  请输入选项 [0/1/2/3]"

    if ($choice -eq '0' -or $choice -eq '') {
        Write-Info "已取消，Rules 文件未修改"
        return
    }

    if (-not (Test-Path $GeminiPath)) {
        Write-Err "找不到 Rules 文件：$GeminiPath"
        Write-Info "请先运行 setup.bat 完成安装"
        return
    }

    if ($choice -notin @('1','2','3')) {
        Write-Err "无效选项：$choice，请输入 0/1/2/3"
        return
    }

    $content = [IO.File]::ReadAllText($GeminiPath, [Text.Encoding]::UTF8)

    if ($content -notmatch '\[LITE MODE\]' -or $content -notmatch '\[PRO MODE\]') {
        Write-Warn "Rules 文件不是最新版（缺少模型档位区块）"
        Write-Info "请先重新运行 setup.bat 更新到最新版本"
        return
    }

    $modeName = @{ '1' = 'LITE MODE'; '2' = 'STANDARD MODE'; '3' = 'PRO MODE' }[$choice]

    $backupPath = $GeminiPath + ".before_switch.bak"
    [IO.File]::WriteAllText($backupPath, $content, [Text.Encoding]::UTF8)
    Write-Info "已备份当前 Rules -> $backupPath"

    $lines = $content -split "`n"
    $result = [System.Collections.Generic.List[string]]::new()
    $zone = 'NONE'

    foreach ($line in $lines) {
        $t = $line.TrimEnd()
        if ($t -match '\[LITE MODE\].*适用')    { $zone = 'LITE';     $result.Add($line); continue }
        if ($t -match '\[STANDARD MODE\].*适用') { $zone = 'STANDARD'; $result.Add($line); continue }
        if ($t -match '\[PRO MODE\].*适用')      { $zone = 'PRO';      $result.Add($line); continue }
        if ($t -match '\[通用规则')              { $zone = 'COMMON';   $result.Add($line); continue }
        if ($t -match '^# [━【]' -or $t -eq '')  { $result.Add($line); continue }

        if ($zone -in @('LITE','STANDARD','PRO')) {
            $isTarget = (($choice -eq '1' -and $zone -eq 'LITE') -or
                         ($choice -eq '2' -and $zone -eq 'STANDARD') -or
                         ($choice -eq '3' -and $zone -eq 'PRO'))
            if ($isTarget) {
                if ($t -match '^# (.+)$') { $result.Add($Matches[1]); continue }
            } else {
                if ($t -notmatch '^#') { $result.Add("# $t"); continue }
            }
        }
        $result.Add($line)
    }

    [IO.File]::WriteAllText($GeminiPath, ($result -join "`n"), [Text.Encoding]::UTF8)

    Write-Host ""
    Write-Sep
    Write-Host "  已切换到：$modeName" -ForegroundColor Green
    Write-Sep
    Write-Host "  重启 Antigravity Agent Manager 后，新对话将使用新档位。" -ForegroundColor Yellow
    Write-Host ""
}

# ── 仅检测模式 ────────────────────────────────────────────────
if ($Check) {
    $cs = Join-Path $PSScriptRoot "tools\tuner_check.ps1"
    if (Test-Path $cs) { & $cs } else { Write-Err "检测脚本不存在：$cs" }
    exit 0
}

# ── 仅档位切换模式 ────────────────────────────────────────────
if ($SwitchMode) {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   Antigravity Ultimate Tuner - 模型档位切换              ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Invoke-ModelSwitch -GeminiPath (Join-Path $env:USERPROFILE ".gemini\GEMINI.md")
    if (-not $Silent) {
        Write-Host "按任意键关闭..." -ForegroundColor Gray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    exit 0
}

# ── Banner ────────────────────────────────────────────────────
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Antigravity Ultimate Tuner  v$VERSION                ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$PROJECT_DIR    = $PSScriptRoot
$GLOBAL_GEM_DIR = Join-Path $env:USERPROFILE ".gemini"
$GLOBAL_AG_DIR  = Join-Path $env:USERPROFILE ".gemini\antigravity"
$BACKUP_DIR     = Join-Path $PROJECT_DIR ".tuner-backup"
$SRC_SKILLS     = Join-Path $PROJECT_DIR ".agent\skills"
$SRC_GEMINI     = Join-Path $PROJECT_DIR "GEMINI.md"

# ── 验证源文件 ────────────────────────────────────────────────
Write-Host "[准备] 验证安装源..." -ForegroundColor White
if (-not (Test-Path $SRC_GEMINI)) { Write-Err "找不到 GEMINI.md，请从仓库根目录运行"; exit 1 }
if (-not (Test-Path $SRC_SKILLS)) { Write-Err "找不到 .agent\skills，请从仓库根目录运行"; exit 1 }
$skillCount = (Get-ChildItem $SRC_SKILLS -Directory).Count
Write-Ok "源文件就绪：GEMINI.md + $skillCount 个 Skills"
Write-Host ""

# ── 路径检测 ──────────────────────────────────────────────────
Write-Host "[路径] 自动识别 Antigravity 目录格式..." -ForegroundColor White
$AGENT_DIR = $null; $AGENT_FORMAT = $null
if     (Test-Path (Join-Path $PROJECT_DIR ".agents")) {
    $AGENT_DIR = Join-Path $PROJECT_DIR ".agents"; $AGENT_FORMAT = ".agents"
    Write-Ok "检测到 .agents（官方新标准）"
} elseif (Test-Path (Join-Path $PROJECT_DIR ".agent")) {
    $AGENT_DIR = Join-Path $PROJECT_DIR ".agent"; $AGENT_FORMAT = ".agent"
    Write-Ok "检测到 .agent（兼容格式）"
} else {
    Write-Warn "未检测到 .agent 或 .agents 目录"
    if ($Silent) {
        $AGENT_DIR = Join-Path $PROJECT_DIR ".agent"; $AGENT_FORMAT = ".agent"
        Write-Info "静默模式：使用默认 .agent"
    } else {
        Write-Host "  [1] .agents（推荐，官方新标准）  [2] .agent（兼容旧版）"
        $fc = Read-Host "  请选择 [1/2]"
        if ($fc -eq "2") { $AGENT_DIR = Join-Path $PROJECT_DIR ".agent"; $AGENT_FORMAT = ".agent" }
        else             { $AGENT_DIR = Join-Path $PROJECT_DIR ".agents"; $AGENT_FORMAT = ".agents" }
        Write-Ok "已选择：$AGENT_FORMAT"
    }
}
Write-Host ""

# ── 冲突检测 ──────────────────────────────────────────────────
Write-Host "[冲突] 检查 GEMINI.md..." -ForegroundColor White
$globalGemini = Join-Path $env:USERPROFILE ".gemini\GEMINI.md"
if (Test-Path $globalGemini) {
    $ec = Get-Content $globalGemini -Raw -Encoding UTF8 2>$null
    if ($ec -match "Antigravity.*Tuner|Ultimate.*Tuner") { Write-Ok "全局 GEMINI.md 已是本工具 Rules" }
    else { Write-Warn "全局 GEMINI.md 已存在（将覆盖）" }
} else { Write-Info "全局 GEMINI.md 不存在，无冲突" }
Write-Host ""

# ══ 步骤 1：创建目录 ══════════════════════════════════════════
Write-Host "[1/4] 创建目录..." -ForegroundColor White
New-Item -ItemType Directory -Force -Path $AGENT_DIR | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $AGENT_DIR "skills") | Out-Null
Write-Ok "目录就绪：$AGENT_DIR"
Write-Host ""

# ══ 步骤 2：部署 GEMINI.md ════════════════════════════════════
Write-Host "[2/4] 部署 Rules (GEMINI.md)..." -ForegroundColor White
$dstGemini = Join-Path $AGENT_DIR "GEMINI.md"
if (Test-Path $dstGemini) {
    New-Item -ItemType Directory -Force -Path $BACKUP_DIR | Out-Null
    Copy-Item $dstGemini (Join-Path $BACKUP_DIR "GEMINI.md.bak") -Force
    Write-Info "原 GEMINI.md 已备份 -> .tuner-backup\"
}
Copy-Item $SRC_GEMINI $dstGemini -Force
Write-Ok "GEMINI.md 已部署 -> $dstGemini"
Write-Host ""

# ══ 步骤 3：部署 Skills ═══════════════════════════════════════
Write-Host "[3/4] 部署 Skills..." -ForegroundColor White
$dstSkills = Join-Path $AGENT_DIR "skills"
$srcR = (Resolve-Path $SRC_SKILLS -EA SilentlyContinue)?.Path
$dstR = (Resolve-Path $dstSkills  -EA SilentlyContinue)?.Path
if ($srcR -and $dstR -and ($srcR.TrimEnd('\') -eq $dstR.TrimEnd('\'))) {
    Write-Info "源路径 == 目标路径，跳过本地复制（仓库内文件直接使用）"
    $skills = Get-ChildItem $SRC_SKILLS -Directory
    $skills | ForEach-Object { Write-Ok "$($_.Name) (已就位)" }
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
            Write-Ok $skill.Name; $successCount++
        } else { Write-Warn "$($skill.Name) - 缺少 SKILL.md，跳过" }
    }
}
Write-Host "  共部署 $successCount 个 Skills" -ForegroundColor Gray
Write-Host ""

# ══ 步骤 4：全局安装 ══════════════════════════════════════════
Write-Host "[4/4] 全局安装..." -ForegroundColor White
$doGlobal = $false
if ($Silent -or $GlobalOnly) { $doGlobal = $true }
else {
    $ans = Read-Host "  是否同时安装到全局目录（所有 Antigravity 项目共享）？[Y/N]"
    $doGlobal = ($ans -match '^[Yy]')
}

if ($doGlobal) {
    New-Item -ItemType Directory -Force -Path $GLOBAL_GEM_DIR | Out-Null
    if (Test-Path $globalGemini) {
        New-Item -ItemType Directory -Force -Path $BACKUP_DIR | Out-Null
        Copy-Item $globalGemini (Join-Path $BACKUP_DIR "GLOBAL_GEMINI.md.bak") -Force
        Write-Info "原全局 GEMINI.md 已备份"
    }
    Copy-Item $SRC_GEMINI $globalGemini -Force
    Write-Ok "全局 GEMINI.md -> $globalGemini"

    $globalSkillsDir = Join-Path $GLOBAL_AG_DIR "skills"
    New-Item -ItemType Directory -Force -Path $globalSkillsDir | Out-Null
    foreach ($skill in $skills) {
        $sf = Join-Path $skill.FullName "SKILL.md"
        if (Test-Path $sf) {
            $dg = Join-Path $globalSkillsDir $skill.Name
            New-Item -ItemType Directory -Force -Path $dg | Out-Null
            Copy-Item $sf (Join-Path $dg "SKILL.md") -Force
            Write-Ok "全局 $($skill.Name)"
        }
    }
    Write-Ok "全局安装完成 -> $globalSkillsDir"
} else { Write-Info "跳过全局安装（仅项目级 $AGENT_FORMAT 生效）" }
Write-Host ""

# ══ 安装完成摘要 ══════════════════════════════════════════════
Write-Sep
Write-Host " 安装完成！" -ForegroundColor Green
Write-Sep
Write-Host " 项目级 Rules  -> $dstGemini"
Write-Host " 项目级 Skills -> $dstSkills"
if ($doGlobal) {
    Write-Host " 全局 GEMINI   -> $globalGemini"
    Write-Host " 全局 Skills   -> $(Join-Path $GLOBAL_AG_DIR 'skills')"
}
Write-Host ""

# ══ 安装后操作菜单 ════════════════════════════════════════════
if (-not $Silent) {
    :mainMenu while ($true) {
        Write-Host ""
        Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor DarkCyan
        Write-Host "║   安装后操作菜单                                         ║" -ForegroundColor DarkCyan
        Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor DarkCyan
        Write-Host ""
        Write-Host "  [1] 模型档位切换" -ForegroundColor Green
        Write-Host "      Flash/GPT -> LITE | Sonnet -> STANDARD | Pro/Opus -> PRO"
        Write-Host ""
        Write-Host "  [2] 部署检测" -ForegroundColor Yellow
        Write-Host "      验证所有文件正确部署，生成桌面 tuner_check_report.txt"
        Write-Host ""
        Write-Host "  [3] 冲突检测" -ForegroundColor Cyan
        Write-Host "      检查 GEMINI.md 是否被其他工具覆盖"
        Write-Host ""
        Write-Host "  [0] 退出"
        Write-Host ""

        $mc = Read-Host "  请输入选项 [0/1/2/3]"
        switch ($mc) {
            '1' {
                $gt = if ($doGlobal) { $globalGemini } else { $dstGemini }
                Invoke-ModelSwitch -GeminiPath $gt
            }
            '2' {
                $cs = Join-Path $PSScriptRoot "tools\tuner_check.ps1"
                if (Test-Path $cs) { Write-Info "正在运行部署检测..."; & $cs }
                else { Write-Err "检测脚本不存在：$cs" }
            }
            '3' {
                $cf = Join-Path $PSScriptRoot "conflict-check.ps1"
                if (Test-Path $cf) { Write-Info "正在运行冲突检测..."; & $cf }
                else { Write-Err "冲突检测脚本不存在：$cf" }
            }
            '0' { break mainMenu }
            default { Write-Warn "无效选项，请输入 0/1/2/3" }
        }
    }
}

Write-Host ""
Write-Sep
Write-Host " 下一步：重启 Antigravity Agent Manager，输入：测试调教状态" -ForegroundColor White
Write-Host " 随时切换档位：双击 tools\switch_mode.bat" -ForegroundColor DarkCyan
Write-Sep
Write-Host ""

if (-not $Silent) {
    Write-Host "按任意键关闭..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
