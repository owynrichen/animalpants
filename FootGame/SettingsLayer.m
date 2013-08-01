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
#import "FadeGrid3D.h"
#import "MBProgressHUD.h"

@interface SettingsLayer()
-(void) redrawMenu;
-(void) blurFadeLayer: (BOOL) blur withDuration: (GLfloat) duration;
@end

@implementation SettingsLayer

@synthesize back;
@synthesize title;
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
    
    title = [CCLabelTTFWithExtrude labelWithString:locstr(@"settings", @"strings", @"") fontName:@"Rather Loud" fontSize:100 * fontScaleForCurrentDevice()];
    [title setColor: ccc3(206, 216, 47)];
    [title setExtrudeColor: ccc3(130, 141, 55)];
    title.extrudeDepth = 20 * fontScaleForCurrentDevice();
    [title drawExtrude];
    
    title.rotation = -8.0;
    title.position = ccpToRatio(512,winSize.height + title.contentSize.height);
    
    back = [CCAutoScalingSprite spriteWithFile:@"rightarrow.png"];
    back.scaleX = -0.4 * fontScaleForCurrentDevice();
    back.scaleY = 0.4 * fontScaleForCurrentDevice();
    back.anchorPoint = ccp(0,0);
    back.position = ccpToRatio(130, winSize.height - 100);
    
    [CCMenuItemFont setFontSize:48 * fontScaleForCurrentDevice()];
    [CCMenuItemFont setFontName:@"Rather Loud"];
    
    feedback = [[FeedbackPrompt alloc] init];
    
    menu = [CCMenu menuWithItems: nil];

    menu.anchorPoint = ccp(0,0);
    menu.position = ccpToRatio(winSize.width * 0.1, 500);
    
    [self redrawMenu];
    
    CircleButton *narrationIcon = [CircleButton buttonWithFile:@"lips.png"];
    narrationIcon.position = ccp(0,0);
    narrationIcon.scale = 0.7;
    
    narration = [CCVolumeMenuItem buttonWithVolumeType:kSoundVolume button:narrationIcon text:locstr(@"sound_volume", @"strings", @"")];
    
    narration.position = ccpToRatio(winSize.width * 0.1, menu.position.y + (((int)[menu.children count]) * -46));
    
    CircleButton *musicIcon = [CircleButton buttonWithFile:@"music.png"];
    musicIcon.position = ccp(0,0);
    musicIcon.scale = 0.7;
    
    music = [CCVolumeMenuItem buttonWithVolumeType:kMusicVolume button:musicIcon text:locstr(@"music_volume", @"strings", @"")];
    
    music.position = ccpToRatio(winSize.width * 0.1, menu.position.y - narration.contentSize.height + (((int)[menu.children count]) * -46));
    
    [self addChild:background];
    [self addChild:back];
    [self addChild:title];
    [self addChild:menu];
    [self addChild:narration];
    [self addChild:music];
    
    return self;
}

-(void) dealloc {
    [feedback release];
    [super dealloc];
}

-(void) onEnter {
    apView(@"Settings View");
    [super onEnter];
}

-(void) onEnterTransitionDidFinish {
    CCScaleBy *titleScale = [CCScaleBy actionWithDuration:0.5 scale:1.025];
    
    // TODO: make this bounce?
    [title runAction:[CCRepeatForever actionWithAction:[CCSequence actions:titleScale, [titleScale reverse], nil]]];
    
    [title runAction:[CCSequence actions:
                      [CCMoveTo actionWithDuration:0.50 position:ccpToRatio(512, 670)],
                      nil]];
    
    [super onEnterTransitionDidFinish];
}

-(void) redrawMenu {
    [menu removeAllChildrenWithCleanup:YES];
    
    CCMenuItemFontWithStroke *restore = [CCMenuItemFontWithStroke itemFromString:locstr(@"restore_purchases", @"strings", @"") color:MENU_COLOR strokeColor:MENU_STROKE strokeSize:(4 * fontScaleForCurrentDevice()) block:^(id sender) {
        [[InAppPurchaseManager instance] restorePurchases:self];
    }];
    restore.anchorPoint = ccp(0,0);
    restore.position = ccp(0,0);
    [menu addChild:restore z:0 tag:1];
    
    CCMenuItemFontWithStroke *fb = [CCMenuItemFontWithStroke itemFromString:locstr(@"send_feedback", @"strings", @"") color:MENU_COLOR strokeColor:MENU_STROKE strokeSize:(4 * fontScaleForCurrentDevice()) block:^(id sender) {
         [feedback showRateThisAppAlert];
        
    }];
    fb.anchorPoint = ccp(0,0);
    fb.position = ccp(0,-46);
    [menu addChild:fb z:0 tag:1];

    if (![[PremiumContentStore instance] ownsProductId:PREMIUM_PRODUCT_ID]) {
        CCMenuItemFontWithStroke *buyAll = [CCMenuItemFontWithStroke itemFromString:locstr(@"buy", @"strings", @"") color:MENU_COLOR strokeColor:MENU_STROKE strokeSize:(4 * fontScaleForCurrentDevice()) block:^(id sender) {
            [[InAppPurchaseManager instance] getProducts:self withData:PREMIUM_PRODUCT_ID];
        }];
        buyAll.anchorPoint = ccp(0,0);
        buyAll.position = ccp(0,-92);
        [menu addChild:buyAll z:0 tag:1];
    }
}

-(void) productRetrievalStarted {

}

-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data {
    if (purchase != nil)
        [purchase release];
    
    purchase = [PurchaseViewController handleProductsRetrievedWithDelegate:self products:products withProductId:(NSString *) data upsell:nil];
    [self blurFadeLayer:YES withDuration:0.5];
}

-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data {
    [PurchaseViewController handleProductsRetrievedFail];
    [self blurFadeLayer:NO withDuration:0.1];
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
    [self blurFadeLayer:NO withDuration:0.1];
}

-(void) purchaseFailed: (NSString *) productId {
    NSLog(@"purchase failed");
    apEvent(@"purchase", @"restore fail", productId);
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    
    apView(@"Settings Purchase Error Dialog");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:locstr(@"product_buy_error_title", @"strings", @"")
                                                    message:locstr(@"product_buy_error_desc", @"strings", @"")
                                                   delegate:nil
                                          cancelButtonTitle:locstr(@"okay", @"strings", @"")
                                          otherButtonTitles:nil];
    
    [alert show];
    [alert release];
    [self redrawMenu];
    [self blurFadeLayer:NO withDuration:0.1];
}


-(BOOL) purchaseFinished: (BOOL) success {
    [self redrawMenu];
    [self blurFadeLayer:NO withDuration:0.1];
    return YES;
}

-(void) blurFadeLayer: (BOOL) blur withDuration: (GLfloat) duration {
    if (blur) {
        FadeGridAction *blur = [FadeGridAction actionWithDuration:duration sigmaStart:0.0 sigmaEnd:1.0 desaturateStart:0.0 desaturateEnd:0.7];
        [self runAction:blur];
    } else {
        FadeGridAction *blur = [FadeGridAction actionWithDuration:duration sigmaStart:1.0 sigmaEnd:0.0 desaturateStart:0.7 desaturateEnd:0.0];
        [self runAction:blur];
    }
}

-(BOOL) cancelClicked: (BOOL) buying {
    [self blurFadeLayer:NO withDuration:0.1];
    return !buying;
}

@end
