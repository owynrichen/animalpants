//
//  InGameMenuLayer.m
//  FootGame
//
//  Created by Owyn Richen on 10/14/12.
//
//

#import "InGameLanguageMenuPopup.h"
#import "LocalizationManager.h"
#import "SoundManager.h"
#import "EarFlagCircleButton.h"
#import "CCButtonMenuItem.h"

@interface InGameLanguageMenuPopup()

-(void) redrawMenu;

@end

@implementation InGameLanguageMenuPopup

-(id) initWithNarrateInLanguageBlock: (NarrateInLanguageBlock) nlBlock {
    CGSize size = CGSizeMake(650, 500);
    self = [self initWithSize:size];
    
    self.narrateInLanguage = [nlBlock copy];
    
    menu = [CCMenu menuWithItems: nil];
    [self addChild:menu];
    [self redrawMenu];
    menu.visible = NO;
    menu.isTouchEnabled = NO;
    menu.opacity = 0;

    return self;
}

+(InGameLanguageMenuPopup *) inGameLanguageMenuWithNarrateInLanguageBlock: (NarrateInLanguageBlock) nlBlock {
    InGameLanguageMenuPopup *igml = [[[InGameLanguageMenuPopup alloc] initWithNarrateInLanguageBlock:nlBlock] autorelease];
    
    return igml;
}

-(void) dealloc {
    [self.narrateInLanguage release];
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

-(BOOL) purchaseFinished: (BOOL) success {
    [self redrawMenu];
    return YES;
}

-(BOOL) cancelClicked: (BOOL) buying {
    return !buying;
}

-(void) redrawMenu {
    [menu removeAllChildrenWithCleanup:YES];
    
    menu.position = ccp(self.contentSize.width * 0.1, self.contentSize.height * 0.775);
    
    __block int count = 0;
    __block InGameLanguageMenuPopup *pointer = self;
    
    for(NSString *lang in [[LocalizationManager sharedManager] getAvailableLanguages]) {
        NSString *langStr = [[LocalizationManager sharedManager] getLanguageNameString:lang];
        
        langStr = [NSString stringWithFormat:locstr(@"hear_it_in", @"strings", @""), langStr];
        
        EarFlagCircleButton *ear = [EarFlagCircleButton buttonWithLanguageCode: lang];
        ear.position = ccp(0,0);
        ear.scale = 0.7;

        CCButtonMenuItem *item = [CCButtonMenuItem itemWithButton: ear text: langStr block:^(id sender) {
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
            if (pointer.opacity < 255)
                return;
            
            NSString *s = [[NSString stringWithFormat:@"%@.mp3", ((CCNode *) sender).userData] lowercaseString];
            NSString *sf = locfile(s);
            [[SoundManager sharedManager] playSound:sf];
        }];

        item.userData = lang;
        item.position = ccp(0, -(item.contentSize.height) * count * fontScaleForCurrentDevice());
        count++;
        [menu addChild:item z:0 tag:1];
    }
}

-(void) showWithOpenBlock:(PopupBlock)openBlock closeBlock:(PopupBlock)closeBlock analyticsKey:(NSString *)key {
    [super showWithOpenBlock:openBlock closeBlock:closeBlock analyticsKey:key];
    
    menu.visible = YES;
    menu.isTouchEnabled = YES;
}

-(void) hide {
    menu.visible = NO;
    menu.isTouchEnabled = NO;
    [super hide];
}

@end
