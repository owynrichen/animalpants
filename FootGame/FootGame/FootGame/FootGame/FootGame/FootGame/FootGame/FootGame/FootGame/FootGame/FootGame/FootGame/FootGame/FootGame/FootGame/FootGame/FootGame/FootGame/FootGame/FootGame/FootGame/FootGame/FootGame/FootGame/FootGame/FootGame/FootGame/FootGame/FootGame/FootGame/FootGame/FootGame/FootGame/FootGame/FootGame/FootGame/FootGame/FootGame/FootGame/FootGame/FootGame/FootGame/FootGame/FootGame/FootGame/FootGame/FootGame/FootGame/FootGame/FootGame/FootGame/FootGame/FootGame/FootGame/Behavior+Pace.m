//
//  Behavior+Pace.m
//  FootGame
//
//  Created by Owyn Richen on 1/3/01.
//
//

#import "Behavior+Pace.h"
#import "CCDirector.h"
#import "Behavior+ParticleSystem.h"

@implementation Behavior(Pace)

-(CCAction *) pace: (NSDictionary *) params {
    CCSprite *node = (CCSprite *) [params objectForKey:@"node"];
    NSNumber *duration = (NSNumber *) [params objectForKey:@"duration"];
    NSNumber *delay = (NSNumber *) [params objectForKey:@"delayBetween"];
    
    float delayBetween = 0.0;
    if (delay != nil) {
        delayBetween = [delay floatValue];
    }
    
    CGPoint movePoint = ccpAdd(ccp(0, node.position.y), ccp(-node.texture.contentSizeInPixels.width * autoScaleForCurrentDevice() *positionScaleForCurrentDevice(kDimensionY), 0));
    
    CCMoveTo *move = [CCMoveTo actionWithDuration:[duration floatValue] position:movePoint];
    ;
    
    float scaleX = node.scaleX;

    CCCallBlockN *flipBlock = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        CCParticleSystem *particles = (CCParticleSystem *) [node getChildByTag:BEHAVIOR_PARTICLE_TAG];
        CCParticleSystem *update = nil;
        
        if (particles != nil) {
            particles.tag += 1;
            update = [particles copy];

            [particles moveToParentsParent];
        }
        
        node.scaleX = -1.0 * scaleX;
        
        if (update != nil) {
            [node addChild:update z:1 tag:BEHAVIOR_PARTICLE_TAG];
            [update matchScale:node];
        }
    }];
    
    CCCallBlockN *flipBackBlock = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        CCParticleSystem *particles = (CCParticleSystem *) [node getChildByTag:BEHAVIOR_PARTICLE_TAG];
        CCParticleSystem *update = nil;
        
        if (particles != nil) {
            particles.tag += 1;
            update = [particles copy];

            [particles moveToParentsParent];
        }
        
        node.scaleX = scaleX;
        
        if (update != nil) {
            [node addChild:update z:1 tag:BEHAVIOR_PARTICLE_TAG];
            [update matchScale:node];
        }
    }];

    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    CGPoint returnPoint = ccpAdd(ccp(winSize.width, node.position.y), ccp(node.texture.contentSizeInPixels.width * autoScaleForCurrentDevice() * positionScaleForCurrentDevice(kDimensionY), 0));
    
    CCMoveTo *moveBack = [CCMoveTo actionWithDuration:[duration floatValue] position:returnPoint];
    
    CCSequence *seq = [CCSequence actions:move, flipBlock, [CCDelayTime actionWithDuration:delayBetween], moveBack, flipBackBlock, [CCDelayTime actionWithDuration:delayBetween], nil];
    CCRepeatForever *rep = [CCRepeatForever actionWithAction:seq];
    rep.tag = BEHAVIOR_TAG_PACE;
    
    node.position = returnPoint;
    
    return rep;
}

@end
