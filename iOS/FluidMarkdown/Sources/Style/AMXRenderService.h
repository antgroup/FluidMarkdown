// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "AMXMarkdownStyle.h"

NS_ASSUME_NONNULL_BEGIN

@interface AMXRenderService : NSObject
+ (instancetype)shared;
/**
 Set a style with a unique ID and assign the ID to AMXMarkdownTextView to render markdown data using that style
 */
-(void)setMarkdownStyleWithId:(AMXMarkdownStyleConfig*)styleConfig styleId:(NSString*)styleId;
/**
 Get the custom style with id
 */
-(AMXMarkdownStyleConfig*)getMarkdownStyleWithId:(NSString*)styleId;
@end

NS_ASSUME_NONNULL_END
