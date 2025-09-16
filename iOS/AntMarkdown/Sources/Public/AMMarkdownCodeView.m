// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMMarkdownCodeView.h"
#import "UITextView+AntMarkdown.h"
#import "AMUtils.h"
#import "AMTextStyles.h"
#import "CMCascadingAttributeStack.h"

const CGFloat AMCodeHeaderHeight = 40.0;
const UIEdgeInsets AMCodeViewInset = {.top = 4, .left = 12, .bottom = 10, .right = 12};

@interface AMMarkdownCodeView ()
@property (nonatomic) AMTextStyles *styles;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;

@end

@implementation AMMarkdownCodeView
@synthesize attachment = _attachment;

- (instancetype)initWithStyles:(AMTextStyles *)styles
{
    self = [super initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, AMCodeHeaderHeight)];
    if (self) {
        self.styles = styles;
        
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 60)];
        self.textView.contentInset = UIEdgeInsetsZero;
        self.textView.textContainer.lineFragmentPadding = 0;
        self.textView.textContainerInset = AMCodeViewInset;
        self.textView.editable = NO;
        self.textView.selectable = NO;
        self.textView.scrollEnabled = YES;
        self.textView.bounces = NO;
        self.textView.scrollsToTop = NO;
        
        UIFont *font = self.styles.codeBlockAttributes.stringAttributes[NSFontAttributeName] ?: [UIFont fontWithName:@"Courier" size:13];
        self.textView.font = font;
        self.textView.textColor = self.styles.baseTextAttributes.stringAttributes[NSForegroundColorAttributeName] ?: [UIColor blackColor];
        if (self.styles.codeBlockAttributes.stringAttributes[NSForegroundColorAttributeName]) {
            self.textView.textColor = self.styles.codeBlockAttributes.stringAttributes[NSForegroundColorAttributeName];
        }
        [self.textView addObserver:self
                        forKeyPath:KEYPATH(self.textView, contentSize)
                           options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                           context:nil];
        if (self.styles.codeBlockAttributes.stringAttributes[@"backgroundColor"]) {
            self.textView.backgroundColor = self.styles.codeBlockAttributes.stringAttributes[@"backgroundColor"];
        }
       
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 12;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = [self.styles.codeBlockAttributes.stringAttributes[@"borderWidth"] floatValue] ? : 0;
        self.layer.borderColor = self.styles.codeBlockAttributes.stringAttributes[@"borderColor"] ? ((UIColor*)self.styles.codeBlockAttributes.stringAttributes[@"borderColor"]).CGColor : [UIColor clearColor].CGColor;
        
        UIView *head = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, AMCodeHeaderHeight)];
        head.backgroundColor = self.styles.codeBlockAttributes.stringAttributes[@"headerBackgroundColor"] ? : [UIColor colorWithHex_ant_mark:0xa1f3b63];
        head.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:head];
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, AMCodeHeaderHeight - 1, self.bounds.size.width, 1)];
        separator.backgroundColor = [UIColor colorWithHex_ant_mark:0x291f3b63];
        separator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        separator.translatesAutoresizingMaskIntoConstraints = YES;
        [head addSubview:separator];
        
        self.languageLabel = [UILabel new];
        self.languageLabel.font = self.styles.codeBlockAttributes.stringAttributes[@"titleFont"] ? : [UIFont boldSystemFontOfSize:13];
        self.languageLabel.textColor =  self.styles.baseTextAttributes.stringAttributes[NSForegroundColorAttributeName] ?: self.styles.paragraphAttributes.stringAttributes[NSForegroundColorAttributeName];
        if (self.styles.codeBlockAttributes.stringAttributes[@"titleFontColor"]) {
            self.languageLabel.textColor = self.styles.codeBlockAttributes.stringAttributes[@"titleFontColor"];
        }
        self.languageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [head addSubview:self.languageLabel];
        [head addConstraints:@[
            [NSLayoutConstraint constraintWithItem:head
                                         attribute:NSLayoutAttributeLeft
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.languageLabel
                                         attribute:NSLayoutAttributeLeft
                                        multiplier:1
                                          constant:-12],
            [NSLayoutConstraint constraintWithItem:head
                                         attribute:NSLayoutAttributeCenterY
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.languageLabel
                                         attribute:NSLayoutAttributeCenterY
                                        multiplier:1
                                          constant:0],
        ]];
        
        self.codeCopyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.codeCopyButton.titleLabel.font = [UIFont systemFontOfSize:12];
        if (self.styles.codeBlockAttributes.stringAttributes[@"operationIcon"]) {
            NSString* iconPath = self.styles.codeBlockAttributes.stringAttributes[@"operationIcon"];
            NSRange iOSRange = [iconPath rangeOfString:@"/"];
            if (iOSRange.location != NSNotFound) {
                 
                NSString *bundlePart = [iconPath substringToIndex:iOSRange.location];
                NSString *imagePart = [iconPath substringFromIndex:iOSRange.location + 1];
                [self.codeCopyButton setImage:[UIImage imageNamed_ant_bundle:bundlePart name:imagePart] forState:UIControlStateNormal];
            }
        } else {
            [self.codeCopyButton setImage:[UIImage imageNamed_ant_mark:@"code_copy_old"] forState:UIControlStateNormal];
        }
        
        [self.codeCopyButton addTarget:self
                                action:@selector(_onCopyCode:)
                      forControlEvents:UIControlEventTouchUpInside];
        self.codeCopyButton.translatesAutoresizingMaskIntoConstraints = NO;
        [head addSubview:self.codeCopyButton];
        [head addConstraints:@[
            [NSLayoutConstraint constraintWithItem:head
                                         attribute:NSLayoutAttributeRight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.codeCopyButton
                                         attribute:NSLayoutAttributeRight
                                        multiplier:1
                                          constant:10],
            [NSLayoutConstraint constraintWithItem:head
                                         attribute:NSLayoutAttributeCenterY
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.codeCopyButton
                                         attribute:NSLayoutAttributeCenterY
                                        multiplier:1
                                          constant:0],
        ]];
        
        self.textView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.textView];
        
        [self.textView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.textView
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1
                                                              constant:AMCodeHeaderHeight];
        self.heightConstraint.priority = UILayoutPriorityDefaultHigh -1;
        
        [self.textView addConstraints:@[self.heightConstraint]];
        
        [self addConstraints:@[
            [NSLayoutConstraint constraintWithItem:self
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:head
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:self
                                         attribute:NSLayoutAttributeLeft
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:head
                                         attribute:NSLayoutAttributeLeft
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:self
                                         attribute:NSLayoutAttributeRight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:head
                                         attribute:NSLayoutAttributeRight
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:head
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1
                                          constant:AMCodeHeaderHeight],
            [NSLayoutConstraint constraintWithItem:self
                                         attribute:NSLayoutAttributeLeft
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.textView
                                         attribute:NSLayoutAttributeLeft
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:self
                                         attribute:NSLayoutAttributeRight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.textView
                                         attribute:NSLayoutAttributeRight
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:self
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.textView
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:head
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.textView
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1
                                          constant:0],
        ]];
    }
    return self;
}

