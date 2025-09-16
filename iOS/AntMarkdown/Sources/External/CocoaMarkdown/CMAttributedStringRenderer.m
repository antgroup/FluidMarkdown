//
//  CMAttributedStringRenderer.m
//  CocoaMarkdown
//
//  Created by Indragie on 1/14/15.
//  Copyright (c) 2015 Indragie Karunaratne. All rights reserved.
//

#import "CMAttributedStringRenderer.h"
#import "CMAttributedStringRenderer_Private.h"
#import "CMAttributeRun.h"
#import "CMCascadingAttributeStack.h"
#import "CMStack.h"
#import "CMHTMLElementTransformer.h"
#import "CMHTMLElement.h"
#import "CMHTMLUtilities.h"
#import "CMTextAttributes.h"
#import "CMImageTextAttachment.h"
#import "CMNode_Private.h"
#import "CMParser.h"
#import "CMHorizontalRuleAttachment.h"
#import "AMTextBackground.h"
#import "Ono.h"
#import "AMEmojiManager.h"
#import "CMTaskCheckAttachment+Private.h"

@implementation CMAttributedStringRenderer

- (instancetype)initWithDocument:(CMDocument *)document attributes:(CMTextAttributes *)attributes
{
    if ((self = [super init])) {
        _document = document;
        _attributes = attributes;
        _tagNameToTransformerMapping = [[NSMutableDictionary alloc] init];

    }
    return self;
}
- (instancetype)initWithDocument:(CMDocument *)document attributes:(CMTextAttributes *)attributes delegate:(nullable id<CMAttributedStringRendererDelegate>)delegate
{
    if ((self = [super init])) {
        _document = document;
        _attributes = attributes;
        _tagNameToTransformerMapping = [[NSMutableDictionary alloc] init];
        _delegate = delegate;
    }
    return self;
}
- (NSTextAttachment *)imageAttachmentWithURL:(NSURL *)url title:(NSString *)title
{
    return [[CMImageTextAttachment alloc] initWithImageURL:url title:title];
}

- (void)appendBulletString:(NSString *)string
{
    [self appendString:string];
}

- (void)registerHTMLElementTransformer:(id<CMHTMLElementTransformer>)transformer
{
    NSParameterAssert(transformer);
    _tagNameToTransformerMapping[[transformer.class tagName]] = transformer;
}

- (NSAttributedString *)render
{
    if (_attributedString == nil) {
        _attributeStack = [[CMCascadingAttributeStack alloc] init];
        _HTMLStack = [[CMStack alloc] init];
        _buffer = [[NSMutableAttributedString alloc] init];
        
        CMParser *parser = [[CMParser alloc] initWithDocument:_document delegate:self];
        [parser parse];
        
        _attributedString = [_buffer copy];
        _attributeStack = nil;
        _HTMLStack = nil;
        _buffer = nil;
    }
    
    return _attributedString;
}

#pragma mark - CMParserDelegate

- (void)parserDidStartDocument:(CMParser *)parser
{
    [_attributeStack pushAttributes:_attributes.baseTextAttributes];
}

- (void)parserDidEndDocument:(CMParser *)parser
{
    CFStringTrimWhitespace((__bridge CFMutableStringRef)_buffer.mutableString);
}

- (void)parser:(CMParser *)parser foundText:(NSString *)text
{
    if (! [self isImageDescriptionNode:parser.currentNode]) { // An image description text shall not be append to the current buffer
        CMHTMLElement *element = [_HTMLStack peek];
        if (element != nil) {
            [element.buffer appendString:text];
        } else {
            [self appendString:text];
        }
    }
}

- (void)parser:(CMParser *)parser didStartHeaderWithLevel:(NSInteger)level
{
    [_attributeStack pushAttributes:[_attributes attributesForHeaderLevel:level]];
}

- (void)parser:(CMParser *)parser didEndHeaderWithLevel:(NSInteger)level
{
    [self closeBlockForNode:parser.currentNode];
    [_attributeStack pop];
}

- (void)parserDidStartParagraph:(CMParser *)parser
{
    BOOL isInTightList = [self nodeIsInTightMode:parser.currentNode];
    [_attributeStack pushAttributes:!isInTightList ? _attributes.paragraphAttributes : nil];
    BOOL isInListItem = parser.currentNode.parent.type == CMNodeTypeItem;
    if (isInListItem && parser.currentNode.previous != nil) {
        CMStyleAttributes * parentAttributes = [_attributeStack attributesWithDepth:1];
        NSString *prefix = parentAttributes.paragraphStyleAttributes[CMParagraphStyleAttributeListItemParagraphPrefix];
        if (prefix) {
            [self appendString:prefix];
        }
    }
}

