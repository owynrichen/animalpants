//
//  Behavior+ParticleSystem.m
//  FootGame
//
//  Created by Owyn Richen on 1/5/01.
//
//

#import "Behavior+ParticleSystem.h"
#import "CCAutoScaling.h"

@implementation Behavior(ParticleSystem)

-(CCAction *) particleSystemActionWithDef: (NSString *) particleDef params: (NSDictionary *) params {
    CCSprite *node = (CCSprite *) [params objectForKey:@"node"];
    CGPoint point = [self parsePosition:[params objectForKey:@"position"]];
    
    if (point.x == CGFLOAT_MAX && point.y == CGFLOAT_MAX)
        point = node.position;
    
    __block CCParticleSystemQuad *emitter = [CCParticleSystemQuad particleWithFile:particleDef];
    
    emitter.position = ccp(point.x, point.y);
//    emitter.startSize = emitter.startSize * positionRatioForCurrentDevice();
//    emitter.startSizeVar = emitter.startSizeVar * positionRatioForCurrentDevice();
//    emitter.endSize = emitter.endSize * positionRatioForCurrentDevice();
//    emitter.endSizeVar = emitter.endSizeVar * positionRatioForCurrentDevice();
//    emitter.posVar = ccp(emitter.posVar.x * positionRatioForCurrentDevice(), emitter.posVar.y * positionRatioForCurrentDevice());
    
    CCCallBlockN *start = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [node addChild:emitter z:1 tag:433];
    }];
    
    CGFloat duration = emitter.duration + emitter.life + emitter.lifeVar;
    CCDelayTime *delay = [CCDelayTime actionWithDuration:duration];
    
    CCCallBlockN *end = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [node removeChildByTag:433 cleanup:YES];
    }];
    
    CCSequence *seq = [CCSequence actions: start, delay, end, nil];
    
    return seq;
}

@end
