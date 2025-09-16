// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AntMarkdown/CMAttributedStringRenderer.h>
#import "AMXMarkdownLogModel.h"
#import "AMXMarkdownCustomRenderEventModel.h"

NS_ASSUME_NONNULL_BEGIN;

/**
 Clickable elemant type
 */
typedef enum : NSUInteger {
    AMXMarkdownTapIconLink,
    AMXMarkdownTapLink,
    AMXMarkdownTapImage,
    AMXMarkdownTapTable,
} AMXMarkdownTapType;
/**
 Printing state
 */
typedef enum : NSUInteger {
    AMXMarkdownPrintStateInitial,
    AMXMarkdownPrintStateRunning,
    AMXMarkdownPrintStatePaused,
    AMXMarkdownPrintStateStopped,
} AMXMarkdownPrintState;

@protocol AMXMarkdownTextViewDelegate <NSObject>
/**
 MarkdownView size change
 */
-(void)onSizeChange:(CGSize)size;
/**
 Markdown printing state change
 */
-(void)didChangeState:(AMXMarkdownPrintState)state;
/**
 The delagate of tap action
 */
-(void)onTap:(AMXMarkdownTapType)type content:(id)content gesture:(UITapGestureRecognizer *)gesture attachment:(NSTextAttachment*)attachment tapIndex:(NSUInteger)tapIndex attrString:(NSAttributedString*)attrString;
/**
 The delagate of exposure element
 */
-(void)onUpdateExposureElement:(NSArray<AMXMarkdownCustomRenderEventModel*>*)elements;

/**
 Exception
 */
-(void)onError:(NSError*)error;

@end

@interface AMXMarkdownTextView : UITextView

@property (nonatomic, weak, nullable) id<AMXMarkdownTextViewDelegate> textViewDelegate;
/**
 Time interval of printing（unit：s），default is  0.025
 */
@property (nonatomic, assign) NSTimeInterval typingSpeed;
/**
 The step length of printing，default is 1
 */
@property (nonatomic, assign) NSInteger chunkSize;
/**
 The unique style id of markdownView instance
 */
@property (nonatomic, strong) NSString* styleId;

/**
 Log model
 */
@property (nonatomic, strong) AMXMarkdownLogModel   *logModel;

/**
 Init with frame, it will change while printing
 */
- (instancetype)initWithFrame_ant_mark:(CGRect)frame;
/**
 Start print with content.
 */
- (void)startStreamingWithContent:(NSString*)content;

/**
 Start print with content, and you can set the index of printing action.
 */
- (void)startStreamingWithContent:(NSString*)content printIndex:(NSInteger)printIndex;
/**
 Append markdown data
 */
- (void)addStreamContent:(NSString *)text;
/**
 Pause, it will continue when run continue function with the previous string
 */
- (void)pause;
/**
 Continue, it will continue after pause function with the previous string
 */
- (void)resume;
/**
 Stop print，it will stop and clear previous string data
 */
- (void)stop;
/**
 Reset, all state recover
 */
- (void)reset;

/**
 Render the markdown string directly without printing process
 */
- (void)renderCompleteContent:(NSString *)text;
/**
 Calculate ths markdownView size with string and style
 */
+ (CGSize)caculateContentSize:(NSString *)markdownText constrainSize:(CGSize)constrainSize styleId:(NSString*)styleId;

@end

NS_ASSUME_NONNULL_END
