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
    BOOL touchPoint = [params objectForKey:@"touch_responsive"] != nil;
    
    if (point.x == CGFLOAT_MAX && point.y == CGFLOAT_MAX)
        point = node.position;
    
    __block CCParticleSystemQuad *emitter = [CCParticleSystemQuad particleWithFile:particleDef];
    
    if (touchPoint) {
        point = [self parsePosition:[params objectForKey:@"touch"]];
        emitter.position = ccp(point.x, point.y);
    } else {
        emitter.position = ccpToRatio(point.x, point.y);
    }
    emitter.startSize = emitter.startSize * positionScaleForCurrentDevice(kDimensionY);
    emitter.startSizeVar = emitter.startSizeVar * positionScaleForCurrentDevice(kDimensionY);
    emitter.endSize = emitter.endSize * positionScaleForCurrentDevice(kDimensionY);
    emitter.endSizeVar = emitter.endSizeVar * positionScaleForCurrentDevice(kDimensionY);
    emitter.posVar = ccp(emitter.posVar.x * positionScaleForCurrentDevice(kDimensionY), emitter.posVar.y * positionScaleForCurrentDevice(kDimensionY));
    emitter.speed *= positionScaleForCurrentDevice(kDimensionY);
    emitter.speedVar *= positionScaleForCurrentDevice(kDimensionY);
    
    NSString *imageName = [params objectForKey:@"imageName"];
    
    if (imageName != nil) {
        CCTexture2D *texture = [[CCTextureCache sharedTextureCache] textureForKey:imageName];
        
        if (texture == nil) {
            texture = [[CCTextureCache sharedTextureCache] addImage:imageName];
        }
        
        if (texture != nil) {
            emitter.texture = texture;
        }
    }
    
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
