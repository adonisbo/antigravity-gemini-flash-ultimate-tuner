# Changelog

All notable changes to this project are documented here.

---

## v2026.03.20 — 2026-03-18

**PowerShell 5.1 兼容性修复（重要）**

- **修复** setup.ps1 在 PowerShell 5.1（Windows 默认版本）上报错问题
  - 根本原因1：文件缺少 UTF-8 BOM，导致 PS5.1 用 GBK 解析中文字节，引发"字符串缺少终止符"和"缺少右括号"
  - 根本原因2：使用了 `?.` 空值条件运算符（仅 PS 7+ 支持），在 PS5.1 上直接语法报错
  - 修复方案：强制写入 UTF-8 with BOM + 改用 `Safe-ResolvePath` 函数 + 输出信息全英文化
- 版本升级至 v2026.03.20

---

## v2026.03.19 — 2026-03-18

**安装后操作菜单 + 模型档位切换**

- **新增** setup.ps1 安装完成后自动显示操作菜单
  - `[1]` 模型档位切换（LITE / STANDARD / PRO MODE）
  - `[2]` 部署检测（调用 tools/tuner_check.ps1）
  - `[3]` 冲突检测（调用 conflict-check.ps1）
- **新增** `-SwitchMode` 参数：随时单独运行档位切换，不重新安装
- **新增** `tools/switch_mode.bat`：双击即可切换模型档位
- **新增** GEMINI.md 三档结构（LITE / STANDARD / PRO MODE）
  - LITE MODE（默认）：适用 Gemini 3 Flash / GPT-OSS 120B，强制 Research + Reflection
  - STANDARD MODE：适用 Claude Sonnet 4.6，建议性约束
  - PRO MODE：适用 Gemini 3.1 Pro / Claude Opus 4.6，极简规则不干扰强模型
- **新增** README 方式0：Antigravity 对话框一键安装 Prompt
- **修复** setup.ps1 自身覆盖警告（源路径 == 目标路径时跳过本地复制）
- 版本升级至 v2026.03.19

---

## v2026.03.18 — 2026-03-18

**稳定性修复版**

- **修复** setup.bat 中文乱码（改为 3 行纯 ASCII 启动器，逻辑移入 setup.ps1）
- **修复** xcopy 循环复制错误（改用 PowerShell `Copy-Item`）
- **修复** 全局 Skills 安装路径不正确（正确写入 `~/.gemini/antigravity/skills/`）
- **新增** `setup.ps1`：PowerShell 主安装脚本，支持 `-Silent`、`-GlobalOnly`、`-Check` 参数
- **新增** `tools/` 工具目录
  - `tuner_check.bat` + `tuner_check.ps1`：部署完整性检测，报告保存到桌面
  - `conflict_check.bat`：冲突检测快速启动器
- 版本升级至 v2026.03.18

---

## v2026.03.17 — 2026-03-17

**初始发布**

- 5 个经过多轮真实调教验证的核心 Skills
  - Best-Practice-Researcher：强制先联网搜索最新实践
  - Architect-Dialogue：架构规划 + 方案对比 + 用户确认
  - Code-Reviewer-Debugger：严格调试 + Reflection 循环
  - Tester：自动生成并执行测试
  - Tuner-Update：Meta-Skill，自检查 GitHub 最新版本
- Windows / Linux / macOS 三端安装脚本
- PowerShell 冲突检测脚本（conflict-check.ps1）
- npx 安装器支持（npx-install.js）
- GitHub Actions CI 工作流（验证 SKILL.md 格式）
- sample_project：最小化 FastAPI 示例演示 Skills 生效效果
- 调教原理章节：解释 Rules + Skills 组合机制
