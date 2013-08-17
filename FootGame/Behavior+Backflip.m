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
    __block CGPoint origPosition = [self getOriginalPosition:params];
    __block CGFloat origRotate = [self getOriginalRotation:params];
    
    CCCallBlockN *centerAnchor = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        node.anchorPoint = ccp(0.5,0.5);
        node.position = ccp((node.contentSize.width * node.scaleX / 2) + node.position.x, (node.contentSize.height * node.scaleY / 2) + node.position.y);
    }];
    
    CCCallBlockN *resetAnchor = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        node.anchorPoint = ccp(0,0);
        node.position = origPosition;
        node.rotation = origRotate;
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
