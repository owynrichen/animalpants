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
#import "AnimalFactsLayer.h"
#import "SoundManager.h"
#import "MainMenuLayer.h"
#import "LocalizationManager.h"
#import "PremiumContentStore.h"
#import "MBProgressHUD.h"
#import "CCMenuItemImageTouchDown.h"

@implementation AnimalSelectLayer

@synthesize background;
@synthesize menu;
@synthesize title;
@synthesize purchase;
@synthesize back;

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
    
    return self;
}

-(void) onEnter {
    [super onEnter];
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    title = [CCAutoScalingSprite spriteWithFile:@"text_theanimals.en.png"];
    title.position = ccpToRatio(512,winSize.height + title.contentSize.height);
    
    background = [CCAutoScalingSprite spriteWithFile:@"tropical.png"];
    background.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
    
    back = [CCAutoScalingSprite spriteWithFile:@"arrow.png"];
    back.scaleX = -0.4 * fontScaleForCurrentDevice();
    back.scaleY = 0.4 * fontScaleForCurrentDevice();
    back.anchorPoint = ccp(0,0);
    back.position = ccpToRatio(130, winSize.height - 100);
    [back addEvent:@"touchup" withBlock:^(CCNode *sender) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[CCDirector sharedDirector].view animated:YES];
        hud.labelText = locstr(@"loading", @"strings", @"");
        
        [[SoundManager sharedManager] playSound:@"glock__g1.mp3"];
        
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[MainMenuLayer scene] backwards:true]];
    }];
    
    menu = [CCMenu menuWithItems: nil];
    
    [self redrawMenu];
    
    [self addChild:background];
    [self addChild:menu];
    [self addChild:title];
    [self addChild:back];
    
    apView(@"Animal Select View");
}

-(void) onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    CCScaleBy *titleScale = [CCScaleBy actionWithDuration:0.5 scale:1.025];
    
    // TODO: make this bounce?
    [title runAction:[CCRepeatForever actionWithAction:[CCSequence actions:titleScale, [titleScale reverse], nil]]];
    
    [title runAction:[CCSequence actions:
                      [CCMoveTo actionWithDuration:0.50 position:ccpToRatio(512, 620)],
                      nil]];
}

-(void) onExitTransitionDidStart {
    [super onExitTransitionDidStart];
}

-(void) redrawMenu {
    [CCMenuItemFont setFontSize:40 * fontScaleForCurrentDevice()];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    [menu removeAllChildrenWithCleanup:YES];
    
	NSString *currentLocale = [[NSLocale currentLocale] localeIdentifier];
    NSLog(@"Locale: %@", currentLocale);

    menu.anchorPoint = ccp(0,0);
    menu.position = ccpToRatio(100, 400);
    __block int count = 0;
    __block int row = 0;
    
    [[[AnimalPartRepository sharedRepository] allAnimals] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *imageKey = [NSString stringWithFormat:@"circle-%@.png", [key lowercaseString]];
        NSString *selectedImageKey = [NSString stringWithFormat:@"circle-%@-happy.png", [key lowercaseString]];
        
        CCMenuItemImageTouchDown *item = [CCMenuItemImageTouchDown itemWithNormalImage:imageKey selectedImage:selectedImageKey block:^(id sender) {
            NSString *key = (NSString *) ((CCNode *) sender).userData;
                
            [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[AnimalFactsLayer sceneWithAnimalKey: key] backwards:false]];

        }];
        
        NSString *sound = [[NSString stringWithFormat:@"%@.mp3", key] lowercaseString];
        NSString *soundfname = locfile(sound);
        [[SoundManager sharedManager] preloadSound:soundfname];
        
        [item addDownEvent:^(id sender) {
            NSString *s = [[NSString stringWithFormat:@"%@.mp3", ((CCNode *) sender).userData] lowercaseString];
            NSString *sf = locfile(s);
            [[SoundManager sharedManager] playSound:sf];
        }];
        
        BOOL owned = [[PremiumContentStore instance] ownsProductId:((Animal *) obj).productId];
        
        if (!owned) {
            item.opacity = 220;
        }
        
        float gap = (winSize.width - (200 * positionScaleForCurrentDevice(kDimensionX)) - (item.contentSize.width * 4)) / 3;
        item.userData = key;
        item.anchorPoint = ccp(0,0);
        item.position = ccp((item.contentSize.width + gap) * (count % 4), row * (-item.contentSize.height - gap / 3));
        count++;
        if (count % 4 == 0)
            row++;
        
        [menu addChild:item z:0 tag:1];
    }];
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
}

-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data {
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    
    [PurchaseViewController handleProductsRetrievedFail];
}

-(void) purchaseFinished: (BOOL) success {
    [self redrawMenu];
}

-(void) dealloc {
    if (purchase != nil)
        [purchase release];
    purchase = nil;
    
    [super dealloc];
}

@end
