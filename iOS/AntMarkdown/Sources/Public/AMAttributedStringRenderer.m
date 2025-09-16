// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMAttributedStringRenderer.h"
#import "CMNode+Table.h"
#import "CMAttributedStringRenderer_Private.h"

#import "AMTextStyles.h"
#import "AMInlineMathAttachment.h"
#import "AMBlockMathAttachment.h"
#import "AMTableViewAttachment.h"
#import "AMCodeViewAttachment.h"
#import "AMImageTextAttachment.h"
#import "AMIconAttachment.h"
#import "AMHTMLTransformer.h"
#import "AMUtils.h"
#import "CMHTMLElement.h"
#import "CMAttributeRun.h"

@implementation AMAttributedStringRenderer
{
    struct {
        unsigned int isInTable:1;
        unsigned int isInTableRow:1;
        unsigned int isInTableCell:1;
    } _flags;
    
    NSMutableArray<CMTableCell *> * _tableCells;
    CMTable * _currentTable;
    NSInteger   _listLevel;
    NSInteger   _orderListLevel;
    NSInteger   _unorderListLevel;
    NSInteger  _parsingNodeType;// 1:order;2:unorder;
    CMStack*     _indentStack;
    CMImageTextAttachment* _currentImageAttachment;
    CGFloat _listItemExtraIndent;
}
@dynamic attributes;

- (instancetype)initWithDocument:(CMDocument *)document attributes:(AMTextStyles *)attributes
{
    self = [super initWithDocument:document attributes:attributes];
    if (self) {
        [self init:attributes];
    }
    return self;
}
- (instancetype)initWithDocument:(CMDocument *)document attributes:(AMTextStyles *)attributes delegate:(nullable id<CMAttributedStringRendererDelegate>)delegate
{
    self = [super initWithDocument:document attributes:attributes delegate:delegate];
    if (self) {
        [self init:attributes];
    }
    return self;
}
-(void)init:(AMTextStyles *)attributes {
    [self registerHTMLElementTransformer:[[CMHTMLStrikethroughTransformer alloc] init]];
    [self registerHTMLElementTransformer:[[CMHTMLSuperscriptTransformer alloc] init]];
    [self registerHTMLElementTransformer:[[CMHTMLSubscriptTransformer alloc] init]];
    [self registerHTMLElementTransformer:[[AMHTMLMarkTransformer alloc] initWithStyles:attributes]];
    [self registerHTMLElementTransformer:[[AMHTMLSpanTransformer alloc] initWithStyles:attributes]];
    [self registerHTMLElementTransformer:[[AMHTMLCiteTransformer alloc] initWithStyles:attributes]];
    [self registerHTMLElementTransformer:[[AMHTMLDelTransformer alloc] initWithStyles:attributes]];
    [self registerHTMLElementTransformer:[[AMHTMLFontTransformer alloc] initWithStyles:attributes]];
    UIColor* underlineColor = attributes.underlineAttributes.stringAttributes[NSForegroundColorAttributeName] ? : [UIColor colorWithHex_ant_mark:0x521677FF];

    CGFloat underLineWidth = attributes.underlineAttributes.stringAttributes[@"lineWidth"] ? [attributes.underlineAttributes.stringAttributes[@"lineWidth"] floatValue] : 6;
    CGFloat underlineOffset = attributes.underlineAttributes.stringAttributes[@"lineOffset"] ? [attributes.underlineAttributes.stringAttributes[@"lineOffset"] floatValue] : 4;
    [self registerHTMLElementTransformer:[[AMHTMLUnderlineTransformer alloc] initWithStyle:NSUnderlineStyleThick
                                                                                     color:underlineColor
                                                                                 lineWidth:underLineWidth
                                                                                    offset:underlineOffset]];
    [self registerHTMLElementTransformer:[[AMHTMLImgTransformer alloc] initWithStyles:attributes]];
    [self registerHTMLElementTransformer:[[AMHTMLIconLinkTransformer alloc] initWithStyles:attributes]];
    [self registerHTMLElementTransformer:[[AMHTMLIconTransformer alloc] initWithStyles:attributes]];
    [attributes.elementTransformers enumerateObjectsUsingBlock:^(id<CMHTMLElementTransformer>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self registerHTMLElementTransformer:obj];
    }];
}
- (NSTextAttachment *)imageAttachmentWithURL:(NSURL *)url title:(NSString *)title
{
    return [[AMImageTextAttachment alloc] initWithImageURL:url title:title];
}

