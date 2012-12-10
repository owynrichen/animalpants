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
#import "LocalizationManager.h"
#import "PremiumContentStore.h"

@implementation AnimalSelectLayer

@synthesize background;
@synthesize menu;
@synthesize facts;
@synthesize purchase;

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
    
    facts = [[UIWebView alloc] init];
    facts.opaque = NO;
    facts.backgroundColor = [UIColor clearColor];
    // TODO: make this scale
    CGPoint pos = ccpToRatio(300, 0);
    CGPoint size = ccpToRatio(724, 768);
    facts.frame = CGRectMake(pos.x, pos.y, size.x, size.y);
    facts.delegate = self;
    
    return self;
}

-(void) onEnter {
    [super onEnter];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    background = [CCAutoScalingSprite spriteWithFile:@"tropical.png"];
    background.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
    
    menu = [CCMenu menuWithItems: nil];
    
    [self redrawMenu];
    
    [self addChild:background];
    [self addChild:menu];
}

-(void) onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    [[CCDirector sharedDirector].view addSubview:facts];
}

-(void) onExitTransitionDidStart {
    [facts removeFromSuperview];
    [super onExitTransitionDidStart];
}

-(void) redrawMenu {
    [CCMenuItemFont setFontSize:40 * fontScaleForCurrentDevice()];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    [menu removeAllChildrenWithCleanup:YES];
    
	NSString *currentLocale = [[NSLocale currentLocale] localeIdentifier];
    NSLog(@"Locale: %@", currentLocale);
    
    CCMenuItemFontWithStroke *back = [CCMenuItemFontWithStroke itemFromString:menulocstr(@"back", @"strings", @"Back") color:MENU_COLOR strokeColor:MENU_STROKE strokeSize:(4 * fontScaleForCurrentDevice()) block:^(id sender) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[MainMenuLayer scene] backwards:true]];
    }];
    back.anchorPoint = ccp(0,0);
    back.position = ccp(0,0);
    
    [menu addChild:back z:0 tag:1];
    menu.anchorPoint = ccp(0,0);
    menu.position = ccp(winSize.width * 0.1, winSize.height * 0.9);
    __block int count = 1;
    
    // TODO: this doesn't fit on an iphone... scrolling?
    //[[PromotionCodeManager instance] usePromotionCode:@"TESTERS" withDelegate:nil];
    //    [[PremiumContentStore instance] returnedProductId:@"com.alchemistinteractive.footgame.premium"];
    
    [[[AnimalPartRepository sharedRepository] allAnimals] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *menuKey = [NSString stringWithFormat:@"menu_%@", [key lowercaseString]];
        NSString *name = menulocstr(menuKey, @"strings", @"");
        
        BOOL owned = [[PremiumContentStore instance] ownsProductId:((Animal *) obj).productId];
        
        if (!owned) {
            name = [NSString stringWithFormat:@"%@ (%@)", name, locstr(@"buy", @"strings","")];
        }
        
        CCMenuItemFontWithStroke *item = [CCMenuItemFontWithStroke itemFromString:name color:MENU_COLOR strokeColor:MENU_STROKE strokeSize:(4 * fontScaleForCurrentDevice()) block:^(id sender) {
            NSString *html = ((Animal *) obj).factsHtml;
            //            NSLog(@"HTML: %@", html);
            NSString *path = [[NSBundle mainBundle] bundlePath];
            NSURL *baseURL = [NSURL fileURLWithPath:path];
            [facts loadHTMLString: html baseURL:baseURL];
        }];
        
        item.anchorPoint = ccp(0,0);
        item.position = ccp(0, -44 * count * fontScaleForCurrentDevice());
        count++;
        [menu addChild:item z:0 tag:1];
    }];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"webView shouldStartLoadWithRequest");
    if ([request.URL.scheme isEqualToString:@"animalpants"]) {
        NSString *key = [request.URL.pathComponents objectAtIndex:1];
        Animal *animal = [[AnimalPartRepository sharedRepository] getAnimalByKey:key];
        
        if ([[PremiumContentStore instance] ownsProductId:animal.productId]) {
            [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[AnimalViewLayer sceneWithAnimalKey: key] backwards:false]];
        } else {
            NSLog(@"Animal %@ isn't owned", key);
            [[InAppPurchaseManager instance] getProducts:self withData:animal.productId];
        }
        
        return NO;
    } else {
      return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webView didStartLoadWithRequest");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webView didFinishLoadWithRequest");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data {
    if (purchase != nil)
        [purchase release];
    
    NSString *productId = (NSString *) data;
    __block SKProduct *product = nil;
    
    [products enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SKProduct *p = (SKProduct *) obj;
        if ([productId isEqualToString:p.productIdentifier]) {
            product = (SKProduct *) obj;
            *stop = YES;
        }
    }];
    
    purchase = [[PurchaseViewController alloc] initWithProduct:product delegate:self];
    [[CCDirector sharedDirector].view addSubview:purchase.view];
    CGPoint pviewSize = ccpToRatio(1024, 768);
    purchase.view.frame = CGRectMake(0, 0, pviewSize.x, pviewSize.y);
}

-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:locstr(@"product_fetch_error_title", @"strings", @"")
                                                    message:locstr(@"product_fetch_error_desc", @"strings", @"")
                                                   delegate:nil
                                          cancelButtonTitle:locstr(@"okay", @"strings", @"")
                                          otherButtonTitles:nil];
    
    [alert show];
    [alert release];
}

-(void) purchaseFinished: (BOOL) success {
    [self redrawMenu];
}

-(void) dealloc {
    facts.delegate = nil;
    [facts release];
    facts = nil;
    
    if (purchase != nil)
        [purchase release];
    purchase = nil;
    
    [super dealloc];
}

@end
