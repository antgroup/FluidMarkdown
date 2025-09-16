// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

@protocol AMViewAttachment;

NS_ASSUME_NONNULL_BEGIN

@protocol AMAttachedView <NSObject>

@optional
@property (nonatomic, weak) id<AMViewAttachment> attachment;

@end

@protocol AMAttachmentUpdatable <NSObject>

@optional
- (void)updateAttachmentFromAttachment:(NSTextAttachment *)attach;

@end

@protocol AMViewAttachment <AMAttachmentUpdatable>

- (nullable __kindof UIView<AMAttachedView> *)view;
- (nullable __kindof UIView<AMAttachedView> *)viewIfLoaded;

@optional
- (NSAttributedString *)attributedString;

- (void)setNeedsLayout;
- (void)setNeedsDisplay;
- (void)setForceNeedsLayout;

@end

/**
 \c object is \c NSAttributedString itself, \c userInfo is:
 \code
 @{
 NSAttachmentAttributeName: attachment instance,
 }
 \endcode
 */
UIKIT_EXTERN NSString *const AMTextAttachmentSizeDidUpdateNotification;


@interface AMViewAttachment : NSTextAttachment <AMViewAttachment>
@property (nonatomic, readonly, nullable) __kindof UIView<AMAttachedView> *view;
@property (nonatomic) BOOL fullWidth;   // Default YES

- (void)setNeedsUpdate DEPRECATED_MSG_ATTRIBUTE("use setNeedsLayout instead");
- (void)setNeedsLayout;
- (void)setNeedsDisplay;

- (NSAttributedString *)attributedString;

- (CGSize)sizeThatFits:(CGSize)size;

- (BOOL)isEqualToAttachment:(AMViewAttachment *)attach;

- (void)updateAttachmentFromAttachment:(AMViewAttachment *)attach NS_REQUIRES_SUPER;

@end


typedef void(^ButtonAction)(void);

@interface AMButtonViewAttachment : AMViewAttachment
@property (nonatomic, strong) UIButton *button;

- (instancetype)initWithTitle:(NSString *)title action:(nullable ButtonAction)action NS_DESIGNATED_INITIALIZER;

@end

@interface UIView (AMAttachedView) <AMAttachedView>

@end

NS_ASSUME_NONNULL_END
