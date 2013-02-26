//
//  LocationManager.m
//  FootGame
//
//  Created by Owyn Richen on 2/21/13.
//
//

#import "LocationManager.h"

@implementation LocationManager

static LocationManager* _instance;
static NSString *_sync = @"";

+(LocationManager *) sharedManager {
    if (_instance == nil) {
        @synchronized(_sync) {
            if (_instance == nil) {
                _instance = [[LocationManager alloc] init];
            }
        }
    }
    
    return _instance;
}

-(id) init {
    self = [super init];
    
    mgr = [[CLLocationManager alloc] init];
    [mgr setDelegate:self];
    [mgr setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    
    return self;
}

-(void) dealloc {
    if (mgr != nil)
        [mgr release];
    
    if (callback != nil) {
        [callback release];
        
        callback = nil;
    }
    
    [super dealloc];
}

-(void) getLocation: (LocationManagerCallback) cb {
    if (callback != nil) {
        [callback release];
        
        callback = nil;
    }
    
    callback = [[cb copy] retain];
    
//    BOOL locationServicesEnabled = [CLLocationManager locationServicesEnabled];
//    if (locationServicesEnabled) {
        [mgr startUpdatingLocation];
//    }
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations {
    CLLocation *loc = (CLLocation *) [locations objectAtIndex:0];
    if (callback) {
        LatitudeLongitude ll = llmk(loc.coordinate.latitude, loc.coordinate.longitude);
        callback(ll);
        
        [callback release];
        callback = nil;
    }
}


-(BOOL) currentLocaleUsesMetric {
    return [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
}

-(float) getLocalizedDistance: (float) distanceInKm {
    if ([self currentLocaleUsesMetric]) {
        return distanceInKm;
    } else {
        return distanceInKm * 0.621371;
    }
}

@end
