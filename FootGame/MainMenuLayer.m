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

static ContentManifest *__manifest;
static NSString *__sync = @"sync";

+(ContentManifest *) myManifest {
    if (__manifest == nil) {
        @synchronized(__sync) {
            if (__manifest == nil) {
                __manifest = [[ContentManifest alloc] initWithImages:
                              [NSArray arrayWithObjects:
                               @"menu_bg.png",
                               @"menu_girls.png",
                               @"text_animalswithpants.en.png",
                               // TODO: preload the other languages
                               @"icon_play.png"
                               @"icon_animals.png",
                               @"icon_credits.png",
                               nil] audio:
                              [NSArray arrayWithObjects:
                               @"play.en.mp3",
                               @"animals.en.mp3",
                               @"languages.en.mp3",
                               @"settings.en.mp3",
                               @"play.es.mp3",
                               @"animals.es.mp3",
                               @"languages.es.mp3",
                               @"settings.es.mp3",
                               @"play.fr.mp3",
                               @"animals.fr.mp3",
                               @"languages.fr.mp3",
                               @"settings.fr.mp3",
                               @"play.de.mp3",
                               @"animals.de.mp3",
                               @"languages.de.mp3",
                               @"settings.de.mp3",
                               nil]];
            }
        }
    }
    
    return [[__manifest copy] autorelease];
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
    
    title = [CCNode node];
    
    float yPos = 0;
    
    CCLabelTTFWithExtrude *line1 = [CCLabelTTFWithExtrude labelWithString:locstr(@"game_title1", @"strings", @"") fontName:@"Rather Loud" fontSize:250 * fontScaleForCurrentDevice()];
    [line1 setColor: ccc3(206, 216, 47)];
    [line1 setExtrudeColor: ccc3(130, 141, 55)];
    line1.extrudeDepth = 20 * fontScaleForCurrentDevice();
    [line1 drawExtrude];
    line1.position = ccpToRatio(0,yPos);
    [title addChild:line1];
    
    yPos -= line1.contentSize.height * 0.75;
    
    NSString *l2str = locstr(@"game_title2", @"strings", @"");
    
    if (![l2str isEqualToString:@""]) {
        yPos += line1.contentSize.height * 0.3;
        
        CCLabelTTFWithExtrude *line2 = [CCLabelTTFWithExtrude labelWithString:l2str fontName:@"Rather Loud" fontSize:100 * fontScaleForCurrentDevice()];
        [line2 setColor: ccc3(206, 216, 47)];
        [line2 setExtrudeColor: ccc3(130, 141, 55)];
        line2.extrudeDepth = 10 * fontScaleForCurrentDevice();
        [line2 drawExtrude];
        line2.position = ccpToRatio(0,yPos);
        [title addChild:line2];
        
        yPos -= line2.contentSize.height * 0.95;
    }
    
    CCLabelTTFWithExtrude *line3 = [CCLabelTTFWithExtrude labelWithString:locstr(@"game_title3", @"strings", @"") fontName:@"Rather Loud" fontSize:250 * fontScaleForCurrentDevice()];
    [line3 setColor: ccc3(206, 216, 47)];
    [line3 setExtrudeColor: ccc3(130, 141, 55)];
    line3.extrudeDepth = 20 * fontScaleForCurrentDevice();
    [line3 drawExtrude];
    line3.position = ccpToRatio(0,yPos);
    [title addChild:line3];
    
    title.rotation = -8.0;
    
    // TODO: set the title contentSize properly
    
    title.position = ccpToRatio(512,winSize.height + title.contentSize.height);
    [self addChild:title];
    
    __block MainMenuLayer *pointer = self;
    
    play = [CCAutoScalingSprite spriteWithFile:@"icon_play.png"];
    play.position = ccpToRatio(512, 170);
    
    [play addEvent:@"touch" withBlock:^(CCNode * sender) {
        [[SoundManager sharedManager] playSound:locfile(@"play.mp3")];
        [sender runAction:[CCScaleTo actionWithDuration:0.1 scale:1.2]];
    }];
    
    [play addEvent:@"touchupoutside" withBlock:^(CCNode *sender) {
        [sender runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
    }];
    
    [play addEvent:@"touchup" withBlock:^(CCNode *sender) {
        [sender runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
        
        [pointer doWhenLoadComplete:locstr(@"loading", @"strings", @"") blk: ^{
            [[AnimalPartRepository sharedRepository] resetAnimals:NO];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[StoryLayer scene] backwards:false]];
            // [[CCDirector sharedDirector] replaceScene:[StoryLayer scene]];
        }];
        
    }];

    [self addChild:play];
    play.opacity = 0;
    
    animals = [CCAutoScalingSprite spriteWithFile:@"icon_animals.png"];
    animals.position = ccpToRatio(890, 650);
    [animals addEvent:@"touch" withBlock:^(CCNode * sender) {
        [[SoundManager sharedManager] playSound:locfile(@"animals.mp3")];
        [sender runAction:[CCScaleTo actionWithDuration:0.1 scale:1.2]];
    }];
    
    [animals addEvent:@"touchupoutside" withBlock:^(CCNode *sender) {
        [sender runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
    }];
    
    [animals addEvent:@"touchup" withBlock:^(CCNode * sender) {
        [sender runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
        
        [pointer doWhenLoadComplete:locstr(@"loading", @"strings", @"") blk: ^{
            // [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[AnimalSelectLayer scene] backwards:false]];
            [[CCDirector sharedDirector] replaceScene:[AnimalSelectLayer scene]];
        }];
    }];
    [self addChild:animals];
    
    languages = [FlagCircleButton buttonWithLanguageCode:@""];
    languages.position = ccpToRatio(890, 530);
    [languages addEvent:@"touch" withBlock:^(CCNode * sender) {
        [[SoundManager sharedManager] playSound:locfile(@"languages.mp3")];
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:1.2]];
    }];
    
    [languages addEvent:@"touchupoutside" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
    }];
    
    [languages addEvent:@"touchup" withBlock:^(CCNode * sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
        
        [pointer doWhenLoadComplete:locstr(@"loading", @"strings", @"") blk: ^{
            // [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[LanguageSelectLayer scene] backwards:false]];
            [[CCDirector sharedDirector] replaceScene:[LanguageSelectLayer scene]];
        }];
    }];
    [self addChild:languages];
    
    credits = [CCAutoScalingSprite spriteWithFile:@"icon_credits.png"];
    credits.position = ccpToRatio(890, 410);
    [credits addEvent:@"touch" withBlock:^(CCNode * sender) {
        [[SoundManager sharedManager] playSound:locfile(@"settings.mp3")];
        [sender runAction:[CCScaleTo actionWithDuration:0.1 scale:1.2]];
    }];
    
    [credits addEvent:@"touchupoutside" withBlock:^(CCNode *sender) {
        [sender runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
    }];
    
    [credits addEvent:@"touchup" withBlock:^(CCNode * sender) {
        [sender runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
        [pointer doWhenLoadComplete:locstr(@"loading", @"strings", @"") blk: ^{
            // [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[SettingsLayer scene] backwards:false]];
            [[CCDirector sharedDirector] replaceScene:[SettingsLayer scene]];
        }];
    }];
    
    [self addChild:credits];
    
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
    
#ifdef TESTING
    __block FeedbackPrompt *pPrompt = prompt;
    CircleButton *bugs = [CircleButton buttonWithFile:@"bugs.png"];
    bugs.scale = 0.5;
    bugs.anchorPoint = ccp(0,0);
    bugs.position = ccpToRatio(50, 768 - 100);
    
    [bugs addEvent:@"touch" withBlock:^(CCNode *sender) {
        [[SoundManager sharedManager] playSound:@"glock__g1.mp3"];
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:0.7]];
    }];
    [bugs addEvent:@"touchupoutside" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:0.5]];
    }];
    [bugs addEvent:@"touchup" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:0.5]];
        if (pPrompt == nil)
            pPrompt = [[FeedbackPrompt alloc] init];
        [pPrompt showFeedbackDialog];
    }];
    [self addChild:bugs];
