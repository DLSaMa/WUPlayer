//
//  NetManger.h
//  WuPlayer
//
//  Created by Qi Liu on 2020/7/15.
//  Copyright © 2020 WU. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XDXVPNManagerModel,NETunnelProviderManager;


@protocol NetDelegate <NSObject>

-(void)loadFromPreferencesComplete;

@end

@interface NetManger : NSObject


@property (nonatomic, strong) NETunnelProviderManager *vpnManager;

@property (nonatomic, weak) id<NetDelegate> delegate;

/**
 *  Configure the base information of vpn.
 */
- (void)configManagerWithModel:(XDXVPNManagerModel *)model;

/**
 *   Start VPN.
 *   If success return YES, otherwise return NO.
 */
- (BOOL)startVPN;

/**
 *  Stop VPN.
 *  If success return YES, otherwise return NO.
 */
- (BOOL)stopVPN;

@end

