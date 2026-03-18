---
name: Tuner-Update
description: 检查 GitHub 上 antigravity-gemini-flash-ultimate-tuner 仓库是否有更新，并提示用户拉取最新版。保持调教成果永不过期。每月自动检查一次，或用户输入"检查更新"时触发。
---

# Tuner-Update Skill（Meta-Skill：自检查更新）

**触发条件**
- 用户输入"检查更新"、"升级调教"、"check update"
- 每月首次启动项目时自动检查

**执行流程**
1. 使用 Browser 工具访问 `https://github.com/[你的用户名]/antigravity-gemini-flash-ultimate-tuner`
2. 检查最新 release tag 或 main 分支最新 commit 时间（对比本地 README 中的 Version 字段）。
3. 同时检查以下关键依赖的最新版本（Browser 搜索）：
   - Antigravity IDE 最新版本
   - Gemini 3 Flash 模型是否有更新或更优替代
   - uv、Python、Distroless 镜像等常用依赖
4. 对比本地版本 vs 最新版本，输出差异摘要。
5. 如果有更新，提示升级命令；否则确认当前最新。

**输出格式**

**Update Check Result**
```
当前版本：v2026.03.17
最新版本：v20XX.XX.XX
状态：✅ 已是最新 / ⚠️ 有更新可用

[如有更新]
更新内容摘要：
- 新增 Skill：...
- 修复：...
- Rules 优化：...

升级命令：
  git pull origin main
  # 然后重新运行 setup.bat / setup.sh
```

**依赖版本速查**
```
uv 最新版：X.X.X（来源：github.com/astral-sh/uv/releases）
Python 推荐生产版：X.X.X（来源：python.org/downloads）
Antigravity 最新版：X.X.X（来源：antigravity.google 官方）
```
