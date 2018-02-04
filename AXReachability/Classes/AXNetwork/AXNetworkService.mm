//
//  AXNetworkService.h
//  XProject
//
//  Created by Ahmad Ansari on 9/11/14.
//  Copyright (c) 2014 Ahmad Ansari. All rights reserved.
//

#import "AXNetworkService.h"

#import <netinet/in.h> /* sockaddr_in */

#define kReachabilityHostName @"apple.com"

#undef TAG
#define kTAG @"AXNetworkService: "
#define TAG kTAG

#define AXNSLog(TAG, FMT, ...) NSLog(@"%@" FMT "\n", TAG, ##__VA_ARGS__)

@interface AXNetworkService (Private)
- (BOOL)startListening;
- (BOOL)stopListening;
- (void)setNetworkReachability:(AXNetworkReachability)reachability_;
- (void)setNetworkType:(AXNetworkType)networkType_;
@end

static AXNetworkReachability
AXConvertFlagsToReachability(SCNetworkConnectionFlags flags) {
    AXNetworkReachability reachability = NetworkReachabilityNone;
    
    if (flags & kSCNetworkFlagsTransientConnection)
        reachability = (AXNetworkReachability)(
                                               reachability | NetworkReachabilityTransientConnection);
    if (flags & kSCNetworkFlagsReachable)
        reachability =
        (AXNetworkReachability)(reachability | NetworkReachabilityReachable);
    if (flags & kSCNetworkFlagsConnectionRequired)
        reachability = (AXNetworkReachability)(
                                               reachability | NetworkReachabilityConnectionRequired);
    if (flags & kSCNetworkFlagsConnectionAutomatic)
        reachability = (AXNetworkReachability)(
                                               reachability | NetworkReachabilityConnectionAutomatic);
    if (flags & kSCNetworkFlagsInterventionRequired)
        reachability = (AXNetworkReachability)(
                                               reachability | NetworkReachabilityInterventionRequired);
    if (flags & kSCNetworkFlagsIsLocalAddress)
        reachability = (AXNetworkReachability)(reachability |
                                               NetworkReachabilityIsLocalAddress);
    if (flags & kSCNetworkFlagsIsDirect)
        reachability =
        (AXNetworkReachability)(reachability | NetworkReachabilityIsDirect);
    
    return reachability;
}

static AXNetworkType
AXConvertFlagsToNetworkType(SCNetworkConnectionFlags flags) {
    
    AXNetworkType networkType = NetworkTypeNone;
#if TARGET_OS_IPHONE
    if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
        networkType =
        (AXNetworkType)(networkType | NetworkType3G); // Ok, this is not true
        // but iOS don't provide
        // suchinformation
    } else
#endif /* TARGET_OS_IPHONE */
    {
        networkType = (AXNetworkType)(networkType | NetworkTypeWLAN);
    }
    
    return networkType;
}

static void AXNetworkReachabilityCallback(SCNetworkReachabilityRef target,
                                          SCNetworkConnectionFlags flags,
                                          void *info) {
    @autoreleasepool {
        AXNetworkService *self_ = (__bridge AXNetworkService *)info;
        
        [self_ setNetworkReachability:AXConvertFlagsToReachability(flags)];
        [self_ setNetworkType:AXConvertFlagsToNetworkType(flags)];
        
        /* raise event */
        AXNetworkEventArgs *eargs =
        [[AXNetworkEventArgs alloc] initWithType:NetworkEventStateChanged];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]
             postNotificationName:kAXNetworkEventArgsName
             object:eargs];
        });
    }
}

//
// private implementation
//

@implementation AXNetworkService (Private)