- (void)parserDidEndParagraph:(CMParser *)parser
{
    CMHTMLElement *element = [_HTMLStack pop];
    while (element) {
        [element.buffer appendFormat:@"</%@>", element.tagName];
        [self appendHTMLElement:element];
        element = [_HTMLStack pop];
    }
    [self closeBlockForNode:parser.currentNode];
    [_attributeStack pop];
}

- (void)parserDidStartEmphasis:(CMParser *)parser
{
    [_attributeStack pushAttributes:_attributes.emphasisAttributes];
}

- (void)parserDidEndEmphasis:(CMParser *)parser
{
    [_attributeStack pop];
}

- (void)parserDidStartStrong:(CMParser *)parser
{
    [_attributeStack pushAttributes:_attributes.strongAttributes];
}

- (void)parserDidEndStrong:(CMParser *)parse
{
    [_attributeStack pop];
}

- (void)parser:(CMParser *)parser didStartLinkWithURL:(NSURL *)URL title:(NSString *)title
{
    CMStyleAttributes * linkStyleAttributes = _attributes.linkAttributes.copy;
    linkStyleAttributes.stringAttributes [NSLinkAttributeName] = URL;
#if !TARGET_OS_IPHONE
    if (title != nil) {
        linkStyleAttributes.stringAttributes [NSToolTipAttributeName] = title;
    }
#endif
    if ([linkStyleAttributes.stringAttributes[CMLinkBold] boolValue]) {
        CMAttributeRun *parentRun = [_attributeStack peek];
        CMStyleAttributes * parentAttributes = parentRun.attributes;
        UIFont* font = parentAttributes.stringAttributes[NSFontAttributeName];
        if (!font) {
            font = self.attributes.paragraphAttributes.stringAttributes[NSFontAttributeName];
        }
        UIFont* linkFont = [UIFont systemFontOfSize:font.pointSize weight:UIFontWeightSemibold];
            [linkStyleAttributes.stringAttributes addEntriesFromDictionary:@{NSFontAttributeName: linkFont}];
    }
    
    [_attributeStack pushAttributes:linkStyleAttributes];
}

- (void)parser:(CMParser *)parser didEndLinkWithURL:(NSURL *)URL title:(NSString *)title
{
    [_attributeStack pop];
    [self addClickableObjects:CMNodeTypeLink data:URL.absoluteString tag:@""];
}

- (void)parser:(CMParser *)parser didStartImageWithURL:(NSURL *)URL title:(NSString *)title
{
    NSTextAttachment* textAttachment = [self imageAttachmentWithURL:URL title:title];
    if (textAttachment != nil) {
        // Detect if an image has its own paragraph, in which cas we can apply specific attributes.
        // (Note: This test also detect the case: image in link in paragraph)
        CMNode* imageNode = parser.currentNode;
        BOOL isInImageParagraph = ((imageNode.next == nil) && (imageNode.previous == nil) 
                                   && ((imageNode.parent.type == CMNodeTypeParagraph) 
                                       || ((imageNode.parent.next == nil) && (imageNode.parent.previous == nil) && (imageNode.parent.parent.type == CMNodeTypeParagraph))));
        
        CMHTMLElement *element = [_HTMLStack peek];
        if (element != nil) {
            // TODO: how should we handle a markdown image inside HTML;? Is this possible????
        } else {
            CMStyleAttributes * imageAttachmentAttributes;
            if (isInImageParagraph) {
                imageAttachmentAttributes = _attributes.imageParagraphAttributes.copy;
            }
            else {
                imageAttachmentAttributes = [CMStyleAttributes new];
            }
            imageAttachmentAttributes.stringAttributes[NSAttachmentAttributeName] = textAttachment;
#if !TARGET_OS_IPHONE
            CMNode *imageDescriptionNode = imageNode.firstChild;
            if ((imageDescriptionNode.type == CMNodeTypeText) && (imageDescriptionNode.stringValue.length > 0)) {
                imageAttachmentAttributes.stringAttributes [NSToolTipAttributeName] = imageDescriptionNode.stringValue;
            }
#endif     
            [_attributeStack pushAttributes:imageAttachmentAttributes];
            
            const unichar attachmentChar = NSAttachmentCharacter;
            [self appendString:[NSString stringWithCharacters:&attachmentChar length:1]];
            
            if (isInImageParagraph) {
                [self closeBlockForNode:imageNode];
            }
        }
    }
}

