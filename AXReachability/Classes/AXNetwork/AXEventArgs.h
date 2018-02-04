//
//  AXNetworkService.h
//  XProject
//
//  Created by Ahmad Ansari on 9/11/14.
//  Copyright (c) 2014 Ahmad Ansari. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AXEventArgs : NSObject {
	NSMutableDictionary* mExtras;
}

-(void)putExtraWithKey: (NSString*)key andValue:(NSString*)value;
-(NSString*)getExtraWithKey: (NSString*)key;

@end
