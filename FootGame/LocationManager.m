//
//  LocationManager.m
//  FootGame
//
//  Created by Owyn Richen on 2/21/13.
//
//

#import "LocationManager.h"
#import "LocalizationManager.h"

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
    cachedLocation = nil;
    [mgr setDelegate:self];
    [mgr setDesiredAccuracy:kCLLocationAccuracyKilometer];
    
    return self;
}

-(void) dealloc {
    if (mgr != nil)
        [mgr release];
    
    if (callback != nil) {
        [callback release];
        
        callback = nil;
    }
    
    if (cachedLocation != nil) {
        llrelp(cachedLocation);
    }
    
    [super dealloc];
}

-(void) getLocation: (LocationManagerCallback) cb {
    if (callback != nil) {
        [callback release];
        
        callback = nil;
    }
    
    callback = [cb copy];
    
    if (callback && cachedLocation) {
        callback(*cachedLocation);
        
        [callback release];
        callback = nil;
    } else {
        [mgr startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations {

    CLLocation *loc = (CLLocation *) [[locations objectAtIndex:0] retain];
    if (callback) {
        if (cachedLocation != nil) {
            llrelp(cachedLocation);
        }
        
        cachedLocation = llmkp(loc.coordinate.latitude, loc.coordinate.longitude);
        callback(*cachedLocation);
        
        [callback release];
        callback = nil;
    }
    [loc release];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:locstr(@"location_error_title", @"strings", @"")
                                                    message:locstr(@"location_error_desc", @"strings", @"")
                                                   delegate:nil
                                          cancelButtonTitle:locstr(@"okay", @"strings", @"")
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}


-(BOOL) currentLocaleUsesMetric {
    NSLocale *locale = [[LocalizationManager sharedManager] getAppPreferredNSLocale];
    NSLocale *curLocale = [NSLocale currentLocale];
    if ([[locale.localeIdentifier substringToIndex:2] isEqualToString:@"en"] &&
        [curLocale.localeIdentifier isEqualToString:@"en_US"]) {
        return NO;
    }
    
    return [[locale objectForKey:NSLocaleUsesMetricSystem] boolValue];
}

-(float) getLocalizedDistance: (float) distanceInKm {
    if ([self currentLocaleUsesMetric]) {
        return distanceInKm;
    } else {
        return distanceInKm * 0.621371;
    }
}

@end
