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
#import "MBProgressHUD.h"
#import "SoundManager.h"
#import "FadeGrid3D.h"

@interface LanguageSelectLayer()
-(void) blurFadeLayer: (BOOL) blur withDuration: (GLfloat) duration;
@end

@implementation LanguageSelectLayer

@synthesize title;
@synthesize menu;
@synthesize background;
@synthesize back;

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
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    title = [CCAutoScalingSprite spriteWithFile:@"text_languages.en.png"];
    title.position = ccpToRatio(512,winSize.height + title.contentSize.height);
    
    background = [CCAutoScalingSprite spriteWithFile:@"tropical.png"];
    background.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
    
    [CCMenuItemFont setFontSize:48 * fontScaleForCurrentDevice()];
    [CCMenuItemFont setFontName:@"Rather Loud"];
    
    back = [CCAutoScalingSprite spriteWithFile:@"arrow.png"];
    back.scaleX = -0.4 * fontScaleForCurrentDevice();
    back.scaleY = 0.4 * fontScaleForCurrentDevice();
    back.anchorPoint = ccp(0,0);
    back.position = ccpToRatio(130, winSize.height - 100);
    [back addEvent:@"touchup" withBlock:^(CCNode *sender) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[CCDirector sharedDirector].view animated:YES];
        hud.labelText = locstr(@"loading", @"strings", @"");
        
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[MainMenuLayer scene] backwards:true]];
    }];
    
    menu = [CCMenu menuWithItems: nil];
    
    [self redrawMenu];
    
    [self addChild:background];
    [self addChild:menu];
    [self addChild:title];
    [self addChild:back];
    
    apView(@"Language Select View");
    [super onEnter];
}

-(void) onEnterTransitionDidFinish {
    CCScaleBy *titleScale = [CCScaleBy actionWithDuration:0.5 scale:1.025];
    
    // TODO: make this bounce?
    [title runAction:[CCRepeatForever actionWithAction:[CCSequence actions:titleScale, [titleScale reverse], nil]]];
    
    [title runAction:[CCSequence actions:
                      [CCMoveTo actionWithDuration:0.50 position:ccpToRatio(512, 620)],
                      nil]];

    [super onEnterTransitionDidFinish];
}

-(void) redrawMenu {
    [menu removeAllChildrenWithCleanup:YES];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    menu.anchorPoint = ccp(0,0);
    menu.position = ccp(winSize.width * 0.5, winSize.height * 0.6);
    
    __block int count = 0;
    
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
        
        NSString *sound = [[NSString stringWithFormat:@"%@.mp3", lang] lowercaseString];
        NSString *soundfname = locfile(sound);
        [[SoundManager sharedManager] preloadSound:soundfname];
        
        [item addDownEvent:^(id sender) {
            NSString *s = [[NSString stringWithFormat:@"%@.mp3", ((CCNode *) sender).userData] lowercaseString];
            NSString *sf = locfile(s);
            [[SoundManager sharedManager] playSound:sf];
        }];
        
        item.userData = lang;
        item.position = ccp(0, -54 * count * fontScaleForCurrentDevice());
        count++;
        [menu addChild:item z:0 tag:1];
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
    
    purchase = [PurchaseViewController handleProductsRetrievedWithDelegate:self products:products withProductId:(NSString *) data upsell:PREMIUM_PRODUCT_ID];
    [self blurFadeLayer:YES withDuration:0.5];
}

-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data {
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    
    [PurchaseViewController handleProductsRetrievedFail];
    [self blurFadeLayer:NO withDuration:0.1];
}

-(void) purchaseFinished: (BOOL) success {
    [self redrawMenu];
    [self blurFadeLayer:NO withDuration:0.1];
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
