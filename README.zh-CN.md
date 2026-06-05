# ui-check

一个用于设计验收的通用 AI 能力仓库，内置 Claude Code 适配器，但不依赖 Claude Code 才能使用。

它用于把 `MasterGo 设计基准` 和 `真实实现页面 / 截图证据` 做对比，输出一份研发可直接修复的问题验收报告。

## 不是只给 Claude Code 用的

你可以把 `ui-check` 用在这些平台：

- Claude Code
- Cursor
- Windsurf
- VS Code AI 助手
- ChatGPT Projects
- Gemini
- 企业内部 Agent / Copilot

仓库分成两层：

- 通用能力层：`AGENT-SPEC.md` + `prompts/universal-audit-prompt.zh-CN.md`
- Claude Code 适配层：`SKILL.md`

## 它能做什么

- 对 `单页面 / 单状态 / 单视口` 做设计验收走查
- 支持 `MasterGo + 真实页面 URL`
- 支持 `MasterGo + 移动端截图`
- 对移动端截图先做逻辑尺寸归一化，再判断偏差
- 同时输出：
  - Markdown 问题报告
  - HTML 图文报告

## 适用场景

- 提测阶段设计走查
- 联调后的 UI 偏差检查
- 上线前设计验收
- 移动端截图验收
- 需要给设计和研发同步同一份问题文档

## 不适用场景

- 全站批量巡检
- 没有设计依据的主观美化建议
- 自动修代码
- 复杂动画逐帧分析

## 仓库结构

```text
.
├── AGENT-SPEC.md
├── SKILL.md
├── README.md
├── README.zh-CN.md
├── LICENSE
├── prompts/
│   └── universal-audit-prompt.zh-CN.md
├── install-skill.sh
├── assets/
│   ├── audit-input-example.yaml
│   └── report-template.html
└── references/
    ├── issue-taxonomy.md
    └── report-template.md
```

## 安装

### 方式 1：在任意 AI 工具里直接使用

直接使用这三个文件：

- `AGENT-SPEC.md`
- `prompts/universal-audit-prompt.zh-CN.md`
- `assets/audit-input-example.yaml`

这种方式不依赖 Claude Code。

### 方式 2：从 GitHub 安装到 Claude Code

```bash
python3 ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  https://github.com/hitsuaoko-creator/ui-check
```

### 方式 3：本地克隆后安装到 Claude Code

```bash
git clone https://github.com/hitsuaoko-creator/ui-check.git
cd ui-check
chmod +x install-skill.sh
./install-skill.sh
```

安装脚本会把 Claude 适配层安装到：

- `~/.codex/skills/ui-check`
- 如果存在 `~/.claude/skills`，也会同步安装到 `~/.claude/skills/ui-check`

## 如何触发

### 在任意 AI 工具里

把 `prompts/universal-audit-prompt.zh-CN.md` 的内容复制到你的 AI 工具里，再提供：

- `design_reference`
- `implementation_target`
- `audit_scope`

如果工具支持附件，就把截图一起传进去。

### 在 Claude Code 里

最稳的方式是直接点名：

```text
用 ui-check 这个 skill，帮我做移动端设计验收走查。
```

或者：

```text
请按 ui-check 的方式，对比 MasterGo 和实现截图，输出问题验收列表。
```

## 输入模型

这个能力使用双输入模型：

1. `design_reference`
2. `implementation_target`

### 推荐的移动端截图输入

```yaml
design_reference:
  type: "mastergo"
  value: "https://mastergo.example/goto/abc123"
  frame_name: "商品列表页 / 默认态"
  logical_size: "393x852"

implementation_target:
  type: "screenshot"
  image: "/absolute/path/product-list-iphone15.png"
  device_name: "iPhone 15"
  logical_viewport: "393x852"
  screenshot_pixel_size: "1179x2556"
  dpr: 3
  includes_status_bar: true
  includes_home_indicator: true
  display_zoom: false
  target_state: "默认加载完成态"

audit_scope:
  page_name: "商品列表页"
  modules: "AUTO"
  focus_points: "AUTO"
  ignore_list: "营销浮层、实验开关位"
  env_note: "预发环境，部分字段为 mock 数据"
  severity_rule: "默认输出 P0-P2，P3 仅在影响一致性时输出"
```

完整样例见：`assets/audit-input-example.yaml`

### `AUTO` 默认值

团队使用时，`modules` 和 `focus_points` 不需要每次手动录入。

推荐默认写法：

```yaml
audit_scope:
  page_name: "页面名"
  modules: "AUTO"
  focus_points: "AUTO"
```

含义：

- `modules: AUTO` = 自动检查当前截图或画板中所有可见主要模块
- `focus_points: AUTO` = 自动使用通用默认检查清单

默认检查清单包括：

- 布局与间距
- 尺寸与对齐
- 字体与排版
- 颜色与视觉样式
- 信息层级
- 组件状态
- 图标与图片表现
- 安全区处理
- 文案承载与截断
- 缺失与冗余元素

## 移动端截图规则

移动端截图验收时：

- 不能把截图原始像素和 1x 设计稿直接硬比
- 必须在同一逻辑尺寸坐标系里比较
- 整屏同比放大或缩小通常不算问题
- 只报告局部比例失衡、间距异常、对齐问题、层级偏差、状态偏差、缺失或冗余元素

## 输出内容

能力会生成：

1. 基于 `references/report-template.md` 的 Markdown 报告
2. 基于 `assets/report-template.html` 的 HTML 图文报告

报告通常包括：

- 严重级别统计
- 归一化说明
- 问题汇总表
- 详细 issue 列表
- 阻塞项 / 不在范围项
- 验收结论

## 许可证

MIT
