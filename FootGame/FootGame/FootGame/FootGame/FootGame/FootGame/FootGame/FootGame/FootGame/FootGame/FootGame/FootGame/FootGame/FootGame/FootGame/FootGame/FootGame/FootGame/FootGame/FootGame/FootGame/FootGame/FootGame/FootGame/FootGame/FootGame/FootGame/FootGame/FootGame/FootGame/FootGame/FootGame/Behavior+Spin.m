//
//  Behavior+Spin.m
//  FootGame
//
//  Created by Owyn Richen on 1/7/13.
//
//

#import "Behavior+Spin.h"

@implementation Behavior(Spin)

-(CCAction *) spin: (NSDictionary *) params {
    __block CGPoint origAnchor;
    __block CGPoint origPosition;
    
    CCCallBlockN *centerAnchor = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        origAnchor = node.anchorPoint;
        origPosition = node.position;
        node.anchorPoint = ccp(0.5,0.5);
        node.position = ccp((node.contentSize.width * node.scaleX / 2) + node.position.x, (node.contentSize.height * node.scaleY / 2) + node.position.y);
    }];
    
    CCCallBlockN *resetAnchor = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        node.anchorPoint = origAnchor;
        node.position = origPosition;
    }];
    
    CCRotateBy *flip = [CCRotateBy actionWithDuration:2.0 angle:1080];
    
    CCSequence *seq = [CCSequence actions:centerAnchor, flip, resetAnchor, nil];
    
    return seq;

}

@end
