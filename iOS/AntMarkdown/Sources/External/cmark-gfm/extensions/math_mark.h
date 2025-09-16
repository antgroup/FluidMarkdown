#ifndef CMARK_GFM_MATH_H
#define CMARK_GFM_MATH_H

#include "cmark-gfm-core-extensions.h"

extern cmark_node_type CMARK_NODE_MATH_INLINE, CMARK_NODE_MATH_BLOCK;

CMARK_GFM_NO_EXPORT
cmark_syntax_extension *create_math_extension(void);

#endif
