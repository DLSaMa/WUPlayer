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
#import "NSString+code.h"
#import "UIForLumberjack/UIForLumberjack.h"
#import "CocoaLumberjack.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

@interface ViewController ()<NetDelegate,XDXVPNManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *showLabel;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
@property (nonatomic, strong) XDXVPNManager   *vpnManager;
//@property (nonatomic, strong) NetManger   *vpnManager;
@end


@implementation ViewController
- (IBAction)senfmsg:(UIButton *)sender {
    NSURLSession * session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:@"http://182.92.2.5:8805/write?msg=str_from_http"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSString * str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.showLabel.text = [NSString stringWithFormat:@"%@",str];
            });
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.showLabel.text = @"网络不通";
            });
        }
    }] resume];
}
- (IBAction)clear:(id)sender{
    self.showLabel.text = @"";
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [DDLog addLogger:[UIForLumberjack sharedInstance]];
    [[UIForLumberjack sharedInstance] showLogInView:self.view];
    
    
    
    
    
    DDLogVerbose(@"Verbose");   // 详细日志
    DDLogDebug(@"Debug");       // 调试日志
    DDLogInfo(@"Info");         // 信息日志
    DDLogWarn(@"Warn");         // 警告日志
    DDLogError(@"Error");       // 错误日志
    
    
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
    
    NSString * str = [NSString stringWithFormat:@"Current_method_%@",NSStringFromSelector(_cmd)];
    
    [self sendMessage:@"this is a string that for test heheheh"];
    
}

-(void)sendMessage:(NSString *)message{
    NSString * str = @"http://182.92.2.5:8805/write?msg=";
    NSString * urlStr = [NSString stringWithFormat:@"%@%@",str,message?message:@""];
    
    //    NSString *strPic = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLUserAllowedCharacterSet]];
    
    
    NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:@"!$&'()*+,-./:;=?@_~%#[]"] invertedSet];
    NSString *resultString = [urlStr stringByAddingPercentEncodingWithAllowedCharacters: set];
    
    NSURL * url = [NSURL URLWithString:resultString];
    NSURLRequest * requrest = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];
    [[session dataTaskWithRequest:requrest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error!= nil) {
            NSLog(@"%@",response.description);
        }
    }] resume];
}




- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
#pragma mark - UI

#pragma mark - Button Action
- (IBAction)didClickConnectBtn:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"Connect"]) {
        [self.vpnManager startVPN];
        [self.vpnManager test00];
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

+ (NSDictionary *)getIpAddresses {
    NSMutableDictionary* addresses = [[NSMutableDictionary alloc] init];
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    
    @try {
        // retrieve the current interfaces - returns 0 on success
        NSInteger success = getifaddrs(&interfaces);
        //NSLog(@"%@, success=%d", NSStringFromSelector(_cmd), success);
        if (success == 0) {
            // Loop through linked list of interfaces
            temp_addr = interfaces;
            while(temp_addr != NULL) {
                if(temp_addr->ifa_addr->sa_family == AF_INET) {
                    // Get NSString from C String
                    NSString* ifaName = [NSString stringWithUTF8String:temp_addr->ifa_name];
                    NSString* address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *) temp_addr->ifa_addr)->sin_addr)];
                    NSString* mask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *) temp_addr->ifa_netmask)->sin_addr)];
                    NSString* gateway = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *) temp_addr->ifa_dstaddr)->sin_addr)];
                    
                    
                    NSLog(@"ifaName:%@",ifaName);
                    NSLog(@"address:%@",address);
                    NSLog(@"mask:%@",mask);
                    NSLog(@"gateway:%@",gateway);
                    
                    //                    AXNetAddress* netAddress = [[AXNetAddress alloc] init];
                    //                    netAddress.name = ifaName;
                    //                    netAddress.address = address;
                    //                    netAddress.netmask = mask;
                    //                    netAddress.gateway = gateway;
                    //                    NSLog(@"netAddress=%@", netAddress);
                    //                    addresses[ifaName] = netAddress;
                }
                temp_addr = temp_addr->ifa_next;
            }
        }
    }
    @catch (NSException *exception) {
        //        NSLog(@"%@ Exception: %@", DEBUG_FUN, exception);
    }
    @finally {
        // Free memory
        freeifaddrs(interfaces);
    }
    return addresses;
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
