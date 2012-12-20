//
//  LanguageSelectLayer.h
//  FootGame
//
//  Created by Owyn Richen on 10/6/12.
//
//

#import "CCLayer.h"
#import "CCAutoScalingSprite.h"
#import "PurchaseViewController.h"

@interface LanguageSelectLayer : CCLayer <ProductRetrievalDelegate, PurchaseViewDelegate> {
    PurchaseViewController *purchase;
}

@property (nonatomic, retain) CCMenu *menu;
@property (nonatomic, retain) CCAutoScalingSprite *background;

+(CCScene *) scene;

-(void) redrawMenu;

-(void) productRetrievalStarted;
-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data;
-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data;
-(void) purchaseFinished: (BOOL) success;

@end
