//
//  CMImageTextAttachment.h
//  CocoaMarkdown
//
//  Created by Jean-Luc on 10/05/2019.
//  Copyright © 2019 Indragie Karunaratne. All rights reserved.
//
@import Foundation;

#if TARGET_OS_IPHONE
@import UIKit;
#else
@import Cocoa;
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CMImageTextAttachment : NSTextAttachment
{
    @protected
    NSURL       * _imageURL;
    CGSize      _imageSize;
}
- (instancetype) initWithImageURL:(NSURL*)imageURL title:(NSString*)title size:(CGSize)size;
- (instancetype) initWithImageURL:(NSURL*)imageURL title:(NSString*)title;

- (instancetype) initWithImageURL:(NSURL*)imageURL;

@property (nonatomic, copy) NSString* altText;

@property (nonatomic, readonly) NSURL* imageURL;

@property (nonatomic, readonly, weak) NSTextContainer *textContainer;

@property (nonatomic, assign) BOOL isImageLoaded;

- (void)setImageWithData:(NSData *)imageData;

- (void)downloadImage:(NSURL *)imageURL
           completion:(void(^)(NSError * _Nullable error, NSData * _Nullable data))block;

- (BOOL)isEqualToAttachment:(CMImageTextAttachment *)attach;

- (NSString*)imageCaption;

@end

@interface NSLayoutManager (CMImageTextAttachment)

- (void) setNeedsDisplayForAttachment:(NSTextAttachment*)textAttachment;
- (void) setNeedsLayoutForAttachment:(NSTextAttachment*)textAttachment;

@end

NS_ASSUME_NONNULL_END
