//
//  SPAppleIAdInterstitialAdapter.m
//  SponsorPayTestApp
//
//  Created by Paweł Kowalczyk on 03.06.2014.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//
#import "SPAppleIAdNetwork.h"
#import <iAd/iAd.h>

@class SPAppleIAdInterstitialAdapter;

@interface SPAppleIAdInterstitialAdapter : NSObject <SPInterstitialNetworkAdapter, ADInterstitialAdDelegate>

@property (weak, nonatomic) SPAppleIAdNetwork *network;

@end
