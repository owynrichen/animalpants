//
//  LanguageSelectLayer.h
//  FootGame
//
//  Created by Owyn Richen on 10/6/12.
//
//

#import "ContentManifest.h"
#import "CCAutoScalingSprite.h"
#import "PurchaseViewController.h"
#import "CCLabelTTFWithExtrude.h"

@interface LanguageSelectLayer : CCPreloadingLayer <ProductRetrievalDelegate, PurchaseViewDelegate> {
    PurchaseViewController *purchase;
}

@property (nonatomic, retain) CCAutoScalingSprite *back;
@property (nonatomic, retain) CCLabelTTFWithExtrude *title;
@property (nonatomic, retain) CCMenu *menu;
@property (nonatomic, retain) CCAutoScalingSprite *background;

+(CCScene *) scene;

-(void) redrawMenu;

-(void) productRetrievalStarted;
-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data;
-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data;
-(BOOL) purchaseFinished: (BOOL) success;

-(BOOL) cancelClicked: (BOOL) buying;

@end
