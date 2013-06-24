//
//  Behavior+FallingLeaves.m
//  FootGame
//
//  Created by Owyn Richen on 8/25/12.
//
//

#import "Behavior+FallingLeaves.h"

@implementation Behavior(FallingLeaves)

-(CCAction *) fallingLeaves: (NSDictionary *) params {
    CCAction * act = [self particleSystemActionWithDef:@"FallingLeaves.plist" params:params];

    act.tag = BEHAVIOR_TAG_FALLING_LEAVES;

    return act;
}

@end
