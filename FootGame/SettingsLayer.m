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
#import "MBProgressHUD.h"

@interface SettingsLayer()
-(void) redrawMenu;
@end

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
    
    menu = [CCMenu menuWithItems: nil];

    menu.anchorPoint = ccp(0,0);
    menu.position = ccp(winSize.width * 0.1, winSize.height * 0.9);
    
    [self redrawMenu];
    
    [self addChild:background];
    [self addChild:menu];
    
    return self;
}

-(void) onEnter {
    apView(@"Settings View");
    [super onEnter];
}

-(void) redrawMenu {
    [menu removeAllChildrenWithCleanup:YES];
    
    CCMenuItemFontWithStroke *back = [CCMenuItemFontWithStroke itemFromString:locstr(@"back", @"strings", @"Back") color:MENU_COLOR strokeColor:MENU_STROKE strokeSize:(4 * fontScaleForCurrentDevice()) block:^(id sender) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[MainMenuLayer scene] backwards:true]];
    }];
    back.anchorPoint = ccp(0,0);
    back.position = ccp(0,0);
    [menu addChild:back z:0 tag:1];
    
    CCMenuItemFontWithStroke *restore = [CCMenuItemFontWithStroke itemFromString:locstr(@"restore_purchases", @"strings", @"") color:MENU_COLOR strokeColor:MENU_STROKE strokeSize:(4 * fontScaleForCurrentDevice()) block:^(id sender) {
        [[InAppPurchaseManager instance] restorePurchases:self];
    }];
    restore.anchorPoint = ccp(0,0);
    restore.position = ccp(0,-44);
    [menu addChild:restore z:0 tag:1];

    if (![[PremiumContentStore instance] ownsProductId:PREMIUM_PRODUCT_ID]) {
        CCMenuItemFontWithStroke *buyAll = [CCMenuItemFontWithStroke itemFromString:locstr(@"buy", @"strings", @"") color:MENU_COLOR strokeColor:MENU_STROKE strokeSize:(4 * fontScaleForCurrentDevice()) block:^(id sender) {
            [[InAppPurchaseManager instance] getProducts:self withData:PREMIUM_PRODUCT_ID];
        }];
        buyAll.anchorPoint = ccp(0,0);
        buyAll.position = ccp(0,-88);
        [menu addChild:buyAll z:0 tag:1];
    }
}

-(void) productRetrievalStarted {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[CCDirector sharedDirector].view animated:YES];
    hud.labelText = locstr(@"get_products", @"strings", @"");
}

-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data {
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    
    if (purchase != nil)
        [purchase release];
    
    purchase = [PurchaseViewController handleProductsRetrievedWithDelegate:self products:products withProductId:(NSString *) data upsell:nil];
}

-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data {
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    
    [PurchaseViewController handleProductsRetrievedFail];
}

-(void) purchaseStarted {
    NSLog(@"starting purchase");
    apEvent(@"purchase", @"restore", @"");
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[CCDirector sharedDirector].view animated:YES];
    hud.labelText = locstr(@"buying_product", @"strings", @"");
}

-(void) purchaseSucceeded: (NSString *) productId {
    NSLog(@"purchase succeeded");
    apEvent(@"purchase", @"restore success", @"");
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    [self redrawMenu];
}

-(void) purchaseFailed: (NSString *) productId {
    NSLog(@"purchase failed");
    apEvent(@"purchase", @"restore fail", productId);
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:locstr(@"product_buy_error_title", @"strings", @"")
                                                    message:locstr(@"product_buy_error_desc", @"strings", @"")
                                                   delegate:nil
                                          cancelButtonTitle:locstr(@"okay", @"strings", @"")
                                          otherButtonTitles:nil];
    
    [alert show];
    [alert release];
    [self redrawMenu];
}


-(void) purchaseFinished: (BOOL) success {
    [self redrawMenu];
}

@end
