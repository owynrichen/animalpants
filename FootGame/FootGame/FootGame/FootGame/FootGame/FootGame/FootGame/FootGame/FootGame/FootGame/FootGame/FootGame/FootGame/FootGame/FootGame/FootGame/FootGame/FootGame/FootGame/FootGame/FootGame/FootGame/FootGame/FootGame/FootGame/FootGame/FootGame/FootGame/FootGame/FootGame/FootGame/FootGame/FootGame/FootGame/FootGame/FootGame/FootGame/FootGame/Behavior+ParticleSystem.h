//
//  Behavior+ParticleSystem.h
//  FootGame
//
//  Created by Owyn Richen on 1/5/01.
//
//

#import <Foundation/Foundation.h>
#import "Behavior.h"
#import "CCParticleSystem+Extras.h"

#define BEHAVIOR_PARTICLE_TAG 433

@interface Behavior(ParticleSystem)

-(CCAction *) particleSystemActionWithDef: (NSString *) particleDef params: (NSDictionary *) params;

@end
