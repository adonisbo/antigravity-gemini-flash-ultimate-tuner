@echo off
setlocal EnableDelayedExpansion

echo =====================================================
echo  Antigravity Gemini 3 Flash Ultimate Tuner
echo  Version: 2026.03.17 - Ultimate Edition
echo  作者：基于多轮真实调教实践整理
echo =====================================================
echo.

set "PROJECT_DIR=%CD%"
set "GLOBAL_DIR=%USERPROFILE%\.gemini\antigravity"
set "GLOBAL_SKILLS=%GLOBAL_DIR%\skills"
set "BACKUP_DIR=%PROJECT_DIR%\.tuner-backup"

rem ── Antigravity 路径自动检测（.agents 复数 vs .agent 单数）────
echo [路径检测] 自动识别 Antigravity 版本目录格式...
set "AGENT_DIR="
set "AGENT_FORMAT="

rem 优先检测新标准 .agents（复数，Antigravity 官方新格式）
if exist "%PROJECT_DIR%\.agents" (
    set "AGENT_DIR=%PROJECT_DIR%\.agents"
    set "AGENT_FORMAT=.agents"
    echo     检测到 .agents 目录（官方新标准格式）
    goto :path_detected
)

rem 其次检测旧标准 .agent（单数，兼容格式）
if exist "%PROJECT_DIR%\.agent" (
    set "AGENT_DIR=%PROJECT_DIR%\.agent"
    set "AGENT_FORMAT=.agent"
    echo     检测到 .agent 目录（兼容旧格式）
    goto :path_detected
)

rem 两者都不存在，询问用户选择
echo     未检测到现有 .agent 或 .agents 目录。
echo.
echo     请选择要使用的格式：
echo       [1] .agents  （推荐，Antigravity 官方新标准，2026.01+）
echo       [2] .agent   （兼容，适用于旧版 Antigravity）
echo.
choice /C 12 /M "请输入选项"
if errorlevel 2 (
    set "AGENT_DIR=%PROJECT_DIR%\.agent"
    set "AGENT_FORMAT=.agent"
    echo     已选择：.agent 格式
) else (
    set "AGENT_DIR=%PROJECT_DIR%\.agents"
    set "AGENT_FORMAT=.agents"
    echo     已选择：.agents 格式
)

:path_detected
echo     使用路径：%AGENT_DIR%
echo.

rem ── 冲突检测 ────────────────────────────────────────────────
echo [冲突检测] 检查全局 GEMINI.md 冲突...
if exist "%USERPROFILE%\.gemini\GEMINI.md" (
    echo ⚠️  警告：检测到全局 %USERPROFILE%\.gemini\GEMINI.md 已存在
    echo     可能被 Gemini CLI 或其他工具写入，存在被覆盖风险。
    echo     本工具将优先使用项目级 %AGENT_FORMAT%\GEMINI.md，安全性更高。
) else (
    echo     无全局冲突风险。
)
echo.

rem ── Step 1：创建目录 ─────────────────────────────────────────
echo [1/4] 创建 %AGENT_FORMAT% 目录结构...
if not exist "%AGENT_DIR%" mkdir "%AGENT_DIR%"
if not exist "%AGENT_DIR%\skills" mkdir "%AGENT_DIR%\skills"
echo     ✅ 目录已就绪

rem ── Step 2：部署 GEMINI.md ───────────────────────────────────
echo [2/4] 部署全局 Rules (GEMINI.md)...
if exist "%AGENT_DIR%\GEMINI.md" (
    echo     检测到已有 GEMINI.md，备份中...
    if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
    copy /Y "%AGENT_DIR%\GEMINI.md" "%BACKUP_DIR%\GEMINI.md.bak" >nul
    echo     备份到：%BACKUP_DIR%\GEMINI.md.bak
)
copy /Y "%PROJECT_DIR%\GEMINI.md" "%AGENT_DIR%\GEMINI.md" >nul
echo     ✅ Rules 已部署

rem ── Step 3：部署 Skills ──────────────────────────────────────
echo [3/4] 部署所有 Skills...

rem 从本仓库的 .agent/skills 复制（统一使用 .agent 作为仓库内源路径）
if exist "%PROJECT_DIR%\.agent\skills" (
    xcopy /E /I /Y "%PROJECT_DIR%\.agent\skills" "%AGENT_DIR%\skills" >nul
    echo     ✅ Skills 已部署（来源：.agent\skills）
) else (
    echo     ⚠️  未找到 .agent\skills 源目录，跳过 Skills 部署
    echo        请确保从仓库根目录运行此脚本
)

rem ── Step 4：全局安装（可选）──────────────────────────────────
echo [4/4] 全局安装（可选）...
echo.
choice /C YN /M "是否同时安装到全局目录（所有 Antigravity 项目共享生效）？"
if errorlevel 2 goto :skip_global

if not exist "%GLOBAL_DIR%" mkdir "%GLOBAL_DIR%"
if not exist "%GLOBAL_SKILLS%" mkdir "%GLOBAL_SKILLS%"

if exist "%GLOBAL_DIR%\GEMINI.md" (
    if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
    copy /Y "%GLOBAL_DIR%\GEMINI.md" "%BACKUP_DIR%\GLOBAL_GEMINI.md.bak" >nul
    echo     ✅ 已备份原全局 GEMINI.md → .tuner-backup\GLOBAL_GEMINI.md.bak
)
copy /Y "%PROJECT_DIR%\GEMINI.md" "%GLOBAL_DIR%\GEMINI.md" >nul
xcopy /E /I /Y "%PROJECT_DIR%\.agent\skills" "%GLOBAL_SKILLS%" >nul
echo     ✅ 全局安装完成：%GLOBAL_DIR%
goto :done

:skip_global
echo     跳过全局安装（仅项目级 %AGENT_FORMAT% 生效）

:done
echo.
echo =====================================================
echo  安装完成！
echo =====================================================
echo  项目级 Rules   → %AGENT_DIR%\GEMINI.md
echo  项目级 Skills  → %AGENT_DIR%\skills\
echo  路径格式       → %AGENT_FORMAT%
echo.
echo  ▶ 下一步：
echo    1. 重启 Antigravity Agent Manager
echo    2. 在聊天框输入：测试调教状态
echo    3. 确认所有 Rules 和 Skills 已加载
echo    4. 开始享受 Gemini 3 Flash 极致模式！
echo.
echo  💡 提示：如遇冲突，运行 conflict-check.ps1 进行诊断
echo =====================================================
pause
