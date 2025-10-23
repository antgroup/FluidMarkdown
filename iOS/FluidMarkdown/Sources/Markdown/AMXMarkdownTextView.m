// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMXMarkdownTextView.h"
#import "AMXMarkdownTimer.h"
#import <AntMarkdown/AMTextStyles.h>
#import "AMTextStyles+CardUIPlugins.h"
#import "AMXMarkdownHelper.h"
#import "AMXRenderService.h"
#import <AntMarkdown/AMUtils.h>
#import "AMXMarkdownUtil.h"
#import "AMXMarkdownDefine.h"
#import "AMXMarkdownCustomRenderEventModel.h"
#import "AMXMarkdownLogModel.h"

static AMXMarkdownTextView* _caculateContentView;

@interface AMXMarkdownTextView()<UITextViewDelegate, UIGestureRecognizerDelegate,CMAttributedStringRendererDelegate, AMXMarkdownTimerDelegate, AMXImageAttachmentProtocol>
@property (nonatomic, strong) AMXMarkdownTimer  *timer;
@property (nonatomic, strong) dispatch_queue_t    queue;
@property (atomic, strong) NSMutableAttributedString *markdownAttrStr;
@property (atomic, strong) NSMutableAttributedString *preloadMarkdownAttrStr;
@property (atomic, assign) NSInteger              timerCountIndex;
@property (nonatomic, assign)AMXMarkdownPrintState state;
@property (nonatomic, strong)AMTextStyles* nativeStyles;
@property (atomic, strong) NSMutableArray    *clickableObjs;
@property (atomic, strong) NSMutableArray    *clickableLocationObjs;
@property (atomic, strong) NSMutableDictionary    *cacheImgDic;
@property (atomic, strong) NSString    *contentStr;
@end

