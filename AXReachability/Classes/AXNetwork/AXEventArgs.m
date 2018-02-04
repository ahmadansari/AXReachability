//
//  AXNetworkService.h
//  XProject
//
//  Created by Ahmad Ansari on 9/11/14.
//  Copyright (c) 2014 Ahmad Ansari. All rights reserved.
//

#import "AXEventArgs.h"

@implementation AXEventArgs

- (void)putExtraWithKey:(NSString *)key andValue:(NSString *)value {
  if (!mExtras) {
    mExtras = [[NSMutableDictionary alloc] init];
  }
  if (value) {
    [mExtras setObject:value forKey:key];
  }
}

- (NSString *)getExtraWithKey:(NSString *)key {
  return [mExtras objectForKey:key];
}

- (void)dealloc {
  mExtras = nil;
}

@end
