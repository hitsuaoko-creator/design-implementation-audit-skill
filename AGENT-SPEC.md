# UI Check Agent Spec

## Purpose

`ui-check` is a platform-agnostic AI capability for UI design acceptance review.

It compares a MasterGo design reference with real implementation evidence and outputs a developer-ready issue report.

This spec is intended to work across:

- Claude Code
- Cursor
- Windsurf
- VS Code AI assistants
- ChatGPT Projects
- Gemini
- internal agent runtimes

## Core Positioning

The agent should behave as a design acceptance auditor, not as a subjective design critic.

Its job is to:

- compare design reference and implementation evidence
- identify concrete deviations
- convert them into engineering-ready issues
- output a structured acceptance report

## Input Contract

Always use a two-part input model:

1. `design_reference`
2. `implementation_target`

Shared review configuration belongs in `audit_scope`.

### design_reference

Recommended fields:

- `type`
- `value`
- `frame_name`
- `logical_size`

### implementation_target

Supported `type` values:

- `live_page`
- `screenshot`
- `screenshot_set`

Recommended fields:

- `page_url`
- `target_state`
- `viewport`
- `image`
- `screenshots`
- `device_name`
- `logical_viewport`
- `screenshot_pixel_size`
- `dpr`
- `includes_status_bar`
- `includes_home_indicator`
- `display_zoom`

### audit_scope

Recommended fields:

- `page_name`
- `modules`
- `focus_points`
- `login_steps`
- `ignore_list`
- `env_note`
- `severity_rule`

Default `AUTO` behavior:

- if `modules` is omitted or set to `AUTO`, inspect all major visible modules in the current frame or screenshot
- if `focus_points` is omitted or set to `AUTO`, use the default universal checklist

Default module coverage for `modules: AUTO`:

- navigation bar or header
- top action area
- primary content area
- list, card, or table area
- bottom bar, floating action area, or fixed footer if visible
- modal, popover, toast, context menu, or overlay if visible

Default checklist for `focus_points: AUTO`:

- layout and spacing
- size and alignment
- typography including font size, weight, and line height
- color and visual style
- information hierarchy
- component states
- icon and image presentation
- safe area handling
- text truncation and content carrying
- missing or extra elements

## Mandatory Rules

### 1. Scope lock

One run should only cover:

- one page
- one state
- one viewport

For mobile screenshots, also lock one device logical viewport.

### 2. Evidence-first review

Never report an issue without both:

- design evidence
- implementation evidence

Do not infer hidden states from one screenshot.

### 3. Mobile normalization

When the implementation target is a mobile screenshot:

- do not compare raw screenshot pixels against a 1x design frame
- normalize the screenshot into the same logical coordinate system
- factor out DPR and export scale first

Treat whole-screen uniform scaling as non-issue unless local distortion exists.

### 4. Module-based comparison

Compare in this order:

1. page structure
2. major blocks
3. component-level details

Prioritize:

- layout
- spacing
- alignment
- typography hierarchy
- component states
- safe area handling
- missing or extra elements

If `modules: AUTO` is used, infer the visible module breakdown from the screenshot or page and report under stable module names.

If `focus_points: AUTO` is used, apply the full default checklist without asking the user to enumerate focus areas.

### 5. Issue quality bar

Each issue must include:

- issue id
- severity
- category
- module
- summary
- expected
- actual
- impact
- suggested fix
- acceptance check

Reject vague outputs such as:

- overall feels off
- suggest polishing
- some visual mismatch

## Severity Model

- `P0`: blocks acceptance or severely breaks a core area
- `P1`: obvious deviation in a core area and should be fixed in the current round
- `P2`: local mismatch with clear fix value
- `P3`: minor polish or consistency issue

## Category Model

- `布局与间距`
- `尺寸与对齐`
- `字体与排版`
- `颜色与视觉样式`
- `组件状态`
- `内容与文案承载`
- `图标与图片资源`
- `信息层级`
- `缺失与冗余实现`
- `响应与适配`

Use `references/issue-taxonomy.md` for detailed definitions.

## Output Contract

The capability should output:

1. audit summary
2. normalization note when relevant
3. issue summary table
4. detailed issue list
5. blocked or out-of-scope items
6. acceptance recommendation

Recommended formats:

- Markdown for tracking and review
- HTML for visual handoff

## Tool Adaptation

### Claude Code

Use `SKILL.md`.

### Other AI tools

Use:

- `AGENT-SPEC.md` as the execution contract
- `prompts/universal-audit-prompt.zh-CN.md` as the ready-to-run prompt

## Non-Goals

This capability is not intended to:

- perform whole-site batch audits in one run
- auto-fix code
- give subjective redesign advice
- do frame-by-frame motion analysis
