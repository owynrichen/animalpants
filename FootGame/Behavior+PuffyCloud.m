//
//  Behavior+PuffyCloud.m
//  FootGame
//
//  Created by Owyn Richen on 11/20/12.
//
//

#import "Behavior+PuffyCloud.h"
#import "Behavior+ParticleSystem.h"

@implementation Behavior(PuffyCloud)

-(CCAction *) floaty: (NSDictionary *) params {
    NSDictionary *sDevDict = (NSDictionary *)[params objectForKey:@"scaleDeviation"];
    NSDictionary *pDevDict = (NSDictionary *)[params objectForKey:@"positionDeviation"];
    NSNumber *durNum = (NSNumber *) [params objectForKey:@"duration"];
    NSNumber *durDevNum = (NSNumber *) [params objectForKey:@"durationDeviation"];
    
    CGPoint scaleDev;
    CGPoint posDev;
    float duration, durationDeviation;
    
    if (durNum != nil) {
        duration = [durNum floatValue];
    } else {
        duration = 2.5;
    }
    
    if (durDevNum != nil) {
        durationDeviation = [durDevNum floatValue];
    } else {
        durationDeviation = 1.25;
    }
    
    if (sDevDict != nil) {
        scaleDev = [self parsePosition:sDevDict];
    } else {
        scaleDev = CGPointMake(0.2,0.2);
    }
    
    if (pDevDict != nil) {
        posDev = [self parsePosition:pDevDict];
    } else {
        posDev = ccpToRatio(20, 20);
    }
    
    // TODO: randomize the floatyness using the deviations
    
    CCScaleBy *scaleX = [CCScaleBy actionWithDuration:duration / 2.0 scaleX:scaleDev.x scaleY:0];
    CCScaleBy *scaleXRev = [CCScaleBy actionWithDuration: duration scaleX: scaleDev.x * 2.0 * -1.0 scaleY:0];
    CCScaleBy *scaleXFwd = [CCScaleBy actionWithDuration: duration scaleX: scaleDev.x * 2.0 scaleY:0];
    
    // CCScaleBy *scaleY = [CCScaleBy actionWithDuration:duration scaleX:0 scaleY:scaleDev.y];
    // CCMoveBy *move = [CCMoveBy actionWithDuration:duration position:posDev];
    
    CCAction *repeat = [CCRepeatForever actionWithAction:[CCSequence actions:scaleXRev, scaleXFwd, nil]];
    CCAction *scaleXseq = [CCSequence actions: scaleX, repeat, nil];
    // CCRepeatForever *scaleYseq = [CCRepeatForever actionWithAction:[CCSequence actions:scaleY, [scaleY reverse], nil]];
    // CCRepeatForever *moveSeq = [CCRepeatForever actionWithAction:[CCSequence actions:move, [move reverse], nil]];
    
    CCCallBlockN *callBlock = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [node runAction:scaleXseq];
        //[node runAction:scaleYseq];
        //[node runAction:moveSeq];
    }];
    
    return callBlock;
}

-(CCAction *) puff: (NSDictionary *) params {
    CCAction *def = [self particleSystemActionWithDef:@"Smoke.plist" params:params];
    
    def.tag = BEHAVIOR_TAG_PUFF;
    
    return def;
}

@end
