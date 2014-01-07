//
//  StoryLayer.h
//  FootGame
//
//  Created by Owyn Richen on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContentManifest.h"
#import "CCAutoScalingSprite.h"
#import "CCAutoScaling.h"
#import "NarrationNode.h"
#import "LongPressButton.h"

@interface GoodbyeLayer : CCPreloadingLayer<CCTargetedTouchDelegate> {
    CCLayer *background;
    CCLayer *midground;
    CCLayer *foreground;
    CCAutoScalingSprite *jeep;
    NarrationNode *outro;
    LongPressButton *skip;
    ALuint truckSound;
#ifdef TESTING
    FeedbackPrompt *prompt;
#endif
}

// returns a CCScene that contains the AnimalViewLayer as the only child
+(CCBaseScene *) scene;

@end
