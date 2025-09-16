// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMUtils.h"

@implementation AMUtils
+ (UIColor *)colorWithOctString:(NSString *)stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    NSArray * components = [cString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"(,)"]];
    if ([components count] < 3) return [UIColor clearColor];

    NSString *rString = components[0];
    NSString *gString = components[1];
    NSString *bString = components[2];

    NSString *alpha = @"1.0";
    if (components.count>=4) {
        alpha = components[3];
    }
    
    return [UIColor colorWithRed:((float) [rString integerValue] / 255.0f)
                           green:((float) [gString integerValue] / 255.0f)
                            blue:((float) [bString integerValue] / 255.0f)
                           alpha:alpha.floatValue];
}

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor clearColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0x"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6 && [cString length] != 8) return [UIColor clearColor];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    CGFloat alpha = 1.0;
    if ([cString length] == 8) {
        range.location = 6;
        NSString *aString = [cString substringWithRange:range];
        unsigned int a;
        [[NSScanner scannerWithString:aString] scanHexInt:&a];
        alpha = ((float) a / 255.0f);
    }
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:alpha];
}
+ (UIColor *)colorWithString:(NSString *)stringToConvert
{
    NSString *cString = [stringToConvert lowercaseString];
    if ([cString hasPrefix:@"rgb"]) {
        NSString *trimString = [cString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"rgba()"]];
        return [self colorWithOctString:trimString];
    } else if([cString hasPrefix:@"0x"] || [cString hasPrefix:@"#"]) {
        return [self colorWithHexString:cString];
    }

    UIColor *color = [UIColor clearColor];
    NSDictionary *colorMap = @{@"grey":[UIColor grayColor],
                               @"gray":[UIColor grayColor],
                               @"darkgray":[UIColor darkGrayColor],
                               @"lightgray":[UIColor lightGrayColor],
                               @"black":[UIColor blackColor],
                               @"white":[UIColor whiteColor],
                               @"red":[UIColor redColor],
                               @"blue":[UIColor blueColor],
                               @"green":[UIColor greenColor],
                               @"yellow":[UIColor yellowColor],
                               @"brown":[UIColor brownColor],
                               @"orange":[UIColor orangeColor]};
    if (colorMap[cString]) {
        color = colorMap[cString];
    }
    return color;
}
+ (id)JSONValue:(id)object {
    if ([object isKindOfClass:[NSString class]]) {
        NSData* data = [object dataUsingEncoding:NSUTF8StringEncoding];
        if (data) {
            return [self JSONValue:data];
        } else {
            return nil;
        }
    } else if ([object isKindOfClass:[NSData class]]) {
        id result = nil;
        @try {
            NSError* error = nil;
            result = [NSJSONSerialization JSONObjectWithData:object options:0 error:&error];
            if (result == nil) {
                NSLog(@"-JSONValue failed. Error is: %@", error);
            }
        } @catch (NSException *exception) {
            NSLog(@"-JSONValue failed. Exception: %@", exception);
        }
        return result;
    } else {
        return nil;
    }
}
+ (CGSize)screenXY {
    static CGSize size;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat width = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        CGFloat height = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        size = CGSizeMake(width, height);
    });
    return size;
}
+ (CGFloat)fontValue:(NSString*)fontStr {
    if (!fontStr.length || [fontStr isEqualToString:@"(null)"]) {
        return 0;
    }
    
    CGFloat fontFloatValue = [fontStr floatValue];
    
    CGFloat ratio = 1;
    
    CGFloat scale = 1;
    scale = [self screenXY].width / 375.f;
    if ([fontStr hasSuffix:@"sip"]) {
        fontFloatValue *= scale;
    }
    else if ([fontStr hasSuffix:@"sp"]) {
        fontFloatValue *= (scale*ratio);
    }
    else if ([fontStr hasSuffix:@"np"]) {
        fontFloatValue *= ratio;
    }
    else if ([fontStr hasSuffix:@"pt"]) {
        fontFloatValue *= ratio;
    }
    
    
    else if ([fontStr hasSuffix:@"dip"]) {
        fontFloatValue *= 1;
    }
    else if ([fontStr hasSuffix:@"pit"]) {
        fontFloatValue *= 1;
    }
    else if ([fontStr hasSuffix:@"apx"]) {
        fontFloatValue *= (1.f/[UIScreen mainScreen].scale);
    }
    else {
        if ([fontStr hasSuffix:@"px"]) {
            fontFloatValue *= 1;
        }
        else if ([fontStr hasSuffix:@"rpx"]) {
            fontFloatValue *= ([self screenXY].width /750.f);
        }
    }
    
    return fontFloatValue;
}
@end

