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

@implementation AnimalSelectLayer

@synthesize background;
@synthesize menu;
@synthesize facts;

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
    
    [CCMenuItemFont setFontSize:40 * fontScaleForCurrentDevice()];
    
	NSString *currentLocale = [[NSLocale currentLocale] localeIdentifier];
    NSLog(@"Locale: %@", currentLocale);
    
    CCMenuItemFontWithStroke *back = [CCMenuItemFontWithStroke itemFromString:menulocstr(@"back", @"strings", @"Back") color:MENU_COLOR strokeColor:MENU_STROKE strokeSize:(4 * fontScaleForCurrentDevice()) block:^(id sender) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[MainMenuLayer scene] backwards:true]];
    }];
    back.anchorPoint = ccp(0,0);
    back.position = ccp(0,0);
    
    menu = [CCMenu menuWithItems: nil];
    
    [menu addChild:back z:0 tag:1];
    menu.anchorPoint = ccp(0,0);
    menu.position = ccp(winSize.width * 0.1, winSize.height * 0.9);
    __block int count = 1;
    
    // TODO: this doesn't fit on an iphone... scrolling?
    
    [[[AnimalPartRepository sharedRepository] allAnimals] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *menuKey = [NSString stringWithFormat:@"menu_%@", [key lowercaseString]];
        NSString *name = menulocstr(menuKey, @"strings", @"");
        CCMenuItemFontWithStroke *item = [CCMenuItemFontWithStroke itemFromString:name color:MENU_COLOR strokeColor:MENU_STROKE strokeSize:(4 * fontScaleForCurrentDevice()) block:^(id sender) {
            NSString *html = ((Animal *) obj).factsHtml;
            NSLog(@"HTML: %@", html);
            NSString *path = [[NSBundle mainBundle] bundlePath];
            NSURL *baseURL = [NSURL fileURLWithPath:path];
            [facts loadHTMLString: html baseURL:baseURL];
        }];
        
        item.anchorPoint = ccp(0,0);
        item.position = ccp(0, -44 * count * fontScaleForCurrentDevice());
        count++;
        [menu addChild:item z:0 tag:1];
    }];
    
    [self addChild:background];
    [self addChild:menu];
    
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

-(void) onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    [[CCDirector sharedDirector].view addSubview:facts];
}

-(void) onExitTransitionDidStart {
    [facts removeFromSuperview];
    [super onExitTransitionDidStart];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"webView shouldStartLoadWithRequest");
    if ([request.URL.scheme isEqualToString:@"animalpants"]) {
        NSString *key = [request.URL.pathComponents objectAtIndex:1];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[AnimalViewLayer sceneWithAnimalKey: key] backwards:false]];
        
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

-(void) dealloc {
    facts.delegate = nil;
    [facts release];
    facts = nil;
    
    [super dealloc];
}

@end