- (void)parser:(CMParser *)parser didEndImageWithURL:(NSURL *)URL title:(NSString *)title
{
    [_attributeStack pop];
}

- (void)parser:(CMParser *)parser foundHTML:(NSString *)HTML
{
    NSString *tagName = CMTagNameFromHTMLTag(HTML);
    if (tagName.length != 0) {
        CMHTMLElement *element = [self newHTMLElementForTagName:tagName HTML:HTML];
        if (element != nil) {
            [self appendHTMLElement:element];
        }
    }
}

- (void)parser:(CMParser *)parser foundInlineHTML:(NSString *)HTML
{
    NSString *tagName = CMTagNameFromHTMLTag(HTML);
    if (tagName.length != 0) {
        CMHTMLElement *element = nil;
        if (CMIsHTMLVoidTagName(tagName)) {
            element = [self newHTMLElementForTagName:tagName HTML:HTML];
            if (element != nil) {
                [self appendHTMLElement:element];
            }
        } else if (CMIsHTMLClosingTag(HTML)) {
            if ((element = [_HTMLStack pop])) {
                NSAssert([element.tagName isEqualToString:tagName], @"Closing tag does not match opening tag");
                [element.buffer appendString:HTML];
                [self appendHTMLElement:element];
            }
        } else if (CMIsHTMLTag(HTML)) {
            element = [self newHTMLElementForTagName:tagName HTML:HTML];
            if (element != nil) {
                [_HTMLStack push:element];
            }
        }
    }
}

- (void)parser:(CMParser *)parser foundEmoji:(NSString *)emoji {
    NSString *emojiVal = [[AMEmojiManager sharedManager] emojiWithName:emoji];
    if (emojiVal) {
        [self appendString:emojiVal];
    } else {
        [self appendString:emoji];
    }
}

- (void)parser:(CMParser *)parser foundCodeBlock:(NSString *)code info:(NSString *)info
{
    [_attributeStack pushAttributes:_attributes.codeBlockAttributes];
    if ([code hasSuffix:@"\n"]) {
        code = [code substringToIndex:code.length - 1]; // Remove final "\n"
    }
    NSString* const lineSeparatorCharacterString = @"\u2028";
    [self appendString:[code stringByReplacingOccurrencesOfString:@"\n" withString:lineSeparatorCharacterString]];
    [self closeBlockForNode:parser.currentNode];
    [_attributeStack pop];
}

- (void)parser:(CMParser *)parser foundInlineCode:(NSString *)code
{
    [_attributeStack pushAttributes:_attributes.inlineCodeAttributes];
    [self appendString:code];
    [_attributeStack pop];
}

- (void)parserFoundSoftBreak:(CMParser *)parser
{
    [self appendString:@" "];
}

- (void)parserFoundLineBreak:(CMParser *)parser
{
    [self appendString:@"\u2028"];
}

- (void)parserFoundHRule:(CMParser *)parser
{
    if (![_buffer.string hasSuffix:@"\n"]) {
        [self appendString:@"\n"];
    }
    
    CMHorizontalRuleAttachment *hruleAttachment = [[CMHorizontalRuleAttachment alloc] init];
    
    CMStyleAttributes *hruleAttributes = _attributes.horizontalRuleAttributes;
    if (hruleAttributes.stringAttributes[NSForegroundColorAttributeName]) {
        hruleAttachment.lineColor = hruleAttributes.stringAttributes[NSForegroundColorAttributeName];
    }
    if (self.attributes.horizontalRuleAttributes.paragraphStyleAttributes[CMParagraphStyleAttributeParagraphSpacingBefore]) {
        hruleAttachment.verticalPaddingBefore = [self.attributes.horizontalRuleAttributes.paragraphStyleAttributes[CMParagraphStyleAttributeParagraphSpacingBefore] intValue];
    }
    if (self.attributes.horizontalRuleAttributes.paragraphStyleAttributes[CMParagraphStyleAttributeParagraphSpacing]) {
        hruleAttachment.verticalPadding = [self.attributes.horizontalRuleAttributes.paragraphStyleAttributes[CMParagraphStyleAttributeParagraphSpacing] intValue];
    }
    
    NSNumber *thickness = hruleAttributes.stringAttributes[CMHorizontalRuleThickness];
    if (thickness) {
        hruleAttachment.lineThickness = [thickness floatValue];
    }
    
    NSMutableDictionary *attachmentAttributes = [NSMutableDictionary dictionaryWithDictionary:_attributeStack.cascadedAttributes];
    attachmentAttributes[NSAttachmentAttributeName] = hruleAttachment;
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:hruleAttachment];
    NSMutableAttributedString *hruleAttrString = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
    [hruleAttrString addAttributes:attachmentAttributes range:NSMakeRange(0, hruleAttrString.length)];
    
    [_buffer appendAttributedString:hruleAttrString];
    
    [self appendString:@"\n"];
    
    [self closeBlockForNode:parser.currentNode];
}

