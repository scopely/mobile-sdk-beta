//
//  SPFlurryAdsMulticastDelegate.h
//
//  Copyright (c) 2014 Fyber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlurryAds.h"

@interface SPFlurryAdsMulticastDelegate : NSObject

- (void)addAdDelegate:(id)delegate;
- (void)removeAdDelegate:(id)delegate;

@end
