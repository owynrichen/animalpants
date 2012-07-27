//
//  BehaviorManager.m
//  FootGame
//
//  Created by Owyn Richen on 7/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BehaviorManager.h"

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

-(BOOL) hasBehaviors {
    return [behaviors count] > 0;
}

@end
