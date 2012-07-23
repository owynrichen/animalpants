//
//  BehaviorManager.m
//  FootGame
//
//  Created by Owyn Richen on 7/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BehaviorManager.h"
#import "CCAutoScaling.h"

@implementation Behavior

@synthesize key;
@synthesize data;

+(Behavior *) behaviorFromKey: (NSString *) key dictionary: (NSDictionary *) data {
    Behavior *b = [[(Behavior *) [Behavior alloc] initWithKey:key data:data] autorelease];
    
    return b;
}

-(id) initWithKey: (NSString *) k data: (NSDictionary *) d {
    self = [super init];
    
    self.key = k;
    self.data = d;
    
    return self;
}

-(CCAction *) getAction {
    NSString *action = (NSString *) [data objectForKey:@"action"];
    
    if ([action isEqualToString:@"shake"]) {
        CCMoveBy *shakeUp = [CCMoveBy actionWithDuration:0.1 position:ccpToRatio(0, -10)];
        CCMoveBy *shakeDown = (CCMoveBy *) [shakeUp reverse];
        CCSequence *shake = [CCSequence actions:shakeUp, shakeDown, shakeUp, shakeDown, nil];
        shake.tag = 1;
        return shake;
    } else {
        NSLog(@"Unknown action %@ in set %@", action, [data description]);
    }
    
    return nil;
}

@end

@implementation BehaviorManager

-(id) init {
    self = [super init];
    
    behaviors = [[NSMutableDictionary alloc] init];
    
    return self;
}

-(void) addBehavior: (Behavior *) behavior {
    [behaviors setObject:behavior forKey:behavior.key];
}

-(Behavior *) getBehavior: (NSString *) key {
    return (Behavior *) [behaviors objectForKey:key];
}

-(void) removeBehavior: (NSString *) key {
    [behaviors removeObjectForKey:key];
}

@end
