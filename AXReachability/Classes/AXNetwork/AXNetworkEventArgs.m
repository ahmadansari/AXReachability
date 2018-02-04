//
//  AXNetworkService.h
//  XProject
//
//  Created by Ahmad Ansari on 9/11/14.
//  Copyright (c) 2014 Ahmad Ansari. All rights reserved.
//

#import "AXNetworkEventArgs.h"

@implementation AXNetworkEventArgs

@synthesize eventType;

- (AXNetworkEventArgs *)initWithType:(AXNetworkEventTypes)eventType {
    if ((self = [super init])) {
    }
    return self;
}

- (void)dealloc {
}

@end
