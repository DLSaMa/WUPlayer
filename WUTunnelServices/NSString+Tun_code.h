//
//  NSString+Tun_code.h
//  WUTunnelServices
//
//  Created by Qi Liu on 2020/7/29.
//  Copyright © 2020 WU. All rights reserved.
//



#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Tun_code)
- (NSString *)tu_urlEncodedString;

- (NSString *)tu_urlDecodeString;
@end

NS_ASSUME_NONNULL_END
