//
//  CMNode.h
//  CocoaMarkdown
//
//  Created by Indragie on 1/12/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "cmark-gfm.h"

extern cmark_node_type CMARK_NODE_TABLE, CMARK_NODE_TABLE_ROW, CMARK_NODE_TABLE_CELL, CMARK_NODE_STRIKETHROUGH, CMARK_NODE_MATH_INLINE, CMARK_NODE_MATH_BLOCK, CMARK_NODE_EMOJI;

@class CMIterator;

typedef NS_ENUM(NSInteger, CMNodeType) {
    /* Error status */
    CMNodeTypeNone          = CMARK_NODE_NONE,
    
    /* Block */
    CMNodeTypeDocument      = CMARK_NODE_DOCUMENT,
    CMNodeTypeBlockQuote    = CMARK_NODE_BLOCK_QUOTE,
    CMNodeTypeList          = CMARK_NODE_LIST,
    CMNodeTypeItem          = CMARK_NODE_ITEM,
    CMNodeTypeCodeBlock     = CMARK_NODE_CODE_BLOCK,
    CMNodeTypeHTML          = CMARK_NODE_HTML,
    CMNodeTypeCustomBlock   = CMARK_NODE_CUSTOM_BLOCK,
    CMNodeTypeParagraph     = CMARK_NODE_PARAGRAPH,
    CMNodeTypeHeader        = CMARK_NODE_HEADER,
    CMNodeTypeHRule         = CMARK_NODE_HRULE,
    CMNodeTypeFootNote      = CMARK_NODE_FOOTNOTE_DEFINITION,
    
    CMNodeTypeFirstBlock    = CMNodeTypeDocument,
    CMNodeTypeLastBlock     = CMNodeTypeFootNote,
    
    /* Inline */
    CMNodeTypeText          = CMARK_NODE_TEXT,
    CMNodeTypeSoftbreak     = CMARK_NODE_SOFTBREAK,
    CMNodeTypeLinebreak     = CMARK_NODE_LINEBREAK,
    CMNodeTypeCode          = CMARK_NODE_CODE,
    CMNodeTypeInlineHTML    = CMARK_NODE_INLINE_HTML,
    CMNodeTypeCustomInline  = CMARK_NODE_CUSTOM_INLINE,
    CMNodeTypeEmphasis      = CMARK_NODE_EMPH,
    CMNodeTypeStrong        = CMARK_NODE_STRONG,
    CMNodeTypeLink          = CMARK_NODE_LINK,
    CMNodeTypeImage         = CMARK_NODE_IMAGE,
    CMNodeTypeFootNoteRef   = CMARK_NODE_FOOTNOTE_REFERENCE,
    
    CMNodeTypeFirstInline   = CMNodeTypeText,
    CMNodeTypeLastInline    = CMNodeTypeFootNoteRef,
};

#define CMNodeTypeTable ((CMNodeType)CMARK_NODE_TABLE)
#define CMNodeTypeTableRow ((CMNodeType)CMARK_NODE_TABLE_ROW)
#define CMNodeTypeTableCell ((CMNodeType)CMARK_NODE_TABLE_CELL)
#define CMNodeTypeStrikeThrough ((CMNodeType)CMARK_NODE_STRIKETHROUGH)
#define CMNodeTypeMathInline ((CMNodeType)CMARK_NODE_MATH_INLINE)
#define CMNodeTypeMathBlock ((CMNodeType)CMARK_NODE_MATH_BLOCK)
#define CMNodeTypeEmoji ((CMNodeType)CMARK_NODE_EMOJI)

typedef NS_ENUM(NSInteger, CMListType) {
    CMListTypeNone,
    CMListTypeUnordered,
    CMListTypeOrdered
};

typedef NS_ENUM(NSInteger, CMDelimeterType) {
    CMDelimeterTypeNone,
    CMDelimeterTypePeriod,
    CMDelimeterTypeParen
};

/**
 *  Immutable interface to a CommonMark node.
 */
@interface CMNode : NSObject

/**
 *  Creates an iterator for the node tree that has the
 *  receiver as its root.
 *
 *  @return A new iterator.
 */
- (CMIterator *)iterator;

/**
 *  The next node in the sequence, or `nil` if there is none.
 */
@property (readonly) CMNode *next;

/**
 *  The previous node in the sequence, or `nil` if there is none.
 */
@property (readonly) CMNode *previous;

/**
 *  The receiver's parent node, or `nil` if there is none.
 */
@property (readonly) CMNode *parent;

/**
 *  The first child node of the receiver, or `nil` if there is none.
 */
@property (readonly) CMNode *firstChild;

/**
 *  The last child node of the receiver, or `nil` if there is none.
 */
@property (readonly) CMNode *lastChild;

/**
 *  The type of the node, or `CMNodeTypeNone` on error.
 */
@property (readonly) CMNodeType type;

/**
 *  String representation of `type`.
 */
@property (readonly) NSString *humanReadableType;

/**
 *  String contents of the receiver, or `nil` if there is none.
 */
@property (readonly) NSString *stringValue;

/**
 *  Content of the receiver, or `nil` if there is none.
 */
@property (readonly) NSString *contentValue;

/**
 *  Header level of the receiver, or `0` if the receiver is not a header.
 */
@property (readonly) NSInteger headerLevel;

/**
 *  Info string from a fenced code block, or `nil` if there is none.
 */
@property (readonly) NSString *fencedCodeInfo;

/**
 *  The receiver's list type, or `CMListTypeNone` if the receiver
 *  is not a list.
 */
@property (readonly) CMListType listType;

/**
 *  The receiver's list delimeter type, or `CMDelimeterTypeNone` if the
 *  receiver is not a list.
 */
@property (readonly) CMDelimeterType listDelimeterType;

/**
 *  Starting number of the list, or `0` if the receiver is not
 *  an ordered list.
 */
@property (readonly) NSInteger listStartingNumber;

/**
 *  `YES` if the receiver is a tight list, `NO` otherwise.
 */
@property (readonly) BOOL listTight;

/**
 *  Link or image URL string (as set in the document), or `nil` if there is none.
 */
@property (readonly) NSString *URLString;

/**
 *  Link or image URL, or `nil` if there is none.
 */
@property (readonly) NSURL *URL;

/**
 *  Link or image title, or `nil` if there is none.
 */
@property (readonly) NSString *title;

/**
 *  The line on which the receiver begins.
 */
@property (readonly) NSInteger startLine;

/**
 *  The column on which the receiver begins.
 */
@property (readonly) NSInteger startColumn;

/**
 *  The line on which the receiver ends.
 */
@property (readonly) NSInteger endLine;

/**
 *  The column on which the receiver ends.
 */
@property (readonly) NSInteger endColumn;

@property (readonly) NSInteger footNoteIndex;

@property (readonly) CMNode *footNoteDefination;


@end
