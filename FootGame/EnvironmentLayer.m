//
//  EnvironmentLayer.m
//  FootGame
//
//  Created by Owyn Richen on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EnvironmentLayer.h"

@implementation EnvironmentLayer

@synthesize key;
@synthesize animalPosition;
@synthesize textPosition;
@synthesize kidPosition;
@synthesize storyKey;
@synthesize touchLayers;

-(id) init {
    self = [super init];
    
    touchLayers = [[NSMutableDictionary alloc] init];

    return self;
}

-(void) dealloc {
    [touchLayers release];
    
    [super dealloc];
}

-(void) triggerRandomBehavior {
    NSMutableArray *array = [[touchLayers allKeys] mutableCopy];
    __block int girlIndex = -1;
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([@"Emma" isEqualToString:obj] || [@"Avery" isEqualToString:obj]) {
            girlIndex = idx;
            *stop = YES;
        }
    }];
    
    if (girlIndex != -1) {
        [array removeObjectAtIndex:girlIndex];
    }
    
    int random = arc4random()%[array count];
    NSString *k = [array objectAtIndex:random];
    
    CCAutoScalingSprite *node = [touchLayers objectForKey:k];
    [node.behaviorManager runBehaviors:@"touch" onNode:node withParams:[[[NSDictionary alloc] init] autorelease]];
}

-(void) showGirls {
    CCAutoScalingSprite *node;
    node = [touchLayers objectForKey:@"Emma"];
    if (node == nil)
        node = [touchLayers objectForKey:@"Avery"];
    
    if (node != nil) {
        [node.behaviorManager runBehaviors:@"touch" onNode:node withParams:[[[NSDictionary alloc] init] autorelease]];
    }
}

@end
