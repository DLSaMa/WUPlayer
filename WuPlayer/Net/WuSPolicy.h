
#import <Foundation/Foundation.h>
#import <Security/Security.h>

typedef NS_ENUM(NSUInteger, WUSSLPinningMode) {
    WUSSLPinningModeNone,
    WUSSLPinningModePublicKey,
    WUSSLPinningModeCertificate,
};

NS_ASSUME_NONNULL_BEGIN

@interface WuSPolicy : NSObject <NSSecureCoding, NSCopying>

@property (readonly, nonatomic, assign) WUSSLPinningMode SSLPinningMode;

@property (nonatomic, strong, nullable) NSSet <NSData *> *pinnedCertificates;
@property (nonatomic, assign) BOOL allowInvalidCertificates;

/**
 Whether or not to validate the domain name in the certificate's CN field. Defaults to `YES`.
 */
@property (nonatomic, assign) BOOL validatesDomainName;

+ (NSSet <NSData *> *)certificatesInBundle:(NSBundle *)bundle;
+ (instancetype)defaultPolicy;

+ (instancetype)policyWithPinningMode:(WUSSLPinningMode)pinningMode;

+ (instancetype)policyWithPinningMode:(WUSSLPinningMode)pinningMode withPinnedCertificates:(NSSet <NSData *> *)pinnedCertificates;

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(nullable NSString *)domain;

@end

NS_ASSUME_NONNULL_END