- (void)parserDidStartBlockQuote:(CMParser *)parser
{
    quoteLevel++;
    CMStyleAttributes *styleAttributes = [_attributes.blockQuoteAttributes copy];
    AMTextBackground *bg = styleAttributes.stringAttributes[AMBackgroundDrawableAttributeName];
    if ([bg isKindOfClass:AMTextBackground.class]) {
        bg.isQuote = YES;
    }
    if (quoteLevel == 1) {
        if (styleAttributes.stringAttributes[NSForegroundColorAttributeName]) {
            paragraphColor = self.attributes.paragraphAttributes.stringAttributes[NSForegroundColorAttributeName];
            paragraphFont = self.attributes.paragraphAttributes.stringAttributes[NSFontAttributeName];
            paragrahpSpace = [self.attributes.paragraphAttributes.paragraphStyleAttributes[CMParagraphStyleAttributeParagraphSpacing] floatValue];
            paragrahpSpaceBofore = [self.attributes.paragraphAttributes.paragraphStyleAttributes[CMParagraphStyleAttributeParagraphSpacingBefore] floatValue];
            [self.attributes.paragraphAttributes.stringAttributes removeObjectForKey:NSForegroundColorAttributeName];
            [self.attributes.paragraphAttributes.stringAttributes removeObjectForKey:NSFontAttributeName];
            [self.attributes.paragraphAttributes.stringAttributes removeObjectForKey:CMParagraphStyleAttributeParagraphSpacing];
            [self.attributes.paragraphAttributes.stringAttributes removeObjectForKey:CMParagraphStyleAttributeParagraphSpacingBefore];
            self.attributes.paragraphAttributes.stringAttributes[NSForegroundColorAttributeName] = styleAttributes.stringAttributes[NSForegroundColorAttributeName];
            self.attributes.paragraphAttributes.stringAttributes[NSFontAttributeName] = styleAttributes.stringAttributes[NSFontAttributeName];
            self.attributes.paragraphAttributes.paragraphStyleAttributes[CMParagraphStyleAttributeParagraphSpacing] = styleAttributes.paragraphStyleAttributes[CMParagraphStyleAttributeParagraphSpacing];
            self.attributes.paragraphAttributes.paragraphStyleAttributes[CMParagraphStyleAttributeParagraphSpacingBefore] = styleAttributes.paragraphStyleAttributes[CMParagraphStyleAttributeParagraphSpacingBefore];
        }
    }
    
  
    [_attributeStack pushAttributes:styleAttributes];
}

- (void)parserDidEndBlockQuote:(CMParser *)parser
{
    quoteLevel--;
    [self closeBlockForNode:parser.currentNode];
    [_attributeStack pop];
    if (quoteLevel == 0) {
        if (self.attributes.blockQuoteAttributes.stringAttributes[NSForegroundColorAttributeName]) {
            [self.attributes.paragraphAttributes.stringAttributes removeObjectForKey:NSForegroundColorAttributeName];
            self.attributes.paragraphAttributes.stringAttributes[NSForegroundColorAttributeName] = paragraphColor;
        }
        if (self.attributes.blockQuoteAttributes.stringAttributes[NSFontAttributeName]) {
            [self.attributes.paragraphAttributes.stringAttributes removeObjectForKey:NSFontAttributeName];
            self.attributes.paragraphAttributes.stringAttributes[NSFontAttributeName] = paragraphFont;
        }
        if (self.attributes.blockQuoteAttributes.paragraphStyleAttributes[CMParagraphStyleAttributeParagraphSpacing]) {
            [self.attributes.paragraphAttributes.paragraphStyleAttributes removeObjectForKey:CMParagraphStyleAttributeParagraphSpacing];
            self.attributes.paragraphAttributes.paragraphStyleAttributes[CMParagraphStyleAttributeParagraphSpacing] = @(paragrahpSpace);
        }
        if (self.attributes.blockQuoteAttributes.paragraphStyleAttributes[CMParagraphStyleAttributeParagraphSpacingBefore]) {
            [self.attributes.paragraphAttributes.paragraphStyleAttributes removeObjectForKey:CMParagraphStyleAttributeParagraphSpacingBefore];
            self.attributes.paragraphAttributes.paragraphStyleAttributes[CMParagraphStyleAttributeParagraphSpacingBefore] = @(paragrahpSpaceBofore);
        }
    }
}

