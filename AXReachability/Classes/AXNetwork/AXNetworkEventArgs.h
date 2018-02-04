//
//  AXNetworkService.h
//  XProject
//
//  Created by Ahmad Ansari on 9/11/14.
//  Copyright (c) 2014 Ahmad Ansari. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AXEventArgs.h"

#define kAXNetworkEventArgsName @"AXNetworkEventArgsName"

/**
 *  Network Event Types
 */
typedef NS_ENUM(NSInteger, AXNetworkEventTypes)
{
    /**
     *  Network State Changed Event
     */
    NetworkEventStateChanged,
};

@interface AXNetworkEventArgs : AXEventArgs {
    AXNetworkEventTypes eventType;
}

-(AXNetworkEventArgs*) initWithType:(AXNetworkEventTypes)eventType;

@property(readonly) AXNetworkEventTypes eventType;

@end
