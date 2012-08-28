//
//  StoryLayer.h
//  FootGame
//
//  Created by Owyn Richen on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLayer.h"
#import "CCAutoScalingSprite.h"
#import "CCAutoScaling.h"
#import "SpeechBubble.h"

@interface StoryLayer : CCLayer {
    CCAutoScalingSprite *background;
    CCAutoScalingSprite *girl1;
    CCAutoScalingSprite *girl2;
    SpeechBubble *story1;
    SpeechBubble *story2;
    SpeechBubble *story3;
}

// returns a CCScene that contains the AnimalViewLayer as the only child
+(CCScene *) scene;

@end
