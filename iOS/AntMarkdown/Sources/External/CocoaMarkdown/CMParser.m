//
//  CMParser.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/13/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMParser.h"
#import "CMDocument.h"
#import "CMIterator.h"
#import "CMNode.h"
#import "CMNode+Table.h"
#import <libkern/OSAtomic.h>

@interface CMParser ()
@property (atomic, readwrite) CMNode *currentNode;
@property (nonatomic, weak, readwrite) id<CMParserDelegate> delegate;
@end

@implementation CMParser {
    struct {
        unsigned int didStartDocument:1;
        unsigned int didEndDocument:1;
        unsigned int didAbort:1;
        unsigned int foundText:1;
        unsigned int foundHRule:1;
        unsigned int didStartHeader:1;
        unsigned int didEndHeader:1;
        unsigned int didStartParagraph:1;
        unsigned int didEndParagraph:1;
        unsigned int didStartEmphasis:1;
        unsigned int didEndEmphasis:1;
        unsigned int didStartStrong:1;
        unsigned int didEndStrong:1;
        unsigned int didStartStrikethrough:1;
        unsigned int didEndStrikethrough:1;
        unsigned int didStartLink:1;
        unsigned int didEndLink:1;
        unsigned int didStartImage:1;
        unsigned int didEndImage:1;
        unsigned int didStartTable:1;
        unsigned int didStartTableRow:1;
        unsigned int didStartTableCell:1;
        unsigned int didEndTable:1;
        unsigned int didEndTableRow:1;
        unsigned int didEndTableCell:1;
        unsigned int foundHTML:1;
        unsigned int foundInlineHTML:1;
        unsigned int foundCodeBlock:1;
        unsigned int foundInlineCode:1;
        unsigned int foundMathBlock:1;
        unsigned int foundInlineMath:1;
        unsigned int foundSoftBreak:1;
        unsigned int foundLineBreak:1;
        unsigned int foundEmoji:1;
        unsigned int foundTasklist:1;
        unsigned int didStartBlockQuote:1;
        unsigned int didEndBlockQuote:1;
        unsigned int didStartUnorderedList:1;
        unsigned int didEndUnorderedList:1;
        unsigned int didStartOrderedList:1;
        unsigned int didEndOrderedList:1;
        unsigned int didStartListItem:1;
        unsigned int didEndListItem:1;
        unsigned int didStartFootNoteRef:1;
        unsigned int didEndFootNoteRef:1;
        unsigned int didStartFootNote:1;
        unsigned int didEndFootNote:1;
    } _delegateFlags;
    volatile int32_t _parsing;
}

#pragma mark - Initialization

