#include <parser.h>
#include <render.h>
#include <html.h>

#include "math_mark.h"
#include "inlines.h"
#include "ext_scanners.h"

cmark_node_type CMARK_NODE_MATH_INLINE, CMARK_NODE_MATH_BLOCK;

static cmark_node *match(cmark_syntax_extension *self, cmark_parser *parser,
                         cmark_node *parent, unsigned char character,
                         cmark_inline_parser *inline_parser) {
    cmark_node *res = NULL;
    
    if (character != '$' && character != '\\')
        return NULL;
    
    int pos = cmark_inline_parser_get_offset(inline_parser);
    cmark_chunk *chunk = cmark_inline_parser_get_chunk(inline_parser);
    unsigned char *input = chunk->data + pos;
    int len = chunk->len - pos;
    if (len <= 2) {
        return NULL;
    }
    bufsize_t matched = 0;
    if ((matched = scan_math_block(chunk->data, chunk->len, pos))) {
        cmark_node *node = cmark_node_new_with_mem_and_ext(CMARK_NODE_MATH_BLOCK, parser->mem, self);
        
        node->start_line = node->end_line = cmark_inline_parser_get_line(inline_parser);
        node->start_column = cmark_inline_parser_get_column(inline_parser);
        node->end_column = node->start_column + matched;
        
        cmark_strbuf_init(parser->mem, &node->content, matched);
        cmark_strbuf_put(&node->content, input, matched);
        
        {
            int nls = 0;
            int since_nl = 0;
            int len = matched;
            int from = pos;
            
            while (len--) {
                if (chunk->data[from++] == '\n') {
                    ++nls;
                    since_nl = 0;
                } else {
                    ++since_nl;
                }
            }
            node->end_line = node->start_line + nls;
            node->end_column = since_nl;
        }
        
        cmark_strbuf buf;
        cmark_strbuf_init(parser->mem, &buf, matched);
        cmark_strbuf_put(&buf, input + 2, matched - 4);
        
        node->as.code.fenced = true;
        node->as.code.fence_char = '$';
        node->as.code.fence_length = (matched > 255) ? 255 : matched;
        node->as.code.fence_offset = parser->first_nonspace - parser->offset;
        node->as.code.info = cmark_chunk_literal("latex");
        node->as.code.literal = cmark_chunk_buf_detach(&buf);
        
        cmark_inline_parser_set_offset(inline_parser, pos + matched);
        cmark_parser_advance_offset(parser, (char *)input,
                                    parser->first_nonspace + matched - parser->offset,
                                    false);
        res = node;
    } else if ((matched = scan_math_inline(chunk->data, chunk->len, pos))) {
        cmark_node *node = cmark_node_new_with_mem_and_ext(CMARK_NODE_MATH_INLINE, parser->mem, self);
        
        node->start_line = node->end_line = cmark_inline_parser_get_line(inline_parser);
        node->start_column = cmark_inline_parser_get_column(inline_parser);
        node->end_column = node->start_column + matched - 1;
        
        cmark_strbuf_init(parser->mem, &node->content, matched);
        cmark_strbuf_put(&node->content, input, matched);
        
        cmark_strbuf buf;
        cmark_strbuf_init(parser->mem, &buf, matched);
        cmark_strbuf_put(&buf, input + 1, matched - 2);
        
        node->as.code.fenced = false;
        node->as.code.fence_char = '$';
        node->as.code.fence_length = (matched > 255) ? 255 : matched;
        node->as.code.fence_offset = parser->first_nonspace - parser->offset;
        node->as.code.info = cmark_chunk_literal("latex");
        node->as.code.literal = cmark_chunk_buf_detach(&buf);
        
        cmark_inline_parser_set_offset(inline_parser, pos + matched);
        res = node;
    }
    return res;
}

