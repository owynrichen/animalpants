//
//  Behavior+BeachBall.m
//  FootGame
//
//  Created by Owyn Richen on 9/15/13.
//
//

#import "Behavior+BeachBall.h"

@implementation Behavior (BeachBall)

-(CCAction *) beachball: (NSDictionary *) params {
    CCSprite *n = (CCSprite *) [params objectForKey:@"node"];
    int zOrder = [((NSNumber *)[params objectForKey:@"behindZOrder"]) intValue];
    
    CCSprite *ball = [CCSprite spriteWithFile:@"beachball.png"];
    CGFloat x = n.position.x + n.contentSize.width;
    ball.position = ccpToRatio(x, 768 + ball.contentSize.height);
    ball.zOrder = n.zOrder;
    
    CCCallBlockN *spawnBall = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [node.parent addChild:ball];
        CCMoveTo *move = [CCMoveTo actionWithDuration:2.0 position:ccpToRatio(x, node.position.y + node.contentSize.height)];
        
        CCCallBlockN *setZ = [CCCallBlockN actionWithBlock:^(CCNode *node) {
            node.zOrder = zOrder;
        }];
        
        CCJumpTo *jump = [CCJumpTo actionWithDuration:3.0 position:ccpToRatio(node.position.x + 400, -ball.contentSize.height) height:(768 - node.position.y) / 2 jumps:1];
        
        CCCallBlockN *remove = [CCCallBlockN actionWithBlock:^(CCNode *node) {
            [node.parent removeChild:node cleanup:YES];
        }];
        
        [ball runAction:[CCRotateBy actionWithDuration:5.0 angle:720]];
        [ball runAction:[CCSequence actions:move, setZ, jump, remove, nil]];
    }];
    
    return spawnBall;
}

@end
