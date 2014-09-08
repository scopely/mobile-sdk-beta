//
//  SPFacebookInterstitialAdapter.m
//  SponsorPayTestApp
//
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import "SPFacebookInterstitialAdapter.h"
#import "SPFacebookNetwork.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "SPLogger.h"

static const NSInteger kSPFacebookNoAdsErrorCode  = 1001;
static const NSInteger kSPFacebookWrongPlacementIdErrorCode  = 2001;

static NSString *const SPFacebookPlacementId = @"SPFacebookInterstitialPlacementId";

@interface SPFacebookInterstitialAdapter()<FBInterstitialAdDelegate>{

}

@property (weak, nonatomic) id<SPInterstitialNetworkAdapterDelegate> delegate;
@property (assign, nonatomic) BOOL userClickedAd;
@property (nonatomic, strong, readwrite) FBInterstitialAd *interstitialAd;
@property (copy, nonatomic, readwrite) NSString *placementId;

@end

@implementation SPFacebookInterstitialAdapter

@synthesize offerData;

- (NSString *)networkName
{
    return [self.network name];
}

- (BOOL)startAdapterWithDict:(NSDictionary *)dict
{
    self.placementId = dict[SPFacebookPlacementId];
    [self loadInterstital];
    return YES;
}

#pragma mark - SPInterstitialNetworkAdapter protocol
- (BOOL)canShowInterstitial
{
    if (!self.interstitialAd || !self.interstitialAd.isAdValid)
    {
        [self loadInterstital];
        return NO;
    } else {
        return YES;
    }
}

- (void)showInterstitialFromViewController:(UIViewController *)viewController
{
        self.userClickedAd = NO;
        [self.interstitialAd showAdFromRootViewController:viewController];
        [self.delegate adapterDidShowInterstitial:self];
}

- (void) loadInterstital
{
    self.interstitialAd = [[FBInterstitialAd alloc] initWithPlacementID:self.placementId];
    self.interstitialAd.delegate = self;
    [self.interstitialAd loadAd];
}


#pragma mark - FBInterstitialAdDelegate methods

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    if(kSPFacebookWrongPlacementIdErrorCode == error.code){
        SPLogError(@" %@ error. Invalid SPFacebookPlacementId.", self.networkName);
    }
    
    if(kSPFacebookNoAdsErrorCode == error.code){
        
    }else{
        NSError *interstitialError = [NSError errorWithDomain:@"com.sponsorpay.interstitialError" code:error.code userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"FBInterstitialAd did fail with error  %@", error]}];
        [self.delegate adapter:self didFailWithError:interstitialError];
    }
}

- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd
{
    self.userClickedAd = YES;
}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd
{
    SPInterstitialDismissReason reason = self.userClickedAd ?
    SPInterstitialDismissReasonUserClickedOnAd : SPInterstitialDismissReasonUserClosedAd;
    
    [self.delegate adapter:self didDismissInterstitialWithReason:reason];
    self.interstitialAd = nil;
    [self loadInterstital];
}

@end
