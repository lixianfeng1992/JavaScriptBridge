//
//  WKJSBridge.h
//  JavascriptBridge
//
//  Created by Allen Li on 2018/6/2.
//  Copyright © 2018年 Allen Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

typedef void (^HandleBlock)(NSDictionary *msg);

@interface WKJSBridge : NSObject

- (void)bridgeForWebView:(WKWebView*)webView;
- (void)registerHandler: (NSString *)handlerName handler: (HandleBlock)handler;
@end
