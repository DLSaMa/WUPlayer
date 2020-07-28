//
//  XDXVPNManagerModel.m
//  WuPlayer
//
//  Created by Qi Liu on 2020/7/15.
//  Copyright © 2020 WU. All rights reserved.
//

#import "XDXVPNManagerModel.h"

@implementation XDXVPNManagerModel
- (void)configureInfoWithTunnelBundleId:(NSString *)tunnelBundleId serverAddress:(NSString *)serverAddress serverPort:(NSString *)serverPort mtu:(NSString *)mtu ip:(NSString *)ip subnet:(NSString *)subnet dns:(NSString *)dns {
    self.tunnelBundleId = tunnelBundleId;
    self.serverAddress  = serverAddress;
    self.serverPort     = serverPort;
    self.mtu            = mtu;
    self.ip             = ip;
    self.subnet         = subnet;
    self.dns            = dns;
}
@end
