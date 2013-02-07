//
//  CCAutoScalingSprite.h
//  FootGame
//
//  Created by Owyn Richen on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCSprite.h"
#import "BehaviorManager.h"
#import "BlockBehavior.h"
#import "BitVector.h"

@interface CCAutoScalingSprite : CCSprite<CCTargetedTouchDelegate, BehaviorManagerDelegate>

@property (nonatomic, readonly) float autoScaleFactor;
@property (nonatomic, readonly) BehaviorManager *behaviorManager;
@property (nonatomic, readonly) BitVector *bitMask;

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event;

-(void) addEvent: (NSString *) event withBlock: (void (^)(CCNode * sender)) blk;

-(void) afterDrawInit;

@end
