//
//  IAXNetworkService.h
//  XProject
//
//  Created by Ahmad Ansari on 9/11/14.
//  Copyright (c) 2014 Ahmad Ansari. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, AXNetworkType) {
  NetworkTypeNone = 0x00,
  NetworkTypeWLAN = 0x01 << 0, // WiFi
  NetworkType2G = 0x01 << 1,
  NetworkTypeEDGE = 0x01 << 2,
  NetworkType3G = 0x01 << 3,
  NetworkType4G = 0x01 << 4,
  NetworkTypeWWAN = (NetworkType2G | NetworkTypeEDGE | NetworkType3G |
                     NetworkType4G),
};

typedef NS_OPTIONS(NSInteger, AXNetworkReachability) {
  NetworkReachabilityNone = 0x00,
  NetworkReachabilityTransientConnection = 0x01 << 0,
  NetworkReachabilityReachable = 0x01 << 1,
  NetworkReachabilityConnectionRequired = 0x01 << 2,
  NetworkReachabilityConnectionAutomatic = 0x01 << 3,
  NetworkReachabilityInterventionRequired = 0x01 << 4,
  NetworkReachabilityIsLocalAddress = 0x01 << 5,
  NetworkReachabilityIsDirect = 0x01 << 6,
};

/*!
 @discussion
 Notification kNotifConnectivityChanged is Posted on internet connectivity
 change.
 */
#define kNotifConnectivityChanged @"kNotifConnectivityChanged"

/*!
 @discussion
 Notification kNotifNoConnectivity is Posted on NO internet connectivity.
 */
#define kNotifNoConnectivity @"kNotifNoConnectivity"

@protocol IAXNetworkService

- (BOOL)start;
- (BOOL)stop;
- (NSString *)getReachabilityHostName;
- (void)setReachabilityHostName:(NSString *)hostName;
- (AXNetworkType)getNetworkType;
- (AXNetworkReachability)getReachability;
- (BOOL)isReachable;
- (BOOL)isReachable:(NSString *)hostName;
- (BOOL)isHostReachable;

@property(readwrite, retain, getter=getReachabilityHostName,
          setter=setReachabilityHostName:) NSString *reachabilityHostName;
@property(readonly, getter=getNetworkType) AXNetworkType networkType;
@property(readonly, getter=getReachability) AXNetworkReachability reachability;
@property(readonly, getter=isReachable) BOOL reachable;

@end
