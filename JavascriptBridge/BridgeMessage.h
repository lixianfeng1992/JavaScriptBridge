//
//  BridgeMessage.h
//  JavascriptBridge
//
//  Created by Allen Li on 2018/6/10.
//  Copyright © 2018年 Allen Li. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^JSResponseCallback)(NSDictionary *responseData);

@interface BridgeMessage : NSObject

@property (nonatomic, copy, readonly) NSString * handler;
@property (nonatomic, copy, readonly) NSDictionary * parameters;
@property (nonatomic, copy, readonly) NSString * callbackID;
@property (nonatomic, copy, readonly) NSString  *callbackFunction;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
//- (void)setCallback: (JSResponseCallback)callback;
- (void)setCallbackFunction: (JSResponseCallback)callback;
- (void)callback: (NSDictionary *)result;

@end
