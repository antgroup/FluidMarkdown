//
//  CMHTMLRenderer.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/20/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMHTMLRenderer.h"
#import "CMDocument_Private.h"
#import "CMNode_Private.h"
#include "cmark-gfm-core-extensions.h"
#include "registry.h"

@implementation CMHTMLRenderer {
    CMDocument *_document;
    cmark_llist * _extensions;
}

- (instancetype)initWithDocument:(CMDocument *)document
{
    if ((self = [super init])) {
        _document = document;
        _extensions = cmark_list_syntax_extensions(cmark_get_default_mem_allocator());
    }
    return self;
}

- (void)dealloc
{
    cmark_llist_free(cmark_get_default_mem_allocator(), _extensions);
}

- (NSString *)render
{
    char *html = cmark_render_html(_document.rootNode.node, (int)_document.options, _extensions);
    return [NSString stringWithUTF8String:html];
}

@end
