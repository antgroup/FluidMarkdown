//
//  emoji.h
//  AntMarkdown
//
//  Created by ToccaLee on 2025/3/25.
//  Copyright © 2025 Alipay. All rights reserved.
//

#ifndef cmark_emoji_h
#define cmark_emoji_h

#include "cmark-gfm-core-extensions.h"

extern cmark_node_type CMARK_NODE_EMOJI;

CMARK_GFM_NO_EXPORT
cmark_syntax_extension *create_emoji_extension(void);

#endif /* emoji_h */
