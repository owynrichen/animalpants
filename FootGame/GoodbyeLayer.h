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
#import "SpeechBubble.h"

@interface GoodbyeLayer : CCPreloadingLayer<CCTargetedTouchDelegate> {
    CCLayer *background;
    CCLayer *midground;
    CCLayer *foreground;
    CCAutoScalingSprite *jeep;
    SpeechBubble *outro;
}

// returns a CCScene that contains the AnimalViewLayer as the only child
+(CCScene *) scene;

@end
