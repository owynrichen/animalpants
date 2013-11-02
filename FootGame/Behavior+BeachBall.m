//
//  Behavior+BeachBall.m
//  FootGame
//
//  Created by Owyn Richen on 9/15/13.
//
//

#import "Behavior+BeachBall.h"
#import "SoundManager.h"
#import "CCParticleSystem+Extras.h"

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
        
        CCCallBlockN *setZPlaySound = [CCCallBlockN actionWithBlock:^(CCNode *node) {
            node.zOrder = zOrder;
            [[SoundManager sharedManager] playSound:@"ball_bounce.mp3"];
        }];
        
        CCJumpTo *jump = [CCJumpTo actionWithDuration:3.0 position:ccpToRatio(node.position.x + 400, -ball.contentSize.height) height:(768 - node.position.y) / 2 jumps:1];
        
        CCCallBlockN *splash = [CCCallBlockN actionWithBlock:^(CCNode *node) {
            [[SoundManager sharedManager] playSound:@"splash.mp3"];
            CCParticleSystemQuad *emitter = [CCParticleSystemQuad particleWithFile:@"Splash.plist" params:params];
            emitter.position = ccpToRatio(node.position.x - node.contentSize.width / 2, node.position.y);
            [node.parent addChild:emitter z:node.zOrder];
            if (emitter.duration > -1) {
                [emitter cleanupWhenDone];
            }
        }];
        
        CCCallBlockN *remove = [CCCallBlockN actionWithBlock:^(CCNode *node) {
            [node.parent removeChild:node cleanup:YES];
        }];
        
        [ball runAction:[CCRotateBy actionWithDuration:5.0 angle:720]];
        [ball runAction:[CCSequence actions:move, setZPlaySound, jump, splash, remove, nil]];
    }];
    
    return spawnBall;
}

@end
