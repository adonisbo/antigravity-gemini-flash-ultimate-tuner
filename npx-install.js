#!/usr/bin/env node
/**
 * Antigravity Gemini 3 Flash Ultimate Tuner
 * npx 安装器入口
 * Version: 2026.03.17
 *
 * 使用方式（发布到 npm 后）：
 *   npx antigravity-gemini-flash-ultimate-tuner
 *
 * 本地测试：
 *   node npx-install.js
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

// ─── 颜色输出 ────────────────────────────────────────────────
const cyan  = (s) => `\x1b[36m${s}\x1b[0m`;
const green = (s) => `\x1b[32m${s}\x1b[0m`;
const yellow= (s) => `\x1b[33m${s}\x1b[0m`;
const red   = (s) => `\x1b[31m${s}\x1b[0m`;

console.log(cyan('\n======================================================='));
console.log(cyan(' Antigravity Gemini 3 Flash Ultimate Tuner'));
console.log(cyan(' npx Installer v2026.03.17'));
console.log(cyan('=======================================================\n'));

const cwd = process.cwd();
const agentDir     = path.join(cwd, '.agent');
const agentSkills  = path.join(agentDir, 'skills');
const globalDir    = path.join(os.homedir(), '.gemini', 'antigravity');
const globalSkills = path.join(globalDir, 'skills');
const backupDir    = path.join(cwd, '.tuner-backup');

// 安装包自身所在目录（npm 包根目录）
const pkgDir = path.join(__dirname);

// ─── 冲突检测 ────────────────────────────────────────────────
console.log('[冲突检测] 检查全局 GEMINI.md...');
const globalGeminiPath = path.join(os.homedir(), '.gemini', 'GEMINI.md');
if (fs.existsSync(globalGeminiPath)) {
  console.log(yellow('⚠️  警告：检测到全局 GEMINI.md 已存在，可能被 Gemini CLI 覆盖'));
  console.log(yellow('    建议：优先使用项目级 .agent/GEMINI.md\n'));
} else {
  console.log(green('    ✅ 无全局冲突\n'));
}

// ─── Step 1: 创建目录 ────────────────────────────────────────
console.log('[1/4] 创建 .agent 目录结构...');
fs.mkdirSync(agentSkills, { recursive: true });
console.log(green('    ✅ 目录创建完成\n'));

// ─── Step 2: 部署 GEMINI.md ──────────────────────────────────
console.log('[2/4] 部署全局 Rules (GEMINI.md)...');
const srcGemini = path.join(pkgDir, 'GEMINI.md');
const dstGemini = path.join(agentDir, 'GEMINI.md');

if (fs.existsSync(srcGemini)) {
  if (fs.existsSync(dstGemini)) {
    fs.mkdirSync(backupDir, { recursive: true });
    fs.copyFileSync(dstGemini, path.join(backupDir, 'GEMINI.md.bak'));
    console.log(yellow('    ℹ️  已备份原 GEMINI.md → .tuner-backup/'));
  }
  fs.copyFileSync(srcGemini, dstGemini);
  console.log(green('    ✅ GEMINI.md 已部署\n'));
} else {
  console.log(red('    ❌ 未找到 GEMINI.md（请确保从仓库根目录运行）\n'));
}

// ─── Step 3: 部署 Skills ─────────────────────────────────────
console.log('[3/4] 部署所有 Skills...');
const skillNames = [
  'Best-Practice-Researcher',
  'Architect-Dialogue',
  'Code-Reviewer-Debugger',
  'Tester',
  'Tuner-Update'
];

skillNames.forEach(skillName => {
  const src = path.join(pkgDir, '.agent', 'skills', skillName, 'SKILL.md');
  const dstDir = path.join(agentSkills, skillName);
  const dst = path.join(dstDir, 'SKILL.md');

  if (fs.existsSync(src)) {
    fs.mkdirSync(dstDir, { recursive: true });
    fs.copyFileSync(src, dst);
    console.log(green(`    ✅ ${skillName}`));
  } else {
    console.log(yellow(`    ⚠️  ${skillName} 未找到，跳过`));
  }
});

console.log('');

// ─── Step 4: 全局安装提示 ────────────────────────────────────
console.log('[4/4] 全局安装提示...');
console.log(yellow('    如需全局安装（所有项目共享），请手动运行：'));
console.log(`    mkdir -p "${globalDir}"`);
console.log(`    cp -r .agent/skills/* "${globalSkills}/"`);
console.log('');

// ─── 完成 ────────────────────────────────────────────────────
console.log(cyan('======================================================='));
console.log(cyan(' 安装完成！'));
console.log(cyan('======================================================='));
console.log(` 项目级 Rules   → ${dstGemini}`);
console.log(` 项目级 Skills  → ${agentSkills}`);
console.log('');
console.log(' ▶ 下一步：');
console.log('   1. 重启 Antigravity Agent Manager');
console.log('   2. 在聊天框输入：测试调教状态');
console.log('   3. 确认 Rules 和 Skills 已加载');
console.log(cyan('=======================================================\n'));
