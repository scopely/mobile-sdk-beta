//
//  SPFlurryInterstitialAdapter.m
//
//  Copyright (c) 2014 Fyber. All rights reserved.
//

#import "SPFlurryNetwork.h"
#import "FlurryAdDelegate.h"

@class SPFlurryInterstitialAdapter;

@interface SPFlurryAppCircleClipsInterstitialAdapter : NSObject<SPInterstitialNetworkAdapter, FlurryAdDelegate>

@property (weak, nonatomic) SPFlurryAppCircleClipsNetwork *network;

@end
