//
//  AnalyticsPublisher.m
//  wishpot
//
//  Created by Owyn Richen on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnalyticsPublisher.h"

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
	
	[ga trackEventWithCategory:event withAction:action withLabel:label withValue:[NSNumber numberWithInt: 1]];
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

+(void) dispatch {
    [[GAI sharedInstance] dispatch];
}

@end
