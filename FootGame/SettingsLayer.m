//
//  SettingsLayer.m
//  FootGame
//
//  Created by Owyn Richen on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsLayer.h"
#import "CCMenuItemFontWithStroke.h"
#import "MainMenuLayer.h"
#import "LocalizationManager.h"

@implementation SettingsLayer

@synthesize menu;
@synthesize background;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	SettingsLayer *layer = [SettingsLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init {
    self = [super init];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    background = [CCAutoScalingSprite spriteWithFile:@"tropical.png"];
    background.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
    
    [CCMenuItemFont setFontSize:48 * fontScaleForCurrentDevice()];
    
	NSString *currentLocale = [[NSLocale currentLocale] localeIdentifier];
    NSLog(@"Locale: %@", currentLocale);
    
    CCMenuItemFontWithStroke *back = [CCMenuItemFontWithStroke itemFromString:locstr(@"back", @"strings", @"Back") color:ccBLUE strokeColor:ccWHITE strokeSize:(4 * fontScaleForCurrentDevice()) block:^(id sender) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[MainMenuLayer scene] backwards:true]];
    }];
    back.anchorPoint = ccp(0,0);
    back.position = ccp(0,0);
    
    menu = [CCMenu menuWithItems: nil];
    
    [menu addChild:back z:0 tag:1];
    menu.anchorPoint = ccp(0,0);
    menu.position = ccp(winSize.width * 0.1, winSize.height * 0.9);
    
    [self addChild:background];
    [self addChild:menu];
    
    return self;
}

@end
