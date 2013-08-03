//
//  Behavior+Shake.m
//  FootGame
//
//  Created by Owyn Richen on 1/3/01.
//
//

#import "Behavior+Shake.h"

@implementation Behavior(Shake)

-(CCAction *) shake: (NSDictionary *) params {
    CCMoveBy *shakeUp = [CCMoveBy actionWithDuration:0.1 position:ccpToRatio(0, -10)];
    CCMoveBy *shakeDown = (CCMoveBy *) [shakeUp reverse];
    CCMoveTo *reset =[CCMoveTo actionWithDuration:0.1 position:CGPointMake([((NSNumber *)[params objectForKey:@"original_x"]) floatValue], [((NSNumber *)[params objectForKey:@"original_y"]) floatValue])];

    CCSequence *shake = [CCSequence actions:reset, shakeUp, shakeDown, shakeUp, shakeDown, nil];
    shake.tag = BEHAVIOR_TAG_SHAKE;
    return shake;
}

@end
