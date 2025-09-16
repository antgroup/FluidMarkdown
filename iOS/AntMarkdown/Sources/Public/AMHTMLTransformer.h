// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <AntMarkdown/CMHTMLElementTransformer.h>
#import <AntMarkdown/CMHTMLUnderlineTransformer.h>
#import <AntMarkdown/AMTextStyles.h>

NS_ASSUME_NONNULL_BEGIN

@interface AMHTMLTransformer : NSObject <CMHTMLElementTransformer>
@property (nonatomic, readonly, weak) AMTextStyles *styles;

- (instancetype)initWithStyles:(AMTextStyles *)styles;

@end

@interface AMHTMLMarkTransformer : AMHTMLTransformer

@end

@interface AMHTMLSpanTransformer : AMHTMLTransformer

@end

@interface AMHTMLCiteTransformer : AMHTMLTransformer

@end

@interface AMHTMLDelTransformer : AMHTMLTransformer

@end

@interface AMHTMLFontTransformer : AMHTMLTransformer

@end

@interface AMHTMLUnderlineTransformer : CMHTMLUnderlineTransformer

- (instancetype)initWithStyle:(NSUnderlineStyle)style
                        color:(UIColor *)color
                    lineWidth:(CGFloat)width
                       offset:(CGFloat)offset NS_DESIGNATED_INITIALIZER;

@end

@interface AMHTMLDefaultTransformer : AMHTMLTransformer

@end

@interface AMHTMLTextLabelTransformer : AMHTMLTransformer

@end
@interface AMHTMLImgTransformer : AMHTMLTransformer

@end
@interface AMHTMLIconLinkTransformer : AMHTMLTransformer

@end
@interface AMHTMLIconTransformer : AMHTMLTransformer

@end
NS_ASSUME_NONNULL_END
