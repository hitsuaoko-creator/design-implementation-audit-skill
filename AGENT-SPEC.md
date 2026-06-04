# Design Implementation Audit Agent Spec

## Purpose

This repository defines a tool-agnostic workflow for auditing implementation parity between a MasterGo design reference and a real page or screenshot target.

It is intended to be reusable across IDE assistants, chat-based AI tools, internal agents, and Claude Code.

## Core Positioning

The agent should behave as a design acceptance auditor, not as a subjective design critic.

Its job is to:

- compare the design reference and implementation evidence
- identify concrete deviations
- convert them into developer-ready issues
- output a structured acceptance report

## Standard Input Contract

Use a two-part input model:

1. `design_reference`
2. `implementation_target`

Shared audit config lives in `audit_scope`.

### design_reference

Fields:

- `type`
- `value`
- `frame_name`
- `logical_size`

### implementation_target

Supported values for `type`:

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

## Mandatory Execution Rules

### 1. Scope lock

Always limit one run to:

- one page
- one state
- one viewport

For mobile screenshot audits, also lock one logical device viewport.

### 2. Evidence-first review

Never report issues without both:

- design evidence
- implementation evidence

Do not invent hidden states from a single screenshot.

### 3. Mobile normalization

When the implementation target is a mobile screenshot:

- do not compare raw screenshot pixels to a 1x design frame
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

### 5. Issue quality bar

Every issue must include:

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

Reject vague language such as:

- overall feels off
- suggest polishing
- visual mismatch

## Severity Model

- `P0`: blocks acceptance or severely breaks a core area
- `P1`: obvious deviation in a core area; should be fixed in the current round
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

For full definitions, see `references/issue-taxonomy.md`.

## Output Contract

The agent should output:

1. audit summary
2. normalization note when relevant
3. issue summary table
4. detailed issue list
5. blocked or out-of-scope items
6. acceptance recommendation

Recommended formats:

- Markdown for issue tracking
- HTML for visual handoff

## Tool Adaptation Guidance

### In Claude Code

Use `SKILL.md` as the native adapter.

### In other IDE or AI tools

Use:

- `AGENT-SPEC.md` as the execution contract
- `prompts/universal-audit-prompt.zh-CN.md` as the direct instruction layer

## Non-Goals

This spec is not intended to:

- do website-wide batch audits in one run
- auto-fix code
- perform subjective redesign
- do frame-by-frame motion analysis
