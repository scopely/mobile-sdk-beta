//
//  SPFlurryAdapter.m
//
//  Created on 6/17/13.
//  Copyright (c) 2011-2014 Fyber. All rights reserved.
//

#import "SPFlurryRewardedVideoAdapter.h"
#import "SPFlurryNetwork.h"
#import "SPLogger.h"

#import "FlurryAds.h"
static const NSInteger kFlurryNoAdsErrorCode = 104;
static NSString *const SPFlurryVideoAdSpace = @"SPFlurryAdSpaceVideo";

@interface SPFlurryAppCircleClipsRewardedVideoAdapter ()

@property (nonatomic, copy) NSString *videoAdsSpace;
@property (copy) SPTPNValidationResultBlock validationResultsBlock;

@property (copy) SPTPNVideoEventsHandlerBlock videoEventsCallback;
@property (assign, nonatomic) SPTPNProviderPlayingState playingState;

@property (assign) BOOL playingDidTimeout;


@end

@implementation SPFlurryAppCircleClipsRewardedVideoAdapter

- (BOOL)startAdapterWithDictionary:(NSDictionary *)dict
{
    self.videoAdsSpace = dict[SPFlurryVideoAdSpace];
    if (!self.videoAdsSpace) {
        SPLogError(@"Could not start %@ video Adapter. %@ empty or missing.", self.networkName, SPFlurryVideoAdSpace);
        return NO;
    }

    [self.network.multicastDelegate addAdDelegate:self];

    return YES;
}

- (NSString *)networkName
{
    return self.network.name;
}

- (void)videosAvailable:(SPTPNValidationResultBlock)callback
{
    if ([FlurryAds adReadyForSpace:self.videoAdsSpace]) {
        self.validationResultsBlock = nil;
        callback(self.networkName, SPTPNValidationSuccess);
    } else {
        self.validationResultsBlock = callback;
        [self fetchFlurryAd];
        [self startValidationTimeoutChecker];
    }
}

- (void)fetchFlurryAd
{
    [FlurryAds fetchAdForSpace:self.videoAdsSpace
                         frame:self.network.mainWindow.rootViewController.view.frame
                          size:FULLSCREEN];
}

- (void)startValidationTimeoutChecker
{
    void (^timeoutBlock)(void) = ^(void) {
        if (self.validating) {
            [self notifyOfValidationResult:SPTPNValidationTimeout];
        }
    };
    double delayInSeconds = SPTPNTimeoutInterval;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), timeoutBlock);
}


- (void)playVideoWithParentViewController:(UIViewController *)parentVC
                        notifyingCallback:(SPTPNVideoEventsHandlerBlock)eventsCallback
{
    self.videoEventsCallback = eventsCallback;
    self.playingState = SPTPNProviderPlayingStateWaitingForPlayStart;

    // According to the documentation, the view is not used by the Flurry SDK, but setting to nil causes an exception
    UIView *topView = [[self.network.mainWindow subviews] lastObject];
    [FlurryAds displayAdForSpace:self.videoAdsSpace onView:topView viewControllerForPresentation:parentVC];

    [self startPlayingTimeoutChecker];
}

- (void)startPlayingTimeoutChecker
{
    self.playingDidTimeout = NO;

    void (^timeoutBlock)(void) = ^(void) {
        if (self.playingState == SPTPNProviderPlayingStateWaitingForPlayStart) {
            self.playingDidTimeout = YES;
            self.playingState = SPTPNProviderPlayingStateNotPlaying;
            self.videoEventsCallback(self.networkName, SPTPNVideoEventTimeout);
        }
    };

    double delayInSeconds = SPTPNTimeoutInterval;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), timeoutBlock);
}

#pragma mark - FlurryAdDelegate

- (void)spaceDidReceiveAd:(NSString *)adSpace
{
    if ([self isThisAdSpace:adSpace]) {
        if (self.validating) {
            [self notifyOfValidationResult:SPTPNValidationSuccess];
        }
    }
}

- (void)spaceDidRender:(NSString *)space interstitial:(BOOL)interstitial
{
    if ([self isThisAdSpace:space]) {
        self.playingState = SPTPNProviderPlayingStatePlaying;
        self.videoEventsCallback(self.networkName, SPTPNVideoEventStarted);
    }
}

- (void)spaceDidFailToReceiveAd:(NSString *)adSpace error:(NSError *)error
{
    if ([self isThisAdSpace:adSpace]) {
        SPLogDebug(@"Flurry's callback invoked: %s %@", __PRETTY_FUNCTION__, error);

        if (self.validating) {
            SPTPNValidationResult validationResult =
            (error.code == kFlurryNoAdsErrorCode ? SPTPNValidationNoVideoAvailable : SPTPNValidationError);
            [self notifyOfValidationResult:validationResult];
        }
    }
}

- (BOOL)spaceShouldDisplay:(NSString *)adSpace interstitial:(BOOL)interstitial
{
    if ([self isThisAdSpace:adSpace]) {
        return !self.playingDidTimeout;
    }
    
    return YES;
}

- (void)spaceDidFailToRender:(NSString *)adSpace error:(NSError *)error
{
    if (![self isThisAdSpace:adSpace]) {
        return;
    }
    SPLogError(@"Flurry failed to render ad: %@", [error localizedDescription]);
    if (self.playingState != SPTPNProviderPlayingStateNotPlaying)
        self.videoEventsCallback(self.networkName, SPTPNVideoEventError);
}

- (void)videoDidFinish:(NSString *)adSpace
{
    if (![self isThisAdSpace:adSpace]) {
        return;
    }
    if (self.playingState == SPTPNProviderPlayingStatePlaying) {
        self.playingState = SPTPNProviderPlayingStateNotPlaying;
        self.videoEventsCallback(self.networkName, SPTPNVideoEventFinished);
    }
}

- (void)spaceDidDismiss:(NSString *)adSpace interstitial:(BOOL)interstitial
{
    if (![self isThisAdSpace:adSpace]) {
        return;
    }
    if (self.playingState == SPTPNProviderPlayingStatePlaying) {
        self.playingState = SPTPNProviderPlayingStateNotPlaying;
        self.videoEventsCallback(self.networkName, SPTPNVideoEventAborted);
    } else {
        self.videoEventsCallback(self.networkName, SPTPNVideoEventClosed);
    }
}

#pragma mark -

- (BOOL)validating
{
    return self.validationResultsBlock != nil;
}

- (void)notifyOfValidationResult:(SPTPNValidationResult)result
{
    if (self.validationResultsBlock) {
        self.validationResultsBlock(self.networkName, result);
        self.validationResultsBlock = nil;
    }
}

- (BOOL)isThisAdSpace:(NSString *)adSpace
{
    return [self.videoAdsSpace isEqualToString:adSpace];
}

@end
