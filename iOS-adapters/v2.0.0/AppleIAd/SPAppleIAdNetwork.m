//
//  SPAppleIAdNetwork.m
//  SponsorPay iOS SDK - InMobi Adapter v.2.0.0
//
//  Created by Paweł Kowalczyk on 03.06.2014.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import "SPAppleIAdNetwork.h"
#import "SPAppleIAdInterstitialAdapter.h"
#import "SPSemanticVersion.h"
#import "SPLogger.h"
#import "SPSystemVersionChecker.h"

// Adapter versioning - Remember to update the header
static const NSInteger SPIAdVersionMajor = 2;
static const NSInteger SPIAdVersionMinor = 0;
static const NSInteger SPIAdVersionPatch = 0;

@interface SPAppleIAdNetwork()

@property (strong, nonatomic) SPAppleIAdInterstitialAdapter *interstitialAdapter;

@end

@implementation SPAppleIAdNetwork

@synthesize interstitialAdapter = _interstitialAdapter;

+ (SPSemanticVersion *)adapterVersion
{
    return [SPSemanticVersion versionWithMajor:SPIAdVersionMajor
                                         minor:SPIAdVersionMinor
                                         patch:SPIAdVersionPatch];
}

- (id)init
{
    self = [super init];
    if (self) {
        _interstitialAdapter = [[SPAppleIAdInterstitialAdapter alloc] init];
    }
    return self;
}

- (BOOL)startSDK:(NSDictionary *)data
{
    // Validates the necessary inputs and return YES if the adapter was initialized
    // successfully or NO in case of failure
    
    //For iOS6 or lower ADInterstitialAd is available only on iPad
    if (![SPSystemVersionChecker runningOniOS7OrNewer] && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        SPLogError(@"Could not start %@ Provider. For iOS6 or lower interstitials are available only on iPad.", self.name);
        return NO;
    }
    return YES;
}

@end
