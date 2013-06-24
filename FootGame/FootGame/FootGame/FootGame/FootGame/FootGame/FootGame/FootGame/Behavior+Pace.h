//
//  Behavior+Pace.h
//  FootGame
//
//  Created by Owyn Richen on 1/3/01.
//
//

#import <Foundation/Foundation.h>
#import "Behavior.h"

#define BEHAVIOR_TAG_PACE 87

@interface Behavior(Pace)

-(CCAction *) pace: (NSDictionary *) params;

@end
