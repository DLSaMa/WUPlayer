//
//  WuNetManager.m
//  WUVerification
//
//  Created by WU on 2019/12/11.
//  Copyright © 2019 WU. All rights reserved.
//

#import "WuNetManager.h"
#import "WuUrlRespSerialization.h"
#import "WuUrlRetSerialization.h"




#define CLIENTTYPE    @"Client-Type"
#define CLIENTID      @"Client-Id"

#define PACKAGENAME   @"Package-Name"
#define PACKAGESIGN   @"Package-Sign"
//相应参数签名方法
#define RESPSIGNTYPE  @"Resp-Sign-Type"
//请求参数签名方法
#define REQSIGNTYPE   @"Req-Sign-Type"
#define REQTIMESTAMP  @"Req-Timestamp"
#define AUTHORIZATION @"Authorization"
#define TRACEID       @"Trace-Id"

@implementation WuNetManager
+(instancetype)shareNetManager{
    static WuNetManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        
        instance = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"http://182.92.2.5:8805/write"]];
        instance.requestSerializer = [WUHTTPRequestSerializer serializer];
        instance.responseSerializer = [WUHTTPResponseSerializer serializer];
        instance.responseSerializer = [WUJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        instance.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
        instance.session.configuration.timeoutIntervalForResource = 10;
    });
    
    return instance;
}


-(void)setHeaderManager{


}


-(NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(id)parameters progress:(void (^)(NSProgress * _Nonnull))uploadProgress success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure{
    NSURL *url = [NSURL URLWithString:URLString relativeToURL:self.baseURL];
    return  [super POST:url.absoluteString parameters:parameters progress:nil success:success failure:failure];
}

-(NSMutableDictionary *)paramsDic{
    if (_paramsDic) { return _paramsDic; }
    return [NSMutableDictionary dictionary];
}
@end
