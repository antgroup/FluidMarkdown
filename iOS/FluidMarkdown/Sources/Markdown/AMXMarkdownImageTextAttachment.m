// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMXMarkdownImageTextAttachment.h"

@interface AMXMarkdownImageTextAttachment ()
{
    BOOL _isImageLoaded_ap;
    NSURLSessionDataTask* _downloadTask;
    NSURL       * _imageURL;
}

@property(nonatomic,assign)CGSize imgSize;

@property(nonatomic,assign)BOOL isDownloading;

@end

@implementation AMXMarkdownImageTextAttachment

- (NSTextAttachment *)buildWithURL:(NSURL *)url
                             title:(nullable NSString *)title
                            styles:(AMTextStyles *)styles;
{
    return [[AMXMarkdownImageTextAttachment alloc] initWithImageURL:url];
}

- (void)downloadImage:(NSURL *)imageURL 
           completion:(void(^)(NSError * _Nullable error, NSData * _Nullable data))block {
    // Not a file URL and no download task in progress: use an URL-data-task to get the data
    [self downloadImage];
}

- (void)downloadImage
{
    if (self.isDownloading) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    self.isDownloading = YES;
    _downloadTask = [NSURLSession.sharedSession dataTaskWithURL:self.imageURL
                                              completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if ((error == nil) && (data.length > 0)) {
            UIImage* image = [UIImage imageWithData:data];
            [weakSelf setImageWithImage:image];
            if (weakSelf.imgDelegate &&
                [weakSelf.imgDelegate respondsToSelector:@selector(onImageLoadFinish:url:)]) {
                [weakSelf.imgDelegate onImageLoadFinish:[UIImage imageWithData:data] url:[weakSelf.imageURL absoluteString]];
            }
        }
        
        self->_downloadTask = nil;
        self.isDownloading = NO;
    }];
    
    [_downloadTask resume];
}

- (void)setImageWithImage:(UIImage *)image {
    if (!image) {
        return;
    }
    CGSize currentImageSize = (self.image == nil) ? CGSizeZero : self.image.size;
    self.image = image;
    self.imgSize = self.image.size;
    if (self.image != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!CGSizeEqualToSize(self.image.size, currentImageSize)) {
                 // The layout needs to be refreshed
                [self.textContainer.layoutManager setNeedsLayoutForAttachment:self];
            } else {
                // The image display should be refreshed
                [self.textContainer.layoutManager setNeedsDisplayForAttachment:self];
            }
        });
    }
    self.isImageLoaded = YES;
}

- (void)refreshImageIfNeed {
    if ([self.imgDelegate respondsToSelector:@selector(getImageFromCacheIfExist:)]) {
        UIImage *img = [self.imgDelegate getImageFromCacheIfExist:[self.imageURL absoluteString]];
        if (img) {
            self.image = img;
            self.imgSize = self.image.size;
            self.isImageLoaded = YES;
        }
    }
}

@end
