//
//  SPFlurryInterstitialAdapter.m
//
//  Copyright (c) 2014 Fyber. All rights reserved.
//

#import "SPFlurryInterstitialAdapter.h"
#import "SPFlurryNetwork.h"
#import "SPFlurryAdsMulticastDelegate.h"
#import "SPLogger.h"

static const NSInteger kFlurryNoAdsErrorCode = 104;
static NSString *const SPFlurryInterstitialAdSpace = @"SPFlurryAdSpaceInterstitial";

@interface SPFlurryAppCircleClipsInterstitialAdapter ()

@property (nonatomic, weak) id<SPInterstitialNetworkAdapterDelegate> delegate;
@property (nonatomic, copy) NSString *interstitialAdsSpace;
@property (nonatomic, assign) BOOL adWasClicked;

@end

@implementation SPFlurryAppCircleClipsInterstitialAdapter

@synthesize offerData;

- (NSString *)networkName
{
    return [self.network name];
}

- (BOOL)startAdapterWithDict:(NSDictionary *)dict
{
    self.interstitialAdsSpace = dict[SPFlurryInterstitialAdSpace];
    if (!self.interstitialAdsSpace) {
        SPLogError(@"Could not start %@ interstitial Adapter. %@ empty or missing.", self.networkName, SPFlurryInterstitialAdSpace);
        return NO;
    }

    [self.network.multicastDelegate addAdDelegate:self];
    [self fetchFlurryAd];
    return YES;
}

- (void)fetchFlurryAd
{
    [FlurryAds fetchAdForSpace:self.interstitialAdsSpace
                         frame:self.network.mainWindow.rootViewController.view.frame
                          size:FULLSCREEN];
}


#pragma mark - SPInterstitialNetworkAdapter protocol

- (BOOL)canShowInterstitial
{
    if (![FlurryAds adReadyForSpace:self.interstitialAdsSpace]) {
        [self fetchFlurryAd];
        return NO;
    }
    return YES;
}

- (void)showInterstitialFromViewController:(UIViewController *)viewController
{
    // According to the documentation, the view is not used by the Flurry SDK, but setting to nil causes an exception
    UIView *topView = [[self.network.mainWindow subviews] lastObject];
    [FlurryAds displayAdForSpace:self.interstitialAdsSpace onView:topView viewControllerForPresentation:viewController];
    self.adWasClicked = NO;
    [self.delegate adapterDidShowInterstitial:self];
}

#pragma mark - FlurryAdDelegate protocol implementation

- (void)spaceDidFailToReceiveAd:(NSString *)adSpace error:(NSError *)error
{
    if (![self isThisAdSpace:adSpace] || error.code == kFlurryNoAdsErrorCode) {
        return;
    }

    NSError *interstitialError =
    [NSError errorWithDomain:@"com.sponsorpay.interstitialError"
                        code:error.code
                    userInfo:@{
                        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Flurry error: %@", error.localizedDescription],
                        NSUnderlyingErrorKey: error
                    }];
    [self.delegate adapter:self didFailWithError:interstitialError];
}

- (BOOL)spaceShouldDisplay:(NSString *)adSpace interstitial:(BOOL)interstitial
{
    return [self isThisAdSpace:adSpace] && interstitial;
}

- (void)spaceDidFailToRender:(NSString *)adSpace error:(NSError *)error
{
    if (![self isThisAdSpace:adSpace]) {
        return;
    }

    SPLogError(@"Flurry failed to render ad: %@", [error localizedDescription]);

    NSError *interstitialError =
    [NSError errorWithDomain:@"com.sponsorpay.interstitialError"
                        code:error.code
                    userInfo:@{
                        NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Flurry error: %@", error.localizedDescription]
                    }];
    [self.delegate adapter:self didFailWithError:interstitialError];
}

- (void)spaceDidDismiss:(NSString *)adSpace interstitial:(BOOL)interstitial
{
    if (![self isThisAdSpace:adSpace]) {
        return;
    }
    SPInterstitialDismissReason reason = SPInterstitialDismissReasonUserClosedAd;
    if (self.adWasClicked) {
        reason = SPInterstitialDismissReasonUserClickedOnAd;
    }

    [self.delegate adapter:self didDismissInterstitialWithReason:reason];
    [self fetchFlurryAd];
}

- (void)spaceDidReceiveClick:(NSString *)adSpace
{
    if ([self isThisAdSpace:adSpace]) {
        self.adWasClicked = YES;
    }
}

#pragma mark -

- (BOOL)isThisAdSpace:(NSString *)adSpace
{
    return [self.interstitialAdsSpace isEqualToString:adSpace];
}

@end
