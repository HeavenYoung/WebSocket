//
//  ViewController.m
//  WebSocket
//
//  Created by ott001 on 2018/8/22.
//  Copyright © 2018 OTT. All rights reserved.
//

#import "ViewController.h"
#import "WebSocketConnectManager.h"
#import "WebSocketRequest.h"

@interface ViewController ()

@property (nonatomic, strong) WebSocketRequest *request;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [[WebSocketManager shareMananger] openWebSocketWithUrlString:@"ws://13.114.100.41:9502"];
//    [[WebSocketManager shareMananger] configHeartBeatContent:KlineBaseInfo];
//    [WebSocketManager shareMananger].delegate = self;
    
    [[WebSocketConnectManager shareMananger] openWebSocketWithUrlString:@"wss://ws.coincap.io/prices?assets=bitcoin"];
    
    WebSocketRequest *request = [[WebSocketRequest alloc] initWithType:@"wss://ws.coincap.io/prices?assets=bitcoin,ethereum" heartBeatFrequence:5.0 response:^(id message) {
        
        NSLog(@"Response data --------- %@", message);
        
    }];
    [request start];
    self.request = request;
    
    WebSocketRequest *request2 = [[WebSocketRequest alloc] initWithType:KlineWeekly heartBeatFrequence:10.0 response:^(id message) {
        
        NSLog(@" KlineWeekly Request --------- %@", message);
        
    }];
    [request2 start];
}

- (void)webSocketManagerDidReceiveMessage:(id)message {
    
    NSLog(@"---- message : %@", message);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.request end];
    self.request = nil;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
