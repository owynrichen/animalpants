//
//  Behavior+Pace.m
//  FootGame
//
//  Created by Owyn Richen on 1/3/01.
//
//

#import "Behavior+Pace.h"
#import "CCDirector.h"

@implementation Behavior(Pace)

-(CCAction *) pace: (NSDictionary *) params {
    CCSprite *node = (CCSprite *) [params objectForKey:@"node"];
    NSNumber *duration = (NSNumber *) [params objectForKey:@"duration"];
    
    CGPoint movePoint = ccpAdd(ccp(0, node.position.y), ccp(-node.texture.contentSizeInPixels.width * autoScaleForCurrentDevice() *positionScaleForCurrentDevice(kDimensionY), 0));
    
    CCMoveTo *move = [CCMoveTo actionWithDuration:[duration floatValue] position:movePoint];
    CCScaleTo *flip = [CCScaleTo actionWithDuration:0.01 scaleX:(-1 * node.scaleX) scaleY:node.scaleY];
    CCScaleTo *flipBack = [CCScaleTo actionWithDuration:0.01 scaleX:node.scaleX scaleY:node.scaleY];

    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    CGPoint returnPoint = ccpAdd(ccp(winSize.width, node.position.y), ccp(node.texture.contentSizeInPixels.width * autoScaleForCurrentDevice() * positionScaleForCurrentDevice(kDimensionY), 0));
    
    CCMoveTo *moveBack = [CCMoveTo actionWithDuration:[duration floatValue] position:returnPoint];
    
    CCSequence *seq = [CCSequence actions:move, flip, moveBack, flipBack, nil];
    CCRepeatForever *rep = [CCRepeatForever actionWithAction:seq];
    rep.tag = BEHAVIOR_TAG_PACE;
    
    node.position = returnPoint;
    
    return rep;
}

@end