@implementation UIColor (AMUtils)

+ (instancetype)colorWithHex_ant_mark:(NSUInteger)hexColor {
    NSInteger a,r,g,b;
    a = (hexColor & 0xFF000000) >> 24;
    r = (hexColor & 0x00FF0000) >> 16;
    g = (hexColor & 0x0000FF00) >>  8;
    b = (hexColor & 0x000000FF) >>  0;
    if (a == 0) {
        a = 0xFF;
    }
    return [UIColor colorWithRed:1.0 * r / 255
                           green:1.0 * g / 255
                            blue:1.0 * b / 255
                           alpha:1.0 * a / 255];
}
+ (instancetype)colorWithHex_ant_mark_alpha:(NSUInteger)hexColor {
    NSInteger a,r,g,b;
    a = (hexColor & 0xFF000000) >> 24;
    r = (hexColor & 0x00FF0000) >> 16;
    g = (hexColor & 0x0000FF00) >>  8;
    b = (hexColor & 0x000000FF) >>  0;
    return [UIColor colorWithRed:1.0 * r / 255
                           green:1.0 * g / 255
                            blue:1.0 * b / 255
                           alpha:1.0 * a / 255];
}
+ (instancetype)colorWithCSSString_ant_mark_alpha:(NSString *)cssColor {
    cssColor = [cssColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([cssColor hasPrefix:@"#"]) {
        NSScanner *scaner = [[NSScanner alloc] initWithString:[cssColor substringFromIndex:1]];
      
        if (cssColor.length == 9) {
            NSUInteger value = 0;
            [scaner scanHexInt:(uint *)&value];
            
            // RGBA to ARGB
            NSInteger a = value & 0xFF;
            value = (value >> 8) | (a << 24);
            return [self colorWithHex_ant_mark_alpha:value];
        }
        if (cssColor.length == 7) {
            NSUInteger value = 0;
            [scaner scanHexInt:(uint *)&value];
            return [self colorWithHex_ant_mark:value];
        }
        else if (cssColor.length == 5) {
            NSUInteger value = 0;
            [scaner scanHexInt:(uint *)&value];
            NSInteger a,r,g,b;
            r = (value & 0xF000) >> 12;
            g = (value & 0x0F00) >>  8;
            b = (value & 0x00F0) >>  4;
            a = (value & 0x000F) >>  0;
            value = ((a * 0x11) << 24) | ((r * 0x11) << 16) | ((g * 0x11) << 8) | ((b * 0x11) << 0);
            return [self colorWithHex_ant_mark_alpha:value];
        }
        else if (cssColor.length == 4) {
            NSUInteger value = 0;
            [scaner scanHexInt:(uint *)&value];
            NSInteger r,g,b;
            r = (value & 0x0F00) >>  8;
            g = (value & 0x00F0) >>  4;
            b = (value & 0x000F) >>  0;
            value = ((r * 0x11) << 16) | ((g * 0x11) << 8) | ((b * 0x11) << 0);
            return [self colorWithHex_ant_mark:value];
        }
    }
    return nil;
}
+ (instancetype)colorWithCSSString_ant_mark:(NSString *)cssColor
{
    cssColor = [cssColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([cssColor hasPrefix:@"#"]) {
        NSScanner *scaner = [[NSScanner alloc] initWithString:[cssColor substringFromIndex:1]];
        if (cssColor.length == 9) {
            NSUInteger value = 0;
            [scaner scanHexInt:(uint *)&value];
            
            // RGBA to ARGB
            NSInteger a = value & 0xFF;
            value = (value >> 8) | (a << 24);
            return [self colorWithHex_ant_mark:value];
        }
        if (cssColor.length == 7) {
            NSUInteger value = 0;
            [scaner scanHexInt:(uint *)&value];
            return [self colorWithHex_ant_mark:value];
        }
        else if (cssColor.length == 5) {
            NSUInteger value = 0;
            [scaner scanHexInt:(uint *)&value];
            NSInteger a,r,g,b;
            r = (value & 0xF000) >> 12;
            g = (value & 0x0F00) >>  8;
            b = (value & 0x00F0) >>  4;
            a = (value & 0x000F) >>  0;
            value = ((a * 0x11) << 24) | ((r * 0x11) << 16) | ((g * 0x11) << 8) | ((b * 0x11) << 0);
            return [self colorWithHex_ant_mark:value];
        }
        else if (cssColor.length == 4) {
            NSUInteger value = 0;
            [scaner scanHexInt:(uint *)&value];
            NSInteger r,g,b;
            r = (value & 0x0F00) >>  8;
            g = (value & 0x00F0) >>  4;
            b = (value & 0x000F) >>  0;
            value = ((r * 0x11) << 16) | ((g * 0x11) << 8) | ((b * 0x11) << 0);
            return [self colorWithHex_ant_mark:value];
        }
    }
    return nil;
}

- (instancetype)transparentColor_ant_mark
{
    CGFloat r,g,b,a;
    if ([self getRed:&r green:&g blue:&b alpha:&a]) {
        return [UIColor colorWithRed:r green:g blue:b alpha:0];
    } else if ([self getWhite:&r alpha:&a]) {
        return [UIColor colorWithWhite:r alpha:0];
    } else {
        return [UIColor clearColor];
    }
}

@end

@implementation UIImage (AMUtils)

+ (instancetype)imageWithGradient_ant_mark:(NSArray<UIColor *> *)colors
                                 locations:(NSArray<NSNumber *> *)locations
                                      size:(CGSize)size
                                 direction:(CGFloat)direction {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSMutableArray *arr = [NSMutableArray array];
    [colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [arr addObject:(id)obj.CGColor];
    }];
    
    CGFloat stackLocs[10] = {0};
    CGFloat *locs = stackLocs;
    BOOL needMalloc = locations.count > 10;
    if (locations.count) {
        locs = needMalloc ? malloc(locations.count * sizeof(CGFloat)) : stackLocs;
        [locations enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            locs[idx] = [obj doubleValue];
        }];
    }
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)arr, locs);
    
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointZero;
    
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: rect];
    UIBezierPath* rectangleRotatedPath = [rectanglePath copy];
    CGAffineTransform transform = CGAffineTransformMakeRotation(-direction / 180 * M_PI + M_PI_2);
    [rectangleRotatedPath applyTransform: transform];
    CGRect rectangleBounds = CGPathGetPathBoundingBox(rectangleRotatedPath.CGPath);
    transform = CGAffineTransformInvert(transform);
    
    startPoint = CGPointApplyAffineTransform(CGPointMake(CGRectGetMinX(rectangleBounds), CGRectGetMidY(rectangleBounds)), transform);
    endPoint = CGPointApplyAffineTransform(CGPointMake(CGRectGetMaxX(rectangleBounds), CGRectGetMidY(rectangleBounds)), transform);
    
    CGContextSaveGState(context);
    CGContextClipToRect(context, rect);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGColorSpaceRelease(space);
    CGGradientRelease(gradient);
    if (needMalloc) {
        free(locs);
    }
    
    return image;
}

