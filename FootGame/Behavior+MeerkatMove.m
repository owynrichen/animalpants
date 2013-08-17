//
//  Behavior+MeerkatMove.m
//  FootGame
//
//  Created by Owyn Richen on 8/17/13.
//
//

#import "Behavior+MeerkatMove.h"

@implementation Behavior(MeerkatMove)

-(CCAction *) meerkatMove: (NSDictionary *) params {
    NSNumber *durNum = (NSNumber *) [params objectForKey:@"duration"];
    CGPoint moveby = [self parseCoordinate:[params objectForKey:@"position"]];
    
    CCCallBlockN *setAnchor = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        node.anchorPoint = ccp(0.4,0.1);
    }];
    
    CCCallBlockN *resetAnchor = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        node.anchorPoint = ccp(0,0);
    }];
    
    CCRotateBy *ground = [CCRotateBy actionWithDuration:0.1 angle:90.0];
    CCJumpBy *hop = [CCJumpBy actionWithDuration:[durNum floatValue] position:moveby height:20 jumps:6];
    CCScaleTo *flip = [CCScaleTo actionWithDuration:0.1 scaleX:1.0 scaleY:-1.0];
    CCScaleTo *flipback = [CCScaleTo actionWithDuration:0.1 scaleX:1.0 scaleY:1.0];
    CCAction *hopback = [hop reverse];
    
    // return [CCSequence actions:[self resetNodeAction:params], ground, [self resetNodeAction:params], nil];
    
    return [CCSequence actions: [self resetNodeAction:params], setAnchor, ground, hop, [ground reverse], [CCDelayTime actionWithDuration:1.0], ground, flip, hopback, flipback, [ground reverse], resetAnchor, [self resetNodeAction:params], nil];
}

@end
