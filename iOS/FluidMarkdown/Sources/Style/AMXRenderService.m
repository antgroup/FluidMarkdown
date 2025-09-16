// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMXRenderService.h"
@interface AMXMarkdownExtendEngine : NSObject
{
    @private
    dispatch_semaphore_t _configMapLock;
}
@property (nonatomic, strong) NSMutableDictionary *styleConfigMap;
-(void)setCustomStyleWithId:(AMXMarkdownStyleConfig*)styleConfig styleId:(NSString*)styleId;
-(AMXMarkdownStyleConfig*)getStyleConfigWithId:(NSString*)styleId;
@end

@implementation AMXMarkdownExtendEngine
-(instancetype)init {
    if (self = [super init]) {
        _configMapLock = dispatch_semaphore_create(1);
        _styleConfigMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)setCustomStyleWithId:(AMXMarkdownStyleConfig*)styleConfig styleId:(NSString*)styleId {
    dispatch_semaphore_wait(self->_configMapLock, DISPATCH_TIME_FOREVER);
    self.styleConfigMap[styleId] = styleConfig;
    dispatch_semaphore_signal(self->_configMapLock);
}
-(AMXMarkdownStyleConfig*)getStyleConfigWithId:(NSString*)styleId {
    dispatch_semaphore_wait(self->_configMapLock, DISPATCH_TIME_FOREVER);
    AMXMarkdownStyleConfig* config = self.styleConfigMap[styleId];
    dispatch_semaphore_signal(self->_configMapLock);
    return config;
}
@end
@interface AMXRenderService()
@property (nonatomic, strong)AMXMarkdownExtendEngine* extendEngine;
@end
@implementation AMXRenderService
+ (instancetype)shared {
    static AMXRenderService *_shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = AMXRenderService.new;
    });
    return _shared;
}
-(instancetype)init {
    self = [super init];
    if (self) {
        self.extendEngine = [[AMXMarkdownExtendEngine alloc] init];
    }
    return self;
}
-(void)setMarkdownStyleWithId:(AMXMarkdownStyleConfig*)styleConfig styleId:(NSString*)styleId
{
    [self.extendEngine setCustomStyleWithId:styleConfig styleId:styleId];
}
-(AMXMarkdownStyleConfig*)getMarkdownStyleWithId:(NSString*)styleId {
    return [self.extendEngine getStyleConfigWithId:styleId];
}
@end