- (void)parser:(CMParser *)parser didStartUnorderedListWithTightness:(BOOL)tight
{
    if ([self sublistLevel:parser.currentNode.parent] == 0) {
       [_attributeStack pushAttributes:_attributes.unorderedListAttributes];
    }
    else {
        [self closeBlockForNode:parser.currentNode]; // When starting a sublist, the parent item must have its block closed first
        [_attributeStack pushAttributes:_attributes.unorderedSublistAttributes];
    }
}

- (void)parser:(CMParser *)parser didEndUnorderedListWithTightness:(BOOL)tight
{
    [_attributeStack pop];
}

- (void)parser:(CMParser *)parser didStartOrderedListWithStartingNumber:(NSInteger)num tight:(BOOL)tight
{
    if ([self sublistLevel:parser.currentNode.parent] == 0) {
        [_attributeStack pushOrderedListAttributes:_attributes.orderedListAttributes withStartingNumber:num];
    }
    else {
        [self closeBlockForNode:parser.currentNode]; // When starting a sublist, the parent item must have its block closed first
        [_attributeStack pushOrderedListAttributes:_attributes.orderedSublistAttributes withStartingNumber:num];
    }
}

- (void)parser:(CMParser *)parser didEndOrderedListWithStartingNumber:(NSInteger)num tight:(BOOL)tight
{
    [_attributeStack pop];
}
-(NSInteger)getOrderListNumber {
    CMAttributeRun *parentRun = [_attributeStack peek];
    return parentRun.orderedListItemNumber;
}
- (void)parserDidStartListItem:(CMParser *)parser
{
    CMAttributeRun *parentRun = [_attributeStack peek];
    CMStyleAttributes * parentAttributes = parentRun.attributes;
    
    CMNode *node = parser.currentNode.parent;
    CMNode *curNode = parser.currentNode;
    switch (node.listType) {
        case CMListTypeNone:
            NSAssert(NO, @"Parent node of list item must be a list");
            break;
        case CMListTypeUnordered: {
            if (curNode && curNode.isCheckBox) {
                [self addCheckBoxAttachment:curNode];
            } else {
                if (!self.attributes.paragraphAttributes.stringAttributes[CMCustomListBullet]) {
                    [self appendBulletString:[NSString stringWithFormat:@"%@\t", parentAttributes.paragraphStyleAttributes [CMParagraphStyleAttributeListItemBulletString]]];
                } else {
                    [self appendBulletString:@"\t"];
                }
            }
            [_attributeStack pushAttributes:_attributes.unorderedListItemAttributes];
            
            break;
        }
        case CMListTypeOrdered: {
            if (curNode && curNode.isCheckBox) {
                [self addCheckBoxAttachment:curNode];
            } else {
                
                if (!self.attributes.paragraphAttributes.stringAttributes[CMCustomListBullet]) {
                    [self appendString:[[NSString stringWithFormat:parentAttributes.paragraphStyleAttributes[CMParagraphStyleAttributeListItemNumberFormat] ?: @"%ld.",
                                         (long)parentRun.orderedListItemNumber]
                                        stringByAppendingString:@"\t"]];
                } else {
                    [self appendString:@"\t"];
                }
                

                parentRun.orderedListItemNumber++;
            }
            [_attributeStack pushAttributes:_attributes.orderedListItemAttributes];
            break;
        }
        default:
            break;
    }
}

