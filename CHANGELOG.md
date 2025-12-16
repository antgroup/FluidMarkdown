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





