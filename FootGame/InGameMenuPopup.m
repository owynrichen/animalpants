//
//  InGameMenuLayer.m
//  FootGame
//
//  Created by Owyn Richen on 10/14/12.
//
//

#import "InGameMenuPopup.h"
#import "LocalizationManager.h"
#import "CCMenuItemFontWithStroke.h"
#import "SoundManager.h"

@interface InGameMenuPopup()

-(void) redrawMenu;

@end

@implementation InGameMenuPopup

-(id) initWithNarrateInLanguageBlock: (NarrateInLanguageBlock) nlBlock goHomeBlock: (GoHomeBlock) ghBlock {
    CGSize size = CGSizeMake(650, 500);
    self = [self initWithSize:size];
    
    self.narrateInLanguage = [nlBlock copy];
    self.goHome = [ghBlock copy];
    
    menu = [CCMenu menuWithItems: nil];
    [self addChild:menu];
    [self redrawMenu];
    menu.position = ccp(self.contentSize.width / 2, self.contentSize.height / 2);
    menu.opacity = 0;

    return self;
}

+(InGameMenuPopup *) inGameMenuWithNarrateInLanguageBlock: (NarrateInLanguageBlock) nlBlock goHomeBlock: (GoHomeBlock) ghBlock {
    InGameMenuPopup *igml = [[[InGameMenuPopup alloc] initWithNarrateInLanguageBlock:nlBlock goHomeBlock:ghBlock] autorelease];
    
    return igml;
}

-(void) dealloc {
    [super dealloc];
}

-(void) setColor:(ccColor3B)color {
    [menu setColor:color];
    [super setColor:color];
}

-(ccColor3B) color {
    return [super color];
}

-(GLubyte) opacity {
    return [super opacity];
}

-(void) setOpacity: (GLubyte) opacity {
    menu.opacity = opacity;
    [super setOpacity:opacity];
}

-(void) productRetrievalStarted {
    
}

-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data {
    if (purchase != nil)
        [purchase release];
    
    purchase = [PurchaseViewController handleProductsRetrievedWithDelegate:self products:products withProductId:(NSString *) data upsell:PREMIUM_PRODUCT_ID];
    // [self blurFadeLayer:YES withDuration:0.5];
}

-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data {
    [PurchaseViewController handleProductsRetrievedFail];
    // [self blurFadeLayer:NO withDuration:0.1];
}

-(void) purchaseFinished: (BOOL) success {
    [self redrawMenu];
    // [self blurFadeLayer:NO withDuration:0.1];
}

-(BOOL) cancelClicked: (BOOL) buying {
    // [self blurFadeLayer:NO withDuration:0.1];
    return !buying;
}

-(void) redrawMenu {
    [menu removeAllChildrenWithCleanup:YES];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    menu.anchorPoint = ccp(0,0);
    menu.position = ccp(winSize.width * 0.5, winSize.height * 0.6);
    
    __block int count = 0;
    __block InGameMenuPopup *pointer = self;
    
    for(NSString *lang in [[LocalizationManager sharedManager] getAvailableLanguages]) {
        NSString *langStr = [[LocalizationManager sharedManager] getLanguageNameString:lang];
        
        langStr = [NSString stringWithFormat:locstr(@"hear_it_in", @"strings", @""), langStr];

        CCMenuItemFontWithStroke *item = [CCMenuItemFontWithStroke itemFromString:langStr color:MENU_COLOR strokeColor:MENU_STROKE strokeSize:(4 * fontScaleForCurrentDevice()) block:^(id sender) {
                if (pointer.opacity < 255)
                    return;
            
                [pointer hide];
                NSString *l = ((CCNode *)sender).userData;
                BOOL o = [[PremiumContentStore instance] ownsProductId:[[LocalizationManager sharedManager] getLanguageProductForKey:l]];
            
                if (o == YES) {
                    pointer.narrateInLanguage(l);
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
    
    CCMenuItemFontWithStroke *go = [CCMenuItemFontWithStroke itemFromString:locstr(@"go_home",@"strings",@"") color:MENU_COLOR strokeColor:MENU_STROKE strokeSize:(4 * fontScaleForCurrentDevice()) block:^(id sender) {
        if (pointer.opacity < 255)
            return;
        
        [pointer hide];
        [pointer goHome];
    }];
    go.position = ccp(0, -54 * count * fontScaleForCurrentDevice());
    [menu addChild:go z:0 tag:1];
}

@end
