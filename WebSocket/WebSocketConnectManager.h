//
//  WebSocketConnectManager.h
//  WebSocket
//
//  Created by ott001 on 2018/8/27.
//  Copyright © 2018 OTT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket.h>
#import "WebSocketRequest.h"

@interface WebSocketConnectManager : NSObject

+ (instancetype)shareMananger;

- (void)openWebSocketWithUrlString:(NSString *)urlString;

- (void)closeWebSocket;

- (void)sendData:(id)data;

- (void)sendPing;

- (void)addWebSocketRequest:(WebSocketRequest *)request;

- (void)removeSocketRequest:(WebSocketRequest *)request;

@end
