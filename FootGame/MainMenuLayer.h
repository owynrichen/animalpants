//
//  MainMenuLayer.h
//  FootGame
//
//  Created by Owyn Richen on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLayer.h"
#import "CCAutoScalingSprite.h"

@interface MainMenuLayer : CCLayer<CCTargetedTouchDelegate>

@property (nonatomic, retain) CCAutoScalingSprite *title;
@property (nonatomic, retain) CCMenu *menu;
@property (nonatomic, retain) CCAutoScalingSprite *titleScroll;
@property (nonatomic, retain) CCAutoScalingSprite *foreground;
@property (nonatomic, retain) CCAutoScalingSprite *background;
@property (nonatomic, retain) CCSprite *splashFade;

+(CCScene *) scene;

@end