- (void)addCheckBoxAttachment:(CMNode *)curNode {

    CMTaskCheckAttachment *attachment = [[CMTaskCheckAttachment alloc] init];
    attachment.checked = curNode.checked;
    
    NSDictionary *cascadedAttributes = _attributeStack.cascadedAttributes;
    UIFont *casFont = cascadedAttributes[NSFontAttributeName];
    if (casFont) {
        attachment.lineHeight = ceil(casFont.lineHeight);
    }
    CMStyleAttributes *checkboxAttributes = _attributes.checkboxAttributes;
    if (checkboxAttributes.stringAttributes[NSForegroundColorAttributeName]) {
        attachment.borderColor = checkboxAttributes.stringAttributes[NSForegroundColorAttributeName];
    }
    
    if (checkboxAttributes.stringAttributes[NSBackgroundColorAttributeName]) {
        attachment.backgroundColor = checkboxAttributes.stringAttributes[NSBackgroundColorAttributeName];
    }
    
    NSNumber *borderWidth = checkboxAttributes.stringAttributes[CMCheckBoxBorderWidth];
    if (borderWidth) {
        attachment.borderWidth = [borderWidth floatValue];
    }
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    [_buffer appendAttributedString:attachmentString];
}

- (void)parserDidEndListItem:(CMParser *)parser
{
    [self closeBlockForNode:parser.currentNode];
    [_attributeStack pop];
}

#pragma mark - Private

- (NSUInteger)sublistLevel:(CMNode *)node
{
    if (node.parent == nil) {
        return 0;
    } else {
        return (node.listType == CMListTypeNone ? 0 : 1) + [self sublistLevel:node.parent];
    }
}

- (CMHTMLElement *)newHTMLElementForTagName:(NSString *)tagName HTML:(NSString *)HTML
{
    NSParameterAssert(tagName);
    id<CMHTMLElementTransformer> transformer = _tagNameToTransformerMapping[tagName];
    if (transformer != nil) {
        CMHTMLElement *element = [[CMHTMLElement alloc] initWithTransformer:transformer];
        [element.buffer appendString:HTML];
        return element;
    }
    return nil;
}

- (BOOL)isImageDescriptionNode:(CMNode *)node
{
    return node.parent.type == CMNodeTypeImage;
}

- (BOOL)nodeIsInTightMode:(CMNode *)node
{
    CMNode *grandparent = node.parent.parent;
    return grandparent.listTight;
}

- (void)appendString:(NSString *)string
{
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string attributes:_attributeStack.cascadedAttributes];
    [_buffer appendAttributedString:attrString];
}

- (void)closeBlockForNode:(CMNode *)currentNode
{
    // Add a paragraph boundary to the attributted string if needed
    if (![_buffer.string hasSuffix:@"\n"]) {
        
        NSRange bufferLastParagraphRange = [_buffer.string paragraphRangeForRange:NSMakeRange(_buffer.string.length, 0)];
        
        [self appendString:@"\n"];
        
        if (bufferLastParagraphRange.length > 0) {
            // Extend the current paragraph style to enclode the whole paragraph if needed
            NSParagraphStyle* bufferLastParagraphStyle = [_buffer attribute:NSParagraphStyleAttributeName atIndex:bufferLastParagraphRange.location effectiveRange:NULL];
            NSParagraphStyle* appendedParagraphStyle = _attributeStack.cascadedAttributes[NSParagraphStyleAttributeName];
            if ((appendedParagraphStyle != nil) && ![appendedParagraphStyle isEqual:bufferLastParagraphStyle]) {
                [_buffer addAttribute:NSParagraphStyleAttributeName value:appendedParagraphStyle range:bufferLastParagraphRange];
            }
            
            if ([self sublistLevel:currentNode] != 0) {
                // In a list: adjust the indentation and tabs of list item's first paragraphs
                [self adjustListItemIndentForNode:currentNode paragraphStyle:appendedParagraphStyle inRange:bufferLastParagraphRange];
            }
        }
    }
}

static NSTextTab * textTabWithPosition(CGFloat tabPosition)
{
    return [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentNatural location:tabPosition options:@{}];
}

