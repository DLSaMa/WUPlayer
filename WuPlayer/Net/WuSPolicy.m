
#import "WuSPolicy.h"

#import <AssertMacros.h>

#if !TARGET_OS_IOS && !TARGET_OS_WATCH && !TARGET_OS_TV
static NSData * WUSecKeyGetData(SecKeyRef key) {
    CFDataRef data = NULL;

    __Require_noErr_Quiet(SecItemExport(key, kSecFormatUnknown, kSecItemPemArmour, NULL, &data), _out);

    return (__bridge_transfer NSData *)data;

_out:
    if (data) {
        CFRelease(data);
    }

    return nil;
}
#endif

static BOOL WUSecKeyIsEqualToKey(SecKeyRef key1, SecKeyRef key2) {
#if TARGET_OS_IOS || TARGET_OS_WATCH || TARGET_OS_TV
    return [(__bridge id)key1 isEqual:(__bridge id)key2];
#else
    return [WUSecKeyGetData(key1) isEqual:WUSecKeyGetData(key2)];
#endif
}

static id WUPublicKeyForCertificate          (NSData *certificate) {
    id allowedPublicKey = nil;
    SecCertificateRef allowedCertificate;
    SecPolicyRef policy = nil;
    SecTrustRef allowedTrust = nil;
    SecTrustResultType result;

    allowedCertificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificate);
    __Require_Quiet(allowedCertificate != NULL, _out);

    policy = SecPolicyCreateBasicX509();
    __Require_noErr_Quiet(SecTrustCreateWithCertificates(allowedCertificate, policy, &allowedTrust), _out);
    __Require_noErr_Quiet(SecTrustEvaluate(allowedTrust, &result), _out);

    allowedPublicKey = (__bridge_transfer id)SecTrustCopyPublicKey(allowedTrust);

_out:
    if (allowedTrust) {
        CFRelease(allowedTrust);
    }

    if (policy) {
        CFRelease(policy);
    }

    if (allowedCertificate) {
        CFRelease(allowedCertificate);
    }

    return allowedPublicKey;
}

static BOOL WUServerTrustIsValid(SecTrustRef serverTrust) {
    BOOL isValid = NO;
    SecTrustResultType result;
    __Require_noErr_Quiet(SecTrustEvaluate(serverTrust, &result), _out);

    isValid = (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);

_out:
    return isValid;
}

static NSArray * WUCertificateTrustChainForServerTrust(SecTrustRef serverTrust) {
    CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
    NSMutableArray *trustChain = [NSMutableArray arrayWithCapacity:(NSUInteger)certificateCount];

    for (CFIndex i = 0; i < certificateCount; i++) {
        SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, i);
        [trustChain addObject:(__bridge_transfer NSData *)SecCertificateCopyData(certificate)];
    }

    return [NSArray arrayWithArray:trustChain];
}

static NSArray * WUPublicKeyTrustChainForServerTrust(SecTrustRef serverTrust) {
    SecPolicyRef policy = SecPolicyCreateBasicX509();
    CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
    NSMutableArray *trustChain = [NSMutableArray arrayWithCapacity:(NSUInteger)certificateCount];
    for (CFIndex i = 0; i < certificateCount; i++) {
        SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, i);

        SecCertificateRef someCertificates[] = {certificate};
        CFArrayRef certificates = CFArrayCreate(NULL, (const void **)someCertificates, 1, NULL);

        SecTrustRef trust;
        __Require_noErr_Quiet(SecTrustCreateWithCertificates(certificates, policy, &trust), _out);

        SecTrustResultType result;
        __Require_noErr_Quiet(SecTrustEvaluate(trust, &result), _out);

        [trustChain addObject:(__bridge_transfer id)SecTrustCopyPublicKey(trust)];

    _out:
        if (trust) {
            CFRelease(trust);
        }

        if (certificates) {
            CFRelease(certificates);
        }

        continue;
    }
    CFRelease(policy);

    return [NSArray arrayWithArray:trustChain];
}

//MARK: -

@interface WuSPolicy()
@property (readwrite, nonatomic, assign) WUSSLPinningMode SSLPinningMode;
@property (readwrite, nonatomic, strong) NSSet *pinnedPublicKeys;
@end

@implementation WuSPolicy

+ (NSSet *)certificatesInBundle:(NSBundle *)bundle {
    NSArray *paths = [bundle pathsForResourcesOfType:@"cer" inDirectory:@"."];

    NSMutableSet *certificates = [NSMutableSet setWithCapacity:[paths count]];
    for (NSString *path in paths) {
        NSData *certificateData = [NSData dataWithContentsOfFile:path];
        [certificates addObject:certificateData];
    }

    return [NSSet setWithSet:certificates];
}

+ (NSSet *)defaultPinnedCertificates {
    static NSSet *_defaultPinnedCertificates = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        _defaultPinnedCertificates = [self certificatesInBundle:bundle];
    });

    return _defaultPinnedCertificates;
}

+ (instancetype)defaultPolicy {
    WuSPolicy *securityPolicy = [[self alloc] init];
    securityPolicy.SSLPinningMode = WUSSLPinningModeNone;
    return securityPolicy;
}

+ (instancetype)policyWithPinningMode:(WUSSLPinningMode)pinningMode {
    return [self policyWithPinningMode:pinningMode withPinnedCertificates:[self defaultPinnedCertificates]];
}

