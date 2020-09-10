//
//  TestProtocol.h
//  WuPlayer
//
//  Created by Qi Liu on 2020/8/21.
//  Copyright © 2020 WU. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TestProtocol <NSObject>

@required
-(void)test00;
@optional
-(void)test01;

@end

NS_ASSUME_NONNULL_END
