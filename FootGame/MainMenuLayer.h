//
//  MainMenuLayer.h
//  FootGame
//
//  Created by Owyn Richen on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLayer.h"

@interface MainMenuLayer : CCLayer<CCTargetedTouchDelegate>

@property (nonatomic, retain) CCSprite *title;
@property (nonatomic, retain) CCMenu *menu;
@property (nonatomic, retain) CCSprite *background;
@property (nonatomic, retain) CCSprite *splashFade;

+(CCScene *) scene;

@end
