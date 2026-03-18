# =============================================================
#  Antigravity Gemini 3 Flash Ultimate Tuner - 部署检测工具
#  Version: 2026.03.18
#  位置：tools/tuner_check.ps1
#  用法：双击 tools/tuner_check.bat，报告保存到桌面
# =============================================================

$REPORT = Join-Path ([Environment]::GetFolderPath('Desktop')) "tuner_check_report.txt"
$PASS = 0; $FAIL = 0; $WARN = 0

function W($x)  { Add-Content $REPORT $x -Encoding UTF8 }
function WP($x) { W $x; $script:PASS++ }
function WF($x) { W $x; $script:FAIL++ }
function WW($x) { W $x; $script:WARN++ }

Set-Content $REPORT "" -Encoding UTF8
W "================================================================"
W " Antigravity Gemini 3 Flash Ultimate Tuner - 部署检测报告"
W " 检测时间：$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
W " 检测机器：$env:COMPUTERNAME"
W " 用户：$env:USERNAME  |  用户目录：$env:USERPROFILE"
W " PowerShell 版本：$($PSVersionTable.PSVersion)"
W "================================================================"
W ""

$REPO = "antigravity-gemini-flash-ultimate-tuner"

# ==== 第一节：仓库位置 ====
W "[第一节] 仓库克隆位置检测"
W "----------------------------------------------------------------"
$REPO_PATH = $null
$candidates = @(
    "$env:USERPROFILE\.gemini\antigravity\scratch\$REPO",
    "$env:USERPROFILE\Desktop\$REPO",
    "$env:USERPROFILE\Documents\$REPO",
    "$env:USERPROFILE\$REPO",
    "C:\$REPO"
)
foreach ($c in $candidates) {
    if (Test-Path $c) {
        WP "[PASS] 仓库找到：$c"
        if (-not $REPO_PATH) { $REPO_PATH = $c }
    } else {
        W "[    ] 不存在：$c"
    }
}
if (-not $REPO_PATH) { WF "[FAIL] 所有候选路径均未找到仓库" }
W ""

# ==== 第二节：全局 GEMINI.md ====
W "[第二节] 全局 GEMINI.md 检测"
W "----------------------------------------------------------------"
$gGemini = "$env:USERPROFILE\.gemini\GEMINI.md"
if (Test-Path $gGemini) {
    $fi = Get-Item $gGemini
    WP "[PASS] 全局 GEMINI.md 存在 | $($fi.Length) 字节 | 修改：$($fi.LastWriteTime)"
    $raw = [IO.File]::ReadAllBytes($gGemini)
    if ($raw[0] -eq 0xEF -and $raw[1] -eq 0xBB -and $raw[2] -eq 0xBF) {
        W "[INFO] 编码：UTF-8 with BOM"
        $txt = [Text.Encoding]::UTF8.GetString($raw, 3, $raw.Length - 3)
    } else {
        W "[INFO] 编码：UTF-8 without BOM / ANSI"
        $txt = [Text.Encoding]::UTF8.GetString($raw)
    }
    if ($txt -match "Ultimate Gemini 3 Flash Rules") { WP "[PASS] 内容确认为本工具 Rules" }
    elseif ($txt -match "Best-Practice-Researcher") { WW "[WARN] 含 Skills 关键词但标题不匹配（可能乱码版本）" }
    else { WW "[WARN] 内容不是本工具 Rules（可能被覆盖）" }
    W "[INFO] 文件前5行："
    ($txt -split "`n" | Select-Object -First 5) | ForEach-Object { W "        $($_.Trim())" }
} else {
    WF "[FAIL] 全局 GEMINI.md 不存在：$gGemini"
}
W ""

# ==== 第三节：Skills 完整性 ====
W "[第三节] Skills 完整性检测"
W "----------------------------------------------------------------"
$SK_PATH = $null
$skChecks = @()
if ($REPO_PATH) { $skChecks += "$REPO_PATH\.agent\skills" }
$skChecks += "$env:USERPROFILE\.gemini\antigravity\skills"
$skChecks += "$env:USERPROFILE\.gemini\.agent\skills"
$skChecks += "$env:USERPROFILE\.gemini\antigravity\scratch\$REPO\.agent\skills"

foreach ($sc in $skChecks) {
    if (Test-Path $sc) {
        W "[INFO] 找到 Skills 目录：$sc"
        if (-not $SK_PATH) { $SK_PATH = $sc }
    }
}

$skills5 = @("Best-Practice-Researcher","Architect-Dialogue","Code-Reviewer-Debugger","Tester","Tuner-Update")
if ($SK_PATH) {
    W "[INFO] 使用路径：$SK_PATH"
    foreach ($s in $skills5) {
        $sf = "$SK_PATH\$s\SKILL.md"
        if (Test-Path $sf) {
            $sz = (Get-Item $sf).Length
            WP "[PASS] $s | $sz 字节"
            try {
                $sc2 = Get-Content $sf -Raw -Encoding UTF8
                if ($sc2 -match "(?m)^name:")        { W "       - name: OK" }        else { WW "       [WARN] 缺少 name: 字段" }
                if ($sc2 -match "(?m)^description:") { W "       - description: OK" } else { WW "       [WARN] 缺少 description: 字段" }
            } catch { WW "       [WARN] 读取内容时出错：$_" }
        } else {
            WF "[FAIL] Skill 缺失：$s"
            W "       期望路径：$sf"
        }
    }
} else {
    WF "[FAIL] 未找到任何 Skills 目录"
    foreach ($sc in $skChecks) { W "       已检查：$sc" }
}
W ""

