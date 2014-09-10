//
//  SPAdColonyInterstitialAdapter.m
//  SponsorPayTestApp
//
//  Created by Paweł Kowalczyk on 30.06.2014.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import "SPAdColonyNetwork.h"
#import <AdColony/AdColony.h>

@class SPAdColonyInterstitialAdapter;

@interface SPAdColonyInterstitialAdapter : NSObject <SPInterstitialNetworkAdapter, AdColonyAdDelegate>

@property (weak, nonatomic) SPAdColonyNetwork *network;

@end