@implementation AMXMarkdownTextView
- (instancetype)initWithFrame_ant_mark:(CGRect)frame {
    if (self = [super initWithFrame_ant_mark:frame delegate:self]) {
        self.queue = dispatch_queue_create("AMXMarkdownWidget", DISPATCH_QUEUE_SERIAL);
        self.typingSpeed = 0.025;
        self.chunkSize = 1;
        self.cacheImgDic = NSMutableDictionary.new;
        self.state = AMXMarkdownPrintStateInitial;
        self.logModel = [[AMXMarkdownLogModel alloc] init];
        // This is an example.
        self.logModel.spm = @"a235";
        self.logModel.styleId = @"demo";
        self.textContainerInset = UIEdgeInsetsZero;
        self.textContainer.lineFragmentPadding = 0;
        self.backgroundColor = UIColor.clearColor;
        
        self.userInteractionEnabled = YES;
        self.scrollEnabled = NO;
        
        self.editable = NO;
        self.delegate = self;
        self.multipleTouchEnabled = NO;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(handleTap:)];
        tap.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onSizeChanged:)
                                                     name:AMTextAttachmentSizeDidUpdateNotification
                                                   object:nil];
        [self addGestureRecognizer:tap];
    }
    return self;
}
-(void)setStyleId:(NSString *)styleId
{
    _styleId = styleId;
    ((AMLayoutManager*)self.layoutManager).styleId = styleId;
}
- (void)renderCompleteContent:(NSString *)text
{
    NSMutableAttributedString* attrStr = [self markdowmMutableAttributedStringFromValue:text];
    [AMXMarkdownHelper setImageAttachListener:attrStr delegate:self];
    [self setAttributedTextPartialUpdate_ant_mark:attrStr];
    [self updateSize];
}
- (void)startStreamingWithContent:(NSString*)content
{
    if (self.state != AMXMarkdownPrintStateStopped && self.state != AMXMarkdownPrintStateInitial) {
        NSError* error = [NSError errorWithDomain:@"AMStreamPrinter"
                                             code:1001
                                         userInfo:@{NSLocalizedDescriptionKey: @"Invalid state transition"}];
        [self notifyError:error];
        return;
    }
    
    if (self.typingSpeed == 0) {
        NSError* error = [NSError errorWithDomain:@"AMStreamPrinter"
                                             code:1001
                                         userInfo:@{NSLocalizedDescriptionKey: @"Invalid speed param"}];
        [self notifyError:error];
        return;
    }
    self.state = AMXMarkdownPrintStateRunning;
    self.preloadMarkdownAttrStr = [self markdowmMutableAttributedStringFromValue:content];
    self.contentStr = content;
    [self startTimer];
}
- (void)startStreamingWithContent:(NSString*)content printIndex:(NSInteger)printIndex
{
    if (printIndex >= (content.length - 1)) {
        [self renderCompleteContent:content];
        return;
    }
    if (self.state != AMXMarkdownPrintStateStopped && self.state != AMXMarkdownPrintStateInitial) {
        NSError* error = [NSError errorWithDomain:@"AMStreamPrinter"
                                             code:1001
                                         userInfo:@{NSLocalizedDescriptionKey: @"Invalid state transition"}];
        [self notifyError:error];
        return;
    }
    
    if (self.typingSpeed == 0) {
        NSError* error = [NSError errorWithDomain:@"AMStreamPrinter"
                                             code:1001
                                         userInfo:@{NSLocalizedDescriptionKey: @"Invalid speed param"}];
        [self notifyError:error];
        return;
    }
    self.state = AMXMarkdownPrintStateRunning;
    self.preloadMarkdownAttrStr = [self markdowmMutableAttributedStringFromValue:content];
    self.contentStr = content;
    [self renderCompleteContent:[content substringToIndex:printIndex]];
    self.timerCountIndex = printIndex;
    [self startTimer];
}
- (void)addStreamContent:(NSString *)text
{
    if (self.state != AMXMarkdownPrintStateRunning && self.state != AMXMarkdownPrintStatePaused) {
        return;
    }
    self.contentStr = [self.contentStr stringByAppendingString:text];
    self.preloadMarkdownAttrStr = [self markdowmMutableAttributedStringFromValue:self.contentStr];
    if (self.state == AMXMarkdownPrintStatePaused) {
        [self resume];
    }
}
- (void)pause
{
    if (self.state == AMXMarkdownPrintStateRunning) {
        self.state = AMXMarkdownPrintStatePaused;
        [self.textViewDelegate didChangeState:AMXMarkdownPrintStatePaused];
    }
    [self stopTimer];
    __weak typeof(self) weakSelf = self;
    dispatch_async_on_main_queue(^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        // render all data without animation to remove the animation maksk layer
        [strongSelf setAttributedTextPartialUpdate_ant_mark:strongSelf.preloadMarkdownAttrStr];
    });
}
- (void)resume
{
    if (self.state == AMXMarkdownPrintStatePaused) {
        self.state = AMXMarkdownPrintStateRunning;
        [self.textViewDelegate didChangeState:AMXMarkdownPrintStateRunning];
    }
    [self startTimer];
}
- (void)stop
{
    if (self.state != AMXMarkdownPrintStateRunning && self.state != AMXMarkdownPrintStatePaused) {
        return;
    }
    [self.timer stopTimer];
    self.timer = nil;
    
    NSMutableAttributedString *attrStr = self.markdownAttrStr.mutableCopy;
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.queue, ^{
        [AMXMarkdownHelper setImageAttachListener:attrStr delegate:self];
        dispatch_async_on_main_queue(^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            // render all data without animation to remove the animation maksk layer
            [strongSelf setAttributedTextPartialUpdate_ant_mark:strongSelf.preloadMarkdownAttrStr];
            [strongSelf updateSize];
            [strongSelf reset];
            [strongSelf.textViewDelegate didChangeState:AMXMarkdownPrintStateStopped];
        });
    });
}
- (void)reset
{
    [self stopTimer];
    self.timerCountIndex = 0;
    self.preloadMarkdownAttrStr = nil;
    self.markdownAttrStr = nil;
    self.clickableObjs = nil;
    self.clickableLocationObjs = nil;
    self.state = AMXMarkdownPrintStateStopped;
}
- (void)onTimer {
    if (!self.timer) {
        return;
    }
    if (self.preloadMarkdownAttrStr.length == 0) {
        return;
    }
    
    if (self.timerCountIndex <= self.preloadMarkdownAttrStr.length) {
        [self timerRenderUI];
        self.timerCountIndex += self.chunkSize;
        if (self.timerCountIndex > self.preloadMarkdownAttrStr.length) {
            [self pause];
        }
    } else {
        [self pause];
    }
}
- (void)startTimer {
    if(!self.timer) {
        self.timer = [[AMXMarkdownTimer alloc] initWithConfig:self.typingSpeed*1000 queue:self.queue];
        self.timer.delegate = self;
    }
    [self.timer startTimer];
}
- (void)stopTimer {
    [self.timer stopTimer];
    self.timer = nil;
}
- (void)timerRenderUI {
    NSMutableAttributedString *attrStr = [self timerUpdateRenderAttrText];
    self.markdownAttrStr = attrStr;
    
    __weak typeof(self) weakSelf = self;
    if (attrStr.string.length > 0) {
        NSLog(@"self: %@, attr: %@, length: %ld", self, attrStr.string, attrStr.length);
        [AMXMarkdownHelper setImageAttachListener:attrStr delegate:weakSelf];
    }else {
        NSLog(@"ignore for null attrStr");
        return;
    }
    
    dispatch_async_on_main_queue(^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setAttributedTextPartialUpdate_ant_mark:attrStr animated:YES];
        [strongSelf updateSize];
    });
}
- (NSMutableAttributedString *)timerUpdateRenderAttrText {
   
    NSMutableAttributedString *markdownAttrStr = [self.preloadMarkdownAttrStr attributedSubstringFromRange:NSMakeRange(0, MIN(self.timerCountIndex, self.preloadMarkdownAttrStr.length))].mutableCopy;
    if (!markdownAttrStr || markdownAttrStr.length <= 0) {
        markdownAttrStr = self.markdownAttrStr;
    }
    return markdownAttrStr;
}
-(void)notifyError:(NSError*)error
{
    if (self.textViewDelegate && [self.textViewDelegate respondsToSelector:@selector(onError:)]) {
        [self.textViewDelegate onError:error];
    }
}
- (void)onSizeChanged:(NSNotification *)noti {
    if ([noti.object isKindOfClass:[NSAttributedString class]]) {
        NSAttributedString *object = (NSAttributedString *)noti.object;
        if ([object.string isEqualToString:self.markdownAttrStr.string]) {
            [self updateSize];
        }
    }
}
-(void)updateSize
{
    dispatch_sync_on_main_queue(^{
        CGFloat maxLabelW = self.frame.size.width;
        CGSize limitSize = CGSizeMake(maxLabelW, MAXFLOAT);
        CGSize contentSize = [AMXMarkdownTextView calculateSizeWithLayoutManager:self limitSize:limitSize];
        if ([self.textViewDelegate respondsToSelector:@selector(onSizeChange:)]) {
            [self.textViewDelegate onSizeChange:contentSize];
        }
    });
    
}
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return NO;
}

