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
#import "CCAutoScaling.h"

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
    
    title = [CCAutoScalingSprite spriteWithFile:@"title.png"];
    title.position = ccp(winSize.width * 0.5, winSize.height * 0.85);
    
    background = [CCAutoScalingSprite spriteWithFile:@"tropical.png"];
    background.position = ccp(winSize.width * 0.5, winSize.height * 0.5);

    [CCMenuItemFont setFontSize:72 * fontScaleForCurrentDevice()];
    CCMenuItemFontWithStroke *smenuItem = [CCMenuItemFontWithStroke itemFromString:@"Play!" color:ccBLUE strokeColor:ccWHITE strokeSize:(4 * fontScaleForCurrentDevice()) block:^(id sender) {
        [[CCDirector sharedDirector] pushScene:[AnimalViewLayer scene]];
    }];
    
    menu = [CCMenu menuWithItems:smenuItem, nil];
    
    [self addChild:background];
    [self addChild:title];
    [self addChild:menu];

    // TODO: until I can figure out how to remove the flicker, disable this
//    splashFade = [CCSprite spriteWithFile:@"AlchemistKids@2x.png"];
//    splashFade.rotation = -90;
//    splashFade.opacity = 255;
//    splashFade.scale = 0.5 * CC_CONTENT_SCALE_FACTOR();
//    splashFade.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
//
//    [self addChild:splashFade];
    
    return self;
}

-(void) onEnter {
    // TODO: until I can figure out how to remove the flicker, disable this
//    if (splashFade.opacity == 255) {
//        [splashFade runAction:[CCFadeOut actionWithDuration:1.0]];
//    }
    
    [super onEnter];
}

@end