# ==== 第四节：全局 Skills 路径（Antigravity 实际读取）====
W "[第四节] Antigravity 全局 Skills 路径检测"
W "----------------------------------------------------------------"
$globalSkillsPath = "$env:USERPROFILE\.gemini\antigravity\skills"
if (Test-Path $globalSkillsPath) {
    $cnt = (Get-ChildItem $globalSkillsPath -Directory -EA SilentlyContinue).Count
    WP "[PASS] 全局 Skills 目录存在：$globalSkillsPath（$cnt 个）"
    foreach ($s in $skills5) {
        if (Test-Path "$globalSkillsPath\$s\SKILL.md") {
            W "       ✅ 全局 $s"
        } else {
            WW "       ⚠️  全局 $s 缺失（仅项目级有效，不影响当前项目）"
        }
    }
} else {
    WW "[WARN] 全局 Skills 目录不存在：$globalSkillsPath"
    W "       说明：Skills 仅在当前仓库项目内有效"
    W "       修复：重新运行 setup.bat（选择 Y 进行全局安装）"
}
W ""

# ==== 第五节：setup 脚本质量 ====
W "[第五节] 安装脚本质量检测"
W "----------------------------------------------------------------"
if ($REPO_PATH) {
    # 检查新版 setup.ps1
    $ps1 = "$REPO_PATH\setup.ps1"
    if (Test-Path $ps1) {
        WP "[PASS] setup.ps1 存在（推荐方式）"
        $psTxt = Get-Content $ps1 -Raw -Encoding UTF8
        if ($psTxt -match "robocopy|Copy-Item") { WP "[PASS] 使用安全复制方式（非 xcopy）" }
        if ($psTxt -match "GLOBAL_AG_DIR|antigravity.skills") { WP "[PASS] 支持全局 Skills 安装" }
    } else {
        WW "[WARN] setup.ps1 不存在（旧版仓库）"
    }
    # 检查 setup.bat
    $bat = "$REPO_PATH\setup.bat"
    if (Test-Path $bat) {
        WP "[PASS] setup.bat 存在"
        $batBytes = [IO.File]::ReadAllBytes($bat)
        $batTxt = [Text.Encoding]::UTF8.GetString($batBytes)
        if ($batTxt -match "setup.ps1") {
            WP "[PASS] setup.bat 为 PS1 代理启动器（推荐架构）"
        } else {
            if ($batTxt -match "chcp 65001") { WP "[PASS] 含 chcp 65001" } else { WF "[FAIL] 缺少 chcp 65001（会乱码）" }
            if ($batTxt -match "xcopy")      { WW "[WARN] 使用 xcopy（可能循环复制）" }
        }
    }
} else {
    W "[INFO] 跳过（仓库未找到）"
}
W ""

# ==== 第六节：目录结构全貌 ====
W "[第六节] .gemini 相关目录结构"
W "----------------------------------------------------------------"
foreach ($dir in @("$env:USERPROFILE\.gemini","$env:USERPROFILE\.gemini\antigravity","$env:USERPROFILE\.gemini\antigravity\scratch")) {
    W "[INFO] 目录：$dir"
    if (Test-Path $dir) {
        try {
            Get-ChildItem $dir -Force -EA Stop |
                Select-Object @{N="T";E={if($_.PSIsContainer){"DIR"}else{"FILE"}}},
                              @{N="修改时间";E={$_.LastWriteTime.ToString("yyyy-MM-dd HH:mm")}},
                              @{N="大小";E={$_.Length}}, Name |
                Format-Table -AutoSize | Out-String | ForEach-Object { W $_ }
        } catch { W "       读取失败：$_" }
    } else { W "       目录不存在" }
}
W ""

# ==== 汇总 ====
W "================================================================"
W " 检测结果汇总"
W "================================================================"
W " 通过（PASS）：$PASS 项"
W " 失败（FAIL）：$FAIL 项"
W " 警告（WARN）：$WARN 项"
W ""
if    ($FAIL -eq 0 -and $WARN -eq 0) { W " 总体状态：[全部通过] 部署完整，可正常使用" }
elseif ($FAIL -eq 0)                  { W " 总体状态：[基本通过] 有警告项，核心功能应可用" }
else                                  { W " 总体状态：[存在失败] 部署不完整，请查阅详细日志" }
W ""
W " 报告路径：$REPORT"
W "================================================================"

Write-Host "================================================================" -ForegroundColor Green
Write-Host " 检测完成！报告已保存到桌面：tuner_check_report.txt" -ForegroundColor Green
Write-Host "================================================================"
Write-Host " PASS: $PASS   FAIL: $FAIL   WARN: $WARN"
Write-Host "================================================================"
Write-Host ""
Write-Host "按任意键关闭..." -ForegroundColor Gray
[Console]::ReadKey($true) | Out-Null