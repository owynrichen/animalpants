//
//  AnalyticsPublisher.m
//  wishpot
//
//  Created by Owyn Richen on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnalyticsPublisher.h"
#import <FacebookSDK/FacebookSDK.h>

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
        [ga close];
        ga = nil;
    }
    
    [super dealloc];
}

-(void) trackView: (NSString *) view {
	[ga trackView:view];
}

-(void) trackEvent: (NSString *) event action: (NSString *) action label: (NSString *) label {
	NSString *act = @"";
	NSString *lbl = @"";
	
	if (action != nil)
		act = action;
	
	if (label != nil)
		lbl = label;
	
	[ga trackEventWithCategory:event withAction:act withLabel:lbl withValue:[NSNumber numberWithInt: 1]];
}

-(void) trackError: (NSError *) error {
    if (error != nil) {
        [ga trackException:NO withNSError:error];
    } else  {
        [self trackErrorWithMessage:@"Unspecified Error"];
    }
}

-(void) trackErrorWithMessage: (NSString *) msg {
    // TODO: grab stack trace and deliver it...
    [ga trackException:NO withDescription:msg];
}

-(void) trackPurchase: (SKProduct *) skpdct txn: (SKPaymentTransaction *) sktxn {
    apEvent(@"Purchase", sktxn.payment.productIdentifier, sktxn.transactionIdentifier);
    
    if (skpdct == nil) {
        return;
    }
    
    GAITransaction *txn = [GAITransaction transactionWithId:sktxn.transactionIdentifier withAffiliation:@"In-App Store"];
    
    int64_t price = (int64_t) (skpdct.price.doubleValue * 1000000);
    txn.taxMicros = 0;
    txn.shippingMicros = 0;
    txn.revenueMicros =  price; // TODO: convert currency to US
    
    [txn addItemWithCode:skpdct.productIdentifier name:skpdct.localizedTitle category:@"Animal Pants In-App" priceMicros:price quantity:sktxn.payment.quantity];
    
    [ga trackTransaction:txn];
}

+(void) dispatch {
    [[GAI sharedInstance] dispatch];
}

@end