- (void)appendString:(NSString *)string {
    if (_tableCellBuffer) {
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string
                                                                         attributes:self.attributeStack.cascadedAttributes];
        [_tableCellBuffer appendAttributedString:attrString];
    } else {
        [super appendString:string];
    }
}

- (void)appendAttributedString:(NSAttributedString *)attributedString {
    if (_tableCellBuffer) {
        [_tableCellBuffer appendAttributedString:attributedString];
    } else {
        [self.buffer appendAttributedString:attributedString];
    }
}

- (void)appendBulletString:(NSString *)string
{
    if([string length] == 0)
        return;
    CMStyleAttributes *attr = self.attributes.listBulletAttributes;
    if (attr) {
        [self.attributeStack pushAttributes:self.attributes.listBulletAttributes];
    }
    [self appendString:string];
    if (attr) {
        [self.attributeStack pop];
    }
}

@end

@implementation AMAttributedStringRenderer (Parser)

- (void)parserDidEndDocument:(CMParser *)parser
{
    if ([_buffer.mutableString hasPrefix:@"\t"])
    {
        [super parserDidEndDocument:parser];
        [_buffer.mutableString insertString:@"\t" atIndex:0];
    }
    else if ([_buffer.mutableString hasPrefix:@"\u00A0"])
    {
        NSAttributedString* spaceStr = [_buffer attributedSubstringFromRange:NSMakeRange(0, 1)];
        [super parserDidEndDocument:parser];
        [_buffer insertAttributedString:spaceStr atIndex:0];
    }
    else
    {
        [super parserDidEndDocument:parser];
    }
}

- (void)parser:(CMParser *)parser foundText:(NSString *)text
{
    [super parser:parser foundText:text];
    
    // An image description text shall be set alt property
    if (CMNodeTypeImage == parser.currentNode.parent.type)
    {
        if(_currentImageAttachment)
        {
            _currentImageAttachment.altText = text;
        }
    }
}

- (void)parser:(CMParser *)parser foundInlineMath:(NSString *)code {
    AMMathStyle *style = [AMMathStyle defaultStyle];
    NSDictionary<NSString *, id> *attributes = self.attributeStack.cascadedAttributes;
    if ([attributes[NSFontAttributeName] isKindOfClass:[UIFont class]]) {
        style.font = ((UIFont *)attributes[NSFontAttributeName]);
    }
    if ([attributes[NSForegroundColorAttributeName] isKindOfClass:[UIColor class]]) {
        style.textColor = attributes[NSForegroundColorAttributeName];
    }
    [self appendAttributedString:[[AMInlineMathAttachment alloc] initWithText:code
                                                                        style:style].attributedString];
}

- (void)parser:(CMParser *)parser foundMathBlock:(NSString *)code {
    AMMathStyle *style = [AMMathStyle defaultBlockStyle];
    style.horizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    NSDictionary<NSString *, id> *attributes = self.attributeStack.cascadedAttributes;
    if ([attributes[NSFontAttributeName] isKindOfClass:[UIFont class]]) {
        style.font = ((UIFont *)attributes[NSFontAttributeName]);
    }
    if ([attributes[NSForegroundColorAttributeName] isKindOfClass:[UIColor class]]) {
        style.textColor = attributes[NSForegroundColorAttributeName];
    }
    
    [self closeBlockOnly];
    NSArray<AMBlockMathAttachment *> *mathAttachments = [AMBlockMathAttachment constructorBlockMathAttachmentWithText:code style:style];
    for (AMBlockMathAttachment *mathAttachment in mathAttachments) {
        NSMutableAttributedString* mathAttrStr = [mathAttachment.attributedString mutableCopy];
        if(mathAttrStr.length > 0) {
            [mathAttrStr addAttribute:NSParagraphStyleAttributeName value:style.paragraphStyle range:NSMakeRange(0, mathAttrStr.length)];
        }
        [self appendAttributedString:mathAttrStr];
        [self closeBlockOnly];
    }
}

- (void)closeBlockOnly
{
    if (![_buffer.string hasSuffix:@"\n"])
    {
        [self appendString:@"\n"];
    }
}

- (void)parserDidStartStrikethrough:(CMParser *)parser
{
    [self.attributeStack pushAttributes:self.attributes.strikethroughAttributes];
}

- (void)parserDidEndStrikethrough:(CMParser *)parser
{
    [self.attributeStack pop];
}

