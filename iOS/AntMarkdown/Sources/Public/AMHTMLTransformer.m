// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMHTMLTransformer.h"
#import "CMCascadingAttributeStack.h"
#import "ONOXMLDocument.h"
#import "AMUtils.h"
#import "AMDrawable.h"
#import "AMUnderline.h"
#import "AMImageTextAttachment.h"
#import "AMTextBackground.h"
#import "AMIconLinkAttachment.h"
#import "NSString+AntMarkdown.h"
#import "AMUtils.h"
#import "AMIconAttachment.h"
const int kHTMLDefaultFontSize = 20;
@implementation AMHTMLTransformer

- (NSAttributedString *)attributedStringForElement:(ONOXMLElement *)element attributes:(NSDictionary *)attributes {
    
    NSMutableDictionary *allAttributes = [attributes mutableCopy];
    
    NSString *className = element.attributes[@"class"];
    if (className.length) {
        CMStyleAttributes *styles = [self.styles attributesForClass:className];
        
        if (styles.stringAttributes.count > 0) {
            [allAttributes addEntriesFromDictionary:styles.stringAttributes];
        }
        
        if (styles.fontAttributes.count > 0) {
            UIFont *baseFont = allAttributes[NSFontAttributeName];
            UIFont *adjustedFont = nil;
            if (baseFont != nil) {
                adjustedFont = [baseFont fontByAddingCMAttributes:styles.fontAttributes];
            }
            else {
                UIFontDescriptor * adjustedFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:styles.fontAttributes];
                if (adjustedFontDescriptor != nil) {
                    adjustedFont = [CMFont fontWithDescriptor:adjustedFontDescriptor size:adjustedFontDescriptor.pointSize];
                }
            }
            if (adjustedFont != nil) {
                allAttributes[NSFontAttributeName] = adjustedFont;
            }
        }
        
        // Set paragraph style attributes
        if (styles.paragraphStyleAttributes.count > 0) {
            NSParagraphStyle* baseParagraphStyle = allAttributes[NSParagraphStyleAttributeName];
            NSParagraphStyle* adjustedParagraphStyle = nil;
            if (baseParagraphStyle != nil) {
                adjustedParagraphStyle = [baseParagraphStyle paragraphStyleByAddingCMAttributes:styles.paragraphStyleAttributes];
            }
            else {
                adjustedParagraphStyle = [NSParagraphStyle paragraphStyleWithCMAttributes:styles.paragraphStyleAttributes];
            }
            if (adjustedParagraphStyle != nil) {
                allAttributes[NSParagraphStyleAttributeName] = adjustedParagraphStyle;
            }
        }
    }
    
    NSString *styleString = element.attributes[@"style"];
    
    if (styleString.length) {
        static dispatch_once_t onceToken;
        static NSDictionary <NSString *, void (^)(NSMutableDictionary *dictionary, NSString *value) > *attributeUpdater = nil;
        dispatch_once(&onceToken, ^{
            attributeUpdater = @{
                @"color": ^(NSMutableDictionary *dictionary, NSString *value) {
                    UIColor *color = [UIColor colorWithCSSString_ant_mark:value];
                    if (color) {
                        dictionary[NSForegroundColorAttributeName] = color;
                    }
                },
                @"background-color": ^(NSMutableDictionary *dictionary, NSString *value) {
                    UIColor *color = [UIColor colorWithCSSString_ant_mark:value];
                    if (color) {
                        dictionary[NSBackgroundColorAttributeName] = color;
                    }
                },
            };
        });
        
        NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
        [[styleString componentsSeparatedByString:@";"] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray <NSString *> *kvPair = [[obj stringByTrimmingCharactersInSet:set] componentsSeparatedByString:@":"];
            if (kvPair.count == 2) {
                NSString *key = [kvPair[0] stringByTrimmingCharactersInSet:set];
                NSString *value = [kvPair[1] stringByTrimmingCharactersInSet:set];
                if (value.length) {
                    (attributeUpdater[key.localizedLowercaseString] ?: ^(NSMutableDictionary *dictionary, NSString *value) {})(allAttributes, value);
                }
            }
        }];
    }
    
    return [[NSAttributedString alloc] initWithString:element.stringValue attributes:allAttributes];
}

+ (NSString *)tagName {
    return @"div";
}


- (nonnull instancetype)initWithStyles:(nonnull AMTextStyles *)styles {
    self = [super init];
    if (self) {
        _styles = styles;
    }
    return self;
}

@end

@implementation AMHTMLMarkTransformer

+ (NSString *)tagName {
    return @"mark";
}

