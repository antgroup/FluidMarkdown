// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMIconAttachment.h"

#import "CMImageTextAttachment.h"
#import "AMImageTextAttachment.h"
#import <CoreText/CoreText.h>
#import "AMUtils.h"

#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h> // For UTType...
#endif

@implementation AMIconAttachment

{
    __weak NSTextContainer *_textContainer;
    NSURLSessionDataTask* _downloadTask;
    NSURL       * _imageURL;
    CGSize      _imageSize;
    UIImage* _iconImage;
    BOOL _isLoaded;
}
- (instancetype)init {
    self = [self initWithData:nil ofType:nil];
    if (self) {
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
    
    return [self isEqualToAttachment:(AMIconAttachment *)object];
}

- (BOOL)isEqualToAttachment:(AMIconAttachment *)attach
{
    return [self.path isEqual:attach.path] && [self.text isEqualToString:attach.text];
}
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer
                      proposedLineFragment:(CGRect)lineFrag
                             glyphPosition:(CGPoint)position
                            characterIndex:(NSUInteger)charIndex {
    _textContainer = textContainer;
    NSInteger height = _attachmentSize.height > 0 ? _attachmentSize.height : _baseFont.ascender;
    return CGRectMake(0, (_baseFont.capHeight - height) / 2.0 , height + _marginLeft + _marginRight, height);
}
- (void)imageResize:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
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
- (void) setImageWithUIImage:(UIImage*)image
{
    self.image = image;
    
    CGSize currentImageSize = self.image.size;
    
#if TARGET_OS_IPHONE
    _iconImage = image;
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
}
+ (BOOL)isNetworkPath:(NSString *)path {
    return [path hasPrefix:@"http://"] || [path hasPrefix:@"https://"];
}
- (void)loadLocalImage:(NSString *)path
            completion:(void(^)(NSError * _Nullable error, UIImage * _Nullable image))block
{
    UIImage *image = nil;
    NSError *error = nil;
    NSString* iOSPath = nil;
    if (!path || path.length == 0)
        return;
    if ([path hasPrefix:@"localResource:"]) {
        // eg: "localResource://loadImage?Android=android-phone-wallet-socialcardwidget$com.alipay.mobile.socialcardwidget$feedback&iOS=HomeCard.bundle/more.png&Harmony=cardres/haibao.jpg"
        NSRange range = [path rangeOfString:@"?"];
        if (range.location == NSNotFound) {
            return;
        }
        NSString* localPath = [path substringFromIndex:range.location];
        NSArray* strArray = [localPath componentsSeparatedByString:@"&"];
        
        for (NSString* subStr in strArray) {
            NSRange subrange = [subStr rangeOfString:@"="];
            if (subrange.location == NSNotFound) {
                continue;
            }
            NSString* prefix = [subStr substringToIndex:subrange.location];
            if ([prefix isEqualToString:@"iOS"]) {
                iOSPath = [subStr substringFromIndex:subrange.location + 1];
            }
        }
    } else {
        iOSPath = path;
    }
    
    if (!iOSPath) {
        return;
    }
    NSRange iOSRange = [iOSPath rangeOfString:@"/"];
    if (iOSRange.location == NSNotFound) {
        return;
    }
 
    NSString *bundlePart = [iOSPath substringToIndex:iOSRange.location];
    NSString *imagePart = [iOSPath substringFromIndex:iOSRange.location + 1];
        
    image = [UIImage imageNamed_ant_bundle:bundlePart name:imagePart];
    
    if (image) {
        block(nil, image);
    } else {
        error = [NSError errorWithDomain:@"ImageLoader"
                                 code:404
                             userInfo:@{NSLocalizedDescriptionKey: @"Local image not found"}];
        block(error, nil);
    }
}
- (UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex
{
    if (!self.image && [NSThread isMainThread]) {
        if (!_isLoaded) {
            NSData *data = nil;
            if ([AMIconAttachment isNetworkPath:self.path]) {
                data = [[AMSimpleImageCache sharedCache] imageDataForURL:[NSURL URLWithString:self.path]];
            }
            if (data) {
                [self setImageWithData:data];
                _isLoaded = YES;
            } else {
                if ([AMIconAttachment isNetworkPath:self.path]) {
                    _imageURL = [NSURL URLWithString:self.path];
                    [self downloadImage:_imageURL
                             completion:^(NSError * _Nullable error, NSData * _Nullable data) {
                        if ((error == nil) && (data.length > 0)) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self setImageWithData:data];
                                _isLoaded = YES;
                            });
                        }
                    }];
                } else {
                    [self loadLocalImage:self.path completion:^(NSError * _Nullable error, UIImage * _Nullable image) {
                                            if ((error == nil) && image) {
                                                [self setImageWithUIImage:image];
                                                _isLoaded = YES;
                                            }
                    }];
                }
                
            }
            
        }
        
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageBounds.size.width, imageBounds.size.height), NO, 0.0);
        CGContextRef con = UIGraphicsGetCurrentContext();
        CGRect iconRect = CGRectMake(_marginLeft, 0, imageBounds.size.width - _marginLeft - _marginRight, imageBounds.size.height);
        if (_iconImage) {
            [self drawImage:con rect:iconRect];
        }
        if (self.text && ![self.text isEqualToString:@""]) {
            UILabel *label = [[UILabel alloc] initWithFrame:iconRect];
            label.backgroundColor = [UIColor clearColor];
            label.layer.masksToBounds = YES;
            label.textAlignment = _textAlignment;

            label.textColor = _textColor ? : [UIColor whiteColor];
            label.font = _boldText ? [UIFont boldSystemFontOfSize:_textSize] : [UIFont systemFontOfSize:_textSize];
            label.text = self.text;
            label.lineBreakMode = NSLineBreakByTruncatingTail;
            label.numberOfLines = 1;

            [label layoutIfNeeded];
            [label.layer renderInContext:con];
        }
        
        self.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return self.image;
}

-(void)drawImage:(CGContextRef)context rect:(CGRect)rect{
    CGContextSaveGState(context);
    CGContextClip(context);
    [_iconImage drawInRect:rect];
    CGContextRestoreGState(context);
}

- (void)setNeedsLayout
{
    NSLayoutManager *mgr = _textContainer.layoutManager;
    if (mgr) {
        [mgr setNeedsLayoutForAttachment:self];
    }
}

@end