+ (instancetype)imageNamed_ant_mark:(NSString *)name
{
    static dispatch_once_t onceToken;
    static NSBundle *bundle = nil;
    dispatch_once(&onceToken, ^{
        NSBundle *main = [NSBundle mainBundle];
        NSString *resourcePath = [[NSBundle bundleForClass:[AMUtils class]] pathForResource:@"AntMarkdown" ofType:@"bundle"];
        if (!resourcePath) {
            resourcePath = [main pathForResource:@"AntMarkdown"
                                          ofType:@"bundle"];
        }
        bundle = main;
        if (resourcePath) {
            bundle = [NSBundle bundleWithPath:resourcePath] ?: main;
        }
    });
    UIImage * image = [self imageNamed:name
                              inBundle:bundle
         compatibleWithTraitCollection:nil] ?: [self imageNamed:[NSString stringWithFormat:@"AntMarkdown.bundle/%@", name]];
    return image;
}
+ (instancetype)imageNamed_ant_bundle:(NSString *)bundlePath name:(NSString*)name
{
    
    NSString* resourcePath = [[NSBundle mainBundle] pathForResource:bundlePath ofType:@"bundle"];
    if (!resourcePath) {
        return nil;
    }
    NSBundle* bundle = [NSBundle bundleWithPath:resourcePath];
    UIImage *image = [UIImage imageNamed:name
                                inBundle:bundle
           compatibleWithTraitCollection:nil];
    return image;
}
@end

