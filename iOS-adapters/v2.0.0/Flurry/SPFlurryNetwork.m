//
//  SPProviderFlurry.m
//  Fyber iOS SDK - Flurry Adapter v.2.2.0
//
//  Created on 02/01/14.
//  Copyright (c) 2014 Fyber. All rights reserved.
//

#import "SponsorPaySDK.h"

#import "SPFlurryNetwork.h"
#import "SPLogger.h"
#import "Flurry.h"
#import "SPSemanticVersion.h"
#import "SPTPNGenericAdapter.h"

static NSString *const SPProviderName = @"SPProviderName";
static NSString *const SPFlurryApiKey = @"SPFlurryApiKey";
static NSString *const SPFlurryLogLevel = @"SPFlurryLogLevel";
static NSString *const SPFlurryEnableTestAds = @"SPFlurryEnableTestAds";

static NSString *const SPFlurryLogLevelNone = @"none";
static NSString *const SPFlurryLogLevelCriticalOnly = @"criticalOnly";
static NSString *const SPFlurryLogLevelDebug = @"debug";
static NSString *const SPFlurryLogLevelAll = @"all";

// Adapter versioning - Remember to update the header
static const NSInteger SPFlurryVersionMajor = 2;
static const NSInteger SPFlurryVersionMinor = 2;
static const NSInteger SPFlurryVersionPatch = 0;


static NSString *const SPFlurryRewardedVideoAdapterClassName = @"SPFlurryAppCircleClipsRewardedVideoAdapter";
static NSString *const SPFlurryInterstitialAdapterClassName = @"SPFlurryAppCircleClipsInterstitialAdapter";

@interface SPFlurryAppCircleClipsNetwork ()


@property (nonatomic, assign, readwrite) SPNetworkSupport supportedServices;
@property (nonatomic, strong) id<SPTPNVideoAdapter> rewardedVideoAdapter;
@property (nonatomic, strong) id<SPInterstitialNetworkAdapter> interstitialAdapter;

@end

@implementation SPFlurryAppCircleClipsNetwork

@synthesize supportedServices;
@synthesize rewardedVideoAdapter;
@synthesize interstitialAdapter;
@synthesize multicastDelegate = _multicastDelegate;

#pragma mark - Class Methods

+ (SPSemanticVersion *)adapterVersion
{
    return
    [SPSemanticVersion versionWithMajor:SPFlurryVersionMajor minor:SPFlurryVersionMinor patch:SPFlurryVersionPatch];
}


#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];

    if (self) {
        Class RewardedVideoAdapterClass = NSClassFromString(SPFlurryRewardedVideoAdapterClassName);
        if (RewardedVideoAdapterClass) {
            self.rewardedVideoAdapter = [[RewardedVideoAdapterClass alloc] init];
        }

        Class InterstitialAdapterClass = NSClassFromString(SPFlurryInterstitialAdapterClassName);
        if (InterstitialAdapterClass) {
            self.interstitialAdapter = [[InterstitialAdapterClass alloc] init];
        }
    }

    return self;
}

- (BOOL)startSDK:(NSDictionary *)data
{
    NSString *apiKey = data[SPFlurryApiKey];
    if (!apiKey.length) {
        SPLogError(@"Could not start %@ Provider. %@ empty or missing.", self.name, SPFlurryApiKey);
        return NO;
    }
    NSString *logLevel = data[SPFlurryLogLevel];
    if (logLevel.length) {
        [Flurry setLogLevel:[self flurryLogLevel:logLevel]];
    }
    [Flurry startSession:apiKey];
    [Flurry addOrigin:@"SponsorPayIOS" withVersion:[SponsorPaySDK versionString]];
    
    BOOL testAdsEnabled = [(NSNumber *)data[SPFlurryEnableTestAds] boolValue];
    [FlurryAds initialize:self.mainWindow.rootViewController];
    [FlurryAds enableTestAds:testAdsEnabled];
    [FlurryAds setAdDelegate:self.multicastDelegate];
    return YES;
}

#pragma mark - Private

- (FlurryLogLevel)flurryLogLevel:(NSString *)logLevel
{
    if ([logLevel isEqualToString:SPFlurryLogLevelNone]) {
        return FlurryLogLevelNone;
    } else if ([logLevel isEqualToString:SPFlurryLogLevelCriticalOnly]) {
        return FlurryLogLevelCriticalOnly;
    } else if ([logLevel isEqualToString:SPFlurryLogLevelDebug]) {
        return FlurryLogLevelDebug;
    } else if ([logLevel isEqualToString:SPFlurryLogLevelAll]) {
        return FlurryLogLevelAll;
    }
    return FlurryLogLevelCriticalOnly;
}

- (SPFlurryAdsMulticastDelegate *)multicastDelegate
{
    if (!_multicastDelegate) {
        _multicastDelegate = [[SPFlurryAdsMulticastDelegate alloc] init];
    }

    return _multicastDelegate;
}

- (UIWindow *)mainWindow
{
    return [UIApplication sharedApplication].windows[0];
}

@end
