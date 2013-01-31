//
//  Behavior+Shake.h
//  FootGame
//
//  Created by Owyn Richen on 1/3/01.
//
//

#import "Behavior.h"
#import <Foundation/Foundation.h>

#define BEHAVIOR_TAG_SHAKE 54

@interface Behavior(Shake)

-(CCAction *) shake: (NSDictionary *) params;

@end
