// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMIconLinkAttachment.h"
#import "CMImageTextAttachment.h"
#import "AMImageTextAttachment.h"
#import <CoreText/CoreText.h>
#import "AMUtils.h"

#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h> // For UTType...
#endif
#define kIconLinkRadius 8
#define kIconLinkPaddingLeft 0
#define kIconLinkPaddingRight 0
#define kIconLinkInterval 1
#define kIconLinkMarginLeft 1
#define kIconLinkMarginRight 0
#define kIconLinkPaddingRatio 0
@implementation AMIconLinkAttachment

{
    __weak NSTextContainer *_textContainer;
    NSURLSessionDataTask* _downloadTask;
    NSURL       * _imageURL;
    CGSize      _imageSize;
    UIImage* _iconImage;
    BOOL _isLoaded;
    CTLineRef _line;
    CGFloat _paddingLeft;
    CGFloat _paddingRight;
    CGFloat _paddingTop;
    CGFloat _paddingBottom;
    CGFloat _marginLeft;
    CGFloat _marginRight;
    CGFloat _radius;
    CGFloat _interval;
    UIColor* _backgroundColor;
    UIColor* _textColor;
    UIFont* _font;
    UIFont* _baseFont;
    CGFloat descent;
    
}

- (instancetype)initWithText:(NSAttributedString *)text url:(NSString*)url bgColor:(UIColor*)bgColor textColor:(UIColor*)textColor subFont:(UIFont*)subFont baseFont:(UIFont*)baseFont{
    self = [self initWithData:nil ofType:nil];
    if (self) {
        self.text = text;
        _imageURL = [NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        _isLoaded = NO;
        _line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)(text));
        _paddingLeft = kIconLinkPaddingLeft;
        _paddingRight = kIconLinkPaddingRight;
        _paddingTop = subFont.pointSize  * kIconLinkPaddingRatio;
        _paddingBottom = subFont.pointSize * kIconLinkPaddingRatio;
        _interval = kIconLinkInterval;
        _marginLeft = kIconLinkMarginLeft;
        _marginRight = kIconLinkMarginRight;
        _radius = kIconLinkRadius;
        _backgroundColor = bgColor;
        _textColor = textColor;
        _font = subFont;
        _baseFont = baseFont;
    }
    return self;
}
- (void)setNeedsUpdate {
    [_textContainer.layoutManager setNeedsLayoutForAttachment:self];
}
- (void)downloadImage:(NSURL *)imageURL completion:(void(^)(NSError * _Nullable error, NSData * _Nullable data))block {
    // Not a file URL and no download task in progress: use an URL-data-task to get the data
    _downloadTask = [NSURLSession.sharedSession dataTaskWithURL:imageURL
                                              completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        block(error, data);
        
        self->_downloadTask = nil;
    }];
    
    [_downloadTask resume];
}
- (BOOL)isEqual:(nullable id)object {
    if (object == nil) {
        return NO;
    }
    
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [self isEqualToAttachment:(AMIconLinkAttachment *)object];
}

- (BOOL)isEqualToAttachment:(AMIconLinkAttachment *)attach
{
    return [self.text isEqual:attach.text];
}

-(BOOL)isIos6Supported{
    static BOOL initialized = false;
    static BOOL supported = false;
    if (!initialized) {
#if TARGET_OS_IPHONE
        NSString *reqSysVer = @"6.0";
        NSString *currSysVer = [UIDevice currentDevice].systemVersion;
        
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
            supported = true;
        }
#else
        supported = true;
#endif
        
        initialized = true;
    }
    return supported;
}
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer
                      proposedLineFragment:(CGRect)lineFrag
                             glyphPosition:(CGPoint)position
                            characterIndex:(NSUInteger)charIndex {
    _textContainer = textContainer;
    CGFloat ascent;
    CGFloat leading;
    double textWidth = CTLineGetTypographicBounds(_line, &ascent, &descent, &leading);
    double textHeight = ascent + descent + leading;
    double height = textHeight + _paddingTop + _paddingBottom;
    double width = textWidth + textHeight + _paddingLeft + _paddingRight + _interval + _marginLeft + _marginRight;
    return CGRectMake(0, (_baseFont.capHeight - height)/2 , width, height);
}
- (void)imageResize:(UIImage *)image scaledToSize:(CGSize)newSize {
    AMUIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _iconImage = newImage;
}
- (void) setImageWithData:(NSData*)imageData
{
    NSString* imageUti = (__bridge_transfer NSString*) UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)_imageURL.pathExtension, kUTTypeData);
    self.fileType = imageUti;
    self.contents = imageData;
    
    CGSize currentImageSize = self.image.size;
    
