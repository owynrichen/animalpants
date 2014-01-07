//
//  AnimalSelectLayer.h
//  FootGame
//
//  Created by Owyn Richen on 9/30/12.
//
//

#import "CCAutoScalingSprite.h"
#import "PurchaseViewController.h"
#import "ContentManifest.h"
#import "CCLabelTTFWithExtrude.h"

@interface AnimalSelectLayer : CCPreloadingLayer<ProductRetrievalDelegate, PurchaseViewDelegate> {
#ifdef TESTING
    FeedbackPrompt *prompt;
#endif
}

@property (nonatomic, retain) CCAutoScalingSprite *back;
@property (nonatomic, retain) CCMenu *menu;
@property (nonatomic, retain) CCLabelTTFWithExtrude *title;
@property (nonatomic, retain) CCAutoScalingSprite *background;
@property (nonatomic, retain) PurchaseViewController *purchase;

+(CCBaseScene *) scene;

-(void) redrawMenu;

-(void) productRetrievalStarted;
-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data;
-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data;
-(BOOL) purchaseFinished: (BOOL) success;

@end
