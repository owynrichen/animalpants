//
//  AnalyticsPublisher.m
//  wishpot
//
//  Created by Owyn Richen on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnalyticsPublisher.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#define GA_ID @"UA-4051939-10"

@implementation AnalyticsPublisher

static AnalyticsPublisher *_instance;
static NSString *_sync = @"sync";

+(AnalyticsPublisher *) instance {
    if (_instance == NULL) {
        @synchronized(_sync) {
            if (_instance == NULL) {
                _instance = [[AnalyticsPublisher alloc] init];
            }
        }
    }
    
    return _instance;
}

-(id) init {
    self = [super init];
    // Optional: automatically track uncaught exceptions with Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
    // Create tracker instance.
    ga = [[GAI sharedInstance] trackerWithTrackingId:GA_ID];
    
    return self;
}

-(void) dealloc {
    if (ga != nil) {
        ga = nil;
    }
    
    [super dealloc];
}

-(void) trackView: (NSString *) view {
    
	[ga send:[[[GAIDictionaryBuilder createAppView] set:view forKey:kGAIScreenName] build]];
}

-(void) trackEvent: (NSString *) event action: (NSString *) action label: (NSString *) label {
	NSString *act = @"";
	NSString *lbl = @"";
	
	if (action != nil)
		act = action;
	
	if (label != nil)
		lbl = label;
    
    [ga send: [[GAIDictionaryBuilder createEventWithCategory:event action:act label:lbl value:[NSNumber numberWithInt:1]] build]];
}

-(void) trackError: (NSError *) error {
    if (error != nil) {
        [ga send:[[GAIDictionaryBuilder createExceptionWithDescription:[error localizedDescription] withFatal:NO] build]];
    } else  {
        [self trackErrorWithMessage:@"Unspecified Error"];
    }
}

-(void) trackErrorWithMessage:(NSString *)msg {
    [ga send:[[GAIDictionaryBuilder createExceptionWithDescription:msg withFatal:NO] build]];
}

-(void) trackPurchase: (SKProduct *) skpdct txn: (SKPaymentTransaction *) sktxn {
    apEvent(@"Purchase", sktxn.payment.productIdentifier, sktxn.transactionIdentifier);
    
    if (skpdct == nil) {
        return;
    }
    
    int64_t price = (int64_t) (skpdct.price.doubleValue * 1000000);
    [ga send:[[GAIDictionaryBuilder createTransactionWithId:sktxn.transactionIdentifier affiliation:@"In-App Store" revenue:[NSNumber numberWithLong: (long) price] tax:0 shipping:0 currencyCode:skpdct.priceLocale.localeIdentifier] build]];
    
    [ga send:[[GAIDictionaryBuilder createItemWithTransactionId:sktxn.transactionIdentifier name:skpdct.localizedTitle sku:skpdct.productIdentifier category:@"Animal Pants In-App" price:[NSNumber numberWithLong:(long) price] quantity:[NSNumber numberWithInt:sktxn.payment.quantity] currencyCode:skpdct.priceLocale.localeIdentifier] build]];
}

+(void) dispatch {
    [[GAI sharedInstance] dispatch];
}

@end
