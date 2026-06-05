---
name: ui-check
description: Compare a MasterGo design frame with a real implemented mobile or web page during QA, integration, or release acceptance. Use when the user wants UI parity checking, design acceptance, implementation gap analysis, or a developer-ready issue report based on MasterGo and a real page URL or screenshot evidence.
---

# UI Check

This file is the Claude Code adapter for the repository-wide `ui-check` capability.

If you are using another AI tool or IDE assistant, use `AGENT-SPEC.md` and `prompts/universal-audit-prompt.zh-CN.md` instead.

Use this skill to audit one mobile page, one web page, or one page state at a time against a MasterGo design source and produce a developer-ready issue report.

This skill is for acceptance and implementation parity checking, not for subjective redesign advice.

## Use This Skill For

- 移动端提测阶段的设计还原度走查
- 提测阶段的设计还原度走查
- 联调后的页面实现偏差检查
- 上线前的设计验收
- 基于 MasterGo 设计稿和真实页面输出研发可修复的问题单

## Do Not Use This Skill For

- 没有设计依据的主观美化建议
- 一次性全站巡检
- 自动改线上代码
- 没有真实页面可访问证据的“云评审”
- 复杂动画逐帧分析

## Input Model

Always structure the task with two inputs:

1. `design_reference`
2. `implementation_target`

`design_reference` describes what the UI should look like.

- `type`: usually `mastergo`
- `value`: MasterGo short link, or `fileId + layerId`
- `frame_name`: optional but recommended
- `logical_size`: required for screenshot-based mobile audits, e.g. `393x852`

`implementation_target` describes what was actually built.

Supported modes:

- `live_page`: real URL + target state + viewport
- `screenshot`: one screenshot with device metadata
- `screenshot_set`: multiple screenshots for multiple visible states

Required fields depend on mode.

For `live_page`, collect:

- `page_url`
- `target_state`
- `viewport`

For `screenshot` or `screenshot_set`, collect:

- `screenshots` or `image`
- `device_name`
- `logical_viewport`
- `screenshot_pixel_size`
- `dpr` if known
- `includes_status_bar`
- `includes_home_indicator`
- `display_zoom` if known

Common audit fields:

- `page_name`
- `scope`
- `focus_points`
- `login_steps`
- `ignore_list`
- `env_note`
- `severity_rule`

Default `AUTO` behavior for team usage:

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

If required inputs are missing, ask only for the missing items. Do not ask broad open-ended questions.

For an input example, see `assets/audit-input-example.yaml`.

## Mobile Screenshot Rule

When the implementation target is a mobile screenshot, do not compare raw screenshot pixels directly against a 1x design frame.

You must normalize first:

1. identify the design frame logical size
2. identify the implementation logical viewport
3. map the screenshot back into the same logical coordinate system
4. compare relative layout and local proportion after normalization

Treat these as non-issues unless other evidence shows a real deviation:

- whole-screen uniform scaling caused by DPR
- minor font rasterization differences
- 1px-level rendering noise
- status bar or home indicator offsets when the crop basis is different

Treat these as likely real issues:

- one module scales differently from surrounding modules
- local spacing becomes tighter or looser while the rest of the screen stays proportional
- hierarchy, alignment, or safe-area handling diverges
- one component state differs from the design while the rest of the screen matches

Use screenshot mode with lower confidence than live-page mode unless the device metadata is complete.

## Scope Rules

Always keep V1 within these boundaries:

- audit one page or one page state per run
- audit one viewport per run
- for mobile screenshot audits, audit one device logical viewport per run
- prefer high-signal issues over exhaustive nitpicks
- output issues that are actionable for engineering
- do not invent issues without design evidence and page evidence
- do not write vague statements such as “视觉不一致” without naming the exact module and deviation

## Required Workflow

### 1. Lock the audit target

- Reduce the task to one page, one state, one viewport.
- For mobile screenshots, also lock one device logical viewport.
- Restate the target clearly before comparing.
- If the user asks for a batch review, split it into separate page runs.