- (NSMutableAttributedString *)markdowmMutableAttributedStringFromValue:(NSString *)value {
    if (value.length <= 0) {
        return NSMutableAttributedString.new;
    }
    if (!self.nativeStyles) {
        AMXMarkdownStyleConfig* style = [[AMXRenderService shared] getMarkdownStyleWithId:self.styleId];
        self.nativeStyles = [AMXMarkdownTextView XRMarkdownStyle2AMTextStyle:style textView:self];
        [AMTextStyles setAMStylesWithId:self.styleId styles:self.nativeStyles];
    }
    
    return [AMXMarkdownHelper mdToAttrString:value
                               defaultStyles:self.nativeStyles
                                    delegate:self
                                    textView:self];
}
-(void)notifyNodeLocation:(NSArray*)locArray {
    if (!self.logModel.spm || [self.logModel.spm isEqualToString:@""]) {
        return;
    }
    if (!locArray || [locArray count] == [self.clickableLocationObjs count]) {
        return;
    }
    if (!self.clickableLocationObjs) {
        self.clickableLocationObjs = [[NSMutableArray alloc] initWithArray:locArray];
    } else {
        NSInteger addCnt = [locArray count] - [self.clickableLocationObjs count];
        if (addCnt > 0) {
            for (NSInteger i = [self.clickableLocationObjs count]; i < [locArray count]; i++) {
                [self.clickableLocationObjs addObject:[locArray objectAtIndex:i]];
            }
        }
    }
    [self updateBounds];
    if ([self.textViewDelegate respondsToSelector:@selector(onUpdateExposureElement:)]) {
        [self.textViewDelegate onUpdateExposureElement:self.clickableObjs];
    }
}
-(void)notifyNodeUpdate:(NSArray*)dataArray {
    if (!dataArray || [dataArray count] == [self.clickableObjs count]) {
        return;
    }
    if (!self.clickableObjs) {
        self.clickableObjs = [self generateAllEventModelWithClickableObjs:dataArray];
    } else {
        NSInteger addCnt = [dataArray count] - [self.clickableObjs count];
        if (addCnt > 0) {
            for (NSInteger i = [self.clickableObjs count]; i < [dataArray count]; i++) {
                NSDictionary* dic = [dataArray objectAtIndex:i];
                if (dic) {
                    AMXMarkdownCustomRenderEventModel* model = [self generateEventModel:dic];
                    if (model) {
                        [self.clickableObjs addObject:model];
                    }
                }
            }
        }
    }
    if ([self.textViewDelegate respondsToSelector:@selector(onUpdateExposureElement:)]) {
        [self.textViewDelegate onUpdateExposureElement:self.clickableObjs];
    }
}
- (void)updateBounds {
    int index = 0;
    for (NSValue* value in self.clickableLocationObjs) {
        CGRect bounds = [value CGRectValue];
        if (index < self.clickableObjs.count) {
            AMXMarkdownCustomRenderEventModel* model = self.clickableObjs[index];
            model.bounds = bounds;
            index++;
        }
    }
}
-(AMXMarkdownCustomRenderEventModel*)generateEventModel:(NSString*)type url:(NSString*)url obj:(NSDictionary*)obj{
    if (!type || !url) {
        return nil;
    }
    AMXMarkdownCustomRenderEventModel * model = [[AMXMarkdownCustomRenderEventModel alloc] init];
    model.extParam = self.logModel.extraParams;
    model.contentUrl = url;
    model.contentType = type;
    model.exposurePercent = 0;
    return model;
}
-(AMXMarkdownCustomRenderEventModel*)generateEventModel:(NSDictionary*)dic{
    NSString* url = [dic objectForKey:@"url"];
    NSString* type = nil;
    CMNodeType nodeType = [[dic objectForKey:@"type"] intValue];
    if (nodeType == CMNodeTypeImage) {
        type = @"image";
    }
    if (nodeType == CMNodeTypeLink) {
        type = @"link";
    }
    if (nodeType == CMNodeTypeInlineHTML && [[[dic objectForKey:@"tag"] stringValue] isEqualToString:@"iconLink"]) {
        type = @"iconLink";
    }
    if (!type || !url) {
        return nil;
    }
    AMXMarkdownCustomRenderEventModel* model = [self generateEventModel:type url:url obj:dic];
    return model;
}
-(NSMutableArray*)generateAllEventModelWithClickableObjs:(NSArray*)clickObjs {
    if (!self.logModel.spm || [self.logModel.spm isEqualToString:@""]) {
        return nil;
    }
    NSMutableArray* modelArray = [[NSMutableArray alloc] init];
    for (NSDictionary* dic in clickObjs) {
        AMXMarkdownCustomRenderEventModel* model = [self generateEventModel:dic];
        if (model) {
            [modelArray addObject:model];
        }
    }
    return modelArray;
}
- (void)updateMarkdowmMutableAttributedString:(NSMutableAttributedString *)attStr {
    self.markdownAttrStr = attStr;
    [AMXMarkdownHelper setImageAttachListener:attStr delegate:self];
    [self _updateMarkdowmAttributedString:attStr];
    [self sizeToFit];
}
- (void)_updateMarkdowmAttributedString:(NSAttributedString *)attStr {
    [self setAttributedText_ant_mark:attStr];
}
-(void)dealloc
{
    if (self.timer) {
        [self.timer stopTimer];
        self.timer = nil;
    }
    [AMTextStyles removeAMStylesWithId:self.styleId];
}
+ (CGSize)caculateContentSize:(NSString *)markdownText constrainSize:(CGSize)constrainSize styleId:(NSString*)styleId{
    AMTextStyles* textStyle = [AMTextStyles cpl_cardDefaultTextStyles];
    
    AMXMarkdownStyleConfig* config = [[AMXRenderService shared] getMarkdownStyleWithId:styleId];
    if (config) {
        textStyle = [AMXMarkdownTextView XRMarkdownStyle2AMTextStyle:config textView:nil];
        [AMTextStyles setAMStylesWithId:styleId styles:textStyle];
    }
    NSMutableAttributedString *attStr = [AMXMarkdownHelper mdToAttrString:markdownText
                                                            defaultStyles:textStyle];
    CGSize limitSize = CGSizeMake(constrainSize.width, MAXFLOAT);
    __block CGSize contentSize;
    dispatch_sync_on_main_queue(^{
        if (!_caculateContentView) {
            _caculateContentView = [[AMXMarkdownTextView alloc] initWithFrame_ant_mark:CGRectMake(0, 0, constrainSize.width, constrainSize.height)];
            _caculateContentView.textContainerInset = UIEdgeInsetsZero;
            _caculateContentView.textContainer.lineFragmentPadding = 0;
            _caculateContentView.font = kCUPLMarkdownTextFont;
        }
        [_caculateContentView setAttributedTextPartialUpdate_ant_mark:attStr];
        contentSize = [AMXMarkdownTextView calculateSizeWithLayoutManager:_caculateContentView limitSize:limitSize];
    });
    CGRect contentRect = CGRectIntegral(CGRectMake(0, 0, contentSize.width, contentSize.height));
    CGFloat tmpWidth = kCUPLMarkdownTextFontSize;
    CGFloat tmpHeight = kCUPLMarkdownTextLineHeight;
    contentRect.size.width =  (contentRect.size.width < tmpWidth) ? tmpWidth : contentRect.size.width;
    contentRect.size.height = (contentRect.size.height < tmpHeight) ? tmpHeight : contentRect.size.height;
    return contentRect.size;
}
+ (CGSize)calculateSizeWithLayoutManager:(UITextView *)textView limitSize:(CGSize)limitSize {
    textView.textContainer.size = CGSizeMake(limitSize.width, CGFLOAT_MAX);
    [textView.layoutManager ensureLayoutForTextContainer:textView.textContainer];
    CGRect usedRect = [textView.layoutManager usedRectForTextContainer:textView.textContainer];
    return CGSizeMake(ceil(usedRect.size.width), ceil(usedRect.size.height));
}
-(void)willRemoveSubview:(UIView *)subview
{
    [super willRemoveSubview:subview];
}


