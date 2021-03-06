//
//  Behavior+WaterDive.m
//  FootGame
//
//  Created by Owyn Richen on 9/23/13.
//
//

#import "Behavior+WaterDive.h"
#import "CCParticleSystem+Extras.h"
#import "SoundManager.h"

@implementation Behavior(WaterDive)

-(CCAction *) waterdive: (NSDictionary *) params {
    int zOrder = [((NSNumber *)[params objectForKey:@"behindZOrder"]) intValue];
    int origZ = [((NSNumber *)[params objectForKey:@"original_z"]) intValue];
    CGPoint origPos = [self getOriginalPosition:params];
    CCNode *n = (CCNode *) [params objectForKey:@"node"];

    CCMoveBy *move = [CCMoveTo actionWithDuration:0.25 position:ccp(origPos.x, origPos.y + n.contentSize.height)];
    
    CCCallBlockN *setZ = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        node.zOrder = zOrder;
    }];
    
    CCMoveTo *hide = [CCMoveTo actionWithDuration:0.25 position:ccpToRatio(origPos.x, origPos.y - 100)];
    
    CCCallBlockN *splash = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [[SoundManager sharedManager] playSound:@"splash.mp3"];
        CCParticleSystemQuad *emitter = [CCParticleSystemQuad particleWithFile:@"Splash.plist" params:params];
        emitter.position = ccpToRatio(node.position.x - node.contentSize.width / 2, node.position.y);
        [node.parent addChild:emitter z:node.zOrder];
        if (emitter.duration > -1) {
            [emitter cleanupWhenDone];
        }
    }];
    
    CCMoveBy *moveBack = [CCMoveTo actionWithDuration:0.5 position:ccp(origPos.x, origPos.y + n.contentSize.height / 2)];
    
    CCCallBlockN *setZ2 = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        node.zOrder = origZ;
    }];
    
    CCMoveBy *reset = [CCMoveTo actionWithDuration:0.25 position:origPos];
    
    return [CCSequence actions:
            move,
            setZ,
            hide,
            splash,
            [CCDelayTime actionWithDuration:1.5],
            moveBack,
            setZ2,
            reset,
            nil];
    
}

@end
