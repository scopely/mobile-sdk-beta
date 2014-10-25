//
//  SPAdColonyNetwork.m
//  SponsorPayTestApp
//
//  Created by Daniel Barden on 07/05/14.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

// Adapter versioning - Remember to update the header

#import "SPAdColonyNetwork.h"
#import "SPTPNGenericAdapter.h"
#import "SPInterstitialNetworkAdapter.h"
#import "SPRewardedVideoNetworkAdapter.h"
#import "SPSemanticVersion.h"
#import "SPLogger.h"
#import "AdColony.h"

#import "WBAdService+Internal.h"

static const NSInteger SPAdColonyVersionMajor = 2;
static const NSInteger SPAdColonyVersionMinor = 1;
static const NSInteger SPAdColonyVersionPatch = 0;

static NSString *const SPAdColonyAppId = @"SPAdColonyAppId";
NSString *const SPAdColonyV4VCZoneId = @"SPAdColonyV4VCZoneId";
NSString *const SPAdColonyInterstitialZoneId = @"SPAdColonyInterstitialZoneId";

static NSString *const SPInterstitialAdapterClassName = @"SPAdColonyInterstitialAdapter";
static NSString *const SPRewardedVideoAdapterClassName = @"SPAdColonyRewardedVideoAdapter";

@interface SPAdColonyNetwork()

@property (strong, nonatomic) SPTPNGenericAdapter *rewardedVideoAdapter;
@property (weak, nonatomic) id<SPRewardedVideoNetworkAdapter, AdColonyDelegate> rewardedVideoNetworkAdapter;
@property (strong, nonatomic) id<SPInterstitialNetworkAdapter> interstitialAdapter;

@end

@implementation SPAdColonyNetwork

@synthesize rewardedVideoAdapter;
@synthesize rewardedVideoNetworkAdapter;
@synthesize interstitialAdapter;

#pragma mark - Class Methods

+ (SPSemanticVersion *)adapterVersion
{
    return [SPSemanticVersion versionWithMajor:SPAdColonyVersionMajor
                                         minor:SPAdColonyVersionMinor
                                         patch:SPAdColonyVersionPatch];
}


#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    if (self) {
        Class RewardedVideoAdapterClass = NSClassFromString(SPRewardedVideoAdapterClassName);
        if (RewardedVideoAdapterClass) {
            id<SPRewardedVideoNetworkAdapter, AdColonyDelegate> adColonyRewardedVideoNetworkAdapter = [[RewardedVideoAdapterClass alloc] init];
            self.rewardedVideoNetworkAdapter = adColonyRewardedVideoNetworkAdapter;
            
            self.rewardedVideoAdapter = [[SPTPNGenericAdapter alloc] initWithVideoNetworkAdapter:adColonyRewardedVideoNetworkAdapter];
            adColonyRewardedVideoNetworkAdapter.delegate = self.rewardedVideoAdapter;
        }
        
        Class InterstitialAdapterClass = NSClassFromString(SPInterstitialAdapterClassName);
        if (InterstitialAdapterClass) {
            self.interstitialAdapter = [[InterstitialAdapterClass alloc] init];
        }
    }
    return self;
}

- (BOOL)startSDK:(NSDictionary *)data
{
//    NSString *appId = [[WBAdService sharedAdService] fullpageIdForAdId:WBAdIdACAppId];
//    NSString *V4VCZoneId = [[WBAdService sharedAdService] fullpageIdForAdId:WBAdIdACIncentivizedZone];
//    NSString *interstitialZoneId = [[WBAdService sharedAdService] fullpageIdForAdId:WBAdIdAC];
//    
//    NSMutableArray *zoneIDs = [NSMutableArray array];
//    if (V4VCZoneId) {
//        [zoneIDs addObject:V4VCZoneId];
//    }
//    if (interstitialZoneId) {
//        [zoneIDs addObject:interstitialZoneId];
//    }
//    
//    [AdColony configureWithAppID:appId zoneIDs:zoneIDs delegate:self.rewardedVideoNetworkAdapter logging:YES];
    return YES;
}

@end