- (void)parser:(CMParser *)parser foundCodeBlock:(NSString *)code info:(NSString *)info
{
    if ([code hasSuffix:@"\n"]) {
        code = [code substringToIndex:code.length - 1]; // Remove final "\n"
    }

    info = [info lowercaseString];
    
    NSTextAttachment<AMViewAttachment> * attach = [self.attributes.codeBuilder buildWithCode:code
                                                                                    language:info
                                                                                      styles:self.attributes];
    if (!attach) {
        attach = [AMCodeViewAttachment attachmentWithCode:code
                                                 language:info
                                                   styles:self.attributes];
    }
    NSAttributedString *attr = nil;
    if ([attach respondsToSelector:@selector(attributedString)]) {
        attr = [attach attributedString];
    }
    if (!attr) {
        attr = [NSAttributedString attributedStringWithAttachment:attach];
    }
    
    [self appendAttributedString:attr];
}

- (void)parser:(CMParser *)parser foundInlineCode:(NSString *)code
{
    [self.attributeStack pushAttributes:_attributes.inlineCodeAttributes];
    if(code && [code length] > 0)
    {
        NSString* codeStr = [NSString stringWithFormat:@"\u00A0%@\u00A0", code];
        [self appendString:codeStr];
        NSDictionary* spaceAttr = @{NSKernAttributeName:@(6),NSFontAttributeName:[UIFont systemFontOfSize:2.f]};
        [self.buffer addAttributes:spaceAttr range:NSMakeRange(self.buffer.length - codeStr.length, 1)];
        [self.buffer addAttributes:spaceAttr range:NSMakeRange(self.buffer.length - 1, 1)];
    }
    [self.attributeStack pop];
}

- (void)parser:(CMParser *)parser didStartTableWithNumberOfColumns:(NSUInteger)columns {
    _flags.isInTable = true;
    
    _currentTable = [CMTable tableWithNumberOfColumns:columns];
    [self.attributeStack pushAttributes:self.attributes.tableCellAttributes];
}

- (void)parser:(CMParser *)parser didEndTableWithNumberOfColumns:(NSUInteger)columns {
    _flags.isInTable = false;
    
    if (_currentTable) {
        NSTextAttachment<AMViewAttachment> * attach = [self.attributes.tableBuilder buildWithTable:_currentTable
                                                                                            styles:self.attributes];
        if (!attach) {
            attach = [[AMTableViewAttachment alloc] initWithTable:_currentTable styles:self.attributes];
        }
        NSAttributedString *attr = nil;
        if ([attach respondsToSelector:@selector(attributedString)]) {
            attr = [attach attributedString];
        }
        if (!attr) {
            attr = [NSAttributedString attributedStringWithAttachment:attach];
        }
        
        [self.buffer appendAttributedString:attr];
        [self.attributeStack pop];
        _currentTable = nil;
    }
}

- (void)parser:(CMParser *)parser didStartTableRowIsHeader:(BOOL)isHeader {
    NSAssert(_flags.isInTable, @"state is error");
    _flags.isInTableRow = true;
    
    if (isHeader) {
        [self.attributeStack pushAttributes:self.attributes.tableHeaderAttributes];
    }
    [_currentTable push:[CMTableRow rowWithHeader:isHeader]];
}

- (void)parser:(CMParser *)parser didEndTableRowIsHeader:(BOOL)isHeader {
    NSAssert(_flags.isInTable, @"state is error");
    _flags.isInTableRow = false;
    
    if (isHeader) {
        [self.attributeStack pop];
    }
}

- (void)parser:(CMParser *)parser didStartTableCellWithAlignment:(NSTextAlignment)alignment {
    NSAssert(_flags.isInTable && _flags.isInTableRow, @"state is error");
    _flags.isInTableCell = true;
    
    _tableCellBuffer = [[NSMutableAttributedString alloc] init];
}

- (void)parser:(CMParser *)parser didEndTableCellWithAlignment:(NSTextAlignment)alignment {
    NSAssert(_flags.isInTable && _flags.isInTableRow, @"state is error");
    _flags.isInTableCell = false;
    
    [_currentTable.peekRow push:[CMTableCell cellWithContent:_tableCellBuffer
                                                   alignment:alignment]];
    _tableCellBuffer = nil;
    
}

