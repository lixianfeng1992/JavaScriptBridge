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
  NSDictionary *msgBody = message.body;\
  HandleBlock handler = [self.handlerMap objectForKey:msgBody[@"handler"]];
  handler(msgBody[@"params"]);
}

@end
