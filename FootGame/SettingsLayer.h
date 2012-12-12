//
//  SettingsLayer.h
//  FootGame
//
//  Created by Owyn Richen on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCLayer.h"
#import "CCAutoScalingSprite.h"
#import "PurchaseViewController.h"

@interface SettingsLayer : CCLayer<ProductRetrievalDelegate, PurchaseViewDelegate> {
    PurchaseViewController *purchase;
}

@property (nonatomic, retain) CCMenu *menu;
@property (nonatomic, retain) CCAutoScalingSprite *background;

+(CCScene *) scene;

-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data;
-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data;
-(void) purchaseFinished: (BOOL) success;


@end
