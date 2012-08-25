//
//  Behavior.m
//  FootGame
//
//  Created by Owyn Richen on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Behavior.h"

@implementation Behavior

@synthesize key;
@synthesize event;
@synthesize data;

+(Behavior *) behaviorFromKey: (NSString *) key dictionary: (NSDictionary *) data {
    Behavior *b = [[(Behavior *) [Behavior alloc] initWithKey:key data:data] autorelease];
    
    return b;
}

-(id) initWithKey: (NSString *) k data: (NSDictionary *) d {
    self = [super init];
    
    self.key = k;
    self.data = d;
    self.event = [self.data objectForKey:@"event"];
    
    return self;
}

-(CCAction *) getAction: (CCNode *) node {
    NSString *action = (NSString *) [data objectForKey:@"action"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *) [data objectForKey:@"params"]];
    [params setObject:node forKey:@"node"];

    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", action]);
    CCAction *act = nil;
        
    if (sel != nil) {
        act = [self performSelector:sel withObject:params];
    }
        
    if (action != nil) {
        return act;
    } else {
        NSLog(@"Unknown action %@ in set %@", action, [data description]);
    }
    
    return nil;
}

-(CGPoint) parsePosition: (NSDictionary *) position {
    if (position == nil)
        return CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
    
    NSNumber *x = (NSNumber *) [position objectForKey:@"x"];
    NSNumber *y = (NSNumber *) [position objectForKey:@"y"];
    
    if (x == nil || y == nil)
        return CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
    
    return ccp([x intValue] * positionRatioForCurrentDevice(),[y intValue] * positionRatioForCurrentDevice());
}

@end
