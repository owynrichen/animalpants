//
//  CircleButton.h
//  FootGame
//
//  Created by Owyn Richen on 2/14/13.
//
//

#import "CCLayer.h"
#import "CCAutoScalingSprite.h"

@interface CircleButton : CCLayer {
    CCAutoScalingSprite *back;
    CCNode *middle;
    CCAutoScalingSprite *sheen;
}

+(CircleButton *) buttonWithFile: (NSString *) img;
+(CircleButton *) buttonWithNode: (CCNode *) node;

-(id) initWithFile: (NSString *) img;
-(id) initWithNode: (CCNode *) node;

@end
