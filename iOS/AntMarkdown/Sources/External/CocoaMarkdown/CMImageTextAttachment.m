//
//  CMImageTextAttachment.m
//  CocoaMarkdown
//
//  Created by Jean-Luc Jumpertz on 10/05/2019.
//  Inspired by https://www.cocoanetics.com/2016/09/asynchronous-nstextattachments-22/
//  Copyright © 2019 Jean-Luc Jumpertz. All rights reserved.
//

#import "CMImageTextAttachment.h"
#import "AMUtils.h"

#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h> // For UTType...
#endif

@interface CMImageTextAttachment ()
{
    NSTextContainer* __weak _textContainer;
    NSURLSessionDataTask* _downloadTask;
    BOOL _isImageLoaded;
    NSString* _imageTitle;
}

@end


@implementation CMImageTextAttachment

static CGSize _placeholderImageSize = {16, 16};
static CGFloat _placeholderImageCornerRadius = 3.0;

#if TARGET_OS_IPHONE
static UIImage* _placeholderImage;

+ (UIImage*) placeholderImage
{
    if (_placeholderImage == nil) {
        AMUIGraphicsBeginImageContextWithOptions(_placeholderImageSize, NO, 0);
        
        CGRect imageRect = CGRectMake(0, 0, _placeholderImageSize.width, _placeholderImageSize.height);
        UIBezierPath* placeholderShape = [UIBezierPath bezierPathWithRoundedRect: imageRect cornerRadius:(CGFloat)_placeholderImageCornerRadius];
        [UIColor.lightGrayColor setFill];
        [placeholderShape fill];
        [UIColor.grayColor setStroke];
        [placeholderShape stroke];
        [@"?" drawInRect:CGRectInset(imageRect, 4, -1) withAttributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:imageRect.size.height - 2],
                                                                         NSForegroundColorAttributeName: UIColor.whiteColor }];
        _placeholderImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    return _placeholderImage;
}

#else

static NSImage* _placeholderImage;

+ (NSImage*) placeholderImage
{
    if (_placeholderImage == nil) {
        _placeholderImage = [NSImage imageWithSize:_placeholderImageSize flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
            NSBezierPath* placeholderShape = [NSBezierPath bezierPathWithRoundedRect:dstRect xRadius:_placeholderImageCornerRadius yRadius:_placeholderImageCornerRadius];
            [NSColor.lightGrayColor setFill];
            [placeholderShape fill];
            [NSColor.grayColor setStroke];
            [placeholderShape stroke];
            [@"?" drawInRect:CGRectInset(dstRect, 4, -1) withAttributes:@{ NSFontAttributeName: [NSFont systemFontOfSize:dstRect.size.height - 2],
                                                                           NSForegroundColorAttributeName: NSColor.whiteColor }];
            return YES;
        }];
    }
    return _placeholderImage;
}
#endif

- (instancetype) initWithImageURL:(NSURL*)imageURL
{
    return [self initWithImageURL:imageURL title:nil];
}

- (instancetype) initWithImageURL:(NSURL*)imageURL title:(NSString*)title
{
    NSString* imageUrlUti = (__bridge_transfer NSString*) UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)imageURL.pathExtension, kUTTypeData);
    
    self = [super initWithData:nil ofType:imageUrlUti];
    if (self != nil) {
        _imageURL = imageURL;
        _imageSize = CGSizeZero;
        _isImageLoaded = NO;
        _imageTitle = title;
        self.image = [self.class placeholderImage];
    }
    return self;
}
- (instancetype) initWithImageURL:(NSURL*)imageURL title:(NSString*)title size:(CGSize)size {
    NSString* imageUrlUti = (__bridge_transfer NSString*) UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)imageURL.pathExtension, kUTTypeData);
    
    self = [super initWithData:nil ofType:imageUrlUti];
    if (self != nil) {
        _imageURL = imageURL;
        _imageSize = size;
        _isImageLoaded = NO;
        _imageTitle = title;
        self.image = [self.class placeholderImage];
    }
    return self;
}
- (NSString*)imageCaption
{
    // 优先使用title,如果title不可用，则使用alt
    return ([_imageTitle length] > 0)?_imageTitle:self.altText;
}

- (BOOL)isImageLoaded
{
    return _isImageLoaded;
}

- (NSTextContainer *)textContainer
{
    return _textContainer;
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
    
    return [self isEqualToAttachment:(CMImageTextAttachment *)object];
}

- (BOOL)isEqualToAttachment:(CMImageTextAttachment *)attach
{
    return [self.imageURL isEqual:attach.imageURL];
}

- (void)downloadImage:(NSURL *)imageURL completion:(void(^)(NSError * _Nullable error, NSData * _Nullable data))block {
    // Not a file URL and no download task in progress: use an URL-data-task to get the data
    _downloadTask = [NSURLSession.sharedSession dataTaskWithURL:_imageURL 
                                              completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        block(error, data);
        
        self->_downloadTask = nil;
    }];
    
    [_downloadTask resume];
}