static delimiter *insert(cmark_syntax_extension *self, cmark_parser *parser,
                         cmark_inline_parser *inline_parser, delimiter *opener,
                         delimiter *closer) {
    cmark_node *math;
    cmark_node *tmp, *next;
    delimiter *delim, *tmp_delim;
    delimiter *res = closer->next;
    
    math = opener->inl_text;
    
    if (opener->inl_text->as.literal.len != closer->inl_text->as.literal.len)
        goto done;
    
    if (!cmark_node_set_type(math, CMARK_NODE_MATH_INLINE))
        goto done;
    
    cmark_node_set_syntax_extension(math, self);
    
    tmp = cmark_node_next(opener->inl_text);
    
    while (tmp) {
        if (tmp == closer->inl_text)
            break;
        next = cmark_node_next(tmp);
        cmark_node_append_child(math, tmp);
        tmp = next;
    }
    
    math->end_column = closer->inl_text->start_column + closer->inl_text->as.literal.len - 1;
    cmark_node_free(closer->inl_text);
    
done:
    delim = closer;
    while (delim != NULL && delim != opener) {
        tmp_delim = delim->previous;
        cmark_inline_parser_remove_delimiter(inline_parser, delim);
        delim = tmp_delim;
    }
    
    cmark_inline_parser_remove_delimiter(inline_parser, opener);
    
    return res;
}

static const char *get_type_string(cmark_syntax_extension *extension,
                                   cmark_node *node) {
    if (node->type == CMARK_NODE_MATH_INLINE) {
        return "math";
    } else if (node->type == CMARK_NODE_MATH_BLOCK) {
        return "math_block";
    } else {
        return "<unknown>";
    }
}

static int can_contain(cmark_syntax_extension *extension, cmark_node *node,
                       cmark_node_type child_type) {
    if (node->type == CMARK_NODE_MATH_INLINE) {
        return child_type == CMARK_NODE_TEXT;
    } else if (node->type == CMARK_NODE_MATH_BLOCK) {
        return child_type == CMARK_NODE_TEXT;
    }
    return false;
}

static void commonmark_render(cmark_syntax_extension *extension,
                              cmark_renderer *renderer, cmark_node *node,
                              cmark_event_type ev_type, int options) {
    renderer->out(renderer, node, node->type == CMARK_NODE_MATH_INLINE ? "$" : "$$", false, LITERAL);
}

static void latex_render(cmark_syntax_extension *extension,
                         cmark_renderer *renderer, cmark_node *node,
                         cmark_event_type ev_type, int options) {
    // requires \usepackage{ulem}
    bool entering = (ev_type == CMARK_EVENT_ENTER);
    if (entering) {
        renderer->out(renderer, node, "", false, LITERAL);
    } else {
        renderer->out(renderer, node, "", false, LITERAL);
    }
}

static void html_render(cmark_syntax_extension *extension,
                        cmark_html_renderer *renderer, cmark_node *node,
                        cmark_event_type ev_type, int options) {
    bool entering = (ev_type == CMARK_EVENT_ENTER);
    if (entering) {
        cmark_strbuf_puts(renderer->html, "<math");
        cmark_strbuf_puts(renderer->html, " style=\"display: ");
        if (node->type == CMARK_NODE_MATH_INLINE) {
            cmark_strbuf_puts(renderer->html, "inline;\"");
        } else {
            cmark_strbuf_puts(renderer->html, "block;\"");
        }
        cmark_html_render_sourcepos(node, renderer->html, options);
        cmark_strbuf_putc(renderer->html, '>');
    } else {
        cmark_strbuf_puts(renderer->html, "</math>");
    }
}

cmark_syntax_extension *create_math_extension(void) {
    cmark_syntax_extension *ext = cmark_syntax_extension_new("math");
    cmark_llist *special_chars = NULL;
    cmark_syntax_extension_set_get_type_string_func(ext, get_type_string);
    cmark_syntax_extension_set_can_contain_func(ext, can_contain);
    cmark_syntax_extension_set_commonmark_render_func(ext, commonmark_render);
    cmark_syntax_extension_set_latex_render_func(ext, latex_render);
    cmark_syntax_extension_set_html_render_func(ext, html_render);
    cmark_syntax_extension_set_plaintext_render_func(ext, commonmark_render);
    
    CMARK_NODE_MATH_INLINE = cmark_syntax_extension_add_node(1);
    CMARK_NODE_MATH_BLOCK = cmark_syntax_extension_add_node(0);
    
    cmark_syntax_extension_set_match_inline_func(ext, match);
    cmark_syntax_extension_set_inline_from_delim_func(ext, insert);
    
    cmark_mem *mem = cmark_get_default_mem_allocator();
    special_chars = cmark_llist_append(mem, special_chars, (void *)'\\');
    special_chars = cmark_llist_append(mem, special_chars, (void *)'$');
    cmark_syntax_extension_set_special_inline_chars(ext, special_chars);
    
    cmark_syntax_extension_set_emphasis(ext, 0);
    
    return ext;
}
