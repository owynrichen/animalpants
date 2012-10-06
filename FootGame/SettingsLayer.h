//
//  SettingsLayer.h
//  FootGame
//
//  Created by Owyn Richen on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLayer.h"
#import "CCAutoScalingSprite.h"

@interface SettingsLayer : CCLayer

@property (nonatomic, retain) CCMenu *menu;
@property (nonatomic, retain) CCAutoScalingSprite *background;

+(CCScene *) scene;

@end
