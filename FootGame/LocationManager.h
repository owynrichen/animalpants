//
//  LocationManager.h
//  FootGame
//
//  Created by Owyn Richen on 2/21/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef struct LatitudeLongitude {
    CGFloat longitude;
    CGFloat latitude;
} LatitudeLongitude;

typedef void (^LocationManagerCallback)(LatitudeLongitude);

@interface LocationManager : NSObject<CLLocationManagerDelegate> {
    CLLocationManager *mgr;
    LocationManagerCallback callback;
}

+(LocationManager *) sharedManager;

-(void) getLocation: (LocationManagerCallback) callback;
-(float) getLocalizedDistance: (float) distanceInKm;
-(BOOL) currentLocaleUsesMetric;

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations;
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

@end

static inline LatitudeLongitude llmk(CGFloat latitude, CGFloat longitude) {
    LatitudeLongitude ll; ll.latitude = latitude; ll.longitude = longitude; return ll;
}

static LatitudeLongitude llFromDict(NSDictionary *dict) {
    LatitudeLongitude ll;
    ll.latitude = [((NSNumber *) [dict objectForKey:@"lat"]) doubleValue];
    ll.longitude = [((NSNumber *) [dict objectForKey:@"lng"]) doubleValue];
    return ll;
}

#define EARTH_RAD 6371.0   // kilometers

static inline CGFloat d2r(CGFloat degrees) {
    return degrees * M_PI / 180;
}

static inline CGFloat r2d(CGFloat radians) {
    return radians * 180 / M_PI;
}

static inline CGFloat hdist(LatitudeLongitude l1, LatitudeLongitude l2) {
    CGFloat dlat = d2r(l2.latitude - l1.latitude);
    CGFloat dlng = d2r(l2.longitude - l1.longitude);
    CGFloat lat1 = d2r(l1.latitude);
    CGFloat lat2 = d2r(l2.latitude);
    
    CGFloat a = sin(dlat / 2) * sin(dlat / 2) +
    sin(dlng / 2) * sin(dlng / 2) *
    cos(lat1) * cos(lat2);
    
    CGFloat c = 2 * atan2(sqrt(a), sqrt(1-a));
    
    return EARTH_RAD * c;
}

