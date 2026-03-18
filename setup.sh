#!/usr/bin/env bash
# =======================================================
#  Antigravity Gemini 3 Flash Ultimate Tuner
#  Version: 2026.03.17 - Ultimate Edition
#  支持：Linux / macOS
# =======================================================

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGENT_DIR="$PROJECT_DIR/.agent"
GLOBAL_DIR="$HOME/.gemini/antigravity"
GLOBAL_SKILLS="$GLOBAL_DIR/skills"
BACKUP_DIR="$PROJECT_DIR/.tuner-backup"

echo "======================================================="
echo " Antigravity Gemini 3 Flash Ultimate Tuner"
echo " Version: 2026.03.17 - Ultimate Edition"
echo "======================================================="
echo ""

# 冲突检测
echo "[冲突检测] 检查全局 GEMINI.md..."
if [ -f "$HOME/.gemini/GEMINI.md" ]; then
    echo "⚠️  警告：检测到 $HOME/.gemini/GEMINI.md 已存在"
    echo "    可能被 Gemini CLI 覆盖，建议优先使用项目级 Rules。"
    echo ""
fi

# Step 1
echo "[1/4] 创建 .agent 目录结构..."
mkdir -p "$AGENT_DIR/skills"

# Step 2
echo "[2/4] 部署全局 Rules (GEMINI.md)..."
if [ -f "$AGENT_DIR/GEMINI.md" ]; then
    echo "    检测到已有 GEMINI.md，备份中..."
    mkdir -p "$BACKUP_DIR"
    cp "$AGENT_DIR/GEMINI.md" "$BACKUP_DIR/GEMINI.md.bak"
fi
cp "$PROJECT_DIR/GEMINI.md" "$AGENT_DIR/GEMINI.md"
echo "    ✅ Rules 已部署"

# Step 3
echo "[3/4] 部署所有 Skills..."
cp -r "$PROJECT_DIR/.agent/skills/"* "$AGENT_DIR/skills/"
echo "    ✅ Skills 已部署（5 个核心 Skills）"

# Step 4 - 全局安装（可选）
echo "[4/4] 全局安装（可选）..."
echo ""
read -p "是否同时安装到全局目录（所有 Antigravity 项目共享生效）？(y/N): " choice
case "$choice" in
  y|Y )
    mkdir -p "$GLOBAL_DIR"
    mkdir -p "$GLOBAL_SKILLS"
    if [ -f "$GLOBAL_DIR/GEMINI.md" ]; then
        mkdir -p "$BACKUP_DIR"
        cp "$GLOBAL_DIR/GEMINI.md" "$BACKUP_DIR/GLOBAL_GEMINI.md.bak"
        echo "    ✅ 已备份原全局 GEMINI.md"
    fi
    cp "$PROJECT_DIR/GEMINI.md" "$GLOBAL_DIR/GEMINI.md"
    cp -r "$PROJECT_DIR/.agent/skills/"* "$GLOBAL_SKILLS/"
    echo "    ✅ 全局安装完成：$GLOBAL_DIR"
    ;;
  * )
    echo "    跳过全局安装（仅项目级生效）"
    ;;
esac

echo ""
echo "======================================================="
echo " 安装完成！"
echo "======================================================="
echo " 项目级 Rules   → $AGENT_DIR/GEMINI.md"
echo " 项目级 Skills  → $AGENT_DIR/skills/"
echo ""
echo " ▶ 下一步："
echo "   1. 重启 Antigravity Agent Manager"
echo "   2. 在聊天框输入：测试调教状态"
echo "   3. 确认 Rules 和 Skills 已加载"
echo "   4. 开始享受 Gemini 3 Flash 极致模式！"
echo "======================================================="
