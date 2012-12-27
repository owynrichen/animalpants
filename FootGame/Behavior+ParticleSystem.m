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
    
    CCParticleSystemQuad *emitter = [CCParticleSystemQuad particleWithFile:particleDef params:params];
    
    if (emitter.position.x == CGFLOAT_MAX && emitter.position.y == CGFLOAT_MAX)
        emitter.position = node.position;
    
    CCCallBlockN *start = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [node addChild:emitter z:1 tag:BEHAVIOR_PARTICLE_TAG];
        [emitter matchScale:node];
        if (emitter.duration > -1) {
            [emitter cleanupWhenDone];
        }
    }];
    
    return start;
}

@end
