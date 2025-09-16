// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <JavaScriptCore/JavaScriptCore.h>

#import "AMCodeHighlighter.h"
#import "AMTextStyles.h"
#import "CMCascadingAttributeStack.h"
#import "AMUtils.h"

@interface AMCodeHighlighter ()
@property (nonatomic) JSVirtualMachine *vm;
@property (nonatomic) JSContext *context;
@property (nonatomic) NSString *stylesheet;
@property (nonatomic) AMTextStyles *styles;
@property (nonatomic) NSCache<NSString *, NSAttributedString *> *cachedAttributedText;
@end

@implementation AMCodeHighlighter

+ (BOOL)isSupportCodeLan:(NSString *)codeLan
{
    if([codeLan length] == 0)
        return NO;

    static NSDictionary* codeLanDic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        codeLanDic = @{
            @"bash":@(YES),
            @"c":@(YES),
            @"cpp":@(YES),
            @"swift":@(YES),
            @"csharp":@(YES),
            @"css":@(YES),
            @"go":@(YES),
            @"java":@(YES),
            @"javascript":@(YES),
            @"json":@(YES),
            @"kotlin":@(YES),
            @"latex":@(YES),
            @"markdown":@(YES),
            @"objectivec":@(YES),
            @"php":@(YES),
            @"python":@(YES),
            @"ruby":@(YES),
            @"sql":@(YES),
            @"typescript":@(YES),
            @"xml":@(YES),
        };
    });
    id obj = [codeLanDic objectForKey:codeLan.lowercaseString];
    return (obj != nil);
}

- (instancetype)initWithStyles:(AMTextStyles *)styles
{
    self = [super init];
    if (self) {
        self.styles = styles;
        
        self.cachedAttributedText = [[NSCache alloc] init];
        self.cachedAttributedText.name = @"Highlighted Code Cache";
        self.cachedAttributedText.totalCostLimit = 10 * 1024 * 1024;
        
        self.vm = [[JSVirtualMachine alloc] init];
        self.context = [[JSContext alloc] initWithVirtualMachine:self.vm];
        [self.context setExceptionHandler:^(JSContext *context, JSValue *exception) {
            NSLog(@"JS Exception: %@", exception);
        }];
        
        NSString *resourcePath = [[NSBundle bundleForClass:self.class] pathForResource:@"highlightjs" ofType:@"bundle"];
        if (!resourcePath) {
            resourcePath = [NSBundle.mainBundle pathForResource:@"highlightjs" ofType:@"bundle"];
        }
        NSBundle *resourceBundle = [NSBundle bundleWithPath:resourcePath];
        NSURL *jsPath = [resourceBundle URLForResource:@"highlight.min" withExtension:@"js"];
        NSURL *stylePath = [resourceBundle URLForResource:@"default.min" withExtension:@"css"];
        self.stylesheet = [NSString stringWithContentsOfURL:stylePath encoding:NSUTF8StringEncoding error:nil];
        NSString *code = [NSString stringWithContentsOfURL:jsPath encoding:NSUTF8StringEncoding error:nil];
        [self.context evaluateScript:code withSourceURL:jsPath];
    }
    return self;
}

- (NSAttributedString *)highlightCodeString:(NSString *)code language:(NSString *)language
{
    NSAttributedString *attr = [self cachedAttributedCodeForCode:code language:language];
    if (!attr) {
        JSValue *hljs = self.context[@"hljs"];
        JSValue *result = nil;
        
        if (language.length && [AMCodeHighlighter isSupportCodeLan:language]) {
            result = [hljs invokeMethod:@"highlight" withArguments:@[code, @{
                @"language": language
            }]];
        } else {
            result = [hljs invokeMethod:@"highlightAuto" withArguments:@[code]];
        }
        NSString * value = [result[@"value"] toString];
        
        UIFont *font = self.styles.codeBlockAttributes.stringAttributes[NSFontAttributeName];
        
        if ([font isKindOfClass:[UIFont class]] && self.styles.codeBlockAttributes.fontAttributes.count > 0) {
            font = [font fontByAddingCMAttributes:self.styles.codeBlockAttributes.fontAttributes];
        }
        
        NSError *error = nil;
        NSString *html = [NSString stringWithFormat:
                          @"<style>"
                          @"code{font-size: %.2fpx}"
                          @"%@"
                          @"</style>"
                          @"<pre><code class=\"hljs\">"
                          @"%@"
                          @"</code></pre>", font ? font.pointSize : 13, self.stylesheet, value];
        NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithData:[html dataUsingEncoding:NSUTF8StringEncoding]
                                                                                   options:@{
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding),
        }
                                                                        documentAttributes:nil
                                                                                     error:&error];
        if ([attri.mutableString hasSuffix:@"\n"]) {
            [attri.mutableString deleteCharactersInRange:NSMakeRange(attri.length - 1, 1)];
        }
        NSParagraphStyle *paragraph = [NSParagraphStyle paragraphStyleWithCMAttributes:self.styles.codeBlockAttributes.paragraphStyleAttributes];
        if (paragraph) {
            [attri addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, attri.length)];
        }
        attr = [attri copy];
        @synchronized (self) {
            if (attr) {
                NSString *cacheKey = [NSString stringWithFormat:@"%@:%@", language, code];
                [self.cachedAttributedText setObject:attr
                                              forKey:cacheKey
                                                cost:attr.length];
            } else {
                AMLogDebug(@"fail to highlight code: %@", code);
            }
        }
    }
    return attr;
}

- (NSAttributedString *)cachedAttributedCodeForCode:(NSString *)code language:(NSString *)language
{
    NSString *cacheKey = [NSString stringWithFormat:@"%@:%@", language, code];
    @synchronized (self) {
        return [self.cachedAttributedText objectForKey:cacheKey];
    }
}

@end
