//
//  SPAppleIAdInterstitialAdapter.m
//  SponsorPayTestApp
//
//  Created by Paweł Kowalczyk on 03.06.2014.
//  Copyright (c) 2014 SponsorPay. All rights reserved.
//

#import "SPAppleIAdInterstitialAdapter.h"
#import "SPAppleIAdNetwork.h"
#import "SPLogger.h"
#import "SPSystemVersionChecker.h"

#define LogInvocation SPLogDebug(@"%s", __PRETTY_FUNCTION__);

@interface SPAppleIAdInterstitialAdapter()

@property (weak, nonatomic) id<SPInterstitialNetworkAdapterDelegate> delegate;

@property (strong, nonatomic) ADInterstitialAd *interstitialAd;
@property (assign, nonatomic) BOOL userClickedAd;
@property (assign, nonatomic, getter = isInterstitialAvailable) BOOL interstitialAvailable;
@property (strong, nonatomic) UIViewController *adViewController;

- (void)fetchInterstitial;

@end

@implementation SPAppleIAdInterstitialAdapter

@synthesize offerData;
@synthesize adViewController;

- (NSString *)networkName
{
    return [self.network name];
}

- (BOOL)startAdapterWithDict:(NSDictionary *)dict
{
    // Sets the specific data for interstitials, such as ad placements.
    // The data dictionary contains the SPNetworkParameters dictionary read from the plist file
    LogInvocation
    
    [self fetchInterstitial];
    
    return YES;
}

#pragma mark - SPInterstitialNetworkAdapter protocol

- (BOOL)canShowInterstitial
{
    LogInvocation
    
    if (!self.isInterstitialAvailable) {
        
        [self fetchInterstitial];
        return NO;
    }
    return YES;
}

- (void)showInterstitialFromViewController:(UIViewController *)viewController
{
    LogInvocation
    
    if ([SPSystemVersionChecker runningOniOS7OrNewer]) {
        [viewController setInterstitialPresentationPolicy:ADInterstitialPresentationPolicyManual];
    }
    
    if (self.interstitialAd.loaded) {
        
        self.adViewController = [UIViewController new];
        [viewController presentViewController:self.adViewController animated:YES completion:nil];
        [self.interstitialAd presentInView:self.adViewController.view];
        [self.delegate adapterDidShowInterstitial:self];
    }
}

- (void)fetchInterstitial
{
    self.interstitialAd = [[ADInterstitialAd alloc] init];
    [self.interstitialAd setDelegate:self];
    if ([SPSystemVersionChecker runningOniOS7OrNewer]) {
        [UIViewController prepareInterstitialAds];
    }
}

#pragma mark - ADInterstitialAdDelegate

- (void)interstitialAdWillLoad:(ADInterstitialAd *)interstitialAd
{
    LogInvocation
}

- (void)interstitialAdDidLoad:(ADInterstitialAd *)interstitialAd
{
    LogInvocation
    
    self.interstitialAvailable = YES;
}

//method fired when the user taps a presented advertisement, the ad’s delegate is called to inform your application that the user wants to interact with the ad
- (BOOL)interstitialAdActionShouldBegin:(ADInterstitialAd *)interstitialAd willLeaveApplication:(BOOL)willLeave
{
    LogInvocation
    self.userClickedAd = YES;
    return YES;
}

- (void)interstitialAdActionDidFinish:(ADInterstitialAd *)interstitialAd
{
    LogInvocation
    
    [self.adViewController dismissViewControllerAnimated:YES completion:^{
        
        if (self.userClickedAd) {
            [self.delegate adapter:self didDismissInterstitialWithReason:SPInterstitialDismissReasonUserClickedOnAd];
        }
        else {
            [self.delegate adapter:self didDismissInterstitialWithReason:SPInterstitialDismissReasonUserClosedAd];
        }
    }];
}

- (void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd
{
    LogInvocation
    [self.interstitialAd setDelegate:nil];
    self.interstitialAd = nil;
}

- (void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    LogInvocation
    self.interstitialAvailable = NO;
    [self.interstitialAd setDelegate:nil];
    self.interstitialAd = nil;
    [self.delegate adapter:self didFailWithError:error];
    SPLogError(@"%s %@", __PRETTY_FUNCTION__, [error localizedDescription]);
}

@end
