// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <AntMarkdown/AMViewAttachment.h>

@class AMTextStyles;

NS_ASSUME_NONNULL_BEGIN

@protocol AMCodeView <NSObject>
- (void)setPlainCodeText:(NSString *)codeText;
- (void)setLanguage:(nullable NSString *)lang;
- (void)setAttributedCodeText:(NSAttributedString *)codeText;

@optional
- (void)didCopyCode:(NSString *)code;

- (instancetype)initWithStyles:(AMTextStyles *)styles;

+ (CGSize)sizeThatFits:(CGSize)size
                  code:(NSString *)code
              language:(nullable NSString *)lang
                styles:(AMTextStyles *)styles;

@end

@interface AMCodeViewAttachment : AMViewAttachment
@property (nonatomic, readonly, nullable) UIView<AMCodeView> *view;
@property (nonatomic) BOOL partialUpdate;
@property (nonatomic, nullable) NSString *language;
@property (nonatomic) NSString *code;

+ (Class<AMCodeView>)codeViewClass;    // Default is AMMarkdownCodeView

+ (instancetype)attachmentWithCode:(NSString *)code
                          language:(nullable NSString *)hint
                            styles:(nullable AMTextStyles *)styles;

@end

NS_ASSUME_NONNULL_END