- (NSAttributedString *)attributedStringForElement:(ONOXMLElement *)element attributes:(NSDictionary *)attributes {
    NSMutableAttributedString *attri = [[super attributedStringForElement:element attributes:attributes] mutableCopy];
    NSDictionary<NSAttributedStringKey, id> *attr = attri.length > 0 ? [attri attributesAtIndex:0 effectiveRange:NULL] : @{};
    if (!element.attributes[@"class"] && !element.attributes[@"style"] && !attributes[NSBackgroundColorAttributeName] && !attr[NSBackgroundColorAttributeName]) {
        [attri addAttributes:@{
            NSBackgroundColorAttributeName: UIColor.yellowColor
        } range:NSMakeRange(0, attri.length)];
    }
    return attri.copy;
}

@end

@implementation AMHTMLSpanTransformer

- (NSAttributedString *)attributedStringForElement:(ONOXMLElement *)element attributes:(NSDictionary *)attributes {
    
    NSMutableDictionary *allAttributes = [attributes mutableCopy];
    
    NSString *className = element.attributes[@"class"];
    if (className.length) {
        CMStyleAttributes *styles = [self.styles attributesForClass:className];
        
        if (styles.stringAttributes.count > 0) {
            [allAttributes addEntriesFromDictionary:styles.stringAttributes];
        }
        
        if (styles.fontAttributes.count > 0) {
            UIFont *baseFont = allAttributes[NSFontAttributeName];
            UIFont *adjustedFont = nil;
            if (baseFont != nil) {
                adjustedFont = [baseFont fontByAddingCMAttributes:styles.fontAttributes];
            }
            else {
                UIFontDescriptor * adjustedFontDescriptor = [UIFontDescriptor fontDescriptorWithFontAttributes:styles.fontAttributes];
                if (adjustedFontDescriptor != nil) {
                    adjustedFont = [CMFont fontWithDescriptor:adjustedFontDescriptor size:adjustedFontDescriptor.pointSize];
                }
            }
            if (adjustedFont != nil) {
                allAttributes[NSFontAttributeName] = adjustedFont;
            }
        }
        
        // Set paragraph style attributes
        if (styles.paragraphStyleAttributes.count > 0) {
            NSParagraphStyle* baseParagraphStyle = allAttributes[NSParagraphStyleAttributeName];
            NSParagraphStyle* adjustedParagraphStyle = nil;
            if (baseParagraphStyle != nil) {
                adjustedParagraphStyle = [baseParagraphStyle paragraphStyleByAddingCMAttributes:styles.paragraphStyleAttributes];
            }
            else {
                adjustedParagraphStyle = [NSParagraphStyle paragraphStyleWithCMAttributes:styles.paragraphStyleAttributes];
            }
            if (adjustedParagraphStyle != nil) {
                allAttributes[NSParagraphStyleAttributeName] = adjustedParagraphStyle;
            }
        }
    }
    
    NSString *styleString = element.attributes[@"style"];
    
    if (styleString.length) {
        static dispatch_once_t onceToken;
        static NSDictionary <NSString *, void (^)(NSMutableDictionary *dictionary, NSString *value) > *attributeUpdater = nil;
        dispatch_once(&onceToken, ^{
            attributeUpdater = @{
                @"color": ^(NSMutableDictionary *dictionary, NSString *value) {
                    UIColor *color = [UIColor colorWithCSSString_ant_mark:value];
                    if (color) {
                        dictionary[NSForegroundColorAttributeName] = color;
                    }
                },
                @"background-color": ^(NSMutableDictionary *dictionary, NSString *value) {
                    UIColor *color = [UIColor colorWithCSSString_ant_mark:value];
                    if (color) {
                        dictionary[NSBackgroundColorAttributeName] = color;
                    }
                },
            };
        });
        
        NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
        [[styleString componentsSeparatedByString:@";"] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray <NSString *> *kvPair = [[obj stringByTrimmingCharactersInSet:set] componentsSeparatedByString:@":"];
            if (kvPair.count == 2) {
                NSString *key = [kvPair[0] stringByTrimmingCharactersInSet:set];
                NSString *value = [kvPair[1] stringByTrimmingCharactersInSet:set];
                if (value.length) {
                    (attributeUpdater[key.localizedLowercaseString] ?: ^(NSMutableDictionary *dictionary, NSString *value) {})(allAttributes, value);
                }
            }
        }];
    }
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithAttributedString:[element.stringValue markdownToAttributedStringWithStyles_ant_mark:self.styles]];
    [attrString addAttributes:allAttributes range:NSMakeRange(0, attrString.string.length)];
    return attrString;
}



+ (NSString *)tagName {
    return @"span";
}

@end

@implementation AMHTMLCiteTransformer