@implementation NSArray (AMUtils)

- (NSArray<id> *)mapWithBlock_ant_mark:(id  _Nonnull (NS_NOESCAPE ^)(id _Nonnull))block {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [arr addObject:block(obj)];
    }];
    return [arr copy];
}

@end

@implementation NSParagraphStyle (AMUtils)

- (BOOL)isEqualToDiffableObject:(NSParagraphStyle *)object
{
    if (![object isKindOfClass:self.class]) {
        return NO;
    }
    
    if (![self isEqual:object]) {
        NSMutableParagraphStyle *style = [self mutableCopy];
        style.lineBreakMode = object.lineBreakMode;
        return [style isEqual:object];
    }
    return YES;
}

@end

@implementation NSDictionary (AMUtils)

- (BOOL)includesDictionary_ant_mark:(NSDictionary *)otherDictionary
{
    if (otherDictionary.count > self.count) {
        return NO;
    }
    __block BOOL included = YES;
    [otherDictionary enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent
                                             usingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
        id obj = self[key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSDictionary * dict = obj;
            if ([dict isKindOfClass:[NSDictionary class]]) {
                if (![dict includesDictionary_ant_mark:value]) {
                    included = NO;
                    *stop = YES;
                }
            } else {
                included = NO;
                *stop = YES;
            }
        } else {
            if ([obj conformsToProtocol:@protocol(AMDiffable)] && [value conformsToProtocol:@protocol(AMDiffable)]) {
                if (![(id<AMDiffable>)obj isEqualToDiffableObject:(id<AMDiffable>)value]) {
                    included = NO;
                    *stop = YES;
                }
            }
            else if (![obj isEqual:value]) {
                included = NO;
                *stop = YES;
            }
        }
    }];
    return included;
}
- (NSString *)stringForKey_ap:(id)aKey {
    return [self stringForKey_ap:aKey defaultValue:@""];
}
- (NSString *)stringOrEmptyStringForKey_ap:(id)akey {
    return [self stringForKey_ap:akey defaultValue:@""];
}
- (NSString *)stringForKey_ap:(id)aKey defaultValue:(NSString *)defaultValue {
    id object = [self objectForKey:aKey];
    if (!object || object == [NSNull null]) {
        return defaultValue;
    }
    if ([object isKindOfClass:[NSString class]]) {
        return (NSString *)object;
    }
    return [object description];
}

@end
