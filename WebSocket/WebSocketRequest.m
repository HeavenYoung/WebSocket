//
//  WebSocketRequest.m
//  WebSocket
//
//  Created by ott001 on 2018/8/27.
//  Copyright © 2018 OTT. All rights reserved.
//

#import "WebSocketRequest.h"
#import "WebSocketConnectManager.h"

@interface WebSocketRequest ()

@property (nonatomic, copy) NSString *type;

@property (nonatomic, assign) NSTimeInterval frequence;

@property (nonatomic, weak) Socketresponse message;

@property (nonatomic, strong) NSTimer *timer;


@end

@implementation WebSocketRequest

- (instancetype)initWithType:(NSString *)type heartBeatFrequence:(NSTimeInterval)frequence response:(Socketresponse)message {
    
    self = [super init];
    if (self) {
       
        self.type = type;
        self.frequence = frequence;
        self.message = message;
        
    }
    return self;
}

- (void)start {
    
    [[WebSocketConnectManager shareMananger] addWebSocketRequest:self];
    
    [self initialTimer];
}

- (void)end {
    
    [self destoryHeartBeat];
    
    [[WebSocketConnectManager shareMananger] removeSocketRequest:self];
}

- (void)initialTimer {
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"----------- 开启心跳计时器 -----------");
        
        weakSelf.timer = [NSTimer timerWithTimeInterval:weakSelf.frequence target:self selector:@selector(sentheart) userInfo:nil repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:weakSelf.timer forMode:NSRunLoopCommonModes];
    });
    
}

- (void)sentheart {
    
    NSDictionary *contentDic = [NSDictionary dictionaryWithObject:self.type forKey:@"type"];

    [[WebSocketConnectManager shareMananger] sendData:[self convertToJsonData:contentDic]];
}

- (void)parseMessage:(id)message {
    
    if (self.message) {
        self.message(message);
    }
}

- (void)destoryHeartBeat {
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (weakSelf.timer) {
            
            NSLog(@"----------- 销毁心跳计时器 -----------");
            
            if ([weakSelf.timer respondsToSelector:@selector(isValid)]){
                if ([weakSelf.timer isValid]){
                    [weakSelf.timer invalidate];
                    weakSelf.timer = nil;
                }
            }
        }
    });
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

- (NSString *)typeValue {
    return self.type;
}

@end