- (void)dealloc
{
    [self.textView removeObserver:self forKeyPath:KEYPATH(self.textView, contentSize)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    if (object == self.textView) {
        CGSize old = [change[NSKeyValueChangeOldKey] CGSizeValue];
        CGSize new = [change[NSKeyValueChangeNewKey] CGSizeValue];
        if (!CGSizeEqualToSize(old, new)) {
            if(self.partialUpdate)
            {
                @weakify(self);
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    self.heightConstraint.constant = new.height;
                    [self.textView removeConstraint:self.heightConstraint];
                    [self.textView addConstraint:self.heightConstraint];
                    [self.textView updateConstraintsIfNeeded];
                    [self.textView layoutIfNeeded];
                    [self.attachment setNeedsLayout];
                });
            }
            else
            {
                if ([self.attachment respondsToSelector:@selector(setNeedsLayout)]) {
                    self.heightConstraint.constant = new.height;
                    [self.textView removeConstraint:self.heightConstraint];
                    [self.textView addConstraint:self.heightConstraint];
                    [self.textView updateConstraintsIfNeeded];
                    [self.textView layoutIfNeeded];
                    [self.attachment setNeedsLayout];
                }
            }
        }
    }
}

- (void)_onCopyCode:(id)sender
{
    [self didCopyCode:self.textView.attributedText.string ?: self.textView.text];
}

- (void)setPlainCodeText:(NSString *)codeText
{
    self.textView.attributedText = [[NSAttributedString alloc] initWithString:codeText ?: @""
                                                                   attributes:@{
        NSFontAttributeName: self.textView.font,
        NSForegroundColorAttributeName: self.textView.textColor,
        NSParagraphStyleAttributeName: [NSParagraphStyle paragraphStyleWithCMAttributes:self.styles.codeBlockAttributes.paragraphStyleAttributes],
    }];
}

- (void)setLanguage:(nullable NSString *)lang {
    self.languageLabel.text = lang.length ? lang : @"文本";
}

- (void)setAttributedCodeText:(NSAttributedString *)codeText
{
    if (self.partialUpdate) {
        [self.textView setAttributedTextPartialUpdate_ant_mark:codeText];
    } else {
        [self.textView setAttributedText:codeText];
    }
    if (codeText.length > 0) {
//        UIColor *bgColor = [codeText attribute:NSBackgroundColorAttributeName
//                                       atIndex:0
//                                effectiveRange:NULL];
//        if ([bgColor isKindOfClass:[UIColor class]]) {
//            self.backgroundColor = bgColor;
//        }
    }
    
    if([NSThread isMainThread])
    {
        [self.textView layoutSubviews];
    }
}

- (void)didCopyCode:(NSString *)code
{
    
}

+ (CGSize)sizeThatFits:(CGSize)size 
                  code:(NSString *)code
              language:(NSString *)lang
                styles:(AMTextStyles *)styles
{
    size = [code boundingRectWithSize:CGSizeMake(size.width - AMCodeViewInset.left - AMCodeViewInset.right, size.height)
                              options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                           attributes:@{
        NSFontAttributeName: styles.codeBlockAttributes.stringAttributes[NSFontAttributeName] ?: [UIFont fontWithName:@"Courier" size:13],
        NSParagraphStyleAttributeName: [NSParagraphStyle paragraphStyleWithCMAttributes:styles.codeBlockAttributes.paragraphStyleAttributes],
    } context:nil].size;
    size.height = ceil(size.height) + AMCodeHeaderHeight + AMCodeViewInset.top + AMCodeViewInset.bottom;
    return size;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    size = [self.textView.attributedText boundingRectWithSize:CGSizeMake(size.width - AMCodeViewInset.left - AMCodeViewInset.right, size.height)
                                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                      context:nil].size;
    
    size.height = ceil(size.height) + AMCodeHeaderHeight + AMCodeViewInset.top + AMCodeViewInset.bottom;
    if (self.maximumHeight > 0) {
        size.height = MIN(size.height, self.maximumHeight);
    }
    return size;
}

@end
