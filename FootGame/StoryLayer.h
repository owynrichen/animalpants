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

@interface StoryLayer : CCPreloadingLayer {
    CCLayer *background;
    CCLayer *foreground;
    CCAutoScalingSprite *jeep;
    NarrationNode *story1;
    LongPressButton *skip;
}

// returns a CCScene that contains the AnimalViewLayer as the only child
+(CCScene *) scene;

@end
