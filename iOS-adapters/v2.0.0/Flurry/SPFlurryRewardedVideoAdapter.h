//
//  SPFlurryAdapter.h
//
//  Created on 6/17/13.
//  Copyright (c) 2011-2014 Fyber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPTPNVideoAdapter.h"
#import "SPFlurryNetwork.h"

#import "FlurryAdDelegate.h"

@class SPFlurryAppCircleClipsNetwork;

@interface SPFlurryAppCircleClipsRewardedVideoAdapter : NSObject <SPTPNVideoAdapter, FlurryAdDelegate>

@property (nonatomic, weak) SPFlurryAppCircleClipsNetwork *network;

@end
