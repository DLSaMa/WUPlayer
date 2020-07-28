//
//  NSMutableDictionary+Safe.m
//  WuPlayer
//
//  Created by Qi Liu on 2020/7/15.
//  Copyright © 2020 WU. All rights reserved.
//

#import "NSMutableDictionary+Safe.h"


@implementation NSMutableDictionary (Safe)

- (void)safeSetObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    if (!key) {
        return ;
    }
    
    if (!obj) {
        [self removeObjectForKey:key];
    }else {
        [self setObject:obj forKey:key];
    }
}

- (void)safeSetObject:(id)aObj forKey:(id<NSCopying>)aKey {
    if (aObj && ![aObj isKindOfClass:[NSNull class]] && aKey) {
        [self setObject:aObj forKey:aKey];
    } else {
        return;
    }
}

- (id)safeObjectForKey:(id<NSCopying>)aKey {
    if (aKey != nil) {
        return [self objectForKey:aKey];
    } else {
        return nil;
    }
}
@end
