//
//  ViewController.m
//  JavascriptBridge
//
//  Created by Allen Li on 2018/6/2.
//  Copyright © 2018年 Allen Li. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "WKJSBridge.h"

@interface ViewController ()

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKJSBridge *bridge;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self initWebView];
  [self loadExamplePage:self.webView];
  [self.bridge registerHandler:@"common" handler:^(BridgeMessage *msg) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"JS回调OC" message:msg.parameters[@"title"] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
    NSDictionary *result = @{@"result": @"result"};
    [msg callback:result];
  }];
}

- (void)initWebView {
  WKWebViewConfiguration *config = [WKWebViewConfiguration new];
  config.preferences = [WKPreferences new];
  config.preferences.minimumFontSize = 16;
  config.preferences.javaScriptEnabled = YES;
  config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
  WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) configuration:config];
  
  self.webView = webView;
  [self.view addSubview:webView];
  
  self.bridge = [[WKJSBridge alloc] init];
  [self.bridge bridgeForWebView:self.webView];
}

- (void)loadExamplePage: (WKWebView*)webView {
  NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
  NSString *appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
  NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];
  [webView loadHTMLString:appHtml baseURL:baseURL];
}

@end
