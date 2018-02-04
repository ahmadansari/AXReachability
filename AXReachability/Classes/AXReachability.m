//
//  AXReachability.m
//  XProject
//
//  Created by Ahmad Ansari on 9/11/14.
//  Copyright (c) 2014 Ahmad Ansari. All rights reserved.
//

#import "AXReachability.h"

@implementation AXReachability

#pragma mark -
#pragma mark ARC Singleton Implementation
static AXReachability *sharedInstance = nil;
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
+ (AXReachability *) sharedReachability
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
- (id)init
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
{
    Class myClass = [self class];
    @synchronized(myClass) {
        if (self = [super init]) {
            sharedInstance = self;
            // Do any other initialisation stuff here
        }
    }
    return sharedInstance;
}

/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
+ (id)allocWithZone:(NSZone *)zone
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super allocWithZone:zone];
    });
    return sharedInstance;
}

/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
- (id)copyWithZone:(NSZone *)zone
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
{
    return self;
}

#pragma mark - Monitoring Methods
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
- (void)startMonitoring
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
{
    if (!self.networkService) {
        self.networkService = [[AXNetworkService alloc] init];
    }
    [self.networkService start];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNetworkEvent:)
                                                 name:kAXNetworkEventArgsName
                                               object:nil];
}

/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
- (void)stopMonintoring
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
{
    self.networkService = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kAXNetworkEventArgsName
                                                  object:nil];
}

#pragma mark - Connection Methods
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
- (AXNetworkType) networkType
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
{
    return [self.networkService getNetworkType];
}

- (NSString *) descriptionForNetworkType:(AXNetworkType)networkType {
    NSString *description = nil;
    switch (networkType) {
        case NetworkTypeWLAN:
            description = @"WiFi";
            break;
        case NetworkType2G:
        case NetworkTypeEDGE:
        case NetworkType3G:
        case NetworkType4G:
        case NetworkTypeWWAN:
            description = @"Mobile Data";
            break;
        case NetworkTypeNone:
        default:
            description = nil;
            break;
    }
    return description;
}

/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
- (BOOL)isConnectedViaWiFi
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
{
    BOOL onWiFiNetwork = NO;
    if (self.networkService.reachable) {
        onWiFiNetwork = (self.networkService.networkType & NetworkTypeWLAN);
    }
    return onWiFiNetwork;
}

/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
- (BOOL)isConnectedViaMobileNetwork
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
{
    BOOL onMobileNetwork = NO;
    if (self.networkService.reachable) {
        onMobileNetwork = (self.networkService.networkType & NetworkTypeWWAN);
    }
    return onMobileNetwork;
}

/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
- (BOOL)isConnectedToInternet
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
{
    BOOL onNetwork = NO;
    if ([self.networkService isReachable]) {
        onNetwork = YES;
    }
    return onNetwork;
}

/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
- (BOOL)isConnectedToHost
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
{
    BOOL hostReachable = NO;
    if ([self.networkService isHostReachable]) {
        hostReachable = YES;
    }
    return hostReachable;
}

#pragma - mark Network Events
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
- (void)onNetworkEvent:(NSNotification *)notification
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
{
    AXNetworkEventArgs *eargs = [notification object];
    
    switch (eargs.eventType) {
        case NetworkEventStateChanged:
        default: {
            NSLog(@"AXNetworkEvent reachable=%@ networkType=%li",
                  self.networkService.reachable ? @"YES" : @"NO",
                  (long)self.networkService.networkType);
            
            if (self.networkService.reachable) {
                BOOL onMobileNework = (self.networkService.networkType & NetworkTypeWWAN);
                
                if (onMobileNework) {
                    // 3G, 4G, EDGE ...
                } else {
                    // WiFi
                }
                [[NSNotificationCenter defaultCenter]
                 postNotification:[NSNotification
                                   notificationWithName:kNotifConnectivityChanged
                                   object:nil]];
            } else {
                // NOT CONNECTED
                [[NSNotificationCenter defaultCenter]
                 postNotification:[NSNotification
                                   notificationWithName:kNotifNoConnectivity
                                   object:nil]];
            }
            break;
        }
    }
}

// Network Observers
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
- (void)addNetworkObserver:(id)target
connectivityChangeSelector:(SEL)conSelector
noConnectivitySelector:(SEL)noConSelector
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
{
    NSAssert(target, @"Target cannot be nil");
    [[NSNotificationCenter defaultCenter] addObserver:target
                                             selector:noConSelector
                                                 name:kNotifNoConnectivity
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:target
                                             selector:conSelector
                                                 name:kNotifConnectivityChanged
                                               object:nil];
}

/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
- (void)removeNetworkObserver:(id)target
/*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
{
    NSAssert(target, @"Target cannot be nil");
    [[NSNotificationCenter defaultCenter] removeObserver:target
                                                    name:kNotifNoConnectivity
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:target
                                                    name:kNotifConnectivityChanged
                                                  object:nil];
}

@end
