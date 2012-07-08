//
//  MainMenuLayer.m
//  FootGame
//
//  Created by Owyn Richen on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainMenuLayer.h"
#import "AnimalViewLayer.h"
#import "CCMenuItemFontWithStroke.h"

@implementation MainMenuLayer

@synthesize title;
@synthesize menu;
@synthesize background;
@synthesize splashFade;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenuLayer *layer = [MainMenuLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init {
    self = [super init];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    title = [CCSprite spriteWithFile:@"title.png"];
    title.position = ccp(winSize.width * 0.5, winSize.height * 0.85);
    title.scale = 0.5 * CC_CONTENT_SCALE_FACTOR();
    
    background = [CCSprite spriteWithFile:@"tropical.png"];
    background.scale = 0.5 * CC_CONTENT_SCALE_FACTOR();
    background.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
    
    CCMenuItemLabel *menuItem = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Play!" fontName:@"Marker Felt" fontSize:72] block:^(id sender) {
        [[CCDirector sharedDirector] pushScene:[AnimalViewLayer scene]];
    }];
    
    menu = [CCMenu menuWithItems:menuItem, nil];
    
    [self addChild:background];
    [self addChild:title];
    [self addChild:menu];
    
    splashFade = [CCSprite spriteWithFile:@"AlchemistKids.png"];
    splashFade.position = ccp(240,160);
    splashFade.rotation = -90;
    splashFade.opacity = 255;
    // splashFade.scale = 0.5 * CC_CONTENT_SCALE_FACTOR();
    splashFade.position = ccp(winSize.width * 0.5, winSize.height * 0.5);

    [self addChild:splashFade];
    
    return self;
}

-(void) onEnter {
    if (splashFade.opacity == 255) {
        [splashFade runAction:[CCFadeOut actionWithDuration:1.0]];
    }
    
    [super onEnter];
}

@end
