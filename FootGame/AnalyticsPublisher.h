//
//  AnalyticsPublisher.h
//  wishpot
//
//  Created by Owyn Richen on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAI.h"
#import <StoreKit/StoreKit.h>

#define apView(view) \
[[AnalyticsPublisher instance] trackView:(view)]

#define apEvent(evt, act, lbl) \
[[AnalyticsPublisher instance] trackEvent:(evt) action:(act) label:(lbl)]

#define apErr(error) \
[[AnalyticsPublisher instance] trackError:(error)];

#define apErrMsg(msg) \
[[AnalyticsPublisher instance] trackErrorWithMessage:(msg)];

#define apPurchase(pdct, trxn) \
[[AnalyticsPublisher instance] trackPurchase: (pdct) txn: (trxn)];

@interface AnalyticsPublisher : NSObject {
    id<GAITracker> ga;
}

+(AnalyticsPublisher *) instance;
-(void) trackView: (NSString *) view;
-(void) trackEvent: (NSString *) event action: (NSString *) action label: (NSString *) label;
-(void) trackError: (NSError *) error;
-(void) trackErrorWithMessage: (NSString *) msg;
-(void) trackPurchase: (SKProduct *) skpdct txn: (SKPaymentTransaction *) sktxn;
+(void) dispatch;

@end