#endif
    
    splashFade = [CCSprite spriteWithFile:file];
    splashFade.rotation = -90;
    splashFade.opacity = 255;
    splashFade.position = ccp(winSize.width * 0.5, winSize.height * 0.5);

    [self addChild:splashFade];

    return self;
}

-(void) dealloc {
#ifdef TESTING
    if (prompt != nil)
        [prompt release];
#endif
    [super dealloc];
}

-(void) onEnter {
    // TODO: until I can figure out how to remove the flicker, disable this
    if (splashFade.opacity == 255) {
        [splashFade runAction:[CCFadeOut actionWithDuration:1.0]];
    }
    apView(@"Main Menu");
    [[SoundManager sharedManager] playBackground:@"The Animals.mp3"];
    
    [[AnimalPartRepository sharedRepository] resetAnimals: NO];
    
    manifestToLoad = [[ContentManifest alloc] initWithManifests:[StoryLayer myManifest], [[AnimalPartRepository sharedRepository] manifest], [AnimalSelectLayer myManifest], [LanguageSelectLayer myManifest], [SettingsLayer myManifest], nil];
    
    [super onEnter];
}

-(void) onEnterTransitionDidFinish {
    CCScaleBy *titleScale = [CCScaleBy actionWithDuration:0.5 scale:1.025];
    
    // TODO: make this bounce?
    [title runAction:[CCRepeatForever actionWithAction:[CCSequence actions:titleScale, [titleScale reverse], nil]]];
    [title runAction:[CCSequence actions:
                      [CCMoveTo actionWithDuration:0.50 position:ccpToRatio(512, 620)],
                      nil]];
    [play runAction:[CCFadeIn actionWithDuration:0.50]];
    
    [super onEnterTransitionDidFinish];
}


@end