+ (instancetype)policyWithPinningMode:(WUSSLPinningMode)pinningMode withPinnedCertificates:(NSSet *)pinnedCertificates {
    WuSPolicy *securityPolicy = [[self alloc] init];
    securityPolicy.SSLPinningMode = pinningMode;
    [securityPolicy setPinnedCertificates:pinnedCertificates];
    return securityPolicy;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.validatesDomainName = YES;

    return self;
}

- (void)setPinnedCertificates:(NSSet *)pinnedCertificates {
    @try {
        _pinnedCertificates = pinnedCertificates;

           if (self.pinnedCertificates) {
               NSMutableSet *mutablePinnedPublicKeys = [NSMutableSet setWithCapacity:[self.pinnedCertificates count]];
               for (NSData *certificate in self.pinnedCertificates) {
                   id publicKey = WUPublicKeyForCertificate          (certificate);
                   if (!publicKey) {
                       continue;
                   }
                   [mutablePinnedPublicKeys addObject:publicKey];
               }
               self.pinnedPublicKeys = [NSSet setWithSet:mutablePinnedPublicKeys];
           } else {
               self.pinnedPublicKeys = nil;
           }
    } @catch (NSException *exception) {
        
    }
}

//MARK: -

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(NSString *)domain{
    @try {
        if (domain && self.allowInvalidCertificates && self.validatesDomainName && (self.SSLPinningMode == WUSSLPinningModeNone || [self.pinnedCertificates count] == 0)) {

               return NO;
           }

           NSMutableArray *policies = [NSMutableArray array];
           if (self.validatesDomainName) {
               [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];
           } else {
               [policies addObject:(__bridge_transfer id)SecPolicyCreateBasicX509()];
           }

           SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);

           if (self.SSLPinningMode == WUSSLPinningModeNone) {
               return self.allowInvalidCertificates || WUServerTrustIsValid(serverTrust);
           } else if (!WUServerTrustIsValid(serverTrust) && !self.allowInvalidCertificates) {
               return NO;
           }

           switch (self.SSLPinningMode) {
               case WUSSLPinningModeNone:
               default:
                   return NO;
               case WUSSLPinningModeCertificate: {
                   NSMutableArray *pinnedCertificates = [NSMutableArray array];
                   for (NSData *certificateData in self.pinnedCertificates) {
                       [pinnedCertificates addObject:(__bridge_transfer id)SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData)];
                   }
                   SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)pinnedCertificates);

                   if (!WUServerTrustIsValid(serverTrust)) {
                       return NO;
                   }

                   // obtain the chain WUter being validated, which *should* contain the pinned certificate in the last position (if it's the Root CA)
                   NSArray *serverCertificates = WUCertificateTrustChainForServerTrust(serverTrust);
                   
                   for (NSData *trustChainCertificate in [serverCertificates reverseObjectEnumerator]) {
                       if ([self.pinnedCertificates containsObject:trustChainCertificate]) {
                           return YES;
                       }
                   }
                   
                   return NO;
               }
               case WUSSLPinningModePublicKey: {
                   NSUInteger trustedPublicKeyCount = 0;
                   NSArray *publicKeys = WUPublicKeyTrustChainForServerTrust(serverTrust);

                   for (id trustChainPublicKey in publicKeys) {
                       for (id pinnedPublicKey in self.pinnedPublicKeys) {
                           if (WUSecKeyIsEqualToKey((__bridge SecKeyRef)trustChainPublicKey, (__bridge SecKeyRef)pinnedPublicKey)) {
                               trustedPublicKeyCount += 1;
                           }
                       }
                   }
                   return trustedPublicKeyCount > 0;
               }
           }
           
           return NO;
    } @catch (NSException *exception) {
        return NO;
    }
   
}

//MARK: - NSKeyValueObserving

+ (NSSet *)keyPathsForValuesWUfectingPinnedPublicKeys {
    return [NSSet setWithObject:@"pinnedCertificates"];
}

//MARK: - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {

    self = [self init];
    if (!self) {
        return nil;
    }

    self.SSLPinningMode = [[decoder decodeObjectOfClass:[NSNumber class] forKey:NSStringFromSelector(@selector(SSLPinningMode))] unsignedIntegerValue];
    self.allowInvalidCertificates = [decoder decodeBoolForKey:NSStringFromSelector(@selector(allowInvalidCertificates))];
    self.validatesDomainName = [decoder decodeBoolForKey:NSStringFromSelector(@selector(validatesDomainName))];
    self.pinnedCertificates = [decoder decodeObjectOfClass:[NSArray class] forKey:NSStringFromSelector(@selector(pinnedCertificates))];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:[NSNumber numberWithUnsignedInteger:self.SSLPinningMode] forKey:NSStringFromSelector(@selector(SSLPinningMode))];
    [coder encodeBool:self.allowInvalidCertificates forKey:NSStringFromSelector(@selector(allowInvalidCertificates))];
    [coder encodeBool:self.validatesDomainName forKey:NSStringFromSelector(@selector(validatesDomainName))];
    [coder encodeObject:self.pinnedCertificates forKey:NSStringFromSelector(@selector(pinnedCertificates))];
}

//MARK: - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
    WuSPolicy *securityPolicy = [[[self class] allocWithZone:zone] init];
    securityPolicy.SSLPinningMode = self.SSLPinningMode;
    securityPolicy.allowInvalidCertificates = self.allowInvalidCertificates;
    securityPolicy.validatesDomainName = self.validatesDomainName;
    securityPolicy.pinnedCertificates = [self.pinnedCertificates copyWithZone:zone];

    return securityPolicy;
}

@end
