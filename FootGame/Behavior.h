//
//  Behavior.h
//  FootGame
//
//  Created by Owyn Richen on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCAutoScaling.h"

#define BEHAVIOR_TAG_NONE 0

@interface Behavior : NSObject

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *event;
@property (nonatomic, retain) NSDictionary *data;

+(Behavior *) behaviorFromKey: (NSString *) key dictionary: (NSDictionary *) data;

-(id) initWithKey: (NSString *) k data: (NSDictionary *) d;
-(CCAction *) getAction: (CCNode *) node withParams: (NSDictionary *) p;
-(float) randWithBase: (float) base deviation: (float) dev;
-(CGPoint) randXYWithBase: (CGPoint) base deviation: (CGPoint) dev;

-(CGPoint) getOriginalPosition: (NSDictionary *) params;
-(float) getOriginalRotation: (NSDictionary *) params;

-(CCFiniteTimeAction *) resetPositionAction: (NSDictionary *) params;
-(CCFiniteTimeAction *) resetRotationAction: (NSDictionary *) params;
-(CCFiniteTimeAction *) resetScaleAction: (NSDictionary *) params;
-(CCFiniteTimeAction *) resetNodeAction: (NSDictionary *) params;

-(CCAction *) move: (NSDictionary *) params;
-(CCAction *) rotate: (NSDictionary *) params;

@end