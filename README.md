# Antigravity Gemini 3 Flash Ultimate Tuner

> **经过多轮真实交互调教出的 Gemini 3 Flash 最强配置包**  
> 让 Gemini 3 Flash 在 [Google Antigravity IDE](https://antigravity.google/) 中接近 Pro 级表现

[![Version](https://img.shields.io/badge/Version-2026.03.19-blue)](.)
[![Platform](https://img.shields.io/badge/Platform-Antigravity%20IDE-orange)](https://antigravity.google/)
[![Model](https://img.shields.io/badge/Model-Gemini%203%20Flash-green)](.)
[![License](https://img.shields.io/badge/License-MIT-yellow)](./LICENSE)
[![CI](https://img.shields.io/github/actions/workflow/status/adonisbo/antigravity-gemini-flash-ultimate-tuner/validate-skills.yml?label=Skills%20CI)](.)

---

## ✨ 核心功能

| 能力 | 说明 |
|------|------|
| 🔍 **强制先 Research** | 任何任务都先调用 Browser/search_web，禁止 hallucination |
| 🏗️ **架构规划闭环** | 自动输出方案对比表 + 树状架构图 + 任务拆分 + 用户确认 |
| 🔄 **Reflection 循环** | 遇到错误自动进行日志分析 + 多方案修复，绝不狡辩 |
| 🌐 **双模式部署** | 支持项目级（`.agent/`）和全局（`~/.gemini/antigravity/`）双模式 |
| 🛡️ **冲突检测** | 自动检测并防止 Gemini CLI 覆盖 Rules 文件 |
| 🔁 **Meta 自更新** | Tuner-Update Skill 可检查 GitHub 最新版，永不过期 |

---

## 🧠 调教原理（为什么这套方案有效？）

> 本节解释为什么 Gemini 3 Flash 需要 Rules + Skills 的组合，而不是单纯修改 Prompt。

### 问题根源：Flash 模型的天生局限

Gemini 3 Flash 是速度优先的轻量级模型，对比 Pro 系列有以下固有缺陷：

| 缺陷 | 表现 | 后果 |
|------|------|------|
| **工具调用懒惰** | 有 Browser 工具却不主动调用，直接用训练数据回答 | 技术版本过时、Hallucination |
| **执行链路短路** | 跳过规划直接编码，跳过测试直接提交 | 架构混乱、bug 频发 |
| **错误应对软弱** | 遇到报错倾向于说"可能是模型限制"而非排查 | 开发者被迫手动 debug |
| **上下文失忆** | 长任务中遗忘早期决策，反复重复工作 | 浪费大量来回对话 |

### 为什么单纯 Prompt 不够？

```
❌ 单纯 Prompt（每次任务都要手写）
   → 只对当次对话生效
   → 用户必须每次重复提醒
   → Flash 模型容易"忘记"或降级执行
   → 上下文一长就失效

✅ Rules + Skills 组合（一次配置，永久生效）
   → Rules（GEMINI.md）：系统级约束，Agent 启动时就加载
   → Skills（SKILL.md）：触发式 SOP，自动匹配任务类型
   → 两者叠加 = 行为约束 × 流程模板 = 接近 Pro 级表现
```

### 调教链路图

```
用户输入任务
     │
     ▼
┌─────────────────────────────────────────┐
│  GEMINI.md（全局 Rules）                 │
│  ● 强制工具调用                          │
│  ● 禁止 Hallucination                   │
│  ● 强制 Reflection 循环                  │
└────────────────┬────────────────────────┘
                 │ 自动触发
     ┌───────────┴───────────────────┐
     ▼                               ▼
Best-Practice-Researcher     Architect-Dialogue
（搜索最新实践）               （规划 + 确认）
     │                               │
     └──────────────┬────────────────┘
                    ▼
              Code-Reviewer-Debugger
              （写代码 + 遇错 Reflection）
                    │
                    ▼
                 Tester
              （生成测试 + 验证）
                    │
                    ▼
              ✅ 高质量交付
```

### 为什么不用 MCP？

MCP（Model Context Protocol）适合接入**外部工具**（数据库、API、文件系统等），而本工具的目标是约束**模型行为**（何时搜索、如何规划、遇错怎么办）。两者互补，不互斥——你可以在已有 MCP 连接的项目上额外部署本工具，效果叠加。

### 实际效果（基于多轮真实测试）

| 指标 | 未调教 | 调教后 |
|------|--------|--------|
| Hallucination 频率 | 高（版本信息经常错误） | 低（强制查最新文档后明显改善）|
| 主动使用 Browser 工具 | 几乎不用 | 强制每任务 ≥2 次 |
| 规划后才编码 | 很少 | 稳定执行 |
| 遇错给出多方案 | 偶尔 | 稳定执行（≥3 个方案）|
| 需要用户反复提醒的次数 | 高 | 极低（Rules 自动保障）|

---

## 📦 文件结构

```
antigravity-gemini-flash-ultimate-tuner/
├── README.md                              ← 本文件
├── GEMINI.md                              ← 全局最强 Rules（核心）
├── setup.bat                              ← Windows 一键安装（3行纯ASCII启动器）
├── setup.ps1                              ← 安装主逻辑（PowerShell，无乱码）
├── setup.sh                               ← Linux/macOS 一键安装
├── conflict-check.ps1                     ← PowerShell 冲突检测
├── npx-install.js                         ← npx 命令支持入口
├── package.json                           ← npm 包配置
├── LICENSE                                ← MIT 协议
├── 更正对比表.md                           ← 对话中错误信息核实记录
├── tools/                                 ← 工具集
│   ├── tuner_check.bat                    ← 部署检测启动器（双击运行）
│   ├── tuner_check.ps1                    ← 部署检测主体（生成桌面报告）
│   └── conflict_check.bat                 ← 冲突检测启动器
├── .github/
│   └── workflows/
│       └── validate-skills.yml            ← GitHub Actions CI 验证
├── sample_project/                        ← 最小化示例项目
│   ├── README.md
│   ├── pyproject.toml
│   ├── src/main.py
│   └── tests/test_main.py
└── .agent/
    └── skills/
        ├── Best-Practice-Researcher/SKILL.md
        ├── Architect-Dialogue/SKILL.md
        ├── Code-Reviewer-Debugger/SKILL.md
        ├── Tester/SKILL.md
        └── Tuner-Update/SKILL.md
```

---

## 🚀 快速安装

### ⭐ 方式 0：在 Antigravity 对话框一键安装（最推荐）

**适用场景**：已在 Antigravity 中选择好模型，希望直接让 AI 帮你完成整个安装。

> **前提条件**：选择任意模型均可使用，推荐先用 Gemini 3 Flash。项目地址：[https://github.com/adonisbo/antigravity-gemini-flash-ultimate-tuner](https://github.com/adonisbo/antigravity-gemini-flash-ultimate-tuner)

**将以下 prompt 复制到 Antigravity 对话框中发送即可：**

---

```
请帮我安装 Antigravity Ultimate Tuner 项目。请按以下步骤严格执行，所有命令均在 PowerShell 终端中运行：

步骤 1：克隆仓库到 Antigravity scratch 目录
  cd $env:USERPROFILE\.gemini\antigravity\scratch
  git clone https://github.com/adonisbo/antigravity-gemini-flash-ultimate-tuner.git
  cd antigravity-gemini-flash-ultimate-tuner

步骤 2：执行静默全局安装（无需手动确认任何选项，跳过所有交互）
  powershell -ExecutionPolicy Bypass -File setup.ps1 -Silent -GlobalOnly

步骤 3：验证安装结果
  powershell -ExecutionPolicy Bypass -File setup.ps1 -Check

安装完成后，请告诉我：
1. 全局 GEMINI.md 安装路径（应为 C:\Users\<用户名>\.gemini\GEMINI.md）
2. 全局 Skills 安装路径（应为 C:\Users\<用户名>\.gemini\antigravity\skills\...）
3. 检测结果中 PASS/FAIL/WARN 各多少项
4. 如果有任何 FAIL，请显示详细错误并修复
```

---

> 💡 **关于模型标位：** 上面的 prompt 默认安装 LITE MODE（适用于 Gemini 3 Flash / GPT-OSS 120B）。
> 安装完成后，如需切换模型标位，在对话框输入：
> 
> ```
> 请帮我运行：powershell -ExecutionPolicy Bypass -File $env:USERPROFILE\.gemini\antigravity\scratch\antigravity-gemini-flash-ultimate-tuner\setup.ps1 -SwitchMode
> ```

---

### 方式 A：Windows（推荐）
```bat
# 1. clone 本仓库到任意目录（推荐放在 Antigravity 项目根目录）
# 2. 双击运行 setup.bat（自动调用 setup.ps1，无乱码、无循环复制）
setup.bat

# 也可直接运行 PowerShell 脚本（支持参数）：
# 静默安装（跳过交互）：
powershell -ExecutionPolicy Bypass -File setup.ps1 -Silent
# 仅运行检测（不安装）：
powershell -ExecutionPolicy Bypass -File setup.ps1 -Check
```

### 方式 B：Linux / macOS
```bash
chmod +x setup.sh
./setup.sh
```

### 方式 C：npx（本地运行）
```bash
node npx-install.js
```

### 方式 D：手动安装
```bash
mkdir -p .agent/skills
cp GEMINI.md .agent/GEMINI.md
cp -r .agent/skills/* <你的项目>/.agent/skills/
# 重启 Antigravity Agent Manager
```

---

## ✅ 安装后验证

### 方式 1：部署检测工具（推荐）
双击运行 `tools\tuner_check.bat`，报告自动保存到**桌面** `tuner_check_report.txt`。

> ⚠️ 注意：报告不是生成在仓库目录里，而是在你的用户桌面。

### 方式 2：Antigravity 内验证
在 Antigravity 聊天框输入：
```
测试调教状态
```
正常应看到 Agent 确认已加载所有 Rules 和 Skills 的完整报告。

---

## ♻️ 升级 / 卸载

### 升级（无需卸载，直接覆盖）
```bat
# 进入仓库目录，拉取最新版后重新运行即可
git pull
setup.bat
```
新版会自动备份原有 GEMINI.md 到 `.tuner-backup\`，不会丢失数据。

### 完全卸载（手动删除以下文件/文件夹）
| 路径 | 说明 |
|------|------|
| `%USERPROFILE%\.gemini\GEMINI.md` | 全局 Rules |
| `%USERPROFILE%\.gemini\antigravity\skills\` | 全局 Skills |
| 仓库本体所在目录 | 仓库文件 |

---

## 🎯 Skills 说明

### 1. Best-Practice-Researcher（核心 ⭐）
**触发时机**：任何编码、选库、部署任务前  
**核心行为**：强制执行 `Search → Compare → Verify` 流程，输出 ADR（Architecture Decision Record）

### 2. Architect-Dialogue
**触发时机**：新功能规划、架构设计、重构  
**核心行为**：调用 Researcher → 方案对比表 → 树状图 → 任务拆分 → 用户确认

### 3. Code-Reviewer-Debugger
**触发时机**：遇到任何 bug、报错、性能问题  
**核心行为**：完整日志分析 → 假设排查 → 至少 3 个修复方案 → 记录 ERRORS.md

### 4. Tester
**触发时机**：每次重大代码变更后  
**核心行为**：自动生成 pytest 用例 → 运行 → 覆盖率报告 → 失败触发 Debugger

### 5. Tuner-Update（Meta-Skill）
**触发时机**：输入"检查更新" 或 "check update"  
**核心行为**：Browser 检查 GitHub 最新版，对比本地版本，给出升级命令

---

## ⚙️ 全局 Rules 说明（GEMINI.md）

### ⚠️ 重要：Rules 对所有模型自动加载

根据 Antigravity 官方文档，`GEMINI.md` 会对**所有对话自动加载**，无论你选择哪个模型。这意味着：

- 使用 **Gemini 3 Flash / GPT-OSS 120B** → LITE MODE 强制约束是必要的，能显著提升质量
- 使用 **Claude Sonnet 4.6** → STANDARD MODE 建议性约束，避免过度干预
- 使用 **Gemini 3.1 Pro / Claude Opus 4.6** → PRO MODE 极简规则，避免降效

> Skills 与 Rules 不同：Skills 是**按需加载**的，只有当你的请求语义匹配时才激活，对强模型几乎无负面影响。

### 🔀 模型档位切换方法

打开 `GEMINI.md`，根据当前使用的模型启用对应区块（取消注释），并注释掉其他区块：

| 你选择的模型 | 启用区块 | 操作 |
|------------|---------|------|
| Gemini 3 Flash / GPT-OSS 120B | `LITE MODE` | 默认已启用，无需修改 |
| Claude Sonnet 4.6 | `STANDARD MODE` | 取消注释 STANDARD 区块，注释 LITE 区块 |
| Gemini 3.1 Pro / Claude Opus 4.6 | `PRO MODE` | 取消注释 PRO 区块，注释 LITE 区块 |

**切换只需两步：**
1. 用任意文本编辑器打开 `~/.gemini/GEMINI.md`
2. 注释掉当前区块，取消注释目标区块，保存

### 🌐 语言开关

默认语言为**简体中文**，修改 GEMINI.md 内对应规则行即可切换：
- 英文：`Language: All responses and code comments in English.`
- 繁體中文：`語言：所有回覆和程式碼注釋必須使用繁體中文。`

---

## 🔄 升级方式

```bash
git pull origin main
setup.bat   # Windows
./setup.sh  # Linux/macOS
```

或在 Antigravity 聊天框输入 `检查更新`，Tuner-Update Skill 自动引导。

---

## 📊 社区参考资源（已验证真实存在）

| 仓库 | 描述 | 状态 |
|------|------|------|
| [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) | 1,259+ 通用技能，支持多 AI 工具 | ✅ 已验证 |
| [rominirani/antigravity-skills](https://github.com/rominirani/antigravity-skills) | Google 官方 Codelab 示例仓库 | ✅ 已验证 |
| [guanyang/antigravity-skills](https://github.com/guanyang/antigravity-skills) | 专业领域技能集（全栈/设计/运维） | ✅ 已验证 |
| [rmyndharis/antigravity-skills](https://github.com/rmyndharis/antigravity-skills) | 300+ 技能，支持 npx 安装 | ✅ 已验证 |
| [anthonylee991/gemini-superpowers-antigravity](https://github.com/anthonylee991/gemini-superpowers-antigravity) | 类 Claude Superpowers 的增强包 | ✅ 已验证 |

---

## ⚠️ 重要说明

- **Antigravity 路径规范（2026.03 确认）**：
  - `.agent/skills/`（单数，兼容性最好，本工具优先）
  - `.agents/skills/`（复数，官方新标准，`setup.bat` 自动检测兼容）
  - 全局：`~/.gemini/antigravity/skills/`
- **GEMINI.md 优先级**：项目级 `.agent/GEMINI.md` > 全局 `~/.gemini/GEMINI.md`
- **冲突风险**：Gemini CLI 也写 `~/.gemini/GEMINI.md`，建议项目级优先，或运行 `conflict-check.ps1`

---

## 📝 更新日志

### v2026.03.18（稳定性修复版）
- **修复** setup.bat 中文乱码问题（改为 3 行 ASCII 启动器 + setup.ps1 主逻辑）
- **修复** xcopy 循环复制错误（改用 PowerShell Copy-Item）
- **修复** 全局 Skills 安装路径不正确（现在正确写入 `~/.gemini/antigravity/skills/`）
- **新增** `tools/` 工具目录：tuner_check.bat/ps1（部署检测）、conflict_check.bat
- **新增** setup.ps1 支持命令行参数：`-Silent`、`-GlobalOnly`、`-Check`
- setup.ps1 支持自动备份已有 GEMINI.md

### v2026.03.17（初始发布）
- 5 个经过多轮真实调教验证的核心 Skills
- Windows/Linux/macOS 三端安装脚本
- PowerShell 冲突检测脚本
- npx 安装器支持
- Meta-Skill（Tuner-Update）：自检查更新机制
- sample_project：最小化 FastAPI 示例
- GitHub Actions CI 工作流
- 调教原理章节

---

## 🤝 贡献

欢迎提交 PR 或 Issue！  
核心贡献方向：新增 Skill、优化现有 Rules、补充示例项目。

---

*本项目基于与 Grok AI 的多轮真实交互调教过程整理，经过实战验证。*
