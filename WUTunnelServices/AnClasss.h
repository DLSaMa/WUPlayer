//
//  AnClasss.h
//  WUTunnelServices
//
//  Created by Qi Liu on 2020/9/1.
//  Copyright © 2020 WU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IPConstant.h"
#import "IPDNSMessage.h"
#import "IPDNSProtocol.h"
#import "IPDNSUtil.h"
#import "IPPacket.h"
#import "IPTCPSegment.h"
#import "IPUDPSegment.h"

NS_ASSUME_NONNULL_BEGIN

@interface AnClasss : NSObject
- (NSData *)dataFromHexString:(NSString *)str;



- (IPTCPSegment *)tcpSegmentWithRawData:(NSData *)rawData;

- (NSData *)ipDataFromRemote:(NSData *)ori;

- (IPPacket *)ipPackageFromRemote:(NSData *)ori;
@end

NS_ASSUME_NONNULL_END
