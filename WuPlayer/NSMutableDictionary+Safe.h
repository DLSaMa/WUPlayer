//
//  NSMutableDictionary+Safe.h
//  WuPlayer
//
//  Created by Qi Liu on 2020/7/15.
//  Copyright © 2020 WU. All rights reserved.
//



#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary (Safe)
/**
    Safe set key-value for dictionary.
 */
- (void)safeSetObject:(id)aObj
               forKey:(id<NSCopying>)aKey;

/**
    Safe read value for key.
 */
- (id)safeObjectForKey:(id<NSCopying>)aKey;

@end

NS_ASSUME_NONNULL_END
