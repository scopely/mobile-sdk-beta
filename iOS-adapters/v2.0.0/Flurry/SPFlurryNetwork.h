//
//  Fyber iOS SDK - Flurry Adapter v.2.2.0
//
//  Created on 02/01/14.
//  Copyright (c) 2014 Fyber. All rights reserved.
//

#import "SPBaseNetwork.h"
#import "SPFlurryAdsMulticastDelegate.h"

@interface SPFlurryAppCircleClipsNetwork : SPBaseNetwork

@property (nonatomic, readonly) SPFlurryAdsMulticastDelegate *multicastDelegate;
@property (nonatomic, weak, readonly) UIWindow *mainWindow;
@end
