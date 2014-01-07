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
#import "ParentGatePopup.h"

@interface SettingsLayer()
-(void) redrawMenu;
-(void) blurFadeLayer: (BOOL) blur withDuration: (GLfloat) duration;
@end

@implementation SettingsLayer

@synthesize back;
@synthesize title;
@synthesize menu;
@synthesize background;
@synthesize credits;

+(CCBaseScene *) scene
{
	// 'scene' is an autorelease object.
	CCBaseScene *scene = [CCBaseScene node];
	
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
    
    __block SettingsLayer *pointer = self;

    [back addEvent:@"touch" withBlock:^(CCNode * sender) {
        [[SoundManager sharedManager] playSound:@"glock__g1.mp3"];
        
        [sender runAction:[CCScaleTo actionWithDuration:0.1 scaleX:-0.6 scaleY:0.6]];
    }];
    
    [back addEvent:@"touchupoutside" withBlock:^(CCNode *sender) {
        [sender runAction:[CCScaleTo actionWithDuration:0.1 scaleX:-0.4 scaleY:0.4]];
    }];
    
    [back addEvent:@"touchup" withBlock:^(CCNode *sender) {
        [pointer doWhenLoadComplete:locstr(@"loading", @"strings", @"") blk: ^{
            [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[MainMenuLayer scene] backwards:true]];
        }];
    }];
    
    [CCMenuItemFont setFontSize:48 * fontScaleForCurrentDevice()];
    [CCMenuItemFont setFontName:@"Rather Loud"];
    
    feedback = [[FeedbackPrompt alloc] init];
    
    menu = [CCMenu menuWithItems: nil];

    menu.anchorPoint = ccp(0,0);
    menu.position = ccpToRatio(winSize.width * 0.05, 450);
    
    [self redrawMenu];
    
    CircleButton *narrationIcon = [CircleButton buttonWithFile:@"lips.png"];
    narrationIcon.position = ccp(0,0);
    narrationIcon.scale = 0.7;
    
    narration = [CCVolumeMenuItem buttonWithVolumeType:kSoundVolume button:narrationIcon text:locstr(@"sound_volume", @"strings", @"")];
    
    narration.position = ccpToRatio(winSize.width * 0.05, menu.position.y + (((int)[menu.children count]) * -narration.contentSize.height * 1.05));
    
    CircleButton *musicIcon = [CircleButton buttonWithFile:@"music.png"];
    musicIcon.position = ccp(0,0);
    musicIcon.scale = 0.7;
    
    music = [CCVolumeMenuItem buttonWithVolumeType:kMusicVolume button:musicIcon text:locstr(@"music_volume", @"strings", @"")];
    
    music.position = ccpToRatio(winSize.width * 0.05, menu.position.y - narration.contentSize.height * 1.1 + (((int)[menu.children count]) * -narration.contentSize.height * 1.05));
    
    [self addChild:background];
    [self addChild:back];
    [self addChild:title z:100];
    [self addChild:menu];
    [self addChild:narration];
    [self addChild:music];
    
#ifdef TESTING
    __block FeedbackPrompt *pPrompt = prompt;
    CircleButton *bugs = [CircleButton buttonWithFile:@"bugs.png"];
    bugs.scale = 0.5;
    bugs.anchorPoint = ccp(0,0);
    bugs.position = ccpToRatio(1024 - 100, 768 - 100);
    
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
    [self addChild: bugs];
#endif
    
    return self;
}

-(void) dealloc {
#ifdef TESTING
    if (prompt != nil)
        [prompt release];
#endif
    [feedback release];
    [super dealloc];
}

-(void) onEnter {
    apView(@"Settings View");
    
    credits = [CreditsNode node];
    credits.position = ccpToRatio(1024 * 0.95 - (credits.contentSize.width / 2), 0);
    [self addChild:credits];
    
    [super onEnter];
}

-(void) onEnterTransitionDidFinish {
    CCScaleBy *titleScale = [CCScaleBy actionWithDuration:0.5 scale:1.025];
    
    // TODO: make this bounce?
    [title runAction:[CCRepeatForever actionWithAction:[CCSequence actions:titleScale, [titleScale reverse], nil]]];
    
    [title runAction:[CCSequence actions:
                      [CCMoveTo actionWithDuration:0.50 position:ccpToRatio(512, 670)],
                      nil]];
    
    CGFloat duration = (credits.contentSize.height + 768) / 768 * 20;
    
    [credits runAction:[CCMoveTo actionWithDuration:duration position:ccpToRatio(credits.position.x, credits.contentSize.height + 768)]];
    
    [super onEnterTransitionDidFinish];
}

