//
//  Behavior+Spout.h
//  FootGame
//
//  Created by Owyn Richen on 1/5/01.
//
//

#import <Foundation/Foundation.h>
#import "Behavior.h"

#define BEHAVIOR_TAG_SPOUT 92

@interface Behavior(Spout)

-(CCAction *) spout: (NSDictionary *) params;

@end
