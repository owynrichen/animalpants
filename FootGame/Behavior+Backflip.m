//
//  Behavior+Backflip.m
//  FootGame
//
//  Created by Owyn Richen on 1/3/01.
//
//

#import "Behavior+Backflip.h"

@implementation Behavior(Backflip)

-(CCAction *) backflip: (NSDictionary *) params {
    __block CGPoint origAnchor;
    __block CGPoint origPosition;
    
    CCCallBlockN *centerAnchor = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        origAnchor = node.anchorPoint;
        origPosition = node.position;
        node.anchorPoint = ccp(0.5,0.5);
        node.position = ccp((node.contentSize.width * node.scale / 2) + node.position.x, (node.contentSize.height * node.scale / 2) + node.position.y);
    }];
    
    CCCallBlockN *resetAnchor = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        node.anchorPoint = origAnchor;
        node.position = origPosition;
    }];
    
    CGPoint jump = ccpToRatio(0, 100);
    CCJumpBy *jumpUp = [CCJumpBy actionWithDuration:0.5 position:ccpToRatio(0, 0) height:jump.y jumps:1];
    CCRotateBy *flip = [CCRotateBy actionWithDuration:0.5 angle:-360];
    
    CCSpawn *backflip = [CCSpawn actions:jumpUp, flip, nil];
    
    CCSequence *seq = [CCSequence actions:centerAnchor, backflip, resetAnchor, nil];
    seq.tag = BEHAVIOR_TAG_BACKFLIP;
    
    return seq;
}

@end
