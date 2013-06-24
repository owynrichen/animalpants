//
//  Behavior+Petals.m
//  FootGame
//
//  Created by Owyn Richen on 1/14/13.
//
//

#import "Behavior+Petals.h"
#import "Behavior+ParticleSystem.h"

@implementation Behavior(Petals)

-(CCAction *) petals: (NSDictionary *) params {
    CCAction *seq = [self particleSystemActionWithDef:@"Petals.plist" params:params];
    
    return seq;
}

@end
