//
//  AnimalSelectLayer.h
//  FootGame
//
//  Created by Owyn Richen on 9/30/12.
//
//

#import "CCLayer.h"
#import "CCAutoScalingSprite.h"
#import "PurchaseViewController.h"

@interface AnimalSelectLayer : CCLayer<ProductRetrievalDelegate, PurchaseViewDelegate>

@property (nonatomic, retain) CCAutoScalingSprite *back;
@property (nonatomic, retain) CCMenu *menu;
@property (nonatomic, retain) CCAutoScalingSprite *title;
@property (nonatomic, retain) CCAutoScalingSprite *background;
@property (nonatomic, retain) PurchaseViewController *purchase;

+(CCScene *) scene;

-(void) redrawMenu;

-(void) productRetrievalStarted;
-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data;
-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data;
-(void) purchaseFinished: (BOOL) success;

@end
