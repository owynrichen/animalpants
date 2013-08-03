//
//  LanguageSelectLayer.m
//  FootGame
//
//  Created by Owyn Richen on 10/6/12.
//
//

#import "LanguageSelectLayer.h"
#import "CCButtonMenuItem.h"
#import "MainMenuLayer.h"
#import "LocalizationManager.h"
#import "PremiumContentStore.h"
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
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    title = [CCLabelTTFWithExtrude labelWithString:locstr(@"languages", @"strings", @"") fontName:@"Rather Loud" fontSize:200 * fontScaleForCurrentDevice()];
    [title setColor: ccc3(206, 216, 47)];
    [title setExtrudeColor: ccc3(130, 141, 55)];
    title.extrudeDepth = 20 * fontScaleForCurrentDevice();
    [title drawExtrude];
    
    title.rotation = -8.0;
    title.position = ccpToRatio(512,winSize.height + title.contentSize.height);
    
    background = [CCAutoScalingSprite spriteWithFile:@"tropical.png"];
    background.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
    
    [CCMenuItemFont setFontSize:48 * fontScaleForCurrentDevice()];
    [CCMenuItemFont setFontName:@"Rather Loud"];
    
    back = [CCAutoScalingSprite spriteWithFile:@"rightarrow.png"];
    back.scaleX = -0.4 * fontScaleForCurrentDevice();
    back.scaleY = 0.4 * fontScaleForCurrentDevice();
    back.anchorPoint = ccp(0,0);
    back.position = ccpToRatio(130, winSize.height - 100);
    
    __block LanguageSelectLayer *pointer = self;
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
    
    menu = [CCMenu menuWithItems: nil];
    
    [self addChild:background];
    [self addChild:menu];
    [self addChild:title];
    [self addChild:back];
    
    [self redrawMenu];
    
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
    
//     menu.anchorPoint = ccp(0,0);
    menu.position = ccp(winSize.width * 0.3, winSize.height * 0.6);
    
    __block int count = 0;
    __block LanguageSelectLayer *pointer = self;
    
    for(NSString *lang in [[LocalizationManager sharedManager] getAvailableLanguages]) {
        NSString *langStr = [[LocalizationManager sharedManager] getLanguageNameString:lang];
        
        BOOL owned = [[PremiumContentStore instance] ownsProductId:[[LocalizationManager sharedManager] getLanguageProductForKey:lang]];
        
        if (!owned) {
            langStr = [NSString stringWithFormat:@"%@ - %@", langStr, locstr(@"buy", @"strings","")];
        }
        
        FlagCircleButton *flag = [FlagCircleButton buttonWithLanguageCode: lang];
        flag.position = ccp(0,0);
        flag.scale = 0.7;
        
        CCButtonMenuItem *item = [CCButtonMenuItem itemWithButton: flag text: langStr block:^(id sender) {
                NSString *l = ((CCNode *)sender).userData;
                BOOL o = [[PremiumContentStore instance] ownsProductId:[[LocalizationManager sharedManager] getLanguageProductForKey:l]];
                if (o == YES) {
                    [pointer doWhenLoadComplete:locstr(@"loading", @"strings", @"") blk: ^{
                        apEvent(@"language select",l,[[LocalizationManager sharedManager] getAppPreferredLocale]);
                        [[LocalizationManager sharedManager] setAppPreferredLocale:l];
                        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[MainMenuLayer scene] backwards:true]];
                    }];
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
        item.position = ccp(0, -item.contentSize.height * 1.05 * count * fontScaleForCurrentDevice());
        count++;
        [menu addChild:item z:0 tag:1];
    }
}

-(void) productRetrievalStarted {
    apEvent(@"languages", @"freemium", @"product start");
}

-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data {
    if (purchase != nil)
        [purchase release];
    
    apEvent(@"languages", @"freemium", @"product success");
    
    purchase = [PurchaseViewController handleProductsRetrievedWithDelegate:self products:products withProductId:(NSString *) data upsell:PREMIUM_PRODUCT_ID];
    [self blurFadeLayer:YES withDuration:0.5];
}

-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data {   
    [PurchaseViewController handleProductsRetrievedFail];
    [self blurFadeLayer:NO withDuration:0.1];
    apEvent(@"languages", @"freemium", @"product error");
}

-(BOOL) purchaseFinished: (BOOL) success {    
    BOOL returnVal = YES;
    if (success) {
      apEvent(@"languages", @"freemium", @"purchase success");
    } else {
        returnVal = NO;
        apEvent(@"languages", @"freemium", @"purchase fail");
    }
    
    [self redrawMenu];
    [self blurFadeLayer:NO withDuration:0.1];
    return returnVal;
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
    apEvent(@"languages", @"freemium", @"cancel click");
    [self blurFadeLayer:NO withDuration:0.1];
    return !buying;
}

@end
