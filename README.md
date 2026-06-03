# design-implementation-audit

A Claude Code skill for design acceptance review.

It compares a MasterGo design reference with a real implemented page or screenshot evidence, then outputs a developer-ready acceptance report with actionable issues.

## What It Does

- audits one page, one state, one viewport at a time
- supports `MasterGo + live page URL`
- supports `MasterGo + mobile screenshot`
- normalizes mobile screenshots by logical viewport before comparing
- outputs:
  - Markdown issue report
  - visual HTML report

## Best Fit

Use this skill for:

- 提测阶段设计走查
- 联调后的 UI 偏差检查
- 上线前设计验收
- 移动端截图验收
- 需要给设计和研发一份可直接协作的问题清单

Do not use it for:

- 全站批量巡检
- 没有设计依据的主观审美建议
- 自动修代码
- 复杂动画逐帧分析

## Repository Structure

```text
.
├── SKILL.md
├── README.md
├── install-skill.sh
├── assets/
│   ├── audit-input-example.yaml
│   └── report-template.html
└── references/
    ├── issue-taxonomy.md
    └── report-template.md
```

## Install

### Option 1: Install from GitHub

```bash
python3 ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  https://github.com/hitsuaoko-creator/design-implementation-audit-skill
```

### Option 2: Install from a local clone

```bash
git clone https://github.com/hitsuaoko-creator/design-implementation-audit-skill.git
cd design-implementation-audit-skill
chmod +x install-skill.sh
./install-skill.sh
```

The local install script copies the skill into:

- `~/.codex/skills/design-implementation-audit`
- `~/.claude/skills/design-implementation-audit` if `~/.claude/skills` already exists

## How To Trigger It

The most reliable trigger is to name the skill directly:

```text
用 design-implementation-audit 这个 skill，帮我做移动端设计验收走查。
```

Or:

```text
请按 design-implementation-audit 的方式，对比 MasterGo 和实现截图，输出问题验收列表。
```

It should also trigger for requests like:

- “帮我做提测前设计走查”
- “对比 MasterGo 和线上页面，输出研发可修复的问题单”
- “做一份设计验收报告”

## Input Model

This skill uses two inputs:

1. `design_reference`
2. `implementation_target`

### Recommended Mobile Screenshot Input

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
  modules: "Header、筛选区、表格首屏"
  focus_points: "间距、字号、按钮状态、表格密度"
  ignore_list: "营销浮层、实验开关位"
  env_note: "预发环境，部分字段为 mock 数据"
  severity_rule: "默认输出 P0-P2，P3 仅在影响一致性时输出"
```

### Recommended Live Page Input

```yaml
design_reference:
  type: "mastergo"
  value: "https://mastergo.example/goto/abc123"

implementation_target:
  type: "live_page"
  page_url: "https://staging.example.com/products"
  target_state: "默认加载完成态"
  viewport: "393x852"

audit_scope:
  page_name: "商品列表页"
  modules: "Header、筛选区、表格首屏"
  login_steps: "先登录，再进入商品列表页"
  focus_points: "间距、字号、按钮状态"
```

For a ready-made input file, see `assets/audit-input-example.yaml`.

## Mobile Screenshot Rule

For mobile screenshot audits:

- do not compare raw screenshot pixels to a 1x design frame
- compare in the same logical coordinate system
- treat whole-screen uniform scaling as non-issue
- report only local distortion, spacing drift, alignment errors, hierarchy problems, state mismatches, or missing/extra elements

This is the core rule that keeps high-DPR screenshots from being misjudged.

## Output

The skill should generate:

1. a Markdown report based on `references/report-template.md`
2. an optional visual HTML report based on `assets/report-template.html`

The issue report includes:

- summary counts by severity
- normalization note
- issue table
- detailed issue cards
- out-of-scope or blocked items
- acceptance recommendation

## HTML Report Template

Open the local template directly to preview:

`assets/report-template.html`

Behavior:

- if no data is injected, it renders a built-in demo report
- if `window.REPORT_DATA` is provided, it renders the real report data

## Team Usage

Recommended workflow:

1. Design or QA provides the MasterGo link and target page state.
2. QA or PM provides the real page URL or screenshots.
3. Claude Code runs this skill.
4. Output is sent to design and engineering as:
   - Markdown for issue tracking
   - HTML for visual handoff

## Publish Notes

This repository is intended to be cloned or installed as a local skill bundle. It does not need any backend service to work as a spec-driven skill.
