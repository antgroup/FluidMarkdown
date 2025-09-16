// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <pthread/pthread.h>

#ifndef CLSSTR
#define CLSSTR(cls) (((void)(NO && ((void)NSStringFromClass(cls.class), NO)), @# cls))
#endif

#ifndef SELSTR
#define SELSTR(sel) (((void)(NO && ((void)NSStringFromSelector(sel), NO)), @# sel))
#endif

#ifndef KEYPATH
#define KEYPATH(OBJ, PATH) (((void)(NO && ((void)(((typeof(OBJ))nil).PATH), NO)), @# PATH))
#endif

#ifndef weakify
#define weakify(OBJ) keywordify __weak typeof(OBJ) weak##OBJ = OBJ;
#endif

#ifndef strongify
#define strongify(OBJ) keywordify __strong typeof(weak##OBJ) OBJ = weak##OBJ;
#endif

#ifndef strongifyOrReturn
#define strongifyOrReturn(OBJ) \
    keywordify \
    __strong typeof(weakSelf) OBJ = weakSelf;\
    if (!OBJ) { \
        return; \
    }
#endif


#if defined(DEBUG) && !defined(NDEBUG)
#define keywordify autoreleasepool {}
#else
#define keywordify try {} @catch (...) {}
#endif

#ifndef AMLogDebug
#define AMLogDebug(log, ...) NSLog(@"[AntMarkdown] " log, __VA_ARGS__)
#endif

static inline void dispatch_async_on_main_queue(void (^block)()) {
    if(!block) return;
    dispatch_async(dispatch_get_main_queue(), block);
}

static inline void dispatch_sync_on_main_queue(void (^block)()) {
    if(!block) return;

    if (pthread_main_np()) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

static inline bool dispatch_is_main_queue() {
    return pthread_main_np() != 0;
}

static inline void delayRun(NSTimeInterval delayTime,dispatch_block_t _Nullable block){
    if(!block) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        block();
    });

}
static inline  void APTMainCall(NSInteger bizType, const char* _Nullable tag, double delayTime, NSOperationQueuePriority priority, dispatch_block_t _Nullable block)
{
    assert(block != nil);
    assert(delayTime >= 0 && delayTime < 3600 * 24 * 7);
    
    do
    {
        static long count = 0;
        static long lastTime = 0;
        ++count;
        if(count == 1)
        {
            lastTime = time(0);
        }
        else
        {
            if(count >= 200)
            {
                long dt = time(0) - lastTime;
                if(dt < 60 * 10)
                {
                    if(count == 200)
                    {
                        NSLog(@"#THM %@", @"APTMainCall-omit...");
                    }
                    break;
                }
                else
                {
                    lastTime = time(0);
                    count = 0;
                }
            }
        }
        NSLog(@"#THM APTMainCall-%d,%s,%lf,%d", (int)bizType, tag?tag:"", delayTime, (int)priority);
    }while (0);
    
    
    if(delayTime > 0)
    {
        if(delayTime >= 1000000)
        {
            delayTime /= NSEC_PER_SEC;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
    }
    else
    {
        if ([NSThread isMainThread])
        {
            block();
            return;
        }
        dispatch_async(dispatch_get_main_queue(), block);
    }
}
static inline CGFloat AUCommonUIGetScreenWidthForPortrait()
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    return MIN(size.width, size.height);
}
static inline CGFloat AUUIGetOnePixel()
{
    static CGFloat onePx = 1.0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        onePx = onePx/[UIScreen mainScreen].scale;
        if(onePx == 0){
            onePx = 1.0;
        }
    });
    return onePx;
}
static inline CGFloat AUFVS(CGFloat value) {
    static dispatch_once_t onceToken;
    static CGFloat scale;
    
    dispatch_once(&onceToken, ^{
        scale = AUCommonUIGetScreenWidthForPortrait() / 375;
    });
  
     
    CGFloat px = value * scale;
    
    long new = floorf( px / AUUIGetOnePixel());
    //不相等取大值
    if(fabs(new * AUUIGetOnePixel() - px) > 0.00001){
       new++;
    }
    
    //NSLog(@"Fitting :%lf,%lf", value,0.10909 +  1.10909 * value);
    
    return (new * AUUIGetOnePixel());
}