- (void) adjustListItemIndentForNode:(CMNode*)currentNode paragraphStyle:(NSParagraphStyle*)currentParagraphStyle inRange:(NSRange)currentParagraphRange
{
    NSUInteger listAttributesStackDepth = 0;
    CGFloat itemContentIndent = 0;
    
    while ((currentNode != nil) && (currentNode.type != CMNodeTypeItem)) {
        if ([currentNode isEqual:currentNode.parent.firstChild]) {
            // indentation change is only needed for list-items' first child
            
            CMStyleAttributes* currentStyleAttributes = [_attributeStack attributesWithDepth:listAttributesStackDepth];
            NSNumber* currentFirstLineExtraIndent = currentStyleAttributes.paragraphStyleAttributes[CMParagraphStyleAttributeFirstLineHeadExtraIndent];
            itemContentIndent += currentFirstLineExtraIndent.doubleValue;
            
            currentNode = currentNode.parent;
            listAttributesStackDepth += 1;
        }
        else {
            currentNode = nil;
        }
    }
    
    if (currentNode.parent.type == CMNodeTypeList) {
        CMStyleAttributes* listStyleAttributes = [_attributeStack attributesWithDepth:listAttributesStackDepth + 1];
        
        NSNumber* listItemMarkerIndent = listStyleAttributes.paragraphStyleAttributes [CMParagraphStyleAttributeListItemLabelIndent];
        if ([listItemMarkerIndent isKindOfClass:[NSNumber class]]) {
            NSMutableParagraphStyle* itemParagrahStyle = [currentParagraphStyle mutableCopy];
            // Set a tab at the original first line head indent, plus a few extra tabs in case the list item marker extends beyond the first tab
            // (typically with dynamic type, in case of bigger text size, extra tabs will help a list item to stay on a single line)
            itemParagrahStyle.tabStops = @[ textTabWithPosition(itemParagrahStyle.firstLineHeadIndent),
                                            textTabWithPosition(itemParagrahStyle.firstLineHeadIndent + listItemMarkerIndent.doubleValue),
                                            textTabWithPosition(itemParagrahStyle.firstLineHeadIndent + listItemMarkerIndent.doubleValue * 2)];
            itemParagrahStyle.firstLineHeadIndent -= listItemMarkerIndent.doubleValue + itemContentIndent;
            // And update the pargraph style attributes
            [_buffer addAttribute:NSParagraphStyleAttributeName value:itemParagrahStyle range:currentParagraphRange];
        }
    }
}    

- (void)appendHTMLElement:(CMHTMLElement *)element
{
    NSError *error = nil;
    ONOXMLDocument *document = [ONOXMLDocument HTMLDocumentWithString:element.buffer encoding:NSUTF8StringEncoding error:&error];
    if (document == nil) {
        NSLog(@"Error creating HTML document for buffer \"%@\": %@", element.buffer, error);
        return;
    }
    
    ONOXMLElement *XMLElement = document.rootElement[0][0];
    if (XMLElement != nil) {
        NSDictionary *attributes = _attributeStack.cascadedAttributes;
        NSAttributedString *attrString = [element.transformer attributedStringForElement:XMLElement attributes:attributes];
        
        if (attrString != nil) {
            CMHTMLElement *parentElement = [_HTMLStack peek];
            if (parentElement == nil) {
                if (_tableCellBuffer) {
                    [_tableCellBuffer appendAttributedString:attrString];
                } else {
                    [_buffer appendAttributedString:attrString];
                }
            } else {
                [parentElement.buffer appendString:attrString.string];
            }
            if ([NSStringFromClass(element.transformer.class) isEqualToString:@"AMHTMLIconLinkTransformer"]) {
                NSDictionary* linkUrl = [element.transformer getParams];
                [self addClickableObjects:CMNodeTypeInlineHTML data:[linkUrl objectForKey:@"linkUrl"] tag:@"iconLink"];
            }
        }
    } else {
        NSLog(@"Warning: XMLElement is nil for HTML buffer: \"%@\"", element.buffer);
    }
}
-(void)addClickableObjects:(CMNodeType)type data:(id)data tag:(NSString*)tag {
    if (!data) {
        return;
    }
    NSDictionary* subDic = nil;
    if ((type == CMNodeTypeInlineHTML && [tag isEqualToString:@"iconLink"])
        || type == CMNodeTypeLink
        || type == CMNodeTypeImage) {
        subDic = @{@"url":(NSString*)data, @"type":@(type), @"tag":tag};
    }
    if (!subDic) {
        return;
    }
    if (!_clickableObjs) {
        _clickableObjs = [[NSMutableArray alloc] init];
    }
    [_clickableObjs addObject:subDic];
}
-(NSArray*)clickableObjs
{
    return [_clickableObjs mutableCopy];
}
@end
