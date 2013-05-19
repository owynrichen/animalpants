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

+(LongPressButton *) buttonWithBlock: (LongPressBlock) blk;


@end
