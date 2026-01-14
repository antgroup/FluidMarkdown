## v1.0.8 (2026-01-14)
### Fixed

- `ohos` Resolved the incorrect callback order in AST parsing tasks caused by StyledString.styledFromHtml.


## v1.0.7 (2026-01-13)
### Changed

- `ohos` AST Parser: Introduced a queue mechanism to guarantee ordered callbacks.
- `ohos` Fragment: Switched to an append-only update strategy during single-shot streaming, improving rendering performance.


## v1.0.6 (2026-01-08)
### Fixed

- `ohos` Fixed an issue where Fragment can not refresh while @Param Node changed on Normal mode.


## v1.0.5 (2026-01-08)
### Fixed

- `ohos` Fixed an issue where Fragment can not render on Normal mode.


## v1.0.4 (2026-01-07)
### Fixed

- `ohos` Use the synchronous API of the uuid library to generate the AST Node model's hash, preventing timing issues caused by the async built-in crypto library.  
- `ohos` Fixed an issue where the typing-finish event might not be emitted when deduplicating fragments.

### Added
- `ohos` Introduced a built-in plugin for the Markdown AST parser module.

## v1.0.3 (2026-01-05)
### Fixed

- `ohos` Resolved an issue where `embed` components were not cleaned up promptly during streaming output, causing overlapping display.
- `ohos` Fixed a problem where the `stop` interface for streaming output was not correctly bound.

### Changed

- `ohos` Refined the assembly and update strategy for the `likelyKey` of embed nodes to reduce rendering flicker during streaming output.
- `ohos` Adjusted the parsing strategy for custom `icon` tags to comply with HTML void-element specifications.
- `ohos` Updated the validation rules for the `Stopped` state in the streaming output control flow to prevent content that has already been stopped from being re-activated by the `resume` interface.

### Added

- `ohos` Introduced `hook-level` plugin customization capabilities in the rendering pipeline.
- `ohos` Added built-in content deduplication during streaming output.
- `ohos` Added a global scroll-state listener for main list scenarios; combined with safe `pause/resume` APIs for streaming output, it improves scrolling smoothness while streaming is active.
- `ohos` Implemented a syntax-parsing queue control mechanism that guarantees asynchronous parse results are delivered in the order they were submitted.
- `ohos` Introduced `Fragment-based` segmented rendering to mitigate slowdowns when streaming long-form content.


## v1.0.2 (2025-12-19)
### Changed
- `ohos` Improved scrolling performance for multiple Markdown components on the list page.
- `ohos` Adjusted the reuse-matching mechanism for embed nodes in streaming mode, allowing prior node types to change dynamically.

### Added
- `ohos` Added hook-level plugin support to the Styled model rendering module.


## v1.0.1 (2025-12-16)
### Fixed
- `ohos` Fixed issue where the `pause` interface could not stop streaming output in typing mode.
- `ohos` Fixed issue where table nodes could not be rendered correctly in typing mode.
- `ohos` Fixed layout issue where table cells containing asynchronously rendered elements (e.g., images) failed to expand properly.
- `ohos` Improved scrolling performance of tables within list views to eliminate stuttering and frame drops.
- `ohos` Fixed paragraph indentation issue when a code block is nested inside a list.

### Changed
- `ohos` Default streaming output interval adjusted to `25 ms`.
- `ohos` Console logs now output in `plain text` by default to simplify debugging.
- `ohos` Ordered-list label now sourced from the node’s `info` field instead of the `index` field.

### Added
- `ohos` ImageService now supports `hook-level plugin`.
- `ohos` Code blocks now expose a `copy code` action.
- `ohos` Log now provides a `global interception configuration` API.
- `ohos` New `landscape-detail component` for table views in horizontal screen scenarios.


## v1.0.0 (2025-12-01)
### Added
- Support for HarmonyOS
- Full Markdown syntax parsing using the markdown-it open-source library
- Native layout and rendering based on HarmonyOS StyledString
- Customizable themes, plugins, and events
- Streaming output mode optimized for AI conversation scenarios


## v0.1.1 (2025-10-28)
### Fixed
+ Fix Android platform bug: unordered list rendering crashes under certain custom styles.
+ Fix Android platform bug: table parsing fails when text starts with leading spaces.
+ Fix iOS platform bug: During streaming output, a section of markdown-formatted content fails to be correctly parsed and rendered when added incrementally via addStreamContent.
+ Fix iOS platform bug: The list cell in the demo page AIChatViewController does not respond to gesture events.


## v0.1.0 (2025-09-08)
### Added
+ Support for markdown syntax: titles, paragraphs, ordered lists, unordered lists, tables, code blocks, mathematical formulas, inline code blocks, quotes, dividing lines, footnotes, links, and images.
+ Support for HTML tags:`<s>` `<sup>` `<sub>` `<mark>` `<a>` `<span>` `<cite>` `<del>` `<font>` `<img>` `<u>`, etc.
+ Streaming rendering and one-time full rendering modes.
+ Customizable rendering styles for Markdown syntax.
+ Adjustable streaming speed via custom parameters.
+ Event support for clickable elements, including click handling, visibility callbacks, and rendering status updates<font style="color:rgb(38, 38, 38);">, etc.
+ Added some new extended HTML tags such as `<iconlink>` `<icon>`in `AMHTMLTransformer` class.