- (BOOL)startListening {
    if ([self stopListening]) {
        Boolean ok;
        int err = 0;
#if 0 /* SCNetworkReachabilityCreateWithName won't returns the rigth flags     \
imediately. We need to wait for the callback. */
        
        const char* hostName = [self.reachabilityHostName UTF8String];
        mReachability = SCNetworkReachabilityCreateWithName(NULL, hostName);
#else
        struct sockaddr_in fakeAddress;
        bzero(&fakeAddress, sizeof(fakeAddress));
        fakeAddress.sin_len = sizeof(fakeAddress);
        fakeAddress.sin_family = AF_INET;
        
        mReachability = SCNetworkReachabilityCreateWithAddress(
                                                               NULL, (struct sockaddr *)&fakeAddress);
#endif
        if (mReachability == NULL) {
            err = SCError();
        }
        
        // Set our callback and install on the runloop.
        if (err == 0) {
            ok = SCNetworkReachabilitySetCallback(
                                                  mReachability, AXNetworkReachabilityCallback, &mReachabilityContext);
            if (!ok) {
                err = SCError();
            }
        }
        if (err == 0) {
            ok = SCNetworkReachabilityScheduleWithRunLoop(
                                                          mReachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
            if (!ok) {
                err = SCError();
            }
        }
        
        if (err == 0) {
            SCNetworkConnectionFlags flags = 0;
            ok = SCNetworkReachabilityGetFlags(mReachability, &flags);
            
            if (ok) {
                [self setNetworkReachability:AXConvertFlagsToReachability(flags)];
                [self setNetworkType:AXConvertFlagsToNetworkType(flags)];
            } else {
                [self setNetworkReachability:NetworkReachabilityNone];
                [self setNetworkType:NetworkTypeNone];
                err = SCError();
            }
        }
        return (err == 0);
    }
    return NO;
}

- (BOOL)stopListening {
    if (mReachability) {
        (void)SCNetworkReachabilityUnscheduleFromRunLoop(
                                                         mReachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        static_cast<void>(CFRelease(mReachability)), mReachability = NULL;
    }
    return YES;
}

- (BOOL)startHostListening {
    if ([self stopHostListening]) {
        Boolean ok;
        int err = 0;
        
        const char *hostName = [self.reachabilityHostName UTF8String];
        mHostReachability = SCNetworkReachabilityCreateWithName(NULL, hostName);
        
        if (mHostReachability == NULL) {
            err = SCError();
        }
        
        // Set our callback and install on the runloop.
        if (err == 0) {
            ok = SCNetworkReachabilitySetCallback(mHostReachability,
                                                  AXNetworkReachabilityCallback,
                                                  &mHostReachabilityContext);
            if (!ok) {
                err = SCError();
            }
        }
        if (err == 0) {
            ok = SCNetworkReachabilityScheduleWithRunLoop(
                                                          mHostReachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
            if (!ok) {
                err = SCError();
            }
        }
        
        if (err == 0) {
            SCNetworkConnectionFlags flags = 0;
            ok = SCNetworkReachabilityGetFlags(mHostReachability, &flags);
            
            if (ok) {
                [self setNetworkReachability:AXConvertFlagsToReachability(flags)];
                [self setNetworkType:AXConvertFlagsToNetworkType(flags)];
            } else {
                [self setNetworkReachability:NetworkReachabilityNone];
                [self setNetworkType:NetworkTypeNone];
                err = SCError();
            }
        }
        return (err == 0);
    }
    return NO;
}

- (BOOL)stopHostListening {
    if (mHostReachability) {
        (void)SCNetworkReachabilityUnscheduleFromRunLoop(
                                                         mHostReachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        static_cast<void>(CFRelease(mHostReachability)), mHostReachability = NULL;
    }
    return YES;
}

- (void)setNetworkReachability:(AXNetworkReachability)reachability_ {
    mNetworkReachability = reachability_;
}

- (void)setNetworkType:(AXNetworkType)networkType_ {
    mNetworkType = networkType_;
}

@end

//
// default implementation
//

@implementation AXNetworkService

- (AXNetworkService *)init {
    if ((self = [super init])) {
        mNetworkType = NetworkTypeNone;
        mNetworkReachability = NetworkReachabilityNone;
        NSString *hostName = kReachabilityHostName;
        mReachabilityHostName = hostName;
        
        mReachabilityContext.version = 0;
        mReachabilityContext.info = (__bridge void *_Nullable)self;
        mReachabilityContext.retain = NULL;
        mReachabilityContext.release = NULL;
        mReachabilityContext.copyDescription = NULL;
        
        mHostReachabilityContext.version = 0;
        mHostReachabilityContext.info = (__bridge void *_Nullable)self;
        mHostReachabilityContext.retain = NULL;
        mHostReachabilityContext.release = NULL;
        mHostReachabilityContext.copyDescription = NULL;
    }
    return self;
}

//
// IBaseService
//

- (BOOL)start {
    AXNSLog(TAG, @"Start()");
    
    // reset current values
    mNetworkType = NetworkTypeNone;
    mNetworkReachability = NetworkReachabilityNone;
    
    mStarted = [self startHostListening] & [self startListening];
    
    return mStarted;
}

- (BOOL)stop {
    AXNSLog(TAG, @"Stop()");
    return YES;
}

//
// IAXNetworkService
//

- (NSString *)getReachabilityHostName {
    return mReachabilityHostName;
}

- (void)setReachabilityHostName:(NSString *)hostName {
    mReachabilityHostName = nil;
    mReachabilityHostName = hostName;
    
    if (mStarted && mReachabilityHostName) {
        [self startListening];
    }
}

- (AXNetworkType)getNetworkType {
    return mNetworkType;
}

- (AXNetworkReachability)getReachability {
    return mNetworkReachability;
}
- (BOOL)isReachable {
    return (mNetworkReachability & NetworkReachabilityReachable)
#if TARGET_OS_MAC || TARGET_IPHONE_SIMULATOR
    && !(mNetworkReachability & NetworkReachabilityConnectionRequired)
#endif
    ;
}

- (BOOL)isReachable:(NSString *)hostName {
    BOOL reachable = NO;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(
                                                                                NULL, [hostName cStringUsingEncoding:NSASCIIStringEncoding]);
    if (reachability) {
        SCNetworkReachabilityFlags flags;
        reachable = (SCNetworkReachabilityGetFlags(reachability, &flags) == true) &&
        (flags & kSCNetworkFlagsReachable)
#if TARGET_OS_MAC || TARGET_IPHONE_SIMULATOR
        && !(flags & kSCNetworkFlagsConnectionRequired)
#endif
        ;
        CFRelease(reachability);
    }
    return reachable;
}

- (BOOL)isHostReachable {
    bool success = false;
    const char *host_name =
    [kReachabilityHostName cStringUsingEncoding:NSASCIIStringEncoding];
    SCNetworkReachabilityRef reachability =
    SCNetworkReachabilityCreateWithName(NULL, host_name);
    SCNetworkReachabilityFlags flags;
    success = SCNetworkReachabilityGetFlags(reachability, &flags);
    bool isAvailable = success && (flags & kSCNetworkFlagsReachable) &&
    !(flags & kSCNetworkFlagsConnectionRequired);
    if (isAvailable) {
        NSLog(@"Host is reachable: %d", flags);
    } else {
        NSLog(@"Host is unreachable");
    }
    return isAvailable;
}

- (void)dealloc {
    [self stopListening];
    [self stopHostListening];
    mReachabilityHostName = nil;
}

@end
