# Issue Taxonomy

Use this reference when classifying findings and deciding severity.

## Severity

- `P0`: blocks acceptance, causes wrong understanding, or severely breaks a core area
- `P1`: obvious deviation in a core area and should be fixed in the current round
- `P2`: local implementation mismatch that should be fixed but does not block the release by itself
- `P3`: minor polish or consistency issue that can be scheduled later

Default to `P1` and `P2`. Use `P0` sparingly.

## Normalization Gate For Mobile Screenshots

When the implementation evidence is a mobile screenshot:

- compare in logical coordinates, not raw exported pixels
- do not file an issue for whole-screen uniform scale differences
- lower confidence when device metadata is incomplete

File a finding only after checking whether the problem survives normalization.

## Categories

Choose one primary category per issue.

### 布局与间距

Use for:

- module spacing
- internal padding
- section rhythm
- first-screen breathing room

Do not use when the real problem is component size mismatch. That belongs to `尺寸与对齐`.

### 尺寸与对齐

Use for:

- width or height mismatch
- baseline drift
- icon and text misalignment
- grid alignment errors

For mobile screenshots, use this category only when the mismatch remains after logical-size normalization. A pure DPR-driven scale difference is not a `尺寸与对齐` issue.

### 字体与排版

Use for:

- font size
- weight
- line height
- text truncation
- paragraph density

### 颜色与视觉样式

Use for:

- color mismatch
- border treatment
- corner radius
- shadow
- opacity

### 组件状态

Use for:

- default
- hover
- active
- selected
- disabled
- loading

If the state is unverified, do not guess. Ask for evidence.

### 内容与文案承载

Use for:

- content overflow
- placeholder behavior
- long text wrapping
- empty state copy presentation

### 图标与图片资源

Use for:

- wrong icon style
- incorrect icon size
- image crop mismatch
- low-quality asset output

### 信息层级

Use for:

- primary and secondary action conflict
- title and body hierarchy collapse
- emphasis mismatch

### 缺失与冗余实现

Use for:

- design has an element that the page is missing
- page shows an extra element that is not in design

### 响应与适配

Use for:

- compression
- overlap
- clipping
- breakpoint behavior within the requested viewport

## Finding Checklist

Before keeping a finding, verify all of the following:

- the module is named clearly
- the deviation is singular and concrete
- the issue includes both expected and actual states
- the impact is user-facing or acceptance-relevant
- the suggested fix points to a practical implementation direction
- in mobile screenshot mode, the issue still exists after normalization to the same logical viewport

If one issue contains multiple unrelated deviations, split it into separate issues.
