//
//  WebSocketManager.m
//  WebSocket
//
//  Created by ott001 on 2018/8/24.
//  Copyright © 2018 OTT. All rights reserved.
//

#import "WebSocketManager.h"

#define kHeartBeatTime 5.0

@interface WebSocketManager () <SRWebSocketDelegate>

@property (nonatomic,strong) SRWebSocket *socket;

@property (nonatomic,copy) NSString *urlString;

@property (nonatomic, copy) NSString *heartBeatContent;

@property (nonatomic, strong) NSTimer *heartBeat;

@end

@implementation WebSocketManager

+ (instancetype)shareMananger {

    static WebSocketManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WebSocketManager alloc] init];
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

- (void)configHeartBeatContent:(NSString *)heartBeatContent {
    
    self.heartBeatContent = heartBeatContent;
}

- (void)closeWebSocket {
    
    if (self.socket){
        [self.socket close];
        self.socket = nil;
    }
}

- (void)initHeartBeat {
    
    __weak typeof(self) weakSelf = self;

    [self destoryHeartBeat];

    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"----------- 开启心跳计时器 -----------");

        weakSelf.heartBeat = [NSTimer timerWithTimeInterval:kHeartBeatTime target:self selector:@selector(sentheart) userInfo:nil repeats:YES];

        [[NSRunLoop currentRunLoop] addTimer:weakSelf.heartBeat forMode:NSRunLoopCommonModes];
    });
    
}

- (void)destoryHeartBeat {

    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (weakSelf.heartBeat) {
            
            NSLog(@"----------- 销毁心跳计时器 -----------");

            if ([weakSelf.heartBeat respondsToSelector:@selector(isValid)]){
                if ([weakSelf.heartBeat isValid]){
                    [weakSelf.heartBeat invalidate];
                    weakSelf.heartBeat = nil;
                }
            }
        }
    });
}

- (void)sentheart{
    
    NSLog(@"----------- 发送心跳包 -----------");

    if (self.heartBeatContent) {
        
        NSDictionary *contentDic = [NSDictionary dictionaryWithObject:self.heartBeatContent forKey:@"type"];
        
        [self sendData:[self convertToJsonData:contentDic]];
        
    } else {
        
        [self ping];
    }
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

- (void)ping{
    
    if (self.socket.readyState == SR_OPEN) {
        [self.socket sendPing:nil];
    } else if (self.socket.readyState == SR_CLOSING || self.socket.readyState == SR_CLOSED || self.socket.readyState == SR_CONNECTING) {
        
        [self reConnect];
    }
}

- (NSString *)convertToJsonData:(NSDictionary *)dict {
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    } else {
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
}

- (void)reConnect {
    
    [self closeWebSocket];
    NSLog(@"重连");

    [self openWebSocketWithUrlString:self.urlString];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"----------- socket 连接成功 -----------");
    [self initHeartBeat];
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
    
    if ([self.delegate respondsToSelector:@selector(webSocketManagerDidReceivePong:)]) {
        [self.delegate webSocketManagerDidReceivePong:pongPayload];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    
    if (webSocket == self.socket) {
        
        NSLog(@"----------- socket收到 message -----------");
        
        if ([self.delegate respondsToSelector:@selector(webSocketManagerDidReceiveMessage:)]) {
            [self.delegate webSocketManagerDidReceiveMessage:message];
        }
    }
}

- (SRReadyState)socketReadyState{
    return self.socket.readyState;
}

@end
