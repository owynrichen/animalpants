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
    NSMutableArray *arr = [behaviors objectForKey:behavior.event];
    if (arr == nil) {
        arr = [NSMutableArray array];
    }
    
    [arr addObject:behavior];
    
    [behaviors setObject:arr forKey:behavior.event];
}

-(NSArray *) getBehaviors: (NSString *) event {
    return (NSArray *) [behaviors objectForKey:event];
}

-(void) removeBehaviors: (NSString *) event {
    [behaviors removeObjectForKey:event];
}

-(BOOL) hasBehaviors {
    return [behaviors count] > 0;
}

-(BOOL) runBehaviors: (NSString *) event onNode: (CCNode *) node {
    NSArray *bh = [self getBehaviors:event];
    
    if (bh != nil) {
        [bh enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Behavior *b = (Behavior *) obj;
            [node runAction:[b getAction:node]];
        }];
        
        return YES;
    }
    
    return NO;
}

@end
