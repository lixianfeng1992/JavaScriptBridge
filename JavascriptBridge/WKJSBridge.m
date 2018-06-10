//
//  WKJSBridge.m
//  JavascriptBridge
//
//  Created by Allen Li on 2018/6/2.
//  Copyright © 2018年 Allen Li. All rights reserved.
//

#import "WKJSBridge.h"

@interface WKJSBridge ()<WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>

@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, weak) UIProgressView *progressView;
@property (nonatomic, strong) NSMutableDictionary *handlerMap;

@end

@implementation WKJSBridge

- (instancetype)init {
  self = [super init];
  if (self != nil) {
    _handlerMap = [[NSMutableDictionary alloc] init];
  }
  
  return self;
}

- (void)bridgeForWebView:(WKWebView*)webView {
  _webView = webView;
  _webView.allowsBackForwardNavigationGestures = YES;
  _webView.navigationDelegate = self;
  
  [self addLoadingProgressBar];
  
  WKUserContentController *userContent = [[WKUserContentController alloc] init];
  _webView.configuration.userContentController = userContent;
  
  [_webView.configuration.userContentController addScriptMessageHandler:self name:@"WKJSBridge"];
}

- (void)registerHandler: (NSString *)handlerName handler: (HandleBlock)handler {
  if (handlerName) {
    [self.handlerMap setObject:handler forKey:handlerName];
  }
}

- (void)addLoadingProgressBar {
  UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 88, _webView.bounds.size.width, 5)];
  _progressView = progressView;
  [_webView addSubview:progressView];
  [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
  if ([keyPath isEqualToString:@"estimatedProgress"]) {
    _progressView.progress = [change[@"new"] floatValue];
    if (_progressView.progress == 1.0) {
      _progressView.hidden = YES;
    }
  }
}

#pragma WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
  NSDictionary *msgBody = message.body;
  if (msgBody) {
    BridgeMessage *bridgeMsg = [[BridgeMessage alloc] initWithDictionary:message.body];
    HandleBlock handler = [self.handlerMap objectForKey:msgBody[@"handler"]];
    
    if (bridgeMsg.callbackID && bridgeMsg.callbackID.length > 0) {
      __weak typeof(self)weakSelf = self;
      JSResponseCallback callback = ^(id resposeData) {
        [weakSelf injectMessageFunction:bridgeMsg.callbackFunction withActionId:bridgeMsg.callbackID withParams:resposeData];
      };
      
      [bridgeMsg setCallbackFunction:callback];
    }
    
    if (handler) {
      handler(bridgeMsg);
    }
  }
}

- (void)injectMessageFunction: (NSString *)msg withActionId: (NSString *)actionId withParams: (NSDictionary *)params {
  NSString *paramsString = [self _serializeMessageData:params];
  NSString *paramsJSString = [self _transcodingJavascriptMessage:paramsString];
  NSString *javascriptCommand = [NSString stringWithFormat:@"%@('%@', '%@');", msg, actionId, paramsJSString];
  if ([[NSThread currentThread] isMainThread]) {
    [self.webView evaluateJavaScript:javascriptCommand completionHandler:nil];
  } else {
    __strong typeof(self)strongSelf = self;
    dispatch_sync(dispatch_get_main_queue(), ^{
      [strongSelf.webView evaluateJavaScript:javascriptCommand completionHandler:nil];
    });
  }
}

// 字典JSON化
- (NSString *)_serializeMessageData:(id)message{
  if (message) {
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:message options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
  }
  return nil;
}
// JSON Javascript编码处理
- (NSString *)_transcodingJavascriptMessage:(NSString *)message
{
  //NSLog(@"dispatchMessage = %@",message);
  message = [message stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
  message = [message stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
  message = [message stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
  message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
  message = [message stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
  message = [message stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
  message = [message stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
  message = [message stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
  
  return message;
}

@end
