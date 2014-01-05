//
//  AnimalFactsLayer.h
//  FootGame
//
//  Created by Owyn Richen on 2/7/13.
//
//

#import "ContentManifest.h"
#import "Animal.h"
#import "PurchaseViewController.h"
#import "FactFrame.h"
#import "FactDetailPopup.h"

@interface AnimalFactsLayer :  CCPreloadingLayer<ProductRetrievalDelegate, PurchaseViewDelegate> {
    Animal *animal;
    PurchaseViewController *purchase;
    
    CCAutoScalingSprite *circle;
    CCNode *title;
    CCAutoScalingSprite *background;
    CCAutoScalingSprite *playbuy;
    CCAutoScalingSprite *back;
    
    FactFrame *heightFrame;
    FactFrame *weightFrame;
    FactFrame *foodFrame;
    FactFrame *speedFrame;
    FactFrame *photoFrame;
    FactFrame *locFrame;
    
    CCBaseLayer *fadeLayer;
    
    FactDetailPopup *popup;
#ifdef TESTING
    FeedbackPrompt *prompt;
#endif
}

+(CCScene *) sceneWithAnimalKey: (NSString *) animal;

+(ContentManifest *) manifestWithAnimalKey: (NSString *) animal;
+(ContentManifest *) manifestWithAnimal: (Animal *) animal;

-(id) initWithAnimalKey: (NSString *) anml;
-(id) initWithAnimal: (Animal *) anml;

-(void) productRetrievalStarted;
-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data;
-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data;

-(BOOL) cancelClicked: (BOOL) buying;
-(BOOL) purchaseFinished: (BOOL) success;

@end
