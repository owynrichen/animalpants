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
#import "FeedbackPrompt.h"
#import "CCLabelTTFWithExtrude.h"
#import "CreditsNode.h"

@interface SettingsLayer : CCPreloadingLayer<ProductRetrievalDelegate, PurchaseDelegate, PurchaseViewDelegate> {
    PurchaseViewController *purchase;
    CCVolumeMenuItem *music;
    CCVolumeMenuItem *narration;
    FeedbackPrompt *feedback;
#ifdef TESTING
    FeedbackPrompt *prompt;
#endif
}

@property (nonatomic, retain) CCLabelTTFWithExtrude *title;
@property (nonatomic, retain) CCAutoScalingSprite *back;
@property (nonatomic, retain) CCMenu *menu;
@property (nonatomic, retain) CCAutoScalingSprite *background;
@property (nonatomic, retain) CreditsNode *credits;

+(CCBaseScene *) scene;

-(void) productRetrievalStarted;
-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data;
-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data;
-(void) purchaseStarted;
-(void) purchaseSucceeded: (NSString *) productId;
-(void) purchaseFailed: (NSString *) productId;
-(BOOL) purchaseFinished: (BOOL) success;

-(BOOL) cancelClicked: (BOOL) buying;


@end
