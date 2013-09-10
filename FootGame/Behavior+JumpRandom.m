//
//  Behavior+JumpRandom.m
//  FootGame
//
//  Created by Owyn Richen on 9/9/13.
//
//

#import "Behavior+JumpRandom.h"

@implementation Behavior(JumpRandom)

-(CCAction *) randomJump: (NSDictionary *) params {
    CCNode *node = (CCNode *) [params objectForKey:@"node"];

    float dist = 70;
    
    if ([params objectForKey:@"maxDistance"] != nil)
        dist = [(NSNumber *) [params objectForKey:@"maxDistance"] floatValue];
    
    double x = (double) arc4random() / (double) UINT32_MAX * dist * 2 + node.position.x - dist;
    double y = (double) arc4random() / (double) UINT32_MAX * dist * 2 + node.position.y - dist;
    
    return [CCJumpTo actionWithDuration:0.5 position:ccp(x,y) height:dist / 2 jumps:1];
}

@end
