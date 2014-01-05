//
//  CircleButton.h
//  FootGame
//
//  Created by Owyn Richen on 2/14/13.
//
//

#import "CCLayer.h"
#import "CCAutoScalingSprite.h"

@interface CircleButton : CCNode<CCTargetedTouchDelegate, CCRGBAProtocol> {
    CCAutoScalingSprite *back;
    CCNode<CCRGBAProtocol> *middle;
    CCAutoScalingSprite *sheen;
    BOOL touchAdded;
}

+(id) buttonWithFile: (NSString *) img;
+(id) buttonWithNode: (CCNode<CCRGBAProtocol> *) node;

-(id) initWithFile: (NSString *) img;
-(id) initWithNode: (CCNode *) node;

-(void) addEvent: (NSString *) event withBlock: (void (^)(CCNode * sender)) blk;

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event;

-(void) enableTouches: (BOOL) on;

-(void) setColor:(ccColor3B)color;
-(ccColor3B) color;

-(GLubyte) opacity;
-(void) setOpacity: (GLubyte) opacity;

@end