- (void)parser:(CMParser *)parser didStartImageWithURL:(NSURL *)URL title:(NSString *)title
{
    _currentImageAttachment = nil;
    if (self.attributes.imageBuilder) {
        NSTextAttachment * textAttachment = [self.attributes.imageBuilder buildWithURL:URL
                                                                                 title:title
                                                                                styles:self.attributes];
        if([textAttachment isKindOfClass:[CMImageTextAttachment class]])
        {
            _currentImageAttachment = (CMImageTextAttachment*)textAttachment;
        }
        
        NSAttributedString *attr = nil;
        if ([textAttachment conformsToProtocol:@protocol(AMViewAttachment)] &&
            [textAttachment respondsToSelector:@selector(attributedString)]) {
            attr = [(id<AMViewAttachment>)textAttachment attributedString];
        } else {
            // Detect if an image has its own paragraph, in which cas we can apply specific attributes.
            // (Note: This test also detect the case: image in link in paragraph)
            CMNode* imageNode = parser.currentNode;
            BOOL isInImageParagraph = ((imageNode.next == nil) && (imageNode.previous == nil)
                                       && ((imageNode.parent.type == CMNodeTypeParagraph)
                                           || ((imageNode.parent.next == nil) && (imageNode.parent.previous == nil) && (imageNode.parent.parent.type == CMNodeTypeParagraph))));
            
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
            [self.attributeStack pushAttributes:imageAttachmentAttributes];
            
            const unichar attachmentChar = NSAttachmentCharacter;
            [self appendString:[NSString stringWithCharacters:&attachmentChar length:1]];
            
            if (isInImageParagraph) {
                [self closeBlockForNode:imageNode];
            }
            
            [self.attributeStack pop];
        }
        if (attr) {
            [self appendAttributedString:attr];
        }
        
    } else {
        [super parser:parser didStartImageWithURL:URL title:title];
    }
}

- (void)parser:(CMParser *)parser didEndImageWithURL:(NSURL *)URL title:(NSString *)title
{
    _currentImageAttachment = nil;
    if (self.attributes.imageBuilder) {
        // nothing
    } else {
        [super parser:parser didEndImageWithURL:URL title:title];
    }
    [self addClickableObjects:CMNodeTypeImage data:URL.absoluteString tag:@""];
}

- (void)parser:(CMParser *)parser didStartFootNoteRefIndex:(NSInteger)index title:(NSString *)title defination:(NSString *)content
{
    if (self.attributes.footnoteRefBuilder) {
        NSAttributedString *attr = [self.attributes.footnoteRefBuilder buildWithReference:content
                                                                                    title:title
                                                                                    index:index
                                                                                   styles:self.attributes];
        CMHTMLElement *element = [_HTMLStack peek];
        if (element) {
            [element.buffer appendString:[NSString stringWithFormat:@"[^%@]", content]];
        }else {
            if (attr) {
                [self appendAttributedString:attr];
            }
        }
        
    } else {
        CMStyleAttributes *attributes = [self.attributes.footNoteRefAttributes copy];
        attributes.stringAttributes[NSLinkAttributeName] = [NSString stringWithFormat:@"#%@", content];
        [self.attributeStack pushAttributes:attributes];
        [self appendString:title];
    }
}

- (void)parser:(CMParser *)parser didEndFootNoteRefIndex:(NSInteger)index title:(NSString *)title defination:(NSString *)content
{
    if (self.attributes.footnoteRefBuilder) {
        
    } else {
        [self.attributeStack pop];
    }
}

- (void)parser:(CMParser *)parser didStartFootNoteDefination:(NSString *)content refCount:(NSInteger)index
{
    [self.attributeStack pushAttributes:self.attributes.footNoteAttributes];
    [self appendString:[NSString stringWithFormat:@"%@: ", content]];
}

- (void)parser:(CMParser *)parser didEndFootNoteDefination:(NSString *)content refCount:(NSInteger)index
{
    [self.attributeStack pop];
}

- (void)parser:(CMParser *)parser didStartOrderedListWithStartingNumber:(NSInteger)num tight:(BOOL)tight
{
    _parsingNodeType = 1;
    _listLevel ++;
    _orderListLevel++;
    if (!_indentStack) {
        _indentStack = [[CMStack alloc] init];
    }
    AMStyleProvider provider = self.attributes.ordererListAttributesProvider;
    if (provider) {
        CMStyleAttributes *attributes = provider(_listLevel);
        if (_listLevel == 1) {
            _listItemExtraIndent = [self.attributeStack.peek.attributes.paragraphStyleAttributes[CMParagraphStyleAttributeHeadExtraIndent] floatValue];
        }
        [self calListIndent:attributes parseTyle:_parsingNodeType];
        attributes.stringAttributes[NSForegroundColorAttributeName] = self.attributes.paragraphAttributes.stringAttributes[NSForegroundColorAttributeName];
        [self.attributeStack pushOrderedListAttributes:attributes withStartingNumber:num];
    } else {
        [super parser:parser didStartOrderedListWithStartingNumber:num tight:tight];
    }
}

