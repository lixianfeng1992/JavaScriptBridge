//
//  BridgeMessage.m
//  JavascriptBridge
//
//  Created by Allen Li on 2018/6/10.
//  Copyright © 2018年 Allen Li. All rights reserved.
//

#import "BridgeMessage.h"

@interface BridgeMessage ()

@property (nonatomic, copy) JSResponseCallback callback;

@end

@implementation BridgeMessage

- (instancetype)initWithDictionary:(NSDictionary *)dict {
  self = [super init];
  if (self != nil) {
    _handler = dict[@"handler"];
    _parameters = dict[@"parameters"];
    _callbackID = dict[@"callbackId"];
    _callbackFunction = dict[@"callbackFunction"];
  }
  
  return self;
}

- (void)setCallbackFunction:(JSResponseCallback)callback {
  _callback = callback;
}

- (void)callback:(NSDictionary *)result {
  _callback(result);
}

@end
