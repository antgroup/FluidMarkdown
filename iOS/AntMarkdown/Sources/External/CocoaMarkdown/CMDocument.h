//
//  CMDocument.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/12/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "cmark-gfm.h"

@class CMNode;

typedef NS_OPTIONS(NSInteger, CMDocumentOptions) {
    /** Default options.
     */
    CMDocumentOptionsDefault = CMARK_OPT_DEFAULT,
    /**
     * Include a `data-sourcepos` attribute on all block elements.
     */
    CMDocumentOptionsSourcepos = CMARK_OPT_SOURCEPOS,
    /**
     * Render `softbreak` elements as hard line breaks.
     */
    CMDocumentOptionsHardBreaks = CMARK_OPT_HARDBREAKS,
    /** `CMARK_OPT_SAFE` is defined here for API compatibility,
        but it no longer has any effect. "Safe" mode is now the default:
        set `CMARK_OPT_UNSAFE` to disable it.
     */
    CMDocumentOptionsSafe = CMARK_OPT_SAFE,
    /** Render `softbreak` elements as spaces.
     */
    CMDocumentOptionsNoBreaks = CMARK_OPT_NOBREAKS,
    /**
     * Normalize tree by consolidating adjacent text nodes.
     */
    CMDocumentOptionsNormalize = CMARK_OPT_NORMALIZE,
    /** Validate UTF-8 in the input before parsing, replacing illegal
     * sequences with the replacement character U+FFFD.
     */
    CMDocumentOptionsValidateUTF8 = CMARK_OPT_VALIDATE_UTF8,
    /**
     * Convert straight quotes to curly, --- to em dashes, -- to en dashes.
     */
    CMDocumentOptionsSmart = CMARK_OPT_SMART,
    /** Use GitHub-style <pre lang="x"></pre> tags for code blocks instead of
     * <pre><code class="language-x"></code></pre>
     */
    CMDocumentOptionsGithubPreLang = CMARK_OPT_GITHUB_PRE_LANG,

    /** Be liberal in interpreting inline HTML tags.
     */
    CMDocumentOptionsLiberalHTMLTag = CMARK_OPT_LIBERAL_HTML_TAG,

    /** Parse footnotes.
     */
    CMDocumentOptionsFootNotes = CMARK_OPT_FOOTNOTES,
    /** Only parse strikethroughs if surrounded by exactly 2 tildes.
     * Gives some compatibility with redcarpet.
     */
    CMDocumentOptionsStrikeThrough = CMARK_OPT_STRIKETHROUGH_DOUBLE_TILDE,

    /** Use style attributes to align table cells instead of align attributes.
     */
    CMDocumentOptionsTablePreferStyle =  CMARK_OPT_TABLE_PREFER_STYLE_ATTRIBUTES,

    /** Include the remainder of the info string in code blocks in
     * a separate attribute.
     */
    CMDocumentOptionsFullInfo = CMARK_OPT_FULL_INFO_STRING,
    /** Render raw HTML and unsafe links (`javascript:`, `vbscript:`,
     * `file:`, and `data:`, except for `image/png`, `image/gif`,
     * `image/jpeg`, or `image/webp` mime types).  By default,
     * raw HTML is replaced by a placeholder HTML comment. Unsafe
     * links are replaced by empty strings.
     */
    CMDocumentOptionsUnsafe = CMARK_OPT_UNSAFE,
    
    CMDocumentOptionsFootNotesWithoutDefinition = CMARK_OPT_FOOTNOTES_WITHOUT_DEFINITION,
};

/**
 *  A Markdown document conforming to the CommonMark spec.
 */
@interface CMDocument : NSObject

/**
 *  Root node of the document.
 */
@property (nonatomic, readonly) CMNode *rootNode;

/**
 *  Initializes the receiver with a string.
 *
 *  @param string Markdown document string.
 *  @param options Document options.
 *
 *  @return An initialized instance of the receiver.
 */
- (instancetype)initWithString:(NSString *)string options:(CMDocumentOptions)options;

/**
 *  Initializes the receiver with data.
 *
 *  @param data Markdown document data.
 *  @param options Document options.
 *
 *  @return An initialized instance of the receiver.
 */
- (instancetype)initWithData:(NSData *)data options:(CMDocumentOptions)options;

/**
 *  Initializes the receiver with data read from a file.
 *
 *  @param path The file path to read from.
 *  @param options Document options.
 *
 *  @return An initialized instance of the receiver, or `nil` if the file
 *  could not be opened.
 */
- (instancetype)initWithContentsOfFile:(NSString *)path options:(CMDocumentOptions)options;


/**
 *  Base URL for links and images in the document.
 *
 *  Used as a base when a link destination is a scheme-less path (relative or absolute).
 *
 *  If the document has been created using `-[initWithContentsOfFile:options]`, linkBaseURL defaults to the document file's parent directory.
 */
@property (nonatomic) NSURL *linksBaseURL;

/**
 *  Get the absolute URL for a link or image node based on the documents's link base URL if needed
 *
 *  @param node Markdown document data.
 *
 *  @return the actual target URL of the node taking into account the documents's link base URL
 */
- (NSURL*) targetURLForNode:(CMNode *)node;

@end
