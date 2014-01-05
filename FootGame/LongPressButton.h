//
//  LongPressButton.h
//  FootGame
//
//  Created by Owyn Richen on 5/9/13.
//
//

#import "CircleButton.h"

typedef void (^LongPressBlock)(CCNode * sender);

@interface LongPressButton : CircleButton {
    
}

@property (nonatomic) LongPressBlock block;
@property (nonatomic) float delay;
@property (nonatomic) double startTime;
@property (nonatomic) float baseScale;
@property (nonatomic) bool autoClickStarted;
@property (nonatomic, retain) CCAutoScalingSprite *clockHand;

+(LongPressButton *) buttonWithBlock: (LongPressBlock) blk;

-(void) autoClickAfter: (float) delay;


@end
