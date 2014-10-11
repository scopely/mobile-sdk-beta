//
//  SPAdColonyInterstitialAdapter.m
//  SponsorPayTestApp
//
//  Created by Paweł Kowalczyk on 30.06.2014.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import "SPAdColonyInterstitialAdapter.h"
#import "SPAdColonyNetwork.h"
#import "SPInterstitialClient.h"
#import "SPLogger.h"

#import "WBAdService+Internal.h"

#define LogInvocation SPLogDebug(@"%s", __PRETTY_FUNCTION__)

@interface SPAdColonyInterstitialAdapter()

@property (weak, nonatomic) id<SPInterstitialNetworkAdapterDelegate> delegate;

@property (copy, nonatomic) NSString *zoneId;
@property (assign, nonatomic, readonly) BOOL isInterstitialAvailable;

@end

@implementation SPAdColonyInterstitialAdapter

@synthesize offerData;
@synthesize zoneId;

- (NSString *)networkName
{
    return [self.network name];
}

- (BOOL)startAdapterWithDict:(NSDictionary *)dict
{
    LogInvocation;

    self.zoneId = [[WBAdService sharedAdService] fullpageIdForAdId:WBAdIdAC];
//    id zoneIdParam = dict[SPAdColonyInterstitialZoneId];
//    self.zoneId = [zoneIdParam isKindOfClass:[NSString class]] ? zoneIdParam : nil;
//    if (!self.zoneId.length) {
//        SPLogError(@"ZoneId for %@ interstitial missing or empty", self.networkName);
//        return NO;
//    }
    return YES;
}

#pragma mark - SPInterstitialNetworkAdapter protocol

- (BOOL)canShowInterstitial
{
    LogInvocation;
    
    if (!self.isInterstitialAvailable) {
        return NO;
    }
    return YES;
}

- (void)showInterstitialFromViewController:(UIViewController *)viewController
{
    if (self.isInterstitialAvailable) {
        [AdColony playVideoAdForZone:self.zoneId withDelegate:self];
    } else {
        SPLogDebug(@"Interstitial for network %@ is not available", self.network.name);
    }
}

#pragma mark - AdColonyDelegate Methods

// Is called when AdColony has taken control of the device screen and is about to begin showing an ad
- (void)onAdColonyAdStartedInZone:(NSString *)zoneID
{
    LogInvocation;
    
    if (![zoneID isEqualToString:self.zoneId]) {
        SPLogWarn(@"zoneId received is different than the one requested by the interstitial");
        return;
    }
    
    [self.delegate adapterDidShowInterstitial:self];
}

// Is called when AdColony has finished trying to show an ad, either successfully or unsuccessfully
- (void)onAdColonyAdAttemptFinished:(BOOL)shown inZone:(NSString *)zoneID
{
    LogInvocation;
    
    if (![zoneID isEqualToString:self.zoneId]) {
        SPLogWarn(@"zoneId received is different than the one requested by the interstitial");
        return;
    }
    
    //If shown == YES, an ad was displayed.
    if (shown) {
        [self.delegate adapter:self didDismissInterstitialWithReason:SPInterstitialDismissReasonUserClosedAd];
    }
    //If shown == NO, for some reason AdColony did not play an ad.
    else {
        NSString *description = [NSString stringWithFormat:@"%@ did not play an ad for zone %@", self.networkName, zoneID];
		SPLogDebug(description);
        NSError *error =
        [NSError errorWithDomain:SPInterstitialClientErrorDomain
                            code:SPInterstitialClientCannotInstantiateAdapterErrorCode
                        userInfo:@{SPInterstitialClientErrorLoggableDescriptionKey : description}];
        [self.delegate adapter:self didFailWithError:error];
    }
}

#pragma mark - Helper methods

- (BOOL)isInterstitialAvailable
{
    ADCOLONY_ZONE_STATUS status = [AdColony zoneStatusForZone:self.zoneId];
    
    BOOL isAvailable = NO;
    
    switch (status) {
        case ADCOLONY_ZONE_STATUS_NO_ZONE:
            SPLogDebug(@"%@ interstitial adapter has not been configured with that zone ID.", self.networkName);
            break;
        case ADCOLONY_ZONE_STATUS_OFF:
            SPLogDebug(@"The zone has been turned off on the www.adcolony.com control panel for %@ interstitial adapter.", self.networkName);
            break;
        case ADCOLONY_ZONE_STATUS_LOADING:
            SPLogDebug(@"The zone is preparing ads for display for %@ interstitial adapter.", self.networkName);
            break;
        case ADCOLONY_ZONE_STATUS_ACTIVE:
            SPLogDebug(@"The zone has completed preparing ads for display for %@ interstitial adapter.", self.networkName);
            isAvailable = YES;
            break;
        case ADCOLONY_ZONE_STATUS_UNKNOWN:
            SPLogDebug(@"%@ has not yet received the zone's configuration from the server.", self.networkName);
            break;
    }
    
    return isAvailable;
}

@end
