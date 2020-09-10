//
//  AnClasss.m
//  WUTunnelServices
//
//  Created by Qi Liu on 2020/9/1.
//  Copyright © 2020 WU. All rights reserved.
//

#import "AnClasss.h"

@implementation AnClasss
- (NSData *)dataFromHexString:(NSString *)str {
    const char *chars = [str UTF8String];
    NSInteger i = 0, len = str.length;
    
    NSMutableData *data = [NSMutableData dataWithCapacity:len / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    while (i < len) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    
    return data;
}

- (IPTCPSegment *)tcpSegmentWithRawData:(NSData *)rawData {
    // 解析IP packet
    IPPacket *packet = [[IPPacket alloc] initWithRawData:rawData];
    NSLog(@"origin address:%@ destination address:%@ 协议类型:%d",packet.header.sourceAddress,packet.header.destinationAddress,packet.header.transportProtocol);
    // ip packet的payload作为TCP的rawData解析
    IPTCPSegment *segment = [[IPTCPSegment alloc] initWithRawData:packet.payload];
    
    return segment;
}

- (NSData *)ipDataFromRemote:(NSData *)ori {
    IPPacket *packet = [[IPPacket alloc] initWithRawData:ori];
    NSLog(@"origin address:%@ destination address:%@ 协议类型:%d",packet.header.sourceAddress,packet.header.destinationAddress,packet.header.transportProtocol);
    NSString *oriIp = packet.header.sourceAddress;
    NSString *destination = packet.header.destinationAddress;
    packet.header.sourceAddress = destination;
    packet.header.destinationAddress = oriIp;
    return packet.toRawData;
}

- (IPPacket *)ipPackageFromRemote:(NSData *)ori {
    IPPacket *packet = [[IPPacket alloc] initWithRawData:ori];
    NSLog(@"origin address:%@ destination address:%@ 协议类型:%d",packet.header.sourceAddress,packet.header.destinationAddress,packet.header.transportProtocol);
    return packet;
}

@end
