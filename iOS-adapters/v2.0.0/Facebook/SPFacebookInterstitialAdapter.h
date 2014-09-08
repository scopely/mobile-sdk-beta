//
//  SPFacebookInterstitialAdapter.m
//  SponsorPayTestApp
//
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//
#import "SPFacebookNetwork.h"

@class SPFacebookInterstitialAdapter;

@interface SPFacebookInterstitialAdapter : NSObject <SPInterstitialNetworkAdapter>

@property (weak, nonatomic) SPFacebookAudienceNetworkNetwork *network;

@end
