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