- (CGRect) attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex
{
    CGSize attachmentImageSize = self.image.size;
    
    CGFloat maxWidth = lineFrag.size.width - textContainer.lineFragmentPadding * 2;
    if (attachmentImageSize.width > maxWidth) {
        attachmentImageSize = CGSizeMake(maxWidth, attachmentImageSize.height * maxWidth / attachmentImageSize.width);
    }
    
    CGRect attachmentBounds;
    attachmentBounds.origin = CGPointZero;
    attachmentBounds.size = attachmentImageSize;
    return attachmentBounds;
}

#if TARGET_OS_IPHONE
- (nullable UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(nullable NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex
#else
- (nullable NSImage *)imageForBounds:(NSRect)imageBounds textContainer:(nullable NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex
#endif
{    
    if (! _isImageLoaded && (_imageURL != nil)) {
        
        // Save a reference to the textcontainer
        _textContainer = textContainer;
        
        // Load the image asynchronously
        if (_imageURL.isFileURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSData* imageData = [NSData dataWithContentsOfURL:self->_imageURL];
                if (imageData.length > 0) {
                    [self setImageWithData:imageData];
                    self->_isImageLoaded = YES;
                }
            });
        }
        else if (_downloadTask == nil) {
            // Not a file URL and no download task in progress: use an URL-data-task to get the data
            [self downloadImage:_imageURL
                     completion:^(NSError * _Nullable error, NSData * _Nullable data) {
                if ((error == nil) && (data.length > 0)) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setImageWithData:data];
                        self->_isImageLoaded = YES;
                    });
                }
            }];
        }
    }    
    
#if !TARGET_OS_IPHONE
#ifdef __MAC_10_15
    if (! [NSProcessInfo.processInfo isOperatingSystemAtLeastVersion: (NSOperatingSystemVersion){10, 15, 0}]) 
#endif
    {
        // On macOS 10.14.6 and below, the image attachment is dislayed vertically flipped, so we need to flip it again to display it correctly
        // This issue has been fixed on macOS 10.15 for applications compiled with Xcode 11 or later (SDK version >= 10.15)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self.image setFlipped:NSGraphicsContext.currentContext.isFlipped];
#pragma clang diagnostic pop
    }
#endif
    
    return self.image;
}
- (void)imageResize:(UIImage *)image scaledToSize:(CGSize)newSize {
    AMUIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.image = newImage;
}
- (void) setImageWithData:(NSData*)imageData
{
    NSString* imageUti = (__bridge_transfer NSString*) UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)_imageURL.pathExtension, kUTTypeData);
    self.fileType = imageUti;
    self.contents = imageData;
    
    CGSize currentImageSize = self.image.size;
    
#if TARGET_OS_IPHONE
    self.image = [UIImage imageWithData: imageData];
#else
    self.image = [[NSImage alloc] initWithData:imageData];
#endif
    
    if (self.image != nil) {
        if (_imageSize.width != 0 && _imageSize.height !=0) {
            [self imageResize:self.image scaledToSize:_imageSize];
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
}

@end

#pragma mark - NSLayoutManager class extension

@implementation NSLayoutManager (CMImageTextAttachment)

/// Trigger a re-display for an attachment
- (void) setNeedsDisplayForAttachment:(NSTextAttachment*)textAttachment
{
    NSArray<NSValue*>* rangesForAttachment = [self rangesForAttachment:textAttachment];
    
    [rangesForAttachment enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSValue * _Nonnull rangeObject, NSUInteger idx, BOOL * _Nonnull stop) {
        // invalidate the display for the range
        [self invalidateDisplayForCharacterRange:rangeObject.rangeValue];
    }];
}

/// Trigger a relayout for an attachment
- (void) setNeedsLayoutForAttachment:(NSTextAttachment*)textAttachment
{
    NSArray<NSValue*>* rangesForAttachment = [self rangesForAttachment:textAttachment];
    
    [rangesForAttachment enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSValue * _Nonnull rangeObject, NSUInteger idx, BOOL * _Nonnull stop) {
        // invalidate the layout for the range
        [self invalidateLayoutForCharacterRange:rangeObject.rangeValue actualCharacterRange:NULL];
        // also need to trigger re-display or already visible images might not get updated
        [self invalidateDisplayForCharacterRange:rangeObject.rangeValue];
    }];
}

- (NSArray<NSValue*>*) rangesForAttachment:(NSTextAttachment*)textAttachment
{
    NSMutableArray<NSValue*>* rangesForAttachment = [NSMutableArray new];
    
    [self.textStorage enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.textStorage.length) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if (value == textAttachment) {
            [rangesForAttachment addObject:[NSValue valueWithRange:range]];
        }
    }];
    
    return rangesForAttachment;
}

@end
