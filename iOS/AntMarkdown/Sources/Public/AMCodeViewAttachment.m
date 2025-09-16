// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMCodeViewAttachment.h"
#import "AMMarkdownCodeView.h"
#import "AMCodeHighlighter.h"
#import "UITextView+AntMarkdown.h"
#import "AMTextStyles.h"
#import "AMUtils.h"
#import "CMCascadingAttributeStack.h"

@implementation AMCodeViewAttachment
{
    AMTextStyles        * _styles;
    UIView<AMCodeView>  * _codeView;
}

+ (instancetype)attachmentWithCode:(NSString *)code
                          language:(NSString *)hint
                            styles:(AMTextStyles *)styles
{
    AMCodeViewAttachment *a = [[self alloc] initWithStyles:styles];
    
    if (styles.highlightCodeOnRender) {
        AMCodeHighlighter *highlighter = [self.class highlighterForStyles:styles];
        [highlighter highlightCodeString:code language:hint];
    }
    
    a.code = code;
    a.language = hint;
    return a;
}

+ (Class)codeViewClass
{
    return [AMMarkdownCodeView class];
}

- (instancetype)initWithStyles:(AMTextStyles *)styles
{
    self = [super init];
    if (self) {
        _styles = styles;
    }
    return self;
}

- (void)dealloc
{
    
}

+ (AMCodeHighlighter *)highlighterForStyles:(AMTextStyles *)styles {
    static dispatch_once_t onceToken;
    static NSCache<NSNumber *, AMCodeHighlighter *> * cached = nil;
    dispatch_once(&onceToken, ^{
        cached = [[NSCache alloc] init];
    });
    
    AMCodeHighlighter *h = [cached objectForKey:@(styles.hash)];
    if (!h) {
        h = [[AMCodeHighlighter alloc] initWithStyles:styles];
        AMLogDebug(@"Create new highlighter with style: %@", styles);
        [cached setObject:h forKey:@(styles.hash)];
    }
    return h;
}

+ (dispatch_queue_t)highlighterQueue {
    static dispatch_once_t onceToken;
    static dispatch_queue_t _queue;
    dispatch_once(&onceToken, ^{
        _queue = dispatch_queue_create("Code Highlight Queue", DISPATCH_QUEUE_SERIAL);
    });
    return _queue;
}

- (void)highlightCode {
    @weakify(self);
    dispatch_async([self.class highlighterQueue], ^{
        @strongify(self);
        if (!self) {
            return;
        }
        AMCodeHighlighter *highlighter = [self.class highlighterForStyles:self->_styles];
        NSAttributedString *attr = [highlighter highlightCodeString:self.code language:self.language];
        if (self->_styles) {
            if (self->_styles.codeBlockAttributes.stringAttributes[NSBackgroundColorAttributeName] && attr) {
                NSMutableAttributedString* tmp = [[NSMutableAttributedString alloc] initWithAttributedString:attr];
                [tmp addAttribute:NSBackgroundColorAttributeName value:self->_styles.codeBlockAttributes.stringAttributes[NSBackgroundColorAttributeName] range:NSMakeRange(0, attr.string.length)];
                attr = tmp;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self) {
                [self->_codeView setAttributedCodeText:attr];
            }
        });
    });
}

- (void)setLanguage:(NSString *)language
{
    _language = language;
    [_codeView setLanguage:language];
}

- (void)setCode:(NSString *)code
{
    if (![_code isEqualToString:code]) {
        _code = code;
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(highlightCode) object:nil];
        
        AMCodeHighlighter *highlighter = [self.class highlighterForStyles:self->_styles];
        NSAttributedString *attr = [highlighter cachedAttributedCodeForCode:code language:self.language];
        if (attr) {
            AMLogDebug(@"hit highlighter cache on code setter", nil);
            [_codeView setAttributedCodeText:attr];
        } else {
            [_codeView setPlainCodeText:code];
            [_codeView setLanguage:self.language];
            [self performSelector:@selector(highlightCode) withObject:nil afterDelay:0.3];
        }
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    if ([NSThread isMainThread] && [self viewIfLoaded]) {
        return [self.view sizeThatFits:size];
    } else {
        Class<AMCodeView> cls = [self.class codeViewClass];
        if ([cls respondsToSelector:@selector(sizeThatFits:code:language:styles:)]) {
            return [cls sizeThatFits:size code:self.code language:self.language styles:_styles];
        } else {
            return [self.view sizeThatFits:size];
        }
    }
}

- (__kindof UIView *)view
{
    if (!_codeView) {
        Class cls = [self.class codeViewClass];
        if ([cls instancesRespondToSelector:@selector(initWithStyles:)]) {
            _codeView = [[cls alloc] initWithStyles:self->_styles];
        } else {
            _codeView = [[cls alloc] init];
        }
        NSAssert([_codeView conformsToProtocol:@protocol(AMCodeView)], @"Class %@ must confirms to AMCodeView", cls);

        [_codeView setLanguage:self.language];
        
        if ([_codeView isKindOfClass:[AMMarkdownCodeView class]]) {
            ((AMMarkdownCodeView *)_codeView).partialUpdate = self.partialUpdate;
        }
        
        AMCodeHighlighter *highlighter = [self.class highlighterForStyles:self->_styles];
        NSAttributedString *attr = [highlighter cachedAttributedCodeForCode:self.code language:self.language];
        if (attr) {
            AMLogDebug(@"hit highlighter cache on view create", nil);
            [_codeView setAttributedCodeText:attr];
        } else {
            [_codeView setPlainCodeText:self.code];
        }
    }
    return _codeView;
}

- (__kindof UIView<AMAttachedView> *)viewIfLoaded
{
    return _codeView;
}

- (BOOL)isEqualToAttachment:(AMCodeViewAttachment *)attach
{
    return [self.language isEqualToString:attach.language]
    && [self.code isEqualToString:attach.code];
}

- (void)updateAttachmentFromAttachment:(AMCodeViewAttachment *)attach
{
    [super updateAttachmentFromAttachment:attach];
    self.partialUpdate = YES;
    if ([_codeView isKindOfClass:[AMMarkdownCodeView class]]) {
        ((AMMarkdownCodeView *)_codeView).partialUpdate = self.partialUpdate;
    }
    self.language = attach.language;
    self.code = attach.code;
}

@end
