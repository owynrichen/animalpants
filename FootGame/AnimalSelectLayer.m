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
#import "CCMenuItemImageTouchDown.h"

@implementation AnimalSelectLayer

@synthesize background;
@synthesize menu;
@synthesize title;
@synthesize purchase;
@synthesize back;

+(CCBaseScene *) scene
{
	// 'scene' is an autorelease object.
	CCBaseScene *scene = [CCBaseScene node];
	
	// 'layer' is an autorelease object.
	AnimalSelectLayer *layer = [AnimalSelectLayer node];
	
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
                NSMutableArray *images = [[NSMutableArray alloc] init];
                NSMutableArray *audio = [[NSMutableArray alloc] init];
                [[[AnimalPartRepository sharedRepository] allAnimals] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    
                    NSString *imageKey = [NSString stringWithFormat:@"circle-%@.png", [key lowercaseString]];
                    NSString *selectedImageKey = [NSString stringWithFormat:@"circle-%@-happy.png", [key lowercaseString]];
                    
                    if (imageKey != nil)
                        [images addObject:imageKey];
                    
                    if (selectedImageKey != nil)
                        [images addObject:selectedImageKey];
                    
                    // TODO: this only loads the current language strings and won't
                    // preload any others again... figure out what to do
                    NSString *sound = [[NSString stringWithFormat:@"%@.mp3", key] lowercaseString];
                    NSString *soundfname = locfile(sound);
                    
                    if (soundfname != nil) {
                        [audio addObject:soundfname];
                    }
                }];
                // TODO: preload title
                
                __manifest = [[ContentManifest alloc] initWithImages:images audio:audio];
                [images release];
                [audio release];
            }
        }
    }
    
    return [[__manifest copy] autorelease];
}

-(id) init {
    self = [super init];
    
    return self;
}

-(void) onEnter {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    title = title = [CCLabelTTFWithExtrude labelWithString:locstr(@"animals", @"strings", @"") fontName:@"Rather Loud" fontSize:200 * fontScaleForCurrentDevice()];
    [title setColor: ccc3(206, 216, 47)];
    [title setExtrudeColor: ccc3(130, 141, 55)];
    title.extrudeDepth = 20 * fontScaleForCurrentDevice();
    [title drawExtrude];
    
    title.rotation = -8.0;
    title.position = ccpToRatio(512,winSize.height + title.contentSize.height);
    
    background = [CCAutoScalingSprite spriteWithFile:@"tropical.png"];
    background.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
    
    back = [CCAutoScalingSprite spriteWithFile:@"rightarrow.png"];
    back.scaleX = -0.4 * fontScaleForCurrentDevice();
    back.scaleY = 0.4 * fontScaleForCurrentDevice();
    back.anchorPoint = ccp(0,0);
    back.position = ccpToRatio(130, winSize.height - 100);
    
    __block AnimalSelectLayer *pointer = self;
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
    
    apView(@"Animal Select View");
    [super onEnter];
}

-(void) onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    CCScaleBy *titleScale = [CCScaleBy actionWithDuration:0.5 scale:1.025];
    
    // TODO: make this bounce?
    [title runAction:[CCRepeatForever actionWithAction:[CCSequence actions:titleScale, [titleScale reverse], nil]]];
    
    [title runAction:[CCSequence actions:
                      [CCMoveTo actionWithDuration:0.50 position:ccpToRatio(512, 670)],
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
    __block AnimalSelectLayer *pointer = self;
    
    [[[AnimalPartRepository sharedRepository] allAnimals] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *imageKey = [NSString stringWithFormat:@"circle-%@.png", [key lowercaseString]];
        NSString *selectedImageKey = [NSString stringWithFormat:@"circle-%@-happy.png", [key lowercaseString]];
        
        CCMenuItemImageTouchDown *item = [CCMenuItemImageTouchDown itemWithNormalImage:imageKey selectedImage:selectedImageKey block:^(id sender) {
            [pointer doWhenLoadComplete:locstr(@"loading", @"strings", @"") blk: ^{
                NSString *key = (NSString *) ((CCNode *) sender).userData;
            
                [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[AnimalFactsLayer sceneWithAnimalKey: key] backwards:false]];
            }];

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

}

-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data {
    if (purchase != nil)
        [purchase release];
    
    purchase = [PurchaseViewController handleProductsRetrievedWithDelegate:self products:products withProductId:PREMIUM_PRODUCT_ID upsell:nil];
}

-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data {
    [PurchaseViewController handleProductsRetrievedFail];
}

-(BOOL) purchaseFinished: (BOOL) success {
    [self redrawMenu];
    return YES;
}

-(void) dealloc {
#ifdef TESTING
    if (prompt != nil)
        [prompt release];
#endif
    
    if (purchase != nil)
        [purchase release];
    purchase = nil;
    
    [super dealloc];
}

@end
