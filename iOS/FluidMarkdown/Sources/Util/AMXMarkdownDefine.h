// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <AntMarkdown/AMUtils.h>
#ifndef AMXMarkdownDefine_h
#define AMXMarkdownDefine_h
#ifdef __OBJC__

#ifndef CARD_UI_PLUGINS_MARKDOWN_LOG_PURE_ATTRSTRING
#define CARD_UI_PLUGINS_MARKDOWN_LOG_PURE_ATTRSTRING 0
#endif

#ifdef PRODUCT_ZHIXIAOBAO
  #define kCPLGMarkDownEnable  1
#endif

#ifdef PRODUCT_ANZHENER
  #define kCPLGMarkDownEnable  0
#endif

#ifdef PRODUCT_WALLET
  #define kPaladinEnable  1
  #define kCPLGMarkDownEnable  1
#endif

#ifdef PRODUCT_WEALTH
  #define kCPLGMarkDownEnable  1
#endif

#ifdef PRODUCT_AIJK
  #define kCPLGMarkDownEnable  1
#endif


#import <Foundation/Foundation.h>


#define CPL_AIGC_BIZCODE  @"CPL-CHAT-LLM"

#define CPLLogInfo(format, ...) \
do { \
NSLog(@"[FluidMarkdown] %@", [NSString stringWithFormat:format, ##__VA_ARGS__]); \
} while(0)

#define kCUPLMarkdownTextFont            [UIFont systemFontOfSize:AUFVS(16.0)]
#define kCUPLMarkdownTextBoldFont        [UIFont boldSystemFontOfSize:AUFVS(16.0)]
#define kCUPLMarkdownCommonTextColor     [AMUtils colorWithString:@"#333333"]
#define kCUPLMarkdownTextFontSize        AUFVS(16.0)

#define kCUPLMarkdownTextLineHeight      AUFVS(25.0)


#define CPL_LOG_TAG (@"#CPL#")
#define cpl_log_i(format, ...) \
    NSLog(CPL_LOG_TAG, @"%s %@", __FUNCTION__, [NSString stringWithFormat:format, ##__VA_ARGS__])

#define cpl_log_d(format, ...) \
    NSLog(CPL_LOG_TAG, @"%s %@", __FUNCTION__, [NSString stringWithFormat:format, ##__VA_ARGS__])

#endif

#endif /* AMXMarkdownDefine_h */
