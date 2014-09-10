//
//  SPAdColonyRewardedVideoAdapter.m
//  SponsorPayTestApp
//
//  Created by Daniel Barden on 07/05/14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPRewardedVideoNetworkAdapter.h"
#import <AdColony/AdColony.h>

@class SPAdColonyNetwork;

@interface SPAdColonyRewardedVideoAdapter : NSObject <SPRewardedVideoNetworkAdapter, AdColonyDelegate, AdColonyAdDelegate>

@property (nonatomic, weak) SPAdColonyNetwork *network;

@end
