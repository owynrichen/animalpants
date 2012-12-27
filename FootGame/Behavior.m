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
    
    srand(time(nil));
    
    self.key = k;
    self.data = d;
    self.event = [self.data objectForKey:@"event"];
    
    return self;
}

-(CCAction *) getAction: (CCNode *) node withParams: (NSDictionary *) p {
    NSString *action = (NSString *) [data objectForKey:@"action"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *) [data objectForKey:@"params"]];
    [params setObject:node forKey:@"node"];
    
    [params setValuesForKeysWithDictionary:p];

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

-(float) randWithBase: (float) base deviation: (float) dev {
    int halfDev = dev * 0.5 * 1000;
    int newDev = dev * 1000;
    
    float r = base + ((float)((rand() % halfDev) - (rand() % newDev)) / 1000.0);
    
    return r;
}

-(CGPoint) randXYWithBase: (CGPoint) base deviation: (CGPoint) dev {
    return CGPointMake([self randWithBase:base.x deviation:dev.x], [self randWithBase:base.y deviation:dev.y]);
}

@end