static CGFloat AMScale(void) {
    static dispatch_once_t onceToken;
    static CGFloat scale = 1;
    dispatch_once(&onceToken, ^{
        scale = [UIScreen mainScreen].scale;
    });
    return scale;
}

static inline CGFloat AMFloor(CGFloat value) {
    return floor(value * AMScale()) / AMScale();
}

static inline CGFloat AMCeil(CGFloat value) {
    return ceil(value * AMScale()) / AMScale();
}

static inline CGSize AMSize(CGFloat width, CGFloat height) {
    return CGSizeMake(AMCeil(width), AMCeil(height));
}

static inline CGSize AMSizeIntegral(CGSize size) {
    return CGSizeMake(AMCeil(size.width), AMCeil(size.height));
}

static inline CGRect AMRectIntegral(CGRect rect) {
    return CGRectMake(AMFloor(rect.origin.x), AMFloor(rect.origin.y), AMCeil(rect.size.width), AMCeil(rect.size.height));
}
static inline void AMUIGraphicsBeginImageContextWithOptions(CGSize size, BOOL opaque, CGFloat scale) {
    if (@available(iOS 17.0, *)) {
        if (size.width <= 0 || size.height <= 0) {
            CGSize s = CGSizeMake(size.width > 0 ? size.width : 0.01, size.height > 0 ? size.height : 0.01);
            UIGraphicsBeginImageContextWithOptions(s, opaque, scale);
        } else {
            UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
        }
    } else {
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
    }
}

NS_ASSUME_NONNULL_BEGIN

@interface AMUtils : NSObject
+ (UIColor *)colorWithString:(NSString *)stringToConvert;
+ (id)JSONValue:(id)object;
+ (CGFloat)fontValue:(NSString*)fontStr;
@end

@interface UIColor (AMUtils)

// ARGB 格式
+ (instancetype)colorWithHex_ant_mark:(NSUInteger)ARGB __attribute__((const));

+ (instancetype)colorWithHex_ant_mark_alpha:(NSUInteger)ARGB __attribute__((const));

/// #RRGGBB #RRGGBBAA #RGB #RGBA
+ (nullable instancetype)colorWithCSSString_ant_mark:(NSString *)cssColor __attribute__((const));

+ (instancetype)colorWithCSSString_ant_mark_alpha:(NSString *)cssColor
__attribute__((const));

- (instancetype)transparentColor_ant_mark __attribute__((const));;

@end

@interface UIImage (AMUtils)


/// create a image with gradient
/// - Parameters:
///   - colors: gradient value
///   - locations: gradient location
///   - size: image size
///   - direction: gradient angle，0  is from top to bottom，clockwise
+ (instancetype)imageWithGradient_ant_mark:(NSArray <UIColor *> *)colors
                                 locations:(nullable NSArray <NSNumber *> *)locations
                                      size:(CGSize)size
                                 direction:(CGFloat)direction;

+ (instancetype)imageNamed_ant_mark:(NSString *)name;
+ (instancetype)imageNamed_ant_bundle:(NSString *)bundlePath name:(NSString*)name;

@end

@interface NSArray<ObjectType> (AMUtils)

- (NSArray<id> *)mapWithBlock_ant_mark:(id (NS_NOESCAPE ^)(ObjectType obj))block __attribute__((const));

@end

@protocol AMDiffable <NSObject>

@required
- (BOOL)isEqualToDiffableObject:(nullable id<AMDiffable>)object;

@end

@interface NSParagraphStyle (AMUtils) <AMDiffable>
@end

@interface NSDictionary<Key, Value> (AMUtils)

- (BOOL)includesDictionary_ant_mark:(NSDictionary<Key, Value> *)otherDictionary;
- (NSString *)stringForKey_ap:(id)aKey;
- (NSString *)stringOrEmptyStringForKey_ap:(id)akey ;
- (NSString *)stringForKey_ap:(id)aKey defaultValue:(NSString *)defaultValue;

@end
NS_ASSUME_NONNULL_END
