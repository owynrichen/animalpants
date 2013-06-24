//
//  Behavior+Smoke.m
//  FootGame
//
//  Created by Owyn Richen on 1/5/01.
//
//

#import "Behavior+Smoke.h"
#import "Behavior+ParticleSystem.h"

@implementation Behavior(Smoke)

-(CCAction *) smoke: (NSDictionary *) params {
    CCAction *def = [self particleSystemActionWithDef:@"Smoke.plist" params:params];
    
    def.tag = BEHAVIOR_TAG_SMOKE;
    
    return def;
}

@end