- (NSAttributedString *)attributedStringForElement:(ONOXMLElement *)element attributes:(NSDictionary *)attributes
{
    NSMutableAttributedString *attri = [[super attributedStringForElement:element attributes:attributes] mutableCopy];
    
    [attri addAttributes:@{
        NSObliquenessAttributeName: @(0.3),
    } range:NSMakeRange(0, attri.length)];
    
    
    return [attri copy];
}

+ (NSString *)tagName {
    return @"cite";
}

@end

@implementation AMHTMLDelTransformer

- (NSAttributedString *)attributedStringForElement:(ONOXMLElement *)element attributes:(NSDictionary *)attributes
{
    NSMutableAttributedString *attri = [[super attributedStringForElement:element attributes:attributes] mutableCopy];
    
    [attri addAttributes:@{
        NSStrikethroughStyleAttributeName: @(NSUnderlineStyleSingle)
    } range:NSMakeRange(0, attri.length)];
    
    
    return [attri copy];
}

+ (NSString *)tagName {
    return @"del";
}

@end


@implementation AMHTMLFontTransformer

+ (NSString *)tagName {
    return @"font";
}

- (NSAttributedString *)attributedStringForElement:(ONOXMLElement *)element attributes:(NSDictionary *)attributes {
    
    NSMutableDictionary *allAttributes = [attributes mutableCopy];
    
    NSString *colorString = element.attributes[@"color"];
    NSString *sizeString = element.attributes[@"size"];
    UIColor *color = [UIColor colorWithCSSString_ant_mark:colorString];
    
    if (color) {
        allAttributes[NSForegroundColorAttributeName] = color;
    }
    
    if (sizeString.length > 0) {
        unichar ch = [sizeString characterAtIndex:0];
        CGFloat value = [sizeString doubleValue];
        UIFont *baseFont = allAttributes[NSFontAttributeName];
        if (ch == '-' || ch == '+') {
            if (baseFont) {
                CGFloat pointSize = baseFont.pointSize;
                pointSize += value;
                allAttributes[NSFontAttributeName] = [baseFont fontWithSize:pointSize];
            }
        } else {
            allAttributes[NSFontAttributeName] = baseFont ? [baseFont fontWithSize:value] : [UIFont systemFontOfSize:value];
        }
    }
    
    return [[NSAttributedString alloc] initWithString:element.stringValue attributes:allAttributes];
}

@end

@implementation AMHTMLUnderlineTransformer
{
    AMUnderline     * _underline;
}

- (instancetype)initWithStyle:(NSUnderlineStyle)style
                        color:(UIColor *)color
                    lineWidth:(CGFloat)width
                       offset:(CGFloat)offset
{
    self = [super initWithUnderlineStyle:NSUnderlineStyleSingle color:[UIColor clearColor]];
    if (self) {
        _underline = [[AMUnderline alloc] initWithColor:color lineWidth:width offset:offset];
    }
    return self;
}

- (NSAttributedString *)attributedStringForElement:(ONOXMLElement *)element attributes:(NSDictionary *)attributes
{
    NSMutableAttributedString *attri = [[super attributedStringForElement:element attributes:attributes] mutableCopy];
    
    if (_underline) {
        [attri addAttributes:@{
            AMUnderlineDrawableAttributeName: _underline,
        } range:NSMakeRange(0, attri.length)];
    }
    
    return [attri copy];
}

@end


@implementation AMHTMLDefaultTransformer

+ (NSString *)tagName {
    return @"p";
}
- (NSAttributedString *)attributedStringForElement:(ONOXMLElement *)element attributes:(NSDictionary *)attributes
{
    return nil;
}
@end


@implementation AMHTMLTextLabelTransformer

+ (NSString *)tagName {
    return @"p";
}

