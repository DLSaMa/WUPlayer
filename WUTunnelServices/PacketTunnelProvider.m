//
//  PacketTunnelProvider.m
//  WUTunnelServices
//
//  Created by Qi Liu on 2020/7/24.
//Copyright © 2020 WU. All rights reserved.
//

#import "PacketTunnelProvider.h"
#import "NSString+Tun_code.h"
#import "AnClasss.h"

@interface PacketTunnelProvider ()
@property NWTCPConnection *connection;

@property(nonatomic,strong) NWUDPSession * session;

//@property(nonatomic,strong)


@property (strong) void (^pendingStartCompletion)(NSError *);
@end

@implementation PacketTunnelProvider

- (void)startTunnelWithOptions:(NSDictionary *)options completionHandler:(void (^)(NSError *))completionHandler
{
    
     NSLog(@"开启通道");
    
    //
    //    NWUDPSession * session = [self createUDPSessionToEndpoint:nil fromEndpoint:nil];
    
//    NWHostEndpoint * endpont = [NWHostEndpoint endpointWithHostname:@"127.0.0.1" port:@"8034"];//有远程/或本地服务端
//    
//    NWTCPConnection *newConnection = [self createTCPConnectionToEndpoint:endpont enableTLS:NO TLSParameters:nil delegate:nil];
//    
//    [newConnection addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionInitial context:nil];
//    self.connection = newConnection;
//    self.pendingStartCompletion = completionHandler;
    
    
    [self startVPNWithOptions:options completionHandler:completionHandler];
    //
}



-(void)startVPNWithOptions:(NSDictionary *)options completionHandler:(void(^)(NSError * error))completionHandler{

    [self sendMessage:[NSString stringWithFormat:@"Current_method_%@",NSStringFromSelector(_cmd)]];
    
    //    包含IP层隧道的IP网络设置。数据包隧道提供程序的虚拟接口的配置。
    NEPacketTunnelNetworkSettings *tunnelNetworkSettings = [[NEPacketTunnelNetworkSettings alloc] initWithTunnelRemoteAddress:@"127.0.0.1"];
    tunnelNetworkSettings.MTU = [NSNumber numberWithInteger:1400];
    tunnelNetworkSettings.IPv4Settings = [[NEIPv4Settings alloc] initWithAddresses:[NSArray arrayWithObjects:@"192.169.89.1", nil]  subnetMasks:[NSArray arrayWithObjects: @"255.255.255.0", nil]];
    tunnelNetworkSettings.IPv4Settings.includedRoutes = @[[NEIPv4Route defaultRoute]];
    // 此处不可随意设置，可根据真实情况设置
    //    NEIPv4Route *excludeRoute = [[NEIPv4Route alloc] initWithDestinationAddress:@"10.12.23.90" subnetMask:@"255.255.255.255"];
    //    tunnelNetworkSettings.IPv4Settings.excludedRoutes = @[excludeRoute];
    
    
    
    
    NEProxySettings * proxySettig = [[NEProxySettings alloc]init];//包含HTTP代理设置。
    proxySettig.HTTPServer = [[NEProxyServer alloc]initWithAddress:@"127.0.0.1" port:8034];
    proxySettig.HTTPServer = [[NEProxyServer alloc]initWithAddress:@"127.0.0.1" port:8034];
    
//    proxySettig.HTTPEnabled = YES;
//    proxySettig.HTTPSEnabled = YES;
    proxySettig.matchDomains = @[@""];
    tunnelNetworkSettings.proxySettings = proxySettig;
    
    
    __weak typeof(self) weakSelf = self;
    [self setTunnelNetworkSettings:tunnelNetworkSettings completionHandler:^(NSError * _Nullable error) {
        if (error == nil) {
            NSLog(@"XDXVPNManager,XDXPacketTunnelManager - Start Tunel Success !");
            completionHandler(nil);
            
            [weakSelf readPakcets];
            
        }else {
            NSLog(@"XDXVPNManager,XDXPacketTunnelManager - Start Tunel Failed - %s !",error.debugDescription.UTF8String);
            completionHandler(error);
            return;
        }
        
        
    }];
    
    
}


