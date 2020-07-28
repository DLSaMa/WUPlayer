//
//  WuNetManager.h
//  WUVerification
//
//  Created by WU on 2019/12/11.
//  Copyright © 2019 WU. All rights reserved.
//

#import "WuHttpSessionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface WuNetManager : WuHttpSessionManager

@property(nonatomic,strong) NSMutableDictionary * paramsDic;

+(instancetype)shareNetManager;
-(void)setHeaderManager;
@end

NS_ASSUME_NONNULL_END