- (NSAttributedString *)attributedStringForElement:(ONOXMLElement *)element attributes:(NSDictionary *)attributes
{
    NSString *html = @"";
    return [[NSAttributedString alloc] initWithData:[html dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];

}

@end
@implementation AMHTMLImgTransformer

+ (NSString *)tagName {
    return @"img";
}
- (NSAttributedString *)attributedStringForElement:(ONOXMLElement *)element attributes:(NSDictionary *)attributes {
    NSLog(@"");
    NSString* ttt = element.attributes[@"src"];
    NSString* strWidth = element.attributes[@"width"];
    NSString* strHeight = element.attributes[@"height"];
    CGSize imgSize = CGSizeMake(strWidth ? [strWidth floatValue] : 0, strHeight ? [strHeight floatValue] : 0);
    
    NSTextAttachment* textAttachment = [[AMImageTextAttachment alloc] initWithImageURL:[NSURL URLWithString:ttt] title:@"" size:imgSize];
    NSMutableDictionary *allAttributes = [attributes mutableCopy];
    allAttributes[NSAttachmentAttributeName] = textAttachment;
    const unichar attachmentChar = NSAttachmentCharacter;
    return [[NSAttributedString alloc] initWithString:[NSString stringWithCharacters:&attachmentChar length:1] attributes:allAttributes];
}
@end
@interface AMHTMLIconLinkTransformer()
{
    NSString*   _linkUrl;
}
@end
@implementation AMHTMLIconLinkTransformer

+ (NSString *)tagName {
    return @"iconlink";
}
-(NSDictionary*)getParams {
    return _linkUrl ? @{@"linkUrl":_linkUrl} : nil;
}
- (NSAttributedString *)attributedStringForElement:(ONOXMLElement *)element attributes:(NSDictionary *)attributes {
    
    NSMutableDictionary *alltextAttributes = [attributes mutableCopy];
    NSMutableDictionary *allAttributes = [attributes mutableCopy];
    NSString *styleString = element.attributes[@"style"];
  
    UIColor* backgroundColor = nil;
    UIColor* textColor = nil;
    NSString* url = element.attributes[@"src"];
    _linkUrl = element.attributes[@"link"];
    UIFont *baseFont = alltextAttributes[NSFontAttributeName];
    UIFont* subFont = [UIFont systemFontOfSize:kHTMLDefaultFontSize];
    if (styleString.length) {
        NSArray<NSString *> * styles = [styleString componentsSeparatedByString:@";"];
        if ([styles count] > 0) {
            NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
            for (NSString* subStyle in styles) {
                NSArray <NSString *> *kvPair = [[subStyle stringByTrimmingCharactersInSet:set] componentsSeparatedByString:@":"];
                if (kvPair.count == 2) {
                    NSString *key = [kvPair[0] stringByTrimmingCharactersInSet:set];
                    NSString *value = [kvPair[1] stringByTrimmingCharactersInSet:set];
                    if ([key isEqualToString:@"background-color"] && value.length) {
                        backgroundColor = [UIColor colorWithCSSString_ant_mark_alpha:value];
                    } else if ([key isEqualToString:@"color"] && value.length) {
                        textColor = [UIColor colorWithCSSString_ant_mark:value];
                        alltextAttributes[NSForegroundColorAttributeName] = textColor;
                    } else if ([key isEqualToString:@"font-size"] && value.length) {
                        int fontSize = [value intValue];
                        if (baseFont) {
                            subFont = [baseFont fontWithSize:AUFVS(fontSize)];
                        } else {
                            subFont = [UIFont systemFontOfSize:AUFVS(fontSize)];
                        }
                        alltextAttributes[NSFontAttributeName] = subFont;
                        allAttributes[NSFontAttributeName] = subFont;
                        
                    }
                   
                }
            }
            
        }
    }
    
    
    
    NSAttributedString* pureText = [[NSAttributedString alloc] initWithString:element.stringValue attributes:alltextAttributes];
    NSTextAttachment* textAttachment = [[AMIconLinkAttachment alloc] initWithText:pureText url:url bgColor:backgroundColor textColor:textColor subFont:subFont baseFont:baseFont];
    
    allAttributes[NSAttachmentAttributeName] = textAttachment;
    allAttributes[NSLinkAttributeName] = _linkUrl;
    const unichar attachmentChar = NSAttachmentCharacter;
    return [[NSAttributedString alloc] initWithString:[NSString stringWithCharacters:&attachmentChar length:1] attributes:allAttributes];
}
-(NSString*)getLinkUrl {
    return _linkUrl;
}
@end
@implementation AMHTMLIconTransformer

+ (NSString *)tagName {
    return @"icon";
}
- (NSAttributedString *)attributedStringForElement:(ONOXMLElement *)element attributes:(NSDictionary *)attributes {
 
    NSMutableDictionary *alltextAttributes = [attributes mutableCopy];
    NSMutableDictionary *allAttributes = [attributes mutableCopy];
  
    NSString* url = element.attributes[@"src"];
   
    UIFont *baseFont = alltextAttributes[NSFontAttributeName];
    if (url.length) {
        AMIconAttachment* textAttachment = [[AMIconAttachment alloc] init];
        textAttachment = [[AMIconAttachment alloc] init];
        textAttachment.path = url;
        textAttachment.baseFont = baseFont;
        textAttachment.attachmentSize = CGSizeMake(baseFont.pointSize, baseFont.pointSize);
        
        allAttributes[NSAttachmentAttributeName] = textAttachment;
    }

    const unichar attachmentChar = NSAttachmentCharacter;
    return [[NSAttributedString alloc] initWithString:[NSString stringWithCharacters:&attachmentChar length:1] attributes:allAttributes];
}
@end