- (void)handleTap:(UITapGestureRecognizer *)gesture {
    CGPoint tapLocation = [gesture locationInView:gesture.view];
    NSUInteger tappedCharacterIndex = -1;
    NSAttributedString *attributedText = nil;
    
    UITextView *textView = (UITextView*)gesture.view;
    
    attributedText = textView.attributedText;
    NSTextContainer *textContainer = textView.textContainer;
    NSLayoutManager *layoutManager = textView.layoutManager;
    
    tapLocation.x -= textView.textContainerInset.left;
    tapLocation.y -= textView.textContainerInset.top;
    
    tappedCharacterIndex = [layoutManager characterIndexForPoint:tapLocation
                                                 inTextContainer:textContainer
                        fractionOfDistanceBetweenInsertionPoints:nil];

    if (tappedCharacterIndex >= 0 && tappedCharacterIndex < attributedText.length) {
        // Check if the tapped character is an attachment
        NSRange range = {0};
        NSDictionary *attributes = [attributedText attributesAtIndex:tappedCharacterIndex
                                                      effectiveRange:&range];
        NSTextAttachment *attachment = attributes[NSAttachmentAttributeName];
        id linkValue = attributes[NSLinkAttributeName];
        if (![self.textViewDelegate respondsToSelector:@selector(onTap:content:gesture:attachment:tapIndex:attrString:)]) {
            return;
        }
        if (linkValue) {
            if (attachment && [attachment isKindOfClass:[AMIconLinkAttachment class]]) {
                [self.textViewDelegate onTap:AMXMarkdownTapIconLink content:linkValue gesture:gesture attachment:attachment tapIndex:tappedCharacterIndex attrString:attributedText];
            } else {
                [self.textViewDelegate onTap:AMXMarkdownTapLink content:linkValue gesture:gesture attachment:attachment tapIndex:tappedCharacterIndex attrString:attributedText];
            }
        } else if(attachment && [attachment isKindOfClass:[CMImageTextAttachment class]]) {
            [self.textViewDelegate onTap:AMXMarkdownTapImage content:linkValue gesture:gesture attachment:attachment tapIndex:tappedCharacterIndex attrString:attributedText];
        } else if(attachment && [attachment isKindOfClass:[AMTableViewAttachment class]]) {
            [self.textViewDelegate onTap:AMXMarkdownTapTable content:linkValue gesture:gesture attachment:attachment tapIndex:tappedCharacterIndex attrString:attributedText];
        }
    }
}
- (void)handleTableClick:(UITapGestureRecognizer *)gesture tableView:(AMMarkdownTableView*)tableView {
    if (![tableView isKindOfClass:[AMMarkdownTableView class]])
        return;
    CGPoint tapLocation = [gesture locationInView:gesture.view];
    NSArray *cells = [tableView.collectionView visibleCells];
    if ([cells isKindOfClass:NSArray.class] && cells.count > 0) {
        for (AMMarkdownTableCell *cell in cells) {
            if (![cell isKindOfClass:[AMMarkdownTableCell class]])
                continue;
            CGRect childFrameInGrandparent = [cell.textview convertRect:cell.textview.bounds toView:gesture.view];
            if(CGRectContainsPoint(childFrameInGrandparent, tapLocation)) {
                [self handleCellViewClick:gesture textView:cell.textview];
            }
        }
    }
}