### 2. Read the design source

- If the design source is MasterGo, use the available MasterGo tools to retrieve structure and visual context.
- Capture the exact frame or layer that represents the target state.
- Do not compare against a guessed design area.
- For screenshot-based mobile audits, record the design frame logical size before making any visual judgment.

### 3. Capture the real page

For `live_page` mode:

- Open the real page in the specified viewport.
- Reach the requested state using the provided login or navigation steps.
- Capture the relevant page view for evidence.
- If the state cannot be reached, stop and report the blocker.

For `screenshot` or `screenshot_set` mode:

- Verify the device metadata first.
- If logical viewport or screenshot basis is unclear, ask before concluding.
- Do not infer hidden states from one screenshot.

### 3.5 Normalize when comparing mobile screenshots

Before judging any mobile screenshot finding:

- align the design frame and the screenshot to the same logical width
- factor out DPR or export scale
- check whether the difference is global uniform scaling or local distortion

If the whole screen is uniformly larger or smaller but ratios remain stable, do not report it as an implementation issue.

### 4. Compare by module

- Compare top-down: page structure, major blocks, then component details.
- Focus first on high-impact areas: layout, spacing, typography, component states, hierarchy, missing elements.
- Ignore low-value noise unless the user explicitly asks for exhaustive polish.

For mobile screenshot audits, prioritize:

- safe area handling
- header and tab bar structure
- touch target size and density
- text hierarchy
- local spacing changes after normalization
- missing or extra UI elements
- state-specific deviations such as disabled, selected, loading, and empty states

If `modules: AUTO` is used, infer the visible module breakdown from the screenshot and report issues under the nearest stable module name.

If `focus_points: AUTO` is used, apply the full default checklist without asking the user to enumerate focus areas.

Load `references/issue-taxonomy.md` when you need the full category rules and severity definitions.

### 5. Convert findings into engineering-ready issues

Each issue must identify:

- module
- exact deviation
- expected behavior
- actual behavior
- impact
- suggested fix direction
- acceptance check

Good issue language is concrete:

- “将输入框高度统一到 32px，并校正 icon 与 placeholder 的垂直居中”
- “补齐表头字重到设计稿对应层级，避免标题与正文层级混淆”

Bad issue language is vague:

- “建议优化样式”
- “整体有偏差”
- “看起来不太对”

### 6. Produce the final report

Default output is Markdown using `references/report-template.md`.

If the user wants a more visual handoff for design and engineering, also render an HTML report based on `assets/report-template.html`.

The HTML report should:

- preserve the same issue IDs and severities as the Markdown report
- keep issue wording identical to the source Markdown
- show summary metrics first
- show visual evidence before long prose
- keep one issue card focused on one concrete problem
- inject real report data via `window.REPORT_DATA` when generating the final report; if no data is injected, the template will render a built-in demo report for preview

## Evidence Rules

- No design evidence, no finding.
- No page evidence, no finding.
- No device basis in screenshot mode, no high-confidence finding.
- If evidence is incomplete, mark it as `需人工确认`.
- If the problem may be intentional, lower confidence and say why.
- If the state is missing from the artifact, ask for that state instead of guessing.
- If the mismatch disappears after logical-size normalization, do not report it as a bug.

## Output Rules

Always output:

1. audit summary
2. issue summary table
3. detailed issue list
4. out-of-scope or blocked items
5. acceptance recommendation

When using screenshot mode, include a short normalization note that states:

- design logical size
- implementation logical viewport
- screenshot pixel size
- whether DPR was known or inferred
- whether confidence was reduced because of incomplete metadata

Findings must be useful to both designers and engineers. The report should help a designer confirm the deviation and help an engineer fix it without a follow-up meeting.

## References

- `references/issue-taxonomy.md` for severity and category rules
- `references/report-template.md` for the default Markdown report structure
- `assets/report-template.html` for the visual handoff template
- `assets/audit-input-example.yaml` for the preferred input shape
