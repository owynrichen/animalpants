//
//  CCAutoScalingSprite.h
//  FootGame
//
//  Created by Owyn Richen on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCSprite.h"
#import "BehaviorManager.h"

@interface CCAutoScalingSprite : CCSprite<CCTargetedTouchDelegate, BehaviorManagerDelegate>

@property (nonatomic, readonly) float autoScaleFactor;
@property (nonatomic, readonly) BehaviorManager *behaviorManager;

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event;

@end
