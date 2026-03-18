# sample_project — 调教效果演示项目

这是一个**最小化 FastAPI 项目**，用于直观演示 Skills 被激活后 Gemini 3 Flash 的工作方式。

## 结构

```
sample_project/
├── README.md           ← 本文件
├── pyproject.toml      ← 依赖管理（使用 uv）
├── src/
│   ├── __init__.py
│   └── main.py         ← FastAPI 应用入口
└── tests/
    ├── __init__.py
    └── test_main.py    ← pytest 测试用例
```

## 如何使用（配合 Antigravity 演示）

1. 在 Antigravity 中打开本目录作为项目
2. 确保已运行 `setup.bat` 部署 Rules 和 Skills
3. 在聊天框输入以下任意一条，观察 Skills 如何自动触发：

```
# 测试 Best-Practice-Researcher
帮我给 src/main.py 增加 JWT 认证功能

# 测试 Architect-Dialogue
分析当前项目架构，给出改进方案

# 测试 Code-Reviewer-Debugger
运行 pytest 后报错了：[粘贴错误信息]

# 测试 Tester
为 src/main.py 中的所有路由生成测试用例
```

## 快速启动

```bash
# 安装依赖（使用 uv）
uv sync

# 启动开发服务器
uv run uvicorn src.main:app --reload --port 8000

# 运行测试
uv run pytest tests/ -v --cov=src
```

## 预期 Skills 触发效果

| 输入任务 | 应自动触发的 Skill | 预期行为 |
|---------|-----------------|---------|
| "增加 JWT 认证" | Best-Practice-Researcher | 先搜索 2026 JWT + FastAPI 最佳实践，再编码 |
| "分析架构" | Architect-Dialogue | 输出方案对比表 + 树状图 + 任务列表 |
| "pytest 报错" | Code-Reviewer-Debugger | 日志分析 + ≥3 个修复方案 |
| "生成测试" | Tester | 自动生成 pytest 用例 + 覆盖率报告 |
