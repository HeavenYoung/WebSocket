//
//  WebSocketManager.h
//  WebSocket
//
//  Created by ott001 on 2018/8/24.
//  Copyright © 2018 OTT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket.h>

static NSString *const KlineDaily = @"KlineDaily";
static NSString *const KlineMonthly = @"KlineWeekly";
static NSString *const KlineWeekly = @"KlineWeekly";
static NSString *const KlineBaseInfo = @"baseInfo";

typedef NS_ENUM(NSInteger, WebSocketManagerState) {
    WSMS_CONNECTING   = 0,
    WSMS_OPEN         = 1,
    WSMS_CLOSING      = 2,
    WSMS_CLOSED       = 3,
};

@protocol WebSocketManagerDelegate <NSObject>

- (void)webSocketManagerDidReceivePong:(NSData *)pongPayload;

- (void)webSocketManagerDidReceiveMessage:(id)message;

- (void)webSocketManagerDidChangeState:(WebSocketManagerState)state;

@end

@interface WebSocketManager : NSObject

@property (nonatomic, assign, readonly) SRReadyState socketReadyState;

@property (nonatomic, weak) id <WebSocketManagerDelegate> delegate;

+ (instancetype)shareMananger;

- (void)openWebSocketWithUrlString:(NSString *)urlString;

- (void)configHeartBeatContent:(NSString *)heartBeatContent;

- (void)closeWebSocket;

- (void)sendData:(id)data;

@end
