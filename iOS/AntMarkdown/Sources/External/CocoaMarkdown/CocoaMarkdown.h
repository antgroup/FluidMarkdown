//
//  CocoaMarkdown.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/12/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for CocoaMarkdown.
FOUNDATION_EXPORT double CocoaMarkdownVersionNumber;

//! Project version string for CocoaMarkdown.
FOUNDATION_EXPORT const unsigned char CocoaMarkdownVersionString[];

#if __has_include(<CocoaMarkdown/CMDocument.h>)
#import <CocoaMarkdown/CMAttributedStringRenderer.h>
#import <CocoaMarkdown/CMDocument.h>
#import <CocoaMarkdown/CMDocument+AttributedStringAdditions.h>
#import <CocoaMarkdown/CMDocument+HTMLAdditions.h>
#import <CocoaMarkdown/CMHTMLRenderer.h>
#import <CocoaMarkdown/CMHTMLStrikethroughTransformer.h>
#import <CocoaMarkdown/CMHTMLUnderlineTransformer.h>
#import <CocoaMarkdown/CMHTMLSuperscriptTransformer.h>
#import <CocoaMarkdown/CMHTMLSubscriptTransformer.h>
#import <CocoaMarkdown/CMImageTextAttachment.h>
#import <CocoaMarkdown/CMInlineTextAttachment.h>
#import <CocoaMarkdown/CMHorizontalRuleAttachment.h>
#import <CocoaMarkdown/CMIterator.h>
#import <CocoaMarkdown/CMNode.h>
#import <CocoaMarkdown/CMNode+Table.h>
#import <CocoaMarkdown/CMParser.h>
#import <CocoaMarkdown/CMTextAttributes.h>
#else
#import "CMAttributedStringRenderer.h"
#import "CMDocument.h"
#import "CMDocument+AttributedStringAdditions.h"
#import "CMDocument+HTMLAdditions.h"
#import "CMHTMLRenderer.h"
#import "CMHTMLStrikethroughTransformer.h"
#import "CMHTMLUnderlineTransformer.h"
#import "CMHTMLSuperscriptTransformer.h"
#import "CMHTMLSubscriptTransformer.h"
#import "CMImageTextAttachment.h"
#import "CMInlineTextAttachment.h"
#import "CMHorizontalRuleAttachment.h"
#import "CMIterator.h"
#import "CMNode.h"
#import "CMNode+Table.h"
#import "CMParser.h"
#import "CMTextAttributes.h"
#endif
