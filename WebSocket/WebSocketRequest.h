//
//  WebSocketRequest.h
//  WebSocket
//
//  Created by ott001 on 2018/8/27.
//  Copyright © 2018 OTT. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const KlineDaily = @"KlineDaily";
static NSString *const KlineMonthly = @"KlineWeekly";
static NSString *const KlineWeekly = @"KlineWeekly";
static NSString *const KlineBaseInfo = @"baseInfo";

typedef void (^Socketresponse) (id message) ;

@interface WebSocketRequest : NSObject

@property (nonatomic, copy, readonly) NSString *typeValue;

- (instancetype)initWithType:(NSString *)type heartBeatFrequence:(NSTimeInterval)frequence response:(Socketresponse)message;

- (void)parseMessage:(id)message;

- (void)start;

- (void)end;

@end
