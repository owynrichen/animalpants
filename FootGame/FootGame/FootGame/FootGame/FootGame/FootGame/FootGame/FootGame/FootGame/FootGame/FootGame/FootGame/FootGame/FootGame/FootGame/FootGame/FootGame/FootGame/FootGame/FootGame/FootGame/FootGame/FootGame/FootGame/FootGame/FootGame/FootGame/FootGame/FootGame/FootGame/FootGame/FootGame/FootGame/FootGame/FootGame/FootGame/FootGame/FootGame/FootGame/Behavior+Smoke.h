//
//  Behavior+Smoke.h
//  FootGame
//
//  Created by Owyn Richen on 1/5/01.
//
//

#import <Foundation/Foundation.h>
#import "Behavior.h"

#define BEHAVIOR_TAG_SMOKE 34

@interface Behavior(Smoke)

-(CCAction *) smoke: (NSDictionary *) params;

@end
