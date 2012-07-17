//
//  EnvironmentLayer.m
//  FootGame
//
//  Created by Owyn Richen on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EnvironmentLayer.h"

@implementation EnvironmentLayer

@synthesize background;
@synthesize key;

+(id) initWithDictionary:(NSDictionary *)setupData {
    EnvironmentLayer *layer = [EnvironmentLayer node];
    
    layer.key = (NSString *) [setupData objectForKey:@"Key"];
    
    NSDictionary *background = (NSDictionary *) [setupData objectForKey:@"Background"];
    NSString *img = (NSString *) [background objectForKey:@"image"];
    layer.background = [CCAutoScalingSprite spriteWithFile:img];
    
    //layer.background.scale = 0.5 * CC_CONTENT_SCALE_FACTOR();
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    layer.background.position = ccp(winSize.width / 2, winSize.height / 2);
    
    [layer addChild:layer.background];
    
    return layer;
}

-(id) init {
    self = [super init];

    return self;
}

@end