-(void) redrawMenu {
    [menu removeAllChildrenWithCleanup:YES];
    
    __block SettingsLayer *pointer = self;
    
    CircleButton *restoreIcon = [CircleButton buttonWithFile:@"restorepurchase.png"];
    restoreIcon.position = ccp(0,0);
    restoreIcon.scale = 0.7;
    
    CCButtonMenuItem *restore = [CCButtonMenuItem itemWithButton: restoreIcon text:locstr(@"restore_purchases", @"strings", @"") block:^(id sender) {
        [[InAppPurchaseManager instance] restorePurchases:pointer];
    }];
    restore.anchorPoint = ccp(0,0);
    restore.position = ccp(0,0);
    [menu addChild:restore z:0 tag:1];
    
    CircleButton *fbIcon = [CircleButton buttonWithFile:@"feedback.png"];
    fbIcon.position = ccp(0,0);
    fbIcon.scale = 0.7;
    
    CCButtonMenuItem *fb = [CCButtonMenuItem itemWithButton: fbIcon text:locstr(@"send_feedback", @"strings", @"") block:^(id sender) {
         [feedback showRateThisAppAlert];
        
    }];
    fb.anchorPoint = ccp(0,0);
    fb.position = ccp(0,-restore.contentSize.height * 1.05);
    [menu addChild:fb z:0 tag:1];
    
    CircleButton *privacyIcon = [CircleButton buttonWithFile:@"lock.png"];
    privacyIcon.position = ccp(0,0);
    privacyIcon.scale = 0.7;
    
    NSString *url = [NSString stringWithFormat:@"http://www.alchemistkids.com/index.php/privacy-policy-%@/", [[LocalizationManager sharedManager] getAppPreferredLocale]];
    
    CCButtonMenuItem *ppolicy = [CCButtonMenuItem itemWithButton:privacyIcon text:locstr(@"privacy_policy", @"strings", @"") block:^(id sender) {
        ParentGatePopup *popup;
        
        if ([pointer getChildByTag:PARENT_GATE_TAG] != nil) {
            popup = (ParentGatePopup *) [pointer getChildByTag:PARENT_GATE_TAG];
        } else {
            popup = [ParentGatePopup popupWithSummaryKey:@"parent_gate_instructions_web" clickBlock:^{
                [[UIApplication sharedApplication]
                 openURL:[NSURL URLWithString:url]];
            }];
            popup.position = ccpToRatio(512, 384);
        
            [pointer addChild:popup z: 1000 tag:PARENT_GATE_TAG];
        }
        
        [popup showWithOpenBlock:^(CCNode<CCRGBAProtocol> *p) {
            
        } closeBlock:^(CCNode<CCRGBAProtocol> *p, PopupCloseState state) {
            
        } analyticsKey:@"Privacy Policy Parent Gate"];
    }];
    ppolicy.anchorPoint = ccp(0,0);
    ppolicy.position = ccp(0, -restore.contentSize.height * 1.05 - fb.contentSize.height * 1.05);
    [menu addChild:ppolicy z:0 tag: 1];

    if (![[PremiumContentStore instance] ownsProductId:PREMIUM_PRODUCT_ID]) {
        CircleButton *buyIcon = [CircleButton buttonWithFile:@"buy.png"];
        buyIcon.position = ccp(0,0);
        buyIcon.scale = 0.7;
        
        CCButtonMenuItem *buyAll = [CCButtonMenuItem itemWithButton: buyIcon text:locstr(@"buy", @"strings", @"") block:^(id sender) {
            [[InAppPurchaseManager instance] getProducts:pointer withData:PREMIUM_PRODUCT_ID];
        }];
        buyAll.anchorPoint = ccp(0,0);
        buyAll.position = ccp(0,-restore.contentSize.height * 1.05 - fb.contentSize.height * 1.05 - ppolicy.contentSize.height * 1.05);
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
