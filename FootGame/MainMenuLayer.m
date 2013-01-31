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
#import "AnimalPartRepository.h"

@implementation MainMenuLayer

@synthesize title;
@synthesize background;
@synthesize girls;
@synthesize play;
@synthesize animals;
@synthesize languages;
@synthesize credits;
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
    
    background = [CCAutoScalingSprite spriteWithFile:@"menu_bg.png"];
    background.position = ccpToRatio(512, 384);
    [self addChild:background];
    
    girls = [CCAutoScalingSprite spriteWithFile:@"menu_girls.png"];
    girls.position = ccpToRatio(800, 100);
    [self addChild:girls];
    
    NSString *titleStr = @"text_animalswithpants.en.png"; //[[LocalizationManager sharedManager] getLocalizedFilename:@"title.png"];
    
    title = [CCAutoScalingSprite spriteWithFile:titleStr];
    title.position = ccpToRatio(512,winSize.height + title.contentSize.height);
    [self addChild:title];
    
    [(NSArray *) [UIFont familyNames] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"%@", obj);
    }];
    
    play = [CCAutoScalingSprite spriteWithFile:@"icon_play.png"];
    play.position = ccpToRatio(512, 170);
    [play.behaviorManager addBehavior:[BlockBehavior behaviorFromKey:@"touch" dictionary:[NSDictionary dictionaryWithObject:@"touch" forKey:@"event"] block:^(id sender) {
        [[AnimalPartRepository sharedRepository] resetAnimals];
        
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[StoryLayer scene] backwards:false]];
    }]];
    [self addChild:play];
    play.opacity = 0;
    
    animals = [CCAutoScalingSprite spriteWithFile:@"icon_animals.png"];
    animals.position = ccpToRatio(890, 650);
    [animals.behaviorManager addBehavior:[BlockBehavior behaviorFromKey:@"touch" dictionary:[NSDictionary dictionaryWithObject:@"touch" forKey:@"event"] block:^(id sender) {
        [[CCDirector sharedDirector] pushScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[AnimalSelectLayer scene] backwards:false]];
    }]];
    [self addChild:animals];
    
    languages = [CCAutoScalingSprite spriteWithFile:@"icon_language.en.png"];
    languages.position = ccpToRatio(890, 530);
    [languages.behaviorManager addBehavior:[BlockBehavior behaviorFromKey:@"touch" dictionary:[NSDictionary dictionaryWithObject:@"touch" forKey:@"event"] block:^(id sender) {
        [[CCDirector sharedDirector] pushScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[LanguageSelectLayer scene] backwards:false]];
    }]];
    [self addChild:languages];
    
    credits = [CCAutoScalingSprite spriteWithFile:@"icon_credits.png"];
    credits.position = ccpToRatio(890, 410);
    [credits.behaviorManager addBehavior:[BlockBehavior behaviorFromKey:@"touch" dictionary:[NSDictionary dictionaryWithObject:@"touch" forKey:@"event"] block:^(id sender) {
        [[CCDirector sharedDirector] pushScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[SettingsLayer scene] backwards:false]];
    }]];
    
    [self addChild:credits];

    // TODO: until I can figure out how to remove the flicker, disable this
    
    NSString *file = @"AlchemistKids.png";
    switch (runningDevice()) {
        case kiPhone:
            file = @"AlchemistKids-iphone.png";
            break;
        case kiPhoneRetina:
            file = @"AlchemistKids-iphone@2x.png";
            break;
        case kiPad:
            break;
        case kiPadRetina:
            file = @"AlchemistKids@2x.png";
            break;
    }
    
    splashFade = [CCSprite spriteWithFile:file];
    splashFade.rotation = -90;
    splashFade.opacity = 255;
//    splashFade.scale = 0.5 * CC_CONTENT_SCALE_FACTOR();
    splashFade.position = ccp(winSize.width * 0.5, winSize.height * 0.5);

    [self addChild:splashFade];
    
    return self;
}

-(void) onEnter {
    // TODO: until I can figure out how to remove the flicker, disable this
    if (splashFade.opacity == 255) {
        [splashFade runAction:[CCFadeOut actionWithDuration:1.0]];
    }
    apView(@"Main Menu");
    [[SoundManager sharedManager] playBackground:@"The Animals.mp3"];
    [super onEnter];
}

-(void) onEnterTransitionDidFinish {
    CCScaleBy *titleScale = [CCScaleBy actionWithDuration:0.5 scale:1.025];
    
    // TODO: make this bounce?
    [title runAction:[CCRepeatForever actionWithAction:[CCSequence actions:titleScale, [titleScale reverse], nil]]];
    [title runAction:[CCSequence actions:
                      [CCMoveTo actionWithDuration:0.50 position:ccpToRatio(512, 520)],
                      nil]];
    [play runAction:[CCFadeIn actionWithDuration:0.50]];
    
    [super onEnterTransitionDidFinish];
}

@end