- (instancetype)initWithDocument:(CMDocument *)document delegate:(id<CMParserDelegate>)delegate
{
    NSParameterAssert(document);
    NSParameterAssert(delegate);
    
    if ((self = [super init])) {
        _document = document;
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - Parsing

- (void)parse
{
    if (!OSAtomicCompareAndSwap32Barrier(0, 1, &_parsing)) return;
    
    [[_document.rootNode iterator] enumerateUsingBlock:^(CMNode *node, CMEventType event, BOOL *stop) {
        self.currentNode = node;
        [self handleNode:node event:event];
        if (self->_parsing == 0) *stop = YES;
    }];
    
    _parsing = 0;
}

- (void)abortParsing
{
    if (!OSAtomicCompareAndSwap32Barrier(1, 0, &_parsing)) return;
    
    if (_delegateFlags.didAbort) {
        [_delegate parserDidAbort:self];
    }
}

- (void)handleNode:(CMNode *)node event:(CMEventType)event {
    NSAssert((event == CMEventTypeEnter) || (event == CMEventTypeExit), @"Event must be either an exit or enter event");
    
    switch (node.type) {
        case CMNodeTypeDocument:
            if (event == CMEventTypeEnter) {
                if (_delegateFlags.didStartDocument) {
                    [_delegate parserDidStartDocument:self];
                }
            } else if (_delegateFlags.didEndDocument) {
                [_delegate parserDidEndDocument:self];
            }
            break;
        case CMNodeTypeText:
            if (_delegateFlags.foundText) {
                [_delegate parser:self foundText:node.stringValue];
            }
            break;
        case CMNodeTypeHRule:
            if (_delegateFlags.foundHRule) {
                [_delegate parserFoundHRule:self];
            }
            break;
        case CMNodeTypeHeader:
            if (event == CMEventTypeEnter) {
                if (_delegateFlags.didStartHeader) {
                    [_delegate parser:self didStartHeaderWithLevel:node.headerLevel];
                }
            } else if (_delegateFlags.didEndHeader) {
                [_delegate parser:self didEndHeaderWithLevel:node.headerLevel];
            }
            break;
        case CMNodeTypeParagraph:
            if (event == CMEventTypeEnter) {
                if (_delegateFlags.didStartParagraph) {
                    [_delegate parserDidStartParagraph:self];
                }
            } else if (_delegateFlags.didEndParagraph) {
                [_delegate parserDidEndParagraph:self];
            }
            break;
        case CMNodeTypeEmphasis:
            if (event == CMEventTypeEnter) {
                if (_delegateFlags.didStartEmphasis) {
                    [_delegate parserDidStartEmphasis:self];
                }
            } else if (_delegateFlags.didEndEmphasis) {
                [_delegate parserDidEndEmphasis:self];
            }
            break;
        case CMNodeTypeStrong:
            if (event == CMEventTypeEnter) {
                if (_delegateFlags.didStartStrong) {
                    [_delegate parserDidStartStrong:self];
                }
            } else if (_delegateFlags.didEndStrong) {
                [_delegate parserDidEndStrong:self];
            }
            break;
        case CMNodeTypeLink: {
            NSURL *nodeURL = [_document targetURLForNode:node];
            
            if (node.parent.type == CMNodeTypeTableCell) {
                break;
            }
            if (event == CMEventTypeEnter) {
                if (_delegateFlags.didStartLink) {
                    [_delegate parser:self didStartLinkWithURL:nodeURL title:node.title];
                }
            } else if (_delegateFlags.didEndLink) {
                [_delegate parser:self didEndLinkWithURL:nodeURL title:node.title];
            }
        }   break;
        case CMNodeTypeImage: {
            NSURL *nodeURL = [_document targetURLForNode:node];
            if (event == CMEventTypeEnter) {
                if (_delegateFlags.didStartImage) {
                    [_delegate parser:self didStartImageWithURL:nodeURL title:node.title];
                }
            } else if (_delegateFlags.didEndImage) {
                [_delegate parser:self didEndImageWithURL:nodeURL title:node.title];
            }
        }   break;
        case CMNodeTypeHTML:
            if (_delegateFlags.foundHTML) {
                [_delegate parser:self foundHTML:node.stringValue];
            }
            break;
        case CMNodeTypeInlineHTML:
            if (_delegateFlags.foundInlineHTML) {
                [_delegate parser:self foundInlineHTML:node.stringValue];
            }
            break;
        case CMNodeTypeCodeBlock:
            if (_delegateFlags.foundCodeBlock) {
                [_delegate parser:self foundCodeBlock:node.stringValue info:node.fencedCodeInfo];
            }
            break;
        case CMNodeTypeCode:
            if (_delegateFlags.foundInlineCode) {
                [_delegate parser:self foundInlineCode:node.stringValue];
            }
            break;
        case CMNodeTypeSoftbreak:
            if (_delegateFlags.foundSoftBreak) {
                [_delegate parserFoundSoftBreak:self];
            }
            break;
        case CMNodeTypeLinebreak:
            if (_delegateFlags.foundLineBreak) {
                [_delegate parserFoundLineBreak:self];
            }
            break;
        case CMNodeTypeBlockQuote:
            if (event == CMEventTypeEnter) {
                if (_delegateFlags.didStartBlockQuote) {
                    [_delegate parserDidStartBlockQuote:self];
                }
            } else if (_delegateFlags.didEndBlockQuote) {
                [_delegate parserDidEndBlockQuote:self];
            }
            break;
        case CMNodeTypeList:
            switch (node.listType) {
                case CMListTypeOrdered:
                    if (event == CMEventTypeEnter) {
                        if (_delegateFlags.didStartOrderedList) {
                            [_delegate parser:self didStartOrderedListWithStartingNumber:node.listStartingNumber tight:node.listTight];
                        }
                    } else if (_delegateFlags.didEndOrderedList) {
                        [_delegate parser:self didEndOrderedListWithStartingNumber:node.listStartingNumber tight:node.listTight];
                    }
                    break;
                case CMListTypeUnordered:
                    if (event == CMEventTypeEnter) {
                        if (_delegateFlags.didStartUnorderedList) {
                            [_delegate parser:self didStartUnorderedListWithTightness:node.listTight];
                        }
                    } else if (_delegateFlags.didEndUnorderedList) {
                        [_delegate parser:self didEndUnorderedListWithTightness:node.listTight];
                    }
                    break;
                default:
                    break;
            }
            break;
        case CMNodeTypeItem:
            if (event == CMEventTypeEnter) {
                if (_delegateFlags.didStartListItem) {
                    [_delegate parserDidStartListItem:self];
                }
            } else if (_delegateFlags.didEndListItem) {
                [_delegate parserDidEndListItem:self];
            }
            break;
        case CMNodeTypeFootNote:
            if (event == CMEventTypeEnter) {
                if (_delegateFlags.didStartFootNote) {
                    [_delegate parser:self didStartFootNoteDefination:node.stringValue refCount:node.footNoteIndex];
                }
            } else if (_delegateFlags.didEndFootNote) {
                [_delegate parser:self didEndFootNoteDefination:node.stringValue refCount:node.footNoteIndex];
            }
            break;
        case CMNodeTypeFootNoteRef:
            if (event == CMEventTypeEnter) {
                if (_delegateFlags.didStartFootNoteRef) {
                    [_delegate parser:self 
             didStartFootNoteRefIndex:node.footNoteIndex
                                title:node.stringValue
                           defination:node.footNoteDefination.stringValue ?: node.stringValue];
                }
            } else if (_delegateFlags.didEndFootNoteRef) {
                [_delegate parser:self
           didEndFootNoteRefIndex:node.footNoteIndex
                            title:node.stringValue
                       defination:node.footNoteDefination.stringValue ?: node.stringValue];
            }
            break;
        default: {
            const CMNodeType type = node.type;
            if (type == CMNodeTypeTable) {
                if (event == CMEventTypeEnter) {
                    if (_delegateFlags.didStartTable) {
                        [_delegate parser:self didStartTableWithNumberOfColumns:node.numberOfColumns];
                    }
                } else {
                    if (_delegateFlags.didEndTable) {
                        [_delegate parser:self didEndTableWithNumberOfColumns:node.numberOfColumns];
                    }
                }
            } else if (type == CMNodeTypeTableRow) {
                if (event == CMEventTypeEnter) {
                    if (_delegateFlags.didStartTableRow) {
                        [_delegate parser:self didStartTableRowIsHeader:node.rowIsHeader];
                    }
                } else {
                    if (_delegateFlags.didEndTableRow) {
                        [_delegate parser:self didEndTableRowIsHeader:node.rowIsHeader];
                    }  
                }
            } else if (type == CMNodeTypeTableCell) {
                if (event == CMEventTypeEnter) {
                    if (_delegateFlags.didStartTableCell) {
                        [_delegate parser:self didStartTableCellWithAlignment:node.cellAlignment];
                    }
                } else {
                    if (_delegateFlags.didEndTableCell) {
                        [_delegate parser:self didEndTableCellWithAlignment:node.cellAlignment];
                    }
                }
            } else if (type == CMNodeTypeStrikeThrough) {
                if (event == CMEventTypeEnter) {
                    if (_delegateFlags.didStartStrikethrough) {
                        [_delegate parserDidStartStrikethrough:self];
                    }
                } else if (_delegateFlags.didEndStrikethrough) {
                    [_delegate parserDidEndStrikethrough:self];
                }
            } else if (type == CMNodeTypeMathInline) {
                if (event == CMEventTypeExit && _delegateFlags.foundInlineMath) {
                    [_delegate parser:self foundInlineMath:node.contentValue];
                }
            } else if (type == CMNodeTypeMathBlock) {
                if (event == CMEventTypeExit && _delegateFlags.foundMathBlock) {
                    [_delegate parser:self foundMathBlock:node.contentValue];
                }
            } else if (type == CMNodeTypeEmoji) {
                if (event == CMEventTypeEnter && _delegateFlags.foundEmoji) {
                    [_delegate parser:self foundEmoji:node.contentValue];
                }
            }
        }
            break;
    }
}

#pragma mark - Accessors

- (void)setDelegate:(id<CMParserDelegate>)delegate
{
    if (_delegate != delegate) {
        _delegate = delegate;
        _delegateFlags.didStartDocument = [_delegate respondsToSelector:@selector(parserDidStartDocument:)];
        _delegateFlags.didEndDocument = [_delegate respondsToSelector:@selector(parserDidEndDocument:)];
        _delegateFlags.didAbort = [_delegate respondsToSelector:@selector(parserDidAbort:)];
        _delegateFlags.foundText = [_delegate respondsToSelector:@selector(parser:foundText:)];
        _delegateFlags.foundHRule = [_delegate respondsToSelector:@selector(parserFoundHRule:)];
        _delegateFlags.didStartHeader = [_delegate respondsToSelector:@selector(parser:didStartHeaderWithLevel:)];
        _delegateFlags.didEndHeader = [_delegate respondsToSelector:@selector(parser:didEndHeaderWithLevel:)];
        _delegateFlags.didStartParagraph = [_delegate respondsToSelector:@selector(parserDidStartParagraph:)];
        _delegateFlags.didEndParagraph = [_delegate respondsToSelector:@selector(parserDidEndParagraph:)];
        _delegateFlags.didStartEmphasis = [_delegate respondsToSelector:@selector(parserDidStartEmphasis:)];
        _delegateFlags.didEndEmphasis = [_delegate respondsToSelector:@selector(parserDidEndEmphasis:)];
        _delegateFlags.didStartStrong = [_delegate respondsToSelector:@selector(parserDidStartStrong:)];
        _delegateFlags.didEndStrong = [_delegate respondsToSelector:@selector(parserDidEndStrong:)];
        _delegateFlags.didStartStrikethrough = [_delegate respondsToSelector:@selector(parserDidStartStrikethrough:)];
        _delegateFlags.didEndStrikethrough = [_delegate respondsToSelector:@selector(parserDidEndStrikethrough:)];
        _delegateFlags.didStartLink = [_delegate respondsToSelector:@selector(parser:didStartLinkWithURL:title:)];
        _delegateFlags.didEndLink = [_delegate respondsToSelector:@selector(parser:didEndLinkWithURL:title:)];
        _delegateFlags.didStartImage = [_delegate respondsToSelector:@selector(parser:didStartImageWithURL:title:)];
        _delegateFlags.didEndImage = [_delegate respondsToSelector:@selector(parser:didEndImageWithURL:title:)];
        _delegateFlags.didStartFootNote = [_delegate respondsToSelector:@selector(parser:didStartFootNoteDefination:refCount:)];
        _delegateFlags.didEndFootNote = [_delegate respondsToSelector:@selector(parser:didEndFootNoteDefination:refCount:)];
        _delegateFlags.didStartFootNoteRef = [_delegate respondsToSelector:@selector(parser:didStartFootNoteRefIndex:title:defination:)];
        _delegateFlags.didEndFootNoteRef = [_delegate respondsToSelector:@selector(parser:didEndFootNoteRefIndex:title:defination:)];
        _delegateFlags.didStartTable = [_delegate respondsToSelector:@selector(parser:didStartTableWithNumberOfColumns:)];
        _delegateFlags.didStartTableRow = [_delegate respondsToSelector:@selector(parser:didEndTableRowIsHeader:)];
        _delegateFlags.didStartTableCell = [_delegate respondsToSelector:@selector(parser:didStartTableCellWithAlignment:)];
        _delegateFlags.didEndTable = [_delegate respondsToSelector:@selector(parser:didEndTableWithNumberOfColumns:)];
        _delegateFlags.didEndTableRow = [_delegate respondsToSelector:@selector(parser:didEndTableRowIsHeader:)];
        _delegateFlags.didEndTableCell = [_delegate respondsToSelector:@selector(parser:didEndTableCellWithAlignment:)];
        _delegateFlags.foundHTML = [_delegate respondsToSelector:@selector(parser:foundHTML:)];
        _delegateFlags.foundInlineHTML = [_delegate respondsToSelector:@selector(parser:foundInlineHTML:)];
        _delegateFlags.foundEmoji = [_delegate respondsToSelector:@selector(parser:foundEmoji:)];
        _delegateFlags.foundCodeBlock = [_delegate respondsToSelector:@selector(parser:foundCodeBlock:info:)];
        _delegateFlags.foundInlineCode = [_delegate respondsToSelector:@selector(parser:foundInlineCode:)];
        _delegateFlags.foundMathBlock = [_delegate respondsToSelector:@selector(parser:foundMathBlock:)];
        _delegateFlags.foundInlineMath = [_delegate respondsToSelector:@selector(parser:foundInlineMath:)];
        _delegateFlags.foundSoftBreak = [_delegate respondsToSelector:@selector(parserFoundSoftBreak:)];
        _delegateFlags.foundLineBreak = [_delegate respondsToSelector:@selector(parserFoundLineBreak:)];
        _delegateFlags.didStartBlockQuote = [_delegate respondsToSelector:@selector(parserDidStartBlockQuote:)];
        _delegateFlags.didEndBlockQuote = [_delegate respondsToSelector:@selector(parserDidEndBlockQuote:)];
        _delegateFlags.didStartUnorderedList = [_delegate respondsToSelector:@selector(parser:didStartUnorderedListWithTightness:)];
        _delegateFlags.didEndUnorderedList = [_delegate respondsToSelector:@selector(parser:didEndUnorderedListWithTightness:)];
        _delegateFlags.didStartOrderedList = [_delegate respondsToSelector:@selector(parser:didStartOrderedListWithStartingNumber:tight:)];
        _delegateFlags.didEndOrderedList = [_delegate respondsToSelector:@selector(parser:didEndOrderedListWithStartingNumber:tight:)];
        _delegateFlags.didStartListItem = [_delegate respondsToSelector:@selector(parserDidStartListItem:)];
        _delegateFlags.didEndListItem = [_delegate respondsToSelector:@selector(parserDidEndListItem:)];
    }
}

@end
