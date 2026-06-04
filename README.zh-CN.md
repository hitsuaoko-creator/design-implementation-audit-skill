# design-implementation-audit

一个面向设计验收的通用 AI 审核规范仓库，内置 Claude Code 适配器，但不依赖 Claude Code 才能使用。

它的作用是把 `MasterGo 设计基准` 和 `真实实现页面 / 截图证据` 做对比，输出一份设计、测试、研发都能直接协作的问题验收报告。

## 这不是只给 Claude Code 用的

这个仓库现在分成两层：

- 通用层：任何 IDE、AI 助手、企业内部 Agent 都可以直接复用
- Claude Code 适配层：保留 `SKILL.md`，方便在 Claude Code 中原生触发

你可以把它用在这些工具里：

- Cursor
- Windsurf
- VS Code 内的 AI 助手
- ChatGPT Projects
- Gemini
- 内部自研 Copilot / Agent

## 核心入口文件

- 通用审核规范：`AGENT-SPEC.md`
- 通用中文 Prompt：`prompts/universal-audit-prompt.zh-CN.md`
- Claude Code Skill 适配器：`SKILL.md`
- 输入样例：`assets/audit-input-example.yaml`
- Markdown 报告模板：`references/report-template.md`
- HTML 报告模板：`assets/report-template.html`

## 它能做什么

- 对 `单页面 / 单状态 / 单视口` 做设计验收走查
- 支持 `MasterGo + 真实页面 URL`
- 支持 `MasterGo + 移动端截图`
- 对移动端截图先做逻辑尺寸归一化，再判断偏差
- 输出研发可直接修复的问题列表
- 同时产出：
  - Markdown 验收报告
  - HTML 图文报告

## 适用场景

- 提测阶段设计走查
- 联调后的 UI 偏差检查
- 上线前验收
- 移动端高分辨率截图验收
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
├── install-skill.sh
├── prompts/
│   └── universal-audit-prompt.zh-CN.md
├── assets/
│   ├── audit-input-example.yaml
│   └── report-template.html
└── references/
    ├── issue-taxonomy.md
    └── report-template.md
```

## 怎么用

### 用在任何 AI 工具里

最简单的方式：

1. 把 `AGENT-SPEC.md` 作为执行规则提供给 AI
2. 把 `prompts/universal-audit-prompt.zh-CN.md` 复制进去作为任务提示词
3. 再附上你的输入数据

也就是这三样一起喂给 AI：

- 通用规则
- 通用 Prompt
- 设计稿与实现证据

### 用在 Claude Code 里

如果你要在 Claude Code 中原生触发，可以安装本仓库里的 `SKILL.md`。

GitHub 安装方式：

```bash
python3 ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  https://github.com/hitsuaoko-creator/design-implementation-audit-skill
```

本地克隆后安装：

```bash
git clone https://github.com/hitsuaoko-creator/design-implementation-audit-skill.git
cd design-implementation-audit-skill
chmod +x install-skill.sh
./install-skill.sh
```

安装脚本会把 Claude 适配层复制到：

- `~/.codex/skills/design-implementation-audit`
- 如果存在 `~/.claude/skills`，也会同步复制到 `~/.claude/skills/design-implementation-audit`

## 输入模型

这个审核规范使用“双输入模型”：

1. `design_reference`
2. `implementation_target`

### `design_reference`

表示“设计上应该长什么样”。

推荐字段：

- `type`
- `value`
- `frame_name`
- `logical_size`

通常写法：

```yaml
design_reference:
  type: "mastergo"
  value: "https://mastergo.example/goto/abc123"
  frame_name: "商品列表页 / 默认态"
  logical_size: "393x852"
```

### `implementation_target`

表示“实际上实现成什么样”。

支持三种模式：

- `live_page`
- `screenshot`
- `screenshot_set`

移动端截图推荐写法：

```yaml
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
```

页面范围和关注点：

```yaml
audit_scope:
  page_name: "商品列表页"
  modules: "Header、筛选区、表格首屏"
  focus_points: "间距、字号、按钮状态、表格密度"
  ignore_list: "营销浮层、实验开关位"
  env_note: "预发环境，部分字段为 mock 数据"
  severity_rule: "默认输出 P0-P2，P3 仅在影响一致性时输出"
```

完整样例见：`assets/audit-input-example.yaml`

## 移动端截图的关键规则

这条规则是这个仓库最重要的判断边界：

> 不能把移动端高分辨率截图的原始像素，直接和 1x 的设计稿像素硬比。

正确做法是：

1. 先识别设计稿逻辑尺寸
2. 再识别设备逻辑视口
3. 把截图映射回同一逻辑坐标系
4. 再比较布局、间距、比例、层级、状态

因此这些通常不算问题：

- DPR 导致的整屏同比放大
- 轻微字体栅格化差异
- 1px 级噪声
- 状态栏或 Home Indicator 裁切基准不同

这些更可能是真问题：

- 局部模块比例失衡
- 间距只在局部变紧或变松
- 安全区处理不一致
- 组件状态和设计稿不一致
- 缺失或多余元素

## 输出内容

默认输出两种报告：

1. Markdown 报告
2. HTML 图文报告

报告内容包括：

- 执行摘要
- 严重级别统计
- 归一化说明
- 问题汇总表
- Issue 详情
- 阻塞项 / 不在范围项
- 验收结论

## 触发方式

### 在通用 AI 工具里

最简单的做法是直接粘贴通用 Prompt，然后附上输入数据。

### 在 Claude Code 里

直接点名：

```text
用 design-implementation-audit 这个 skill，帮我做移动端设计验收走查。
```

或者：

```text
请按 design-implementation-audit 的方式，对比 MasterGo 和实现截图，输出问题验收列表。
```

## 推荐团队工作流

1. 设计或 QA 提供 MasterGo 链接和目标状态
2. QA、PM 或研发提供真实页面 URL 或截图证据
3. AI 按本仓库规范执行走查
4. 输出：
   - Markdown 给 issue 跟踪
   - HTML 给设计 / 研发图文同步

## 发布说明

这个仓库的定位已经不是“只给 Claude Code 用的 Skill”。

它现在是：

- 一个可跨 IDE / 跨 AI 工具复用的审核规范仓库
- 外加一个 Claude Code 适配器
