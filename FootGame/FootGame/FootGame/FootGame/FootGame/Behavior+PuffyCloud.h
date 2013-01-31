//
//  Behavior+PuffyCloud.h
//  FootGame
//
//  Created by Owyn Richen on 11/20/12.
//
//

#import "Behavior.h"

#define BEHAVIOR_TAG_FLOATY 983
#define BEHAVIOR_TAG_PUFF 984

@interface Behavior(PuffyCloud)

-(CCAction *) floaty: (NSDictionary *) params;
-(CCAction *) puff: (NSDictionary *) params;

@end