- (void)handleCellViewClick:(UITapGestureRecognizer *)gesture textView:(UITextView *)textView {
    if(![textView isKindOfClass:[UITextView class]])
        return;
    CGPoint tapLocation = [gesture locationInView:textView];
    
    NSUInteger tappedCharacterIndex = 0;
    NSAttributedString *attributedText = nil;
    attributedText = textView.attributedText;
    
    NSTextContainer *textContainer = textView.textContainer;
    NSLayoutManager *layoutManager = textView.layoutManager;
    
    tapLocation.x -= textView.textContainerInset.left;
    tapLocation.y -= textView.textContainerInset.top;
    tappedCharacterIndex = [layoutManager characterIndexForPoint:tapLocation inTextContainer:textContainer fractionOfDistanceBetweenInsertionPoints:nil];

    if (tappedCharacterIndex >= 0 && tappedCharacterIndex < attributedText.length) {
        // Check if the tapped character is an attachment
        NSRange range = {0};
        NSDictionary *attributes = [attributedText attributesAtIndex:tappedCharacterIndex
                                                      effectiveRange:&range];
        NSTextAttachment *attachment = attributes[NSAttachmentAttributeName];
        id linkValue = attributes[NSLinkAttributeName];
        if (![self.textViewDelegate respondsToSelector:@selector(onTap:content:gesture:attachment:tapIndex:attrString:)]) {
            return;
        }
        if (linkValue) {
            if (attachment && [attachment isKindOfClass:[AMIconLinkAttachment class]]) {
                [self.textViewDelegate onTap:AMXMarkdownTapIconLink content:linkValue gesture:gesture attachment:attachment tapIndex:tappedCharacterIndex attrString:attributedText];
            } else {
                [self.textViewDelegate onTap:AMXMarkdownTapLink content:linkValue gesture:gesture attachment:attachment tapIndex:tappedCharacterIndex attrString:attributedText];
            }
        } else if(attachment && [attachment isKindOfClass:[CMImageTextAttachment class]]) {
            [self.textViewDelegate onTap:AMXMarkdownTapImage content:linkValue gesture:gesture attachment:attachment tapIndex:tappedCharacterIndex attrString:attributedText];
        } else if(attachment && [attachment isKindOfClass:[AMTableViewAttachment class]]) {
            [self.textViewDelegate onTap:AMXMarkdownTapTable content:linkValue gesture:gesture attachment:attachment tapIndex:tappedCharacterIndex attrString:attributedText];
        }
    }
}

