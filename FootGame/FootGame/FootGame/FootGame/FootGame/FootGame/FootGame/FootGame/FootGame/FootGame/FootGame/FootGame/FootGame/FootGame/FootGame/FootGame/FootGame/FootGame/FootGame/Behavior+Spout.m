//
//  Behavior+Spout.m
//  FootGame
//
//  Created by Owyn Richen on 1/5/01.
//
//

#import "Behavior+Spout.h"
#import "Behavior+ParticleSystem.h"

@implementation Behavior(Spout)

-(CCAction *) spout: (NSDictionary *) params {
    CCAction *seq = [self particleSystemActionWithDef:@"Spout.plist" params:params];
    
    seq.tag = BEHAVIOR_TAG_SPOUT;
    
    return seq;
}

@end
