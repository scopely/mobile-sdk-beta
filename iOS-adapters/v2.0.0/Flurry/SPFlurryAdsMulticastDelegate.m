//
//  SPFlurryAdsMulticastDelegate.m
//
//  Copyright (c) 2014 Fyber. All rights reserved.
//

#import "SPFlurryAdsMulticastDelegate.h"


@interface SPFlurryAdsMulticastDelegate ()

@property (nonatomic, strong) NSMutableArray *delegates;

@end

@implementation SPFlurryAdsMulticastDelegate : NSObject

- (id)init
{
    if (self = [super init]) {
        self.delegates = [NSMutableArray array];
    }
    return self;
}

- (void)addAdDelegate:(id)delegate
{
    [self.delegates addObject:delegate];
}

- (void)removeAdDelegate:(id)delegate
{
    [self.delegates removeObject:delegate];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }

    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:aSelector]) {
            return YES;
        }
    }

    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];

    if (!signature) {
        for (id delegate in self.delegates) {
            if ([delegate respondsToSelector:aSelector]) {
                return [delegate methodSignatureForSelector:aSelector];
            }
        }
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if (strcmp(@encode(BOOL), [anInvocation.methodSignature methodReturnType]) == 0) {
        BOOL retValue = NO;
        // invocation will return YES, if one of the delegates will return YES.
        for (id delegate in self.delegates) {
            if ([delegate respondsToSelector:[anInvocation selector]]) {
                BOOL tempReturnValue;
                [anInvocation invokeWithTarget:delegate];
                [anInvocation getReturnValue:&tempReturnValue];
                retValue = retValue || tempReturnValue;
            }
        }
        [anInvocation setReturnValue:&retValue];
    } else {
        for (id delegate in self.delegates) {
            if ([delegate respondsToSelector:[anInvocation selector]]) {
                [anInvocation invokeWithTarget:delegate];
            }
        }
    }
}


@end
