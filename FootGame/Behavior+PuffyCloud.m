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
        duration = 1.5;
    }
    
    if (durDevNum != nil) {
        durationDeviation = [durDevNum floatValue];
    } else {
        durationDeviation = 0.75;
    }
    
    if (sDevDict != nil) {
        scaleDev = [self parsePosition:sDevDict];
    } else {
        scaleDev = CGPointMake(0.075,0.075);
    }
    
    if (pDevDict != nil) {
        posDev = [self parsePosition:pDevDict];
    } else {
        posDev = ccpToRatio(20, 20);
    }
    
    float xDur = [self randWithBase:duration deviation:durationDeviation];
    float yDur = [self randWithBase:duration deviation:durationDeviation];
    CGPoint sDev = [self randXYWithBase:CGPointMake(0, 0) deviation:scaleDev];
    
    CCScaleBy *scaleX = [CCScaleBy actionWithDuration:xDur / 2.0 scaleX:1.0 + sDev.x scaleY:1];
    CCScaleBy *scaleXRev = [CCScaleBy actionWithDuration: xDur scaleX: 1.0 + sDev.x * 2.0 * -1.0 scaleY:1];
    CCScaleBy *scaleXFwd = [CCScaleBy actionWithDuration: xDur scaleX: 1.0 + sDev.x * 2.0 scaleY:1];
    
    CCScaleBy *scaleY = [CCScaleBy actionWithDuration:yDur / 2.0 scaleX:1 scaleY:1.0 + sDev.y];
    CCScaleBy *scaleYRev = [CCScaleBy actionWithDuration: yDur scaleX:1 scaleY: 1.0 + sDev.y * 2.0 * -1.0];
    CCScaleBy *scaleYFwd = [CCScaleBy actionWithDuration: yDur scaleX:1 scaleY: 1.0 + sDev.y * 2.0];
    
    //CCMoveBy *move = [CCMoveBy actionWithDuration:duration position:posDev];
    
    CCCallBlockN *repXBlock = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        CCSequence *seq = [CCSequence actions:scaleXRev, scaleXFwd, nil];
        CCRepeatForever *rep = [CCRepeatForever actionWithAction:seq];
        [node runAction:rep];
    }];
    
    CCCallBlockN *repYBlock = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        CCSequence *seq = [CCSequence actions:scaleYRev, scaleYFwd, nil];
        CCRepeatForever *rep = [CCRepeatForever actionWithAction:seq];
        [node runAction:rep];
    }];
    
    CCSequence *scaleXseq = [CCSequence actions: scaleX, repXBlock, nil];
    CCSequence *scaleYseq = [CCSequence actions: scaleY, repYBlock, nil];
    // CCRepeatForever *moveSeq = [CCRepeatForever actionWithAction:[CCSequence actions:move, [move reverse], nil]];
    
    CCCallBlockN *callBlock = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        node.anchorPoint = ccp(0.5,0.5);
        node.position = ccp((node.contentSize.width * node.scaleX / 2) + node.position.x, (node.contentSize.height * node.scaleY / 2) + node.position.y);
        [node runAction:scaleXseq];
        [node runAction:scaleYseq];
        //[node runAction:moveSeq];
    }];
    
    return callBlock;
}

-(CCAction *) puff: (NSDictionary *) params {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];

    CCAction *def = [self particleSystemActionWithDef:@"CloudPuffy.plist" params:dict];
    
    def.tag = BEHAVIOR_TAG_PUFF;
    
    return def;
}

@end
