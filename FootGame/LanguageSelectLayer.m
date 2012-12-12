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
#import "PremiumContentStore.h"

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
    
    return self;
}

-(void) onEnter {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    background = [CCAutoScalingSprite spriteWithFile:@"tropical.png"];
    background.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
    
    [CCMenuItemFont setFontSize:48 * fontScaleForCurrentDevice()];
    
    menu = [CCMenu menuWithItems: nil];
    
    [self redrawMenu];
    
    [self addChild:background];
    [self addChild:menu];
    
    apView(@"Language Select View");
    [super onEnter];
}

-(void) redrawMenu {
    [menu removeAllChildrenWithCleanup:YES];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    CCMenuItemFontWithStroke *back = [CCMenuItemFontWithStroke itemFromString:menulocstr(@"back", @"strings", @"Back") color:MENU_COLOR strokeColor:MENU_STROKE strokeSize:(4 * fontScaleForCurrentDevice()) block:^(id sender) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[MainMenuLayer scene] backwards:true]];
    }];
    back.anchorPoint = ccp(0,0);
    back.position = ccp(0,0);
    
    [menu addChild:back z:0 tag:1];
    menu.anchorPoint = ccp(0,0);
    menu.position = ccp(winSize.width * 0.1, winSize.height * 0.9);
    
    __block int count = 1;
    
    for(NSString *lang in [[LocalizationManager sharedManager] getAvailableLanguages]) {
        NSString *langStr = [[LocalizationManager sharedManager] getLanguageNameString:lang];
        
        BOOL owned = [[PremiumContentStore instance] ownsProductId:[[LocalizationManager sharedManager] getLanguageProductForKey:lang]];
        
        if (!owned) {
            langStr = [NSString stringWithFormat:@"%@ - %@", langStr, locstr(@"buy", @"strings","")];
        }
        
        CCMenuItemFontWithStroke *item = [CCMenuItemFontWithStroke itemFromString:langStr color:MENU_COLOR strokeColor:MENU_STROKE strokeSize:(4 * fontScaleForCurrentDevice()) block:^(id sender) {
            NSString *l = ((CCNode *)sender).userData;
            BOOL o = [[PremiumContentStore instance] ownsProductId:[[LocalizationManager sharedManager] getLanguageProductForKey:l]];
            
            if (o == YES) {
                [[LocalizationManager sharedManager] setAppPreferredLocale:l];
                [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[MainMenuLayer scene] backwards:true]];
            } else {
                NSLog(@"Language %@ isn't owned", l);
                [[InAppPurchaseManager instance] getProducts:self withData:[[LocalizationManager sharedManager] getLanguageProductForKey:l]];
            }
        }];
        item.userData = lang;
        item.anchorPoint = ccp(0,0);
        item.position = ccp(0, -54 * count * fontScaleForCurrentDevice());
        count++;
        [menu addChild:item z:0 tag:1];
    }
}

-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data {
    if (purchase != nil)
        [purchase release];
    
    purchase = [PurchaseViewController handleProductsRetrievedWithDelegate:self products:products withProductId:(NSString *) data upsell:PREMIUM_PRODUCT_ID];
}

-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data {
    [PurchaseViewController handleProductsRetrievedFail];
}

-(void) purchaseFinished: (BOOL) success {
    [self redrawMenu];
}

@end
