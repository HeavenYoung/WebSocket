//
//  WebSocketConnectManager.m
//  WebSocket
//
//  Created by ott001 on 2018/8/27.
//  Copyright © 2018 OTT. All rights reserved.
//

#import "WebSocketConnectManager.h"

@interface WebSocketConnectManager () <SRWebSocketDelegate>

@property (nonatomic, strong) SRWebSocket *socket;

@property (nonatomic, copy) NSString *urlString;

@property (nonatomic, strong) NSMutableDictionary *requestDic;

@end

@implementation WebSocketConnectManager

+ (instancetype)shareMananger {
    
    static WebSocketConnectManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WebSocketConnectManager alloc] init];
    });
    return instance;
}

- (void)openWebSocketWithUrlString:(NSString *)urlString {

    if (self.socket) {
        return;
    }
    
    if (!urlString) {
        return;
    }
    
    self.urlString = urlString;
    
    self.socket = [[SRWebSocket alloc] initWithURLRequest:
                   [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    
    self.socket.delegate = self;
    
    [self.socket open];
    
    NSLog(@"----------- 启动 socket -----------");
}

- (void)closeWebSocket {
    
    if (self.socket){
        [self.socket close];
        self.socket = nil;
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"----------- socket 连接成功 -----------");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    
    if (webSocket == self.socket) {
        NSLog(@"----------- socket 连接失败 -----------");
        self.socket = nil;
    
        [self reConnect];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
    if (webSocket == self.socket) {
        NSLog(@"----------- socket连接断开 -----------");
        
        NSLog(@"关闭连接，code:%ld,reason:%@,wasClean:%d",(long)code,reason,wasClean);
        
        [self closeWebSocket];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    
    NSLog(@"----------- socket收到 Pong -----------");
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    
    if (webSocket == self.socket) {
        
        NSLog(@"----------- socket收到 message -----------");
        
        NSData *responseData = [message dataUsingEncoding:NSUTF8StringEncoding];
        id responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        
        NSDictionary *messageDic = (NSDictionary *)responseObject;
        
//        NSString *type = [messageDic objectForKey:@"type"];
        NSString *type = @"wss://ws.coincap.io/prices?assets=bitcoin,ethereum" ;

        WebSocketRequest *request = [_requestDic objectForKey:type];
        
        [request parseMessage:message];
    }
}

- (void)reConnect {
    
    [self closeWebSocket];
    NSLog(@"重连");
    
    [self openWebSocketWithUrlString:self.urlString];
}

- (void)sendData:(id)data {
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_queue_create("xyz", NULL), ^{
        
        if (weakSelf.socket == nil) {
            return ;
        }
        
        if (weakSelf.socket.readyState == SR_OPEN) {
            
            [weakSelf.socket send:data];
            
        }  else if (weakSelf.socket.readyState == SR_CLOSING || weakSelf.socket.readyState == SR_CLOSED || weakSelf.socket.readyState == SR_CONNECTING) {
            
            [self reConnect];
        }
    });
}

- (void)sendPing {
    
    if (self.socket.readyState == SR_OPEN) {
        [self.socket sendPing:nil];
    } else if (self.socket.readyState == SR_CLOSING || self.socket.readyState == SR_CLOSED || self.socket.readyState == SR_CONNECTING) {
        
        [self reConnect];
    }
}

- (void)addWebSocketRequest:(WebSocketRequest *)request {
    
    [self.requestDic setObject:request forKey:request.typeValue];
}

- (void)removeSocketRequest:(WebSocketRequest *)request {
    [self.requestDic removeObjectForKey:request.typeValue];
}

- (NSMutableDictionary *)requestDic {
    if (_requestDic == nil) {
        _requestDic = [[NSMutableDictionary alloc] init];
    }
    return _requestDic;
}

@end
