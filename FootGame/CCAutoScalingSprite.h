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
#import "chipmunk.h"

//# define DRAW_HITSPACE 1

@interface CCAutoScalingSprite : CCSprite<CCTargetedTouchDelegate, BehaviorManagerDelegate>

@property (nonatomic, readonly) float autoScaleFactor;
@property (nonatomic, readonly) BehaviorManager *behaviorManager;
@property (nonatomic, readonly) BitVector *bitMask;
@property (nonatomic, readonly) cpBody *physicsBody;
@property (nonatomic, readonly) cpShape *physicsShape;
@property (nonatomic, readonly) cpSpace *physicsSpace;
@property (nonatomic) BOOL physicsEnabled;
@property (nonatomic, readonly) NSString *name;

+(id) spriteWithFile: (NSString *) filename space: (cpSpace *) physicsSpace;
+(id) spriteWithAnimationFile: (NSString *) filename frame: (NSString *) frameName space: (cpSpace *) physicsSpace;

-(id) initWithFile:(NSString *)filename space: (cpSpace *) physicsSpace;
-(id) initWithAnimationFile: (NSString *) filename frame: (NSString *) frameName space: (cpSpace *) physicsSpace;

-(void) enableTouches:(BOOL) on;
-(void) addToSpace: (cpSpace *) space;
-(void) addToSpace: (cpSpace *) space withBody: (cpBody *) body andShape: (cpShape *) shape;
-(void) removeFromSpace: (cpSpace *) space;

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event;

-(void) addEvent: (NSString *) event withBlock: (void (^)(CCNode * sender)) blk;

-(void) afterDrawInit;

@end
