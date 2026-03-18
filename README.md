# Antigravity Gemini 3 Flash Ultimate Tuner

> **经过多轮真实交互调教出的 Gemini 3 Flash 最强配置包**  
> 让 Gemini 3 Flash 在 [Google Antigravity IDE](https://antigravity.google/) 中接近 Pro 级表现

[![Version](https://img.shields.io/badge/Version-2026.03.17-blue)](.)
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
├── setup.bat                              ← Windows 一键安装（含路径自动检测）
├── setup.sh                               ← Linux/macOS 一键安装
├── npx-install.js                         ← npx 命令支持入口
├── conflict-check.ps1                     ← PowerShell 冲突检测
├── package.json                           ← npm 包配置
├── LICENSE                                ← MIT 协议
├── 更正对比表.md                           ← 对话中错误信息核实记录
├── .github/
│   └── workflows/
│       └── validate-skills.yml            ← GitHub Actions CI 验证
├── sample_project/                        ← 最小化示例项目
│   ├── README.md
│   ├── pyproject.toml
│   ├── src/
│   │   └── main.py
│   └── tests/
│       └── test_main.py
└── .agent/
    └── skills/
        ├── Best-Practice-Researcher/      ← 强制先搜索最新实践
        │   └── SKILL.md
        ├── Architect-Dialogue/            ← 架构规划 + 方案对比
        │   └── SKILL.md
        ├── Code-Reviewer-Debugger/        ← 严格调试 + Reflection
        │   └── SKILL.md
        ├── Tester/                        ← 自动生成 + 执行测试
        │   └── SKILL.md
        └── Tuner-Update/                  ← Meta-Skill：自检查更新
            └── SKILL.md
```

---

## 🚀 快速安装

### 方式 A：Windows（推荐，含自动路径检测）
```bat
# 1. 进入你的 Antigravity 项目根目录
# 2. 将本仓库文件复制或 clone 到该目录
# 3. 双击运行（自动检测 .agent / .agents 并兼容）
setup.bat
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

在 Antigravity 聊天框输入：
```
测试调教状态
```
正常应看到 Agent 确认已加载所有 Rules 和 Skills 的完整报告。

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

本工具的 `GEMINI.md` 包含 9 条强制规则。**默认语言为简体中文**，如需切换为英文，将文件内第 5 条规则中的"简体中文"改为"English"即可。

核心逻辑：

1. 任何任务 → 先调用 Best-Practice-Researcher（≥2 次真实搜索）
2. 涉及规划 → 调用 Architect-Dialogue（对比表 + 树状图 + 确认）
3. 遇到错误 → 自动 Reflection 循环（禁止说"模型限制"）
4. 全部输出必须有工具调用证据（禁止 Hallucination）
5. **语言开关**：规则第 5 条，默认"简体中文"，可改为"English"

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

### v2026.03.17（初始发布）
- 5 个经过多轮真实调教验证的核心 Skills
- Windows/Linux/macOS 三端安装脚本（含 .agent/.agents 自动检测）
- PowerShell 冲突检测脚本
- npx 安装器支持
- Meta-Skill（Tuner-Update）：自检查更新机制
- sample_project：最小化 FastAPI 示例演示 Skills 生效效果
- GitHub Actions CI：自动验证所有 SKILL.md 格式合规
- 调教原理章节：解释 Rules + Skills 组合机制

---

## 🤝 贡献

欢迎提交 PR 或 Issue！  
核心贡献方向：新增 Skill、优化现有 Rules、补充示例项目。

---

*本项目基于与 Grok AI 的多轮真实交互调教过程整理，经过实战验证。*
