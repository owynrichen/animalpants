//
//  InGameMenuLayer.h
//  FootGame
//
//  Created by Owyn Richen on 10/14/12.
//
//

#import "Popup.h"
#import "CCAutoScalingSprite.h"
#import "PurchaseViewController.h"

typedef void (^NarrateInLanguageBlock)(NSString *lang);

@interface InGameLanguageMenuPopup : Popup<PurchaseViewDelegate, ProductRetrievalDelegate> {
    CCMenu *menu;
    
    PurchaseViewController *purchase;
}

@property (nonatomic) NarrateInLanguageBlock narrateInLanguage;

+(InGameLanguageMenuPopup *) inGameLanguageMenuWithNarrateInLanguageBlock: (NarrateInLanguageBlock) nlBlock;

-(id) initWithNarrateInLanguageBlock: (NarrateInLanguageBlock) nlBlock;

-(void) productRetrievalStarted;
-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data;
-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data;
-(void) purchaseFinished: (BOOL) success;
-(BOOL) cancelClicked: (BOOL) buying;

@end
