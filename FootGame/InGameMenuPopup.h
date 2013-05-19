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
typedef void (^GoHomeBlock)(void);

@interface InGameMenuPopup : Popup<PurchaseViewDelegate, ProductRetrievalDelegate> {
    CCAutoScalingSprite *head1;
    CCAutoScalingSprite *head2;
    
    CCMenu *menu;
    
    PurchaseViewController *purchase;
}

@property (nonatomic) NarrateInLanguageBlock narrateInLanguage;
@property (nonatomic) GoHomeBlock goHome;

+(InGameMenuPopup *) inGameMenuWithNarrateInLanguageBlock: (NarrateInLanguageBlock) nlBlock goHomeBlock: (GoHomeBlock) ghBlock;

-(id) initWithNarrateInLanguageBlock: (NarrateInLanguageBlock) nlBlock goHomeBlock: (GoHomeBlock) ghBlock;

-(void) productRetrievalStarted;
-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data;
-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data;
-(void) purchaseFinished: (BOOL) success;
-(BOOL) cancelClicked: (BOOL) buying;

@end
