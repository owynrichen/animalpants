//
//  MainMenuLayer.m
//  FootGame
//
//  Created by Owyn Richen on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainMenuLayer.h"
#import "StoryLayer.h"
#import "AnimalSelectLayer.h"
#import "SettingsLayer.h"
#import "CCMenuItemFontWithStroke.h"
#import "CCAutoScaling.h"
#import "SoundManager.h"
#import "LocalizationManager.h"
#import "LanguageSelectLayer.h"

@implementation MainMenuLayer

@synthesize title;
@synthesize titleScroll;
@synthesize menu;
@synthesize foreground;
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
    
    background = [CCAutoScalingSprite spriteWithFile:@"menu_background.png"];
    background.position = ccpToRatio(512, 384);
    [self addChild:background];
    
    titleScroll = [CCAutoScalingSprite spriteWithFile:@"title_scroll.png"];
    titleScroll.position = ccpToRatio(512,winSize.height + titleScroll.contentSize.height);
    [self addChild:titleScroll];
    
    NSString *titleStr = @"title.en.png"; //[[LocalizationManager sharedManager] getLocalizedFilename:@"title.png"];
    
    title = [CCAutoScalingSprite spriteWithFile:titleStr];
    title.position = ccpToRatio(512,winSize.height + titleScroll.contentSize.height + 40);
    [self addChild:title];
    
    [(NSArray *) [UIFont familyNames] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"%@", obj);
    }];

    [CCMenuItemFont setFontSize:72 * fontScaleForCurrentDevice()];
    [CCMenuItemFont setFontName:@"Pacifico"];
    
	NSString *currentLocale = [[NSLocale currentLocale] localeIdentifier];
    NSLog(@"Locale: %@", currentLocale);

    CCMenuItemFontWithStroke *smenuItem = [CCMenuItemFontWithStroke itemFromString:menulocstr(@"play", @"strings", @"Play!") color:MENU_COLOR strokeColor:MENU_STROKE strokeSize:(4 * fontScaleForCurrentDevice()) block:^(id sender) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[StoryLayer scene] backwards:false]];
    }];
    
    CCMenuItemFontWithStroke *smenuItem2 = [CCMenuItemFontWithStroke itemFromString:menulocstr(@"animals", @"strings", @"Animals") color:MENU_COLOR strokeColor:MENU_STROKE strokeSize:(4 * fontScaleForCurrentDevice()) block:^(id sender) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[AnimalSelectLayer scene] backwards:false]];
    }];
    smenuItem2.position = ccp(0, -80 * fontScaleForCurrentDevice());
    
    CCMenuItemFontWithStroke *smenuItem3 = [CCMenuItemFontWithStroke itemFromString:menulocstr(@"languages", @"strings", @"Languages") color:MENU_COLOR strokeColor:MENU_STROKE strokeSize:(4 * fontScaleForCurrentDevice()) block:^(id sender) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[LanguageSelectLayer scene] backwards:false]];
    }];
    smenuItem3.position = ccp(0, -80 * 2 * fontScaleForCurrentDevice());
    
    CCMenuItemFontWithStroke *smenuItem4 = [CCMenuItemFontWithStroke itemFromString:menulocstr(@"settings", @"strings", @"Settings") color:MENU_COLOR strokeColor:MENU_STROKE strokeSize:(4 * fontScaleForCurrentDevice()) block:^(id sender) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[SettingsLayer scene] backwards:false]];
    }];
    smenuItem4.position = ccp(0, -80 * 3 * fontScaleForCurrentDevice());
    
    menu = [CCMenu menuWithItems:smenuItem, smenuItem2, smenuItem3, smenuItem4, nil];
    menu.opacity = 0;
    menu.position = ccpToRatio(512, 384);
    [self addChild:menu];
    
    foreground = [CCAutoScalingSprite spriteWithFile:@"menu_foreground.png"];
    foreground.position = ccpToRatio(512, 384);
    [self addChild:foreground];

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
    [[SoundManager sharedManager] playBackground:@"game_intro_bgmusic.mp3"];
    [super onEnter];
}

-(void) onEnterTransitionDidFinish {
    CCScaleBy *titleScale = [CCScaleBy actionWithDuration:0.5 scale:1.025];
    
    // TODO: make this bounce?
    [titleScroll runAction:[CCMoveTo actionWithDuration:0.50 position:ccpToRatio(512, 550)]];
    [title runAction:[CCRepeatForever actionWithAction:[CCSequence actions:titleScale, [titleScale reverse], nil]]];
    [title runAction:[CCSequence actions:
                      [CCMoveTo actionWithDuration:0.50 position:ccpToRatio(512, 520)],
                      nil]];
    [menu runAction:[CCFadeIn actionWithDuration:0.50]];
    
    [super onEnterTransitionDidFinish];
}

@end
