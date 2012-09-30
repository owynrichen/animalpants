//
//  AnimalSelectLayer.m
//  FootGame
//
//  Created by Owyn Richen on 9/30/12.
//
//

#import "AnimalSelectLayer.h"
#import "AnimalPartRepository.h"
#import "AnimalViewLayer.h"
#import "CCMenuItemFontWithStroke.h"
#import "MainMenuLayer.h"

@implementation AnimalSelectLayer

@synthesize background;
@synthesize menu;

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	AnimalSelectLayer *layer = [AnimalSelectLayer node];
	
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
    
    CCMenuItemFontWithStroke *back = [CCMenuItemFontWithStroke itemFromString:NSLocalizedStringFromTable(@"back", @"strings", @"Back") color:ccBLUE strokeColor:ccWHITE strokeSize:(4 * fontScaleForCurrentDevice()) block:^(id sender) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[MainMenuLayer scene] backwards:true]];
    }];
    back.position = ccp(0,0);
    
    menu = [CCMenu menuWithItems: nil];
    
    [menu addChild:back z:0 tag:1];
    menu.anchorPoint = ccp(0,0);
    menu.position = ccp(winSize.width * 0.2, winSize.height * 0.8);
    
    [[[AnimalPartRepository sharedRepository] allAnimals] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *menuKey = [NSString stringWithFormat:@"menu_%@", [key lowercaseString]];
        NSString *name = NSLocalizedStringFromTable(menuKey, @"strings", @"");
        CCMenuItemFontWithStroke *item = [CCMenuItemFontWithStroke itemFromString:name color:ccBLUE strokeColor:ccWHITE strokeSize:(4 * fontScaleForCurrentDevice()) block:^(id sender) {
            [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[AnimalViewLayer sceneWithAnimalKey: key] backwards:false]];
        }];
        
        item.anchorPoint = ccp(0,0);
        item.position = ccp(0, 48 + (48 * [menu.children count]));
        [menu addChild:item z:0 tag:1];
    }];
    
    [self addChild:background];
    [self addChild:menu];
    
    return self;
}

@end
