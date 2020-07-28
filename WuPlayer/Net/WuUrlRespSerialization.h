
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
NS_ASSUME_NONNULL_BEGIN

@protocol WuUrlRespSerialization <NSObject, NSSecureCoding, NSCopying>
- (nullable id)responseObjectForResponse:(nullable NSURLResponse *)response
                           data:(nullable NSData *)data
                          error:(NSError * _Nullable __autoreleasing *)error NS_SWIFT_NOTHROW;
@end
@interface WUHTTPResponseSerializer : NSObject <WuUrlRespSerialization>
- (instancetype)init;
@property (nonatomic, assign) NSStringEncoding stringEncoding DEPRECATED_MSG_ATTRIBUTE("The string encoding is never used. WUHTTPResponseSerializer only validates status codes and content types but does not try to decode the received data in any way.");
+ (instancetype)serializer;
@property (nonatomic, copy, nullable) NSIndexSet *acceptableStatusCodes;
@property (nonatomic, copy, nullable) NSSet <NSString *> *acceptableContentTypes;
- (BOOL)validateResponse:(nullable NSHTTPURLResponse *)response
                    data:(nullable NSData *)data
                   error:(NSError * _Nullable __autoreleasing *)error;
@end

@interface WUJSONResponseSerializer : WUHTTPResponseSerializer
- (instancetype)init;
@property (nonatomic, assign) NSJSONReadingOptions readingOptions;
@property (nonatomic, assign) BOOL removesKeysWithNullValues;
+ (instancetype)serializerWithReadingOptions:(NSJSONReadingOptions)readingOptions;
@end

@interface WUXMLParserResponseSerializer : WUHTTPResponseSerializer
@end

#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED
@interface WUXMLDocumentResponseSerializer : WUHTTPResponseSerializer
- (instancetype)init;
@property (nonatomic, assign) NSUInteger options;
+ (instancetype)serializerWithXMLDocumentOptions:(NSUInteger)mask;
@end
#endif


@interface WUPropertyListResponseSerializer : WUHTTPResponseSerializer
- (instancetype)init;
@property (nonatomic, assign) NSPropertyListFormat format;
@property (nonatomic, assign) NSPropertyListReadOptions readOptions;
+ (instancetype)serializerWithFormat:(NSPropertyListFormat)format
                         readOptions:(NSPropertyListReadOptions)readOptions;
@end


@interface WUImageResponseSerializer : WUHTTPResponseSerializer

#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
@property (nonatomic, assign) CGFloat imageScale;
@property (nonatomic, assign) BOOL automaticallyInflatesResponseImage;
#endif
@end


@interface WUCompoundResponseSerializer : WUHTTPResponseSerializer
@property (readonly, nonatomic, copy) NSArray <id<WuUrlRespSerialization>> *responseSerializers;
+ (instancetype)compoundSerializerWithResponseSerializers:(NSArray <id<WuUrlRespSerialization>> *)responseSerializers;

@end

FOUNDATION_EXPORT NSString * const WuUrlRespSerializationErrorDomain;
FOUNDATION_EXPORT NSString * const WUNetworkingOperationFailingURLResponseErrorKey;
FOUNDATION_EXPORT NSString * const WUNetworkingOperationFailingURLResponseDataErrorKey;
NS_ASSUME_NONNULL_END
