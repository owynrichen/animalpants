//
//  LanguageSelectLayer.m
//  FootGame
//
//  Created by Owyn Richen on 10/6/12.
//
//

#import "LanguageSelectLayer.h"
#import "CCMenuItemFontWithStroke.h"
#import "MainMenuLayer.h"
#import "LocalizationManager.h"

@implementation LanguageSelectLayer

@synthesize menu;
@synthesize background;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	LanguageSelectLayer *layer = [LanguageSelectLayer node];
	
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
    
    CCMenuItemFontWithStroke *back = [CCMenuItemFontWithStroke itemFromString:menulocstr(@"back", @"strings", @"Back") color:ccBLUE strokeColor:ccWHITE strokeSize:(4 * fontScaleForCurrentDevice()) block:^(id sender) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[MainMenuLayer scene] backwards:true]];
    }];
    back.anchorPoint = ccp(0,0);
    back.position = ccp(0,0);
    
    menu = [CCMenu menuWithItems: nil];
    
    [menu addChild:back z:0 tag:1];
    menu.anchorPoint = ccp(0,0);
    menu.position = ccp(winSize.width * 0.1, winSize.height * 0.9);
    __block int count = 1;
    
    for(NSString *lang in [[LocalizationManager sharedManager] getAvailableLanguages]) {
        NSString *langStr = [[LocalizationManager sharedManager] getLanguageNameString:lang];
        CCMenuItemFontWithStroke *item = [CCMenuItemFontWithStroke itemFromString:langStr color:ccBLUE strokeColor:ccWHITE strokeSize:(4 * fontScaleForCurrentDevice()) block:^(id sender) {
            [[LocalizationManager sharedManager] setAppPreferredLocale:((CCNode *)sender).userData];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[MainMenuLayer scene] backwards:true]];
        }];
        item.userData = lang;
        item.anchorPoint = ccp(0,0);
        item.position = ccp(0, -54 * count * fontScaleForCurrentDevice());
        count++;
        [menu addChild:item z:0 tag:1];
    }
    
    [self addChild:background];
    [self addChild:menu];
    
    return self;
}


@end
