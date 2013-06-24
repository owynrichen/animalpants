//
//  Behavior+FallingLeaves.h
//  FootGame
//
//  Created by Owyn Richen on 8/25/12.
//
//

#import <Foundation/Foundation.h>
#import "Behavior+ParticleSystem.h"

#define BEHAVIOR_TAG_FALLING_LEAVES 775

@interface Behavior(FallingLeaves)

-(CCAction *) fallingLeaves: (NSDictionary *) params;

@end
