//
//  AXNetworkService.h
//  XProject
//
//  Created by Ahmad Ansari on 9/11/14.
//  Copyright (c) 2014 Ahmad Ansari. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>
#include <SystemConfiguration/SystemConfiguration.h>

#import "IAXNetworkService.h"
#import "AXNetworkEventArgs.h"

@interface AXNetworkService : NSObject <IAXNetworkService>
{
    
@private
	BOOL mStarted;
	SCNetworkReachabilityRef        mReachability;
    SCNetworkReachabilityContext    mReachabilityContext;

    SCNetworkReachabilityRef        mHostReachability;
    SCNetworkReachabilityContext    mHostReachabilityContext;
    
	NSString *mReachabilityHostName;
    AXNetworkType mNetworkType;
	AXNetworkReachability mNetworkReachability;
}

@end
