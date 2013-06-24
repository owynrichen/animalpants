//
//  Behavior+Backflip.h
//  FootGame
//
//  Created by Owyn Richen on 1/3/01.
//
//

#import <Foundation/Foundation.h>
#import "Behavior.h"

#define BEHAVIOR_TAG_BACKFLIP 32

@interface Behavior(Backflip)

-(CCAction *) backflip: (NSDictionary *) params;

@end
