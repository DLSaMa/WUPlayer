//
//  ViewController.m
//  WuPlayer
//
//  Created by Qi Liu on 2020/7/15.
//  Copyright © 2020 WU. All rights reserved.
//

#import "ViewController.h"
#import <NetworkExtension/NetworkExtension.h>
#import "NetManger.h"
#import "XDXVPNManager.h"
#import "XDXVPNManagerModel.h"
#import "WuNetManager.h"


@interface ViewController ()<NetDelegate,XDXVPNManagerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (nonatomic, strong) XDXVPNManager   *vpnManager;
//@property (nonatomic, strong) NetManger   *vpnManager;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XDXVPNManagerModel *model = [[XDXVPNManagerModel alloc] init];
    [model configureInfoWithTunnelBundleId:@"com.microwu.qos.extention"
                             serverAddress:@"XDX"
                                serverPort:@"54345"
                                       mtu:@"1400"
                                        ip:@"10.8.0.2"
                                    subnet:@"255.255.255.0"
                                       dns:@"8.8.8.8,8.4.4.4"];
    
    self.vpnManager = [[XDXVPNManager alloc] init];
//     self.vpnManager = [[NetManger alloc] init];
    [self.vpnManager configManagerWithModel:model];
    self.vpnManager.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vpnDidChange:) name:NEVPNStatusDidChangeNotification object:nil];
    
    [self sendMessage:@"this is a string that for test"];
    
}

-(void)sendMessage:(NSString *)message{
//    NSString * str = @"http://113.200.129.28:8805?msg=";
    
     NSString * str = @"http://182.92.2.5:8805/write?msg=guss what";
    
//    NSString * urlStr = [NSString stringWithFormat:@"%@%@",str,message?message:@""];
    NSURL * url = [NSURL URLWithString:str];
    NSURLRequest * requrest = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];
    [session dataTaskWithRequest:requrest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error!= nil) {
            NSLog(@"%@",response.description);
        }
    }];
    
    
    
    NSData * data = [NSData dataWithContentsOfURL:url];
    NSLog(@"%@",data);
    
    
    
    WuNetManager * se = [WuNetManager shareNetManager];
    [se GET:@"" parameters:@{@"msg":@"frome anfetworking"} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject != nil) {
            NSLog(@"%@",responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            NSLog(@"error :%@",error);
        }
    }];
    
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
#pragma mark - UI

#pragma mark - Button Action
- (IBAction)didClickConnectBtn:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"Connect"]) {
        [self.vpnManager startVPN];
    }else {
        [self.vpnManager stopVPN];
    }
}

#pragma mark - Notification
- (void)vpnDidChange:(NSNotification *)notification {
    OSStatus status = self.vpnManager.vpnManager.connection.status;
    
    switch (status) {
        case NEVPNStatusConnecting:
        {
            NSLog(@"Connecting...");
            [self.connectBtn setTitle:@"Disconnect" forState:UIControlStateNormal];
        }
            break;
        case NEVPNStatusConnected:
        {
            NSLog(@"Connected...");
            [self.connectBtn setTitle:@"Disconnect" forState:UIControlStateNormal];
            
        }
            break;
        case NEVPNStatusDisconnecting:
        {
            NSLog(@"Disconnecting...");
            
        }
            break;
        case NEVPNStatusDisconnected:
        {
            NSLog(@"Disconnected...");
            [self.connectBtn setTitle:@"Connect" forState:UIControlStateNormal];
            
        }
            break;
        case NEVPNStatusInvalid:
            
            NSLog(@"Invliad");
            //             [self.connectBtn setTitle:@"Connect" forState:UIControlStateNormal];
            break;
        case NEVPNStatusReasserting:
            NSLog(@"Reasserting...");
            break;
    }
}

#pragma mark - Delegate
- (void)loadFromPreferencesComplete {
    [self vpnDidChange:nil];
}

#pragma mark - Dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)loadFormPrefrencesComplete {
    
}



@end
