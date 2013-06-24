//
//  SettingsLayer.h
//  FootGame
//
//  Created by Owyn Richen on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContentManifest.h"
#import "CCAutoScalingSprite.h"
#import "PurchaseViewController.h"
#import "CCVolumeMenuItem.h"

@interface SettingsLayer : CCPreloadingLayer<ProductRetrievalDelegate, PurchaseDelegate, PurchaseViewDelegate> {
    PurchaseViewController *purchase;
    CCVolumeMenuItem *music;
    CCVolumeMenuItem *narration;
}

@property (nonatomic, retain) CCMenu *menu;
@property (nonatomic, retain) CCAutoScalingSprite *background;

+(CCScene *) scene;

-(void) productRetrievalStarted;
-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data;
-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data;
-(void) purchaseStarted;
-(void) purchaseSucceeded: (NSString *) productId;
-(void) purchaseFailed: (NSString *) productId;
-(void) purchaseFinished: (BOOL) success;

-(BOOL) cancelClicked: (BOOL) buying;


@end