- (void)readPakcets {
    //    [self sendMessage:[NSString stringWithFormat:@"Current_method_%@",NSStringFromSelector(_cmd)]];
    
    NSLog(@"读取数据");
    
    __weak PacketTunnelProvider *weakSelf = self;
    __block  NSMutableData * mudata = [NSMutableData data];
    
//    [self.packetFlow readPacketObjectsWithCompletionHandler:^(NSArray<NEPacket *> * _Nonnull packets) {
//        [packets enumerateObjectsUsingBlock:^(NEPacket * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//
//            NSLog(@"标识：%@",obj.metadata.sourceAppSigningIdentifier);
//             NSLog(@"标识：%@",obj.metadata.sourceAppUniqueIdentifier);
//
//        }];
//         [weakSelf readPakcets];
//    }];
    
    
    [self.packetFlow readPacketsWithCompletionHandler:^(NSArray<NSData *> * _Nonnull packets, NSArray<NSNumber *> * _Nonnull protocols) {
        
        NSLog(@"收到数据");
        [packets enumerateObjectsUsingBlock:^(NSData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [mudata appendData:obj];
            
            IPPacket * pac = [[IPPacket alloc]initWithRawData:obj];
            if (pac.header.transportProtocol == TCP) {
                 NSLog(@"wuplayer---------收到数据是TCP");
            }else if (pac.header.transportProtocol == UDP){
                NSLog(@"wuplayer---------收到数据是UDP");
            }
            
            
            
//            NEPacket * pack = [NEPacket alloc]initWithData:<#(nonnull NSData *)#> protocolFamily:<#(sa_family_t)#>;
            
            
//            IPUDPSegment * ipPack = [[IPUDPSegment alloc]initWithRawData:obj];
//            NSLog(@"源地址：%ld",(long)ipPack.header.sourcePort);
//            NSLog(@"目标地址：%ld",(long)ipPack.header.sourcePort);
//            NSLog(@"长度：%ld",(long)ipPack.header.length);
//            NSLog(@"checksum：%ld",(long)ipPack.header.checksum);
            
            //            [self.connection write:obj completionHandler:^(NSError * _Nullable error) {
            //                if (error) {
            //                    NSLog(@"error ---%@",error);
            //                }
            //            }];
            
            
            
            //            [weakSelf sendMessage:packetStr];
        }];
        
        
        NSString *packetStr = [[NSString alloc]initWithData:mudata encoding:NSUTF8StringEncoding];
        NSLog(@"wu_log:Read Packet - %@ !",packetStr);
        
        //        for (NSData *packet in packets) {
        //            [self.connection write:packet completionHandler:^(NSError * _Nullable error) {
        //                if (error) {
        //                    NSLog(@"error ---%@",error);
        //                }
        //            }];
        //             NSLog(@"XDXVPNManager , Read Packet - %s",[NSString stringWithFormat:@"%@",packet].UTF8String);
        //            __typeof__(self) strongSelf = weakSelf;
        //            NSLog(@"XDX : read packet - %@",packet);
        //              NSString *packetStr = [NSString stringWithFormat:@"%@",obj];
        //            log4cplus_debug("XDXVPNManager", "XDXPacketTunnelManager - Read Packet - %s !",packetStr.UTF8String);
        //        }
        [weakSelf readPakcets];
    }];
    
    
    
//    [self.packetFlow readPacketObjectsWithCompletionHandler:^(NSArray<NEPacket *> * _Nonnull packets) {
//        for (NEPacket * data in packets) {
////             IPTCPSegment * str = [[AnClasss alloc]ipDataFromRemote:data.data];
//        }
////        IPTCPSegment * str = [AnClasss alloc]ipDataFromRemote:;
//    }];
}

-(void)sendMessage:(NSString *)message{
    NSString * str = @"http://182.92.2.5:8805/write?msg=";
    NSString * urlStr = [NSString stringWithFormat:@"%@%@",str,message?message:@""];
    NSURL * url = [NSURL URLWithString:[urlStr tu_urlEncodedString]];
    NSURLRequest * requrest = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];
    [[session dataTaskWithRequest:requrest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error!= nil) {
            NSLog(@"%@",response.description);
        }
    }] resume];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"state"]) {
        NWTCPConnection *conn = (NWTCPConnection *)object;
        if (conn.state == NWTCPConnectionStateConnected) {
            NWHostEndpoint *ra = (NWHostEndpoint *)conn.remoteAddress;
            __weak PacketTunnelProvider *weakself = self;
            [self setTunnelNetworkSettings:[[NEPacketTunnelNetworkSettings alloc] initWithTunnelRemoteAddress:ra.hostname] completionHandler:^(NSError *error) {
                if (error == nil) {
                    [weakself addObserver:weakself forKeyPath:@"defaultPath" options:NSKeyValueObservingOptionInitial context:nil];
                    [weakself.packetFlow readPacketsWithCompletionHandler:^(NSArray<NSData *> *packets, NSArray<NSNumber *> *protocols) {
                        // Add code here to deal with packets, and call readPacketsWithCompletionHandler again when ready for more.
                    }];
                    [conn readMinimumLength:0 maximumLength:8192 completionHandler:^(NSData *data, NSError *error) {
                        // Add code here to parse packets from the data, call [self.packetFlow writePackets] with the result
                    }];
                }
                if (weakself.pendingStartCompletion != nil) {
                    weakself.pendingStartCompletion(nil);
                    weakself.pendingStartCompletion = nil;
                }
            }];
        } else if (conn.state == NWTCPConnectionStateDisconnected) {
            NSError *error = [NSError errorWithDomain:@"PacketTunnelProviderDomain" code:-1 userInfo:@{ NSLocalizedDescriptionKey: @"Connection closed by server" }];
            if (self.pendingStartCompletion != nil) {
                self.pendingStartCompletion(error);
                self.pendingStartCompletion = nil;
            } else {
                [self cancelTunnelWithError:error];
            }
            [conn cancel];
        } else if (conn.state == NWTCPConnectionStateCancelled) {
            [self removeObserver:self forKeyPath:@"defaultPath"];
            [conn removeObserver:self forKeyPath:@"state"];
            self.connection = nil;
        }
    } else if ([keyPath isEqualToString:@"defaultPath"]) {
        // Add code here to deal with changes to the network
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)stopTunnelWithReason:(NEProviderStopReason)reason completionHandler:(void (^)(void))completionHandler
{
    [self sendMessage:[NSString stringWithFormat:@"Current method: %@",NSStringFromSelector(_cmd)]];
    // Add code here to start the process of stopping the tunnel
    [self.connection cancel];
    completionHandler();
}

- (void)handleAppMessage:(NSData *)messageData completionHandler:(void (^)(NSData *))completionHandler
{
    
    [self sendMessage:[NSString stringWithFormat:@"Current method: %@",NSStringFromSelector(_cmd)]];
    
    NSString * str = [[NSString alloc]initWithData:messageData encoding:NSUTF8StringEncoding];
    [self sendMessage:str];
    
    // Add code here to handle the message
    if (completionHandler != nil) {
        completionHandler(messageData);
    }
}

- (void)sleepWithCompletionHandler:(void (^)(void))completionHandler
{
    // Add code here to get ready to sleep
    completionHandler();
}

- (void)wake
{
    // Add code here to wake up
}



@end
