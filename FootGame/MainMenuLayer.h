//
//  MainMenuLayer.h
//  FootGame
//
//  Created by Owyn Richen on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCAutoScalingSprite.h"
#import "FlagCircleButton.h"
#import "ContentManifest.h"

@interface MainMenuLayer : CCPreloadingLayer<CCTargetedTouchDelegate>

@property (nonatomic, retain) CCAutoScalingSprite *title;
@property (nonatomic, retain) CCAutoScalingSprite *background;
@property (nonatomic, retain) CCAutoScalingSprite *girls;
@property (nonatomic, retain) CCAutoScalingSprite *play;
@property (nonatomic, retain) FlagCircleButton *languages;
@property (nonatomic, retain) CCAutoScalingSprite *animals;
@property (nonatomic, retain) CCAutoScalingSprite *credits;
@property (nonatomic, retain) CCSprite *splashFade;

+(CCScene *) scene;


@end