#if TARGET_OS_IPHONE
    _iconImage = [UIImage imageWithData: imageData];
#else
    _iconImage = [[NSImage alloc] initWithData:imageData];
#endif
    
    if (_iconImage != nil) {
        if (_imageSize.width != 0 && _imageSize.height !=0) {
            [self imageResize:_iconImage scaledToSize:_imageSize];
        }
        if (! CGSizeEqualToSize(self.image.size, currentImageSize)) {
             // The layout needs to be refreshed
            [_textContainer.layoutManager setNeedsLayoutForAttachment:self];
        }
        else {
            // The image display should be refreshed
            [_textContainer.layoutManager setNeedsDisplayForAttachment:self];
        }
    }
    
    [[AMSimpleImageCache sharedCache] setImageData:imageData forURL:_imageURL];
}
- (UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex
{
    if (!self.image && [NSThread isMainThread]) {
        if (!_isLoaded) {
            NSData *data = [[AMSimpleImageCache sharedCache] imageDataForURL:_imageURL];
            if (data) {
                [self setImageWithData:data];
                _isLoaded = YES;
            } else {
                [self downloadImage:_imageURL
                         completion:^(NSError * _Nullable error, NSData * _Nullable data) {
                    if ((error == nil) && (data.length > 0)) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self setImageWithData:data];
                            _isLoaded = YES;
                        });
                    }
                }];
            }
            
        }
        
        CGSize size = CGSizeMake(imageBounds.size.width, imageBounds.size.height);
        AMUIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        CGRect rect = CGRectMake(_marginLeft, 0, size.width - _marginLeft - _marginRight, size.height);
        CGContextRef con = UIGraphicsGetCurrentContext();
        [self drawBackground:con rect:rect];
        CGRect iconRect = CGRectMake(rect.origin.x + _paddingLeft, _paddingTop, rect.size.height - (_paddingTop + _paddingBottom), rect.size.height - (_paddingTop + _paddingBottom));
        if (_iconImage) {
            [self drawImage:con rect:iconRect];
        }
        [AMIconLinkAttachment setTransformContextForCoreText:con frame:rect];
        [self drawText:con pt:CGPointMake(iconRect.origin.x + iconRect.size.width + _interval, iconRect.origin.y+descent)];
        self.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return self.image;
}
-(void)drawBackground:(CGContextRef)context rect:(CGRect)rect{
    CGColorRef fillColor = _backgroundColor.CGColor;

    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:_radius];

    CGContextSetFillColorWithColor(context, fillColor);
    [path fill];
}
-(void)drawImage:(CGContextRef)context rect:(CGRect)rect{
    CGContextSaveGState(context);
    CGContextAddEllipseInRect(context, rect);
    CGContextClip(context);
    [_iconImage drawInRect:rect];
    CGContextRestoreGState(context);
}
-(void)drawText:(CGContextRef)context pt:(CGPoint)pt{
    CGContextSetTextPosition(context, pt.x, pt.y);
    CTLineDraw(_line, context);
}
- (void)setNeedsLayout
{
    NSLayoutManager *mgr = _textContainer.layoutManager;
    if (mgr) {
        [mgr setNeedsLayoutForAttachment:self];
        
        NSNotification *noti = [[NSNotification alloc] initWithName:AMTextAttachmentSizeDidUpdateNotification
                                                             object:mgr.textStorage
                                                           userInfo:@{
            NSAttachmentAttributeName: self,
        }];
        [[NSNotificationQueue defaultQueue] enqueueNotification:noti
                                                   postingStyle:NSPostWhenIdle
                                                   coalesceMask:NSNotificationCoalescingOnSender
                                                       forModes:nil];
    }
}
+ (void)setTransformContextForCoreText:(CGContextRef)context frame:(CGRect)frame
{
    CGContextSetTextMatrix(context, CGAffineTransformScale(CGAffineTransformIdentity, 1.f, 1.f));
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, frame.size.height), 1.f, -1.f);
    CGContextConcatCTM(context, transform);
}
-(void)dealloc {
    if (_line) {
        CFRelease(_line);
    }
}
@end