- (void)parser:(CMParser *)parser didEndOrderedListWithStartingNumber:(NSInteger)num tight:(BOOL)tight
{
    _listLevel --;
    _orderListLevel--;
    if (_indentStack) {
        [_indentStack pop];
        if (!_indentStack.objects.count) {
            _indentStack = nil;
        }
    }
    if (_listLevel == 0) {
        _listItemExtraIndent = 0;
    }
    [super parser:parser didEndOrderedListWithStartingNumber:num tight:tight];
}

- (void)parser:(CMParser *)parser didStartUnorderedListWithTightness:(BOOL)tight
{
    _parsingNodeType = 2;
    _listLevel ++;
    _unorderListLevel++;
    if (!_indentStack) {
        _indentStack = [[CMStack alloc] init];
    }
    AMStyleProvider provider = self.attributes.unordererListAttributesProvider;
    if (provider) {
        CMStyleAttributes *attributes = provider(_listLevel);
#if !TARGET_OS_IPHONE
        CMNode *imageDescriptionNode = imageNode.firstChild;
        if ((imageDescriptionNode.type == CMNodeTypeText) && (imageDescriptionNode.stringValue.length > 0)) {
            imageAttachmentAttributes.stringAttributes [NSToolTipAttributeName] = imageDescriptionNode.stringValue;
        }
#endif
        if (_listLevel == 1) {
            _listItemExtraIndent = [self.attributeStack.peek.attributes.paragraphStyleAttributes[CMParagraphStyleAttributeHeadExtraIndent] floatValue];
        }
        
        [self calListIndent:attributes parseTyle:_parsingNodeType];
        attributes.stringAttributes[NSForegroundColorAttributeName] = self.attributes.paragraphAttributes.stringAttributes[NSForegroundColorAttributeName];
        [self.attributeStack pushAttributes:attributes];
    } else {
        [super parser:parser didStartUnorderedListWithTightness:tight];
    }
}

