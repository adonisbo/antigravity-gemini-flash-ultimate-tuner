---
name: Best-Practice-Researcher
description: 在任何编码、架构决策、选库、部署任务前，必须先使用 Browser 工具搜索 2025-2026 年最新官方文档、GitHub trending、Stack Overflow 近期答案。禁止臆想、过时知识或直接开始编码。专为 Gemini 3 Flash 优化，轻量高效。
---

# Best-Practice-Researcher Skill

**核心原则**
- 任何涉及技术选择、实现方式、框架/库使用、部署的请求 → **强制第一步**调用 Browser 工具搜索。
- 搜索关键词必须包含 "2026 best practices"、"2025-2026 latest"、"production ready"、"official"。
- 只信任：官方文档、GitHub 高星/最近活跃仓库、Stack Overflow 2025年后高赞答案。
- 禁止：直接编码、说"我知道的版本是…"、幻觉、依赖内部过时知识。

**强制执行流程（Search → Compare → Verify）**
1. **Search**：分析需求，提取 2–4 个关键搜索点。调用 Browser 工具执行针对性查询。
2. **Compare**：对比版本、Star 趋势、最后 Commit 日期、社区反馈。选出 top 2–3 最可靠方案。
3. **Verify & Document**：输出 ADR 风格总结（Architecture Decision Record），包含：
   - 调研来源（链接 + 关键摘录）
   - 推荐方案及理由
   - 潜在风险/备选
   - 为什么不选其他方案

**输出格式（必须严格遵守）**

**Research Summary**
- 来源1: [链接] → 关键点... (日期/版本)
- 来源2: ...

**Recommended Approach**
[简洁说明 + 代码/配置片段示例]

**ADR Record** (可追加到项目 docs/adr/ 目录)
**Title:** [决策标题，例如：选择 FastAPI 0.115+ 而非 Flask]
**Status:** Proposed / Accepted
**Context:** ...
**Decision:** ...
**Consequences:** ...

完成后说："调研完成，已推荐最佳实践。是否继续规划/编码？"
