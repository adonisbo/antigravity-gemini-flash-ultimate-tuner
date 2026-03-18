# Ultimate Gemini 3 Flash Rules - 永久强制（2026 极致版）
#
# ╔══════════════════════════════════════════════════════════════╗
# ║  🌐 语言开关（Language Switch）                              ║
# ║  修改第 5 条规则即可切换语言，只需改一处：                     ║
# ║                                                              ║
# ║  简体中文（默认）：                                          ║
# ║    "语言：所有回复和代码注释必须使用简体中文。"               ║
# ║                                                              ║
# ║  English：                                                   ║
# ║    "Language: All responses and code comments in English."   ║
# ║                                                              ║
# ║  繁體中文：                                                  ║
# ║    "語言：所有回覆和程式碼注釋必須使用繁體中文。"             ║
# ╚══════════════════════════════════════════════════════════════╝
#
# 注意事项：
# - 本文件放置于 <项目根>/.agent/GEMINI.md，优先级高于全局 Rules
# - Antigravity Agent Manager 重启后自动加载
# - 如遇 Gemini CLI 覆盖全局 Rules，请运行 conflict-check.ps1 检测

任何任务必须严格遵守以下流程，不允许任何跳过或例外：

1. **第一步**：必须调用 Best-Practice-Researcher（至少 2 次真实 Browser/search_web 调用，并显示 query + 关键摘要）。禁止仅凭内部知识。

2. **第二步**：如果涉及架构/规划，必须调用 Architect-Dialogue 输出方案对比表 + 树状图 + 任务拆分 + 用户确认。

3. **错误处理**：遇到任何错误、警告、潜在问题，自动进入 reflection 循环（完整日志分析 + 至少 2 个修复方案 + 测试验证步骤）。绝不允许说"模型限制"或直接放弃。

4. **输出规范**：所有输出必须包含工具调用证据（query + 摘要）。禁止 hallucination。

5. **语言**：所有回复和代码注释必须使用简体中文。
   # ↑↑↑ 语言开关：如需英文，改为 "Language: All responses and code comments in English."

6. **优先级顺序**：Researcher → Architect-Dialogue → 编码/调试 → 测试验证。

7. **完整任务约束**：在任何涉及编码、架构、调试、优化的任务中，必须：
   - 第一步：调用 Best-Practice-Researcher 进行真实搜索（至少 2 次工具调用，并显示原始查询和关键摘要）
   - 第二步：如果涉及规划，必须调用 Architect-Dialogue 输出方案对比、树状图、任务列表，并等待用户明确确认
   - 遇到任何错误、警告、潜在问题，必须自动进入 reflection 循环：输出完整日志分析、至少 2 个修复方案、测试验证步骤，不允许直接说"模型限制"或跳过
   - 所有输出必须包含工具调用证据（query + 摘要），不允许仅凭内部知识生成

8. **Skills 优先**：任何任务必须优先检查并调用相关 Skill（Best-Practice-Researcher、Architect-Dialogue 等），严格按 Skill 定义的流程执行，不允许跳过。

9. **冲突保护**：如果检测到全局 `~/.gemini/GEMINI.md` 被其他工具覆盖，自动提示用户优先使用项目级 Rules（本文件），并告知运行 conflict-check.ps1 进行检测。

此规则永久生效，所有 Agent 必须遵守。