#pragma mark - Selectable


- (NSDictionary *)textViewSelectedInfo
{
    return @{
        CS_NATIVE_WIDGET_EVENT_PAYLOAD_MAKRDOWN_SELECTED_TEXT: [self.text substringWithRange:self.selectedRange]?:@"",
        CS_NATIVE_WIDGET_EVENT_PAYLOAD_MAKRDOWN_START_SELECTED_RECT: [NSValue valueWithCGRect:[self firstRectForRange:[self textRangeFromPosition:self.selectedTextRange.start toPosition:self.selectedTextRange.start]]],
        CS_NATIVE_WIDGET_EVENT_PAYLOAD_MAKRDOWN_END_SELECTED_RECT: [NSValue valueWithCGRect:[self firstRectForRange:[self textRangeFromPosition:self.selectedTextRange.end toPosition:self.selectedTextRange.end]]],
        CS_NATIVE_WIDGET_EVENT_PAYLOAD_MAKRDOWN_SELECTED_RECT: [NSValue valueWithCGRect:[self firstRectForRange:self.selectedTextRange]],
    };
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

+(AMTextStyles*)XRMarkdownStyle2AMTextStyle:(AMXMarkdownStyleConfig*)config textView:(UITextView*)textView{
    AMTextStyles* styles = [AMTextStyles cpl_cardDefaultTextStyles];
    [AMXMarkdownHelper transformParagraph:styles customStyle:config];
    [AMXMarkdownHelper transformTitle:styles customStyle:config];
    [AMXMarkdownHelper transformOrderList:styles customStyle:config];
    [AMXMarkdownHelper transformUnorderList:styles customStyle:config];
    [AMXMarkdownHelper transformTable:styles customStyle:config];
    [AMXMarkdownHelper transformHRule:styles customStyle:config];
    [AMXMarkdownHelper transformFootNote:styles customStyle:config];
    [AMXMarkdownHelper transformLink:styles customStyle:config textView:textView];
    [AMXMarkdownHelper transformInlineCode:styles customStyle:config];
    [AMXMarkdownHelper transformCodeBlock:styles customStyle:config];
    [AMXMarkdownHelper transformUnderLine:styles customStyle:config];
    [AMXMarkdownHelper transformBlockQuote:styles customStyle:config];
    return styles;
}
+ (BOOL)isEmptyStringOrNotString:(id)value {
    return !value || ![value isKindOfClass:NSString.class] || ((NSString *)value).length < 1;
}
#pragma mark CPLImageAttachmentProtocol

- (UIImage *)getImageFromCacheIfExist:(NSString *)url {
    UIImage *img = nil;
    if(![AMXMarkdownTextView isEmptyStringOrNotString:url]) {
        img = [self.cacheImgDic objectForKey:url];
    }
    return img;
}

- (void)onImageLoadFinish:(UIImage *)image url:(NSString *)url {
    if (image &&
       ![AMXMarkdownTextView isEmptyStringOrNotString:url]) {
        [self.cacheImgDic setObject:image forKey:url];
    }
    
    @weakify(self)
    dispatch_async_on_main_queue(^{
        @strongify(self)
        [self updateSize];
    });
}

@end
