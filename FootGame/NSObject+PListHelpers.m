//
//  NSObject+PListHelpers.m
//  FootGame
//
//  Created by Owyn Richen on 12/26/12.
//
//

#import "NSObject+PListHelpers.h"

@implementation NSObject(PListHelpers)

-(CGPoint) parseCoordinate:(NSDictionary *)coordinate {
    if (coordinate == nil)
        return CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
    
    NSNumber *x = (NSNumber *) [coordinate objectForKey:@"x"];
    NSNumber *y = (NSNumber *) [coordinate objectForKey:@"y"];
    
    if (x == nil || y == nil)
        return CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
    
    return CGPointMake([x floatValue],[y floatValue]);
}

@end