- (void)parser:(CMParser *)parser didEndUnorderedListWithTightness:(BOOL)tight
{
    _listLevel --;
    _unorderListLevel--;
    if (_indentStack) {
        [_indentStack pop];
        if (!_indentStack.objects.count) {
            _indentStack = nil;
        }
    }
    if (_listLevel == 0) {
        _listItemExtraIndent = 0;
    }
    [super parser:parser didEndUnorderedListWithTightness:tight];
}
- (void)parserDidStartListItem:(CMParser *)parser
{
    
    AMStyleProvider provider = nil;
    CMNode *node = parser.currentNode.parent;
    long number = 0;
    if (node.listType == CMListTypeUnordered) {
        provider = self.attributes.unordererListAttributesProvider;
    } else if (node.listType == CMListTypeOrdered) {
        provider = self.attributes.ordererListAttributesProvider;
    }
    NSInteger level = _listLevel;
    NSString* path = CMParagraphStyleAttributeListItemLabelIcon;
    NSString* tmpKey = nil;
    if (provider) {
        CMStyleAttributes *attributes = provider(level);
        tmpKey = CMCustomListBullet;
        // prefix image type
        if (attributes.stringAttributes[path]) {
            UIFont* font = nil;
            if ([self.attributeStack.cascadedAttributes[NSFontAttributeName] isKindOfClass:[UIFont class]]) {
                font = ((UIFont *)self.attributeStack.cascadedAttributes[NSFontAttributeName]);
            }
            if (!font) {
                font = self.attributes.paragraphAttributes.stringAttributes[NSFontAttributeName];
            }
            if (!font) {
                font = self.attributes.baseTextAttributes.stringAttributes[NSFontAttributeName];
            }
            AMIconAttachment* attachment = nil;
            if (node.listType == CMListTypeUnordered) {
                int size = [attributes.stringAttributes[CMParagraphStyleAttributeListItemLabelIconSize] floatValue];
                attachment = [[AMIconAttachment alloc] init];
                attachment.path = attributes.stringAttributes[path];
                attachment.baseFont = font;
                attachment.attachmentSize = CGSizeMake(size, size);
            } else {
                BOOL subTitleStyle = NO;
                if ([attributes.stringAttributes[path] isEqualToString:@""]) {
                    subTitleStyle = YES;
                }
                number = (long)[super getOrderListNumber];
                int iconSize = [attributes.stringAttributes[CMParagraphStyleAttributeListItemLabelIconSize] floatValue];
                if (number > 9 && subTitleStyle) {
                    iconSize = 24;
                }
                
                attachment = [[AMIconAttachment alloc] init];
                attachment.path = attributes.stringAttributes[path];
                attachment.baseFont = font;
                attachment.attachmentSize = CGSizeMake(iconSize, iconSize);
                attachment.text = !subTitleStyle ? [NSString stringWithFormat:@"%ld", number] : [NSString stringWithFormat:@"%ld.", number];
                attachment.textColor = !subTitleStyle ? attributes.stringAttributes[@"iconTitleColor"] : self.attributes.paragraphAttributes.stringAttributes[NSForegroundColorAttributeName];
                attachment.textSize = !subTitleStyle ? 10 : font.pointSize;
                attachment.textAlignment = !subTitleStyle ? NSTextAlignmentCenter : NSTextAlignmentLeft;
                attachment.boldText = !subTitleStyle;
  
                if (number > 9 && subTitleStyle) {
                    [self calOrderListTwoDigitIndent:attributes number:number size:iconSize subTitle:subTitleStyle];
                }
            }
            if (!self.buffer || self.buffer.string.length == 0) {
                const unichar attachmentChar = NSAttachmentCharacter;
                NSAttributedString* holderStr = [[NSAttributedString alloc] initWithString:[NSString stringWithCharacters:&attachmentChar length:1] attributes:nil];
                [self appendAttributedString:holderStr];
            }
            
            [self appendString:[NSString stringWithFormat:@"\t"]];
            [self appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
            if (tmpKey) {
                [self.attributes.paragraphAttributes.stringAttributes addEntriesFromDictionary:@{tmpKey:attributes.stringAttributes[path]}];
            }
        } else if (attributes.stringAttributes[CMListSingleDigitSize]) {
            // prefix character type
            number = (long)[super getOrderListNumber];
            CGFloat digitSize = 0;
            if (number > 9 && node.listType == CMListTypeOrdered) {
                if (number > 9 && number < 100) {
                    // 三位数indent处理
                    digitSize = [attributes.stringAttributes[CMListTwoDigitSize] floatValue];
                } else if (number > 100) {
                    digitSize = [attributes.stringAttributes[CMListThreeDigitSize] floatValue];
                }
                NSMutableParagraphStyle* paraStyle = attributes.stringAttributes[NSParagraphStyleAttributeName];
                NSMutableArray *mutableTabs = [paraStyle.tabStops mutableCopy];

                if (mutableTabs.count > 0) {
                
                    NSTextTab *tab1 = (NSTextTab*)[mutableTabs objectAtIndex:0];
                    CGFloat digitIndent = tab1.location + _listItemExtraIndent;
                    CGFloat internal = [attributes.stringAttributes[CMListInternalSpace] floatValue];
                    
                    CGFloat textIndent = digitIndent + digitSize + internal + _listItemExtraIndent;
                    NSTextTab *newTab1 = [[NSTextTab alloc]            initWithTextAlignment:NSTextAlignmentLeft
                                                                         location:digitIndent
                                                                                     options:@{}];
                    NSTextTab *tab2 = [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft
                                                                      location:textIndent
                                                                       options:@{}];
                    [mutableTabs replaceObjectAtIndex:0 withObject:newTab1];
                    [mutableTabs replaceObjectAtIndex:1 withObject:tab2];
                    [paraStyle setValue:[mutableTabs copy] forKey:@"tabStops"];
                    [paraStyle setValue:@(textIndent) forKey:@"headIndent"];
                }
                [_attributeStack pop];
                [self.attributeStack pushOrderedListAttributes:attributes withStartingNumber:number];
            }
            
        }
    }
    [super parserDidStartListItem:parser];
    if (tmpKey) {
        [self.attributes.paragraphAttributes.stringAttributes removeObjectForKey:tmpKey];
    }
    
}
- (void)parser:(CMParser *)parser didStartLinkWithURL:(NSURL *)URL title:(NSString *)title
{
    if (self.attributes.linkAttributes.stringAttributes[CMLinkIconPrefix]) {
        UIFont* font = nil;
        if ([self.attributeStack.cascadedAttributes[NSFontAttributeName] isKindOfClass:[UIFont class]]) {
            font = ((UIFont *)self.attributeStack.cascadedAttributes[NSFontAttributeName]);
        }
        if (!font) {
            font = self.attributes.paragraphAttributes.stringAttributes[NSFontAttributeName];
        }
        if (!font) {
            font = self.attributes.baseTextAttributes.stringAttributes[NSFontAttributeName];
        }
        AMIconAttachment* attachment = [[AMIconAttachment alloc] init];
        attachment.path = self.attributes.linkAttributes.stringAttributes[CMLinkIconPrefix];
        attachment.baseFont = font;
        attachment.attachmentSize = CGSizeZero;
        attachment.marginRight = [self.attributes.linkAttributes.stringAttributes[CMLinkIconSpace] floatValue];
        attachment.marginLeft = 0;
        [self appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    }
    [super parser:parser didStartLinkWithURL:URL title:title];
}
- (void)parser:(CMParser *)parser didEndLinkWithURL:(NSURL *)URL title:(NSString *)title
{
    if (self.attributes.linkAttributes.stringAttributes[CMLinkIconSuffix]) {
        UIFont* font = nil;
        if ([self.attributeStack.cascadedAttributes[NSFontAttributeName] isKindOfClass:[UIFont class]]) {
            font = ((UIFont *)self.attributeStack.cascadedAttributes[NSFontAttributeName]);
        }
        if (!font) {
            font = self.attributes.paragraphAttributes.stringAttributes[NSFontAttributeName];
        }
        if (!font) {
            font = self.attributes.baseTextAttributes.stringAttributes[NSFontAttributeName];
        }
        AMIconAttachment* attachment = [[AMIconAttachment alloc] init];
        attachment.path = self.attributes.linkAttributes.stringAttributes[CMLinkIconSuffix];
        attachment.baseFont = font;
        attachment.attachmentSize = CGSizeZero;
        attachment.marginLeft = [self.attributes.linkAttributes.stringAttributes[CMLinkIconSpace] floatValue];
        attachment.marginRight = 0;
        [self appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    }
    [super parser:parser didEndLinkWithURL:URL title:title];
}
-(void)calOrderListTwoDigitIndent:(CMStyleAttributes*)attributes number:(long)number size:(NSInteger)size subTitle:(BOOL)subTitle{
    if (self.attributes.orderedListAttributes.stringAttributes[CMOrderListFirstLevelIndent]) {
        NSInteger iconSize = size;
        NSInteger extraIndent;
        if (subTitle) {
            extraIndent = [[_indentStack.objects objectAtIndex:(_indentStack.objects.count - 2)] floatValue];
        } else {
            [self.attributes.orderedListAttributes.stringAttributes[CMOrderListFirstLevelIndent] intValue];
        }
        NSTextAlignment alignment = NSTextAlignmentLeft;
        NSInteger textExtraIndent = iconSize + [attributes.stringAttributes[CMListInternalSpace] intValue];
        NSMutableParagraphStyle* paraStyle = attributes.stringAttributes[NSParagraphStyleAttributeName];
        NSMutableArray *mutableTabs = [paraStyle.tabStops mutableCopy];

        if (mutableTabs.count > 0) {
            NSTextTab *newTab1;
            newTab1 = [[NSTextTab alloc]            initWithTextAlignment:alignment
                                                                 location:extraIndent
                                                                             options:@{}];
            NSTextTab *newTab2 = [[NSTextTab alloc]            initWithTextAlignment:NSTextAlignmentLeft
                                                                            location:extraIndent + textExtraIndent
                                                                             options:@{}];
            [mutableTabs replaceObjectAtIndex:0 withObject:newTab1];
            [mutableTabs replaceObjectAtIndex:1 withObject:newTab2];
            [paraStyle setValue:[mutableTabs copy] forKey:@"tabStops"];
            [paraStyle setValue:@(extraIndent + textExtraIndent) forKey:@"headIndent"];
        }
        [_attributeStack pop];
        [self.attributeStack pushOrderedListAttributes:attributes withStartingNumber:number];
    }
}
-(void)calListIndent:(CMStyleAttributes*)attributes parseTyle:(NSInteger)parseType{
    if (attributes.stringAttributes[CMParagraphStyleAttributeListItemLabelIconSize]) {
        int iconSize = [attributes.stringAttributes[CMParagraphStyleAttributeListItemLabelIconSize] floatValue];
        CGFloat extraIndent = _indentStack.objects.count ? [_indentStack.peek floatValue] : 0;
        if (attributes.stringAttributes[CMListLevelIndent]) {
            extraIndent = [attributes.stringAttributes[CMListLevelIndent] floatValue];
        }
        extraIndent += _listLevel == 1 ? (1 + _listItemExtraIndent) : 0.5;
        CGFloat iconIndent = extraIndent;
        CGFloat textIndent = extraIndent + iconSize + [attributes.stringAttributes[CMListInternalSpace] intValue];
        NSMutableParagraphStyle* paraStyle = attributes.stringAttributes[NSParagraphStyleAttributeName];
        NSMutableArray *mutableTabs = [paraStyle.tabStops mutableCopy];

        if (mutableTabs.count > 0) {
            NSTextTab *newTab1;
            newTab1 = [[NSTextTab alloc]            initWithTextAlignment:NSTextAlignmentLeft
                                                                 location:iconIndent
                                                                             options:@{}];
            NSTextTab *newTab2 = [[NSTextTab alloc]            initWithTextAlignment:NSTextAlignmentLeft
                                                                 location:textIndent
                                                                             options:@{}];
            [mutableTabs replaceObjectAtIndex:0 withObject:newTab1];
            [mutableTabs replaceObjectAtIndex:1 withObject:newTab2];
        }
        [paraStyle setValue:[mutableTabs copy] forKey:@"tabStops"];
        [paraStyle setValue:@(textIndent) forKey:@"headIndent"];
        
        [_indentStack push:@(textIndent)];
    } else if (attributes.stringAttributes[CMListSingleDigitSize]) {
        NSMutableParagraphStyle* paraStyle = attributes.stringAttributes[NSParagraphStyleAttributeName];
        NSMutableArray *mutableTabs = [paraStyle.tabStops mutableCopy];

        if (mutableTabs.count > 0) {
        
            NSTextTab *tab1 = (NSTextTab*)[mutableTabs objectAtIndex:0];
            CGFloat digitIndent = tab1.location;
            CGFloat internal = [attributes.stringAttributes[CMListInternalSpace] floatValue];
            CGFloat digitSize = [attributes.stringAttributes[CMListSingleDigitSize] floatValue];
            CGFloat iconIndent = digitIndent + _listItemExtraIndent + [attributes.stringAttributes[CMListLevelIndent] floatValue];;
            CGFloat textIndent = digitIndent + digitSize + internal + _listItemExtraIndent + [attributes.stringAttributes[CMListLevelIndent] floatValue];;
            NSTextTab *newTab1 = [[NSTextTab alloc]            initWithTextAlignment:NSTextAlignmentLeft
                                                                 location:iconIndent
                                                                             options:@{}];
            NSTextTab *tab2 = [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft
                                                              location:textIndent
                                                               options:@{}];
            [mutableTabs replaceObjectAtIndex:0 withObject:newTab1];
            [mutableTabs replaceObjectAtIndex:1 withObject:tab2];
            [paraStyle setValue:[mutableTabs copy] forKey:@"tabStops"];
            [paraStyle setValue:@(textIndent) forKey:@"headIndent"];
        }
    }
    else {
        if (_listItemExtraIndent != 0) {
            NSMutableParagraphStyle* paraStyle = attributes.stringAttributes[NSParagraphStyleAttributeName];
            NSMutableArray *mutableTabs = [paraStyle.tabStops mutableCopy];

            if (mutableTabs.count > 0) {
                CGFloat iconIndent = ((NSTextTab*)[mutableTabs objectAtIndex:0]).location + _listItemExtraIndent;
                CGFloat textIndent = ((NSTextTab*)[mutableTabs objectAtIndex:1]).location + _listItemExtraIndent;
                NSTextTab *newTab1;
                newTab1 = [[NSTextTab alloc]            initWithTextAlignment:NSTextAlignmentLeft
                                                                     location:iconIndent
                                                                                 options:@{}];
                NSTextTab *newTab2 = [[NSTextTab alloc]            initWithTextAlignment:NSTextAlignmentLeft
                                                                     location:textIndent
                                                                                 options:@{}];
                [mutableTabs replaceObjectAtIndex:0 withObject:newTab1];
                [mutableTabs replaceObjectAtIndex:1 withObject:newTab2];
                [paraStyle setValue:[mutableTabs copy] forKey:@"tabStops"];
                [paraStyle setValue:@(textIndent) forKey:@"headIndent"];
            
            }
        }
        
    }
}
@end

