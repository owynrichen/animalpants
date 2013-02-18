//
//  AnimalFactsLayer.h
//  FootGame
//
//  Created by Owyn Richen on 2/7/13.
//
//

#import "CCLayer.h"
#import "Animal.h"
#import "PurchaseViewController.h"
#import "FactFrame.h"

@interface AnimalFactsLayer :  CCLayer<CCTargetedTouchDelegate, ProductRetrievalDelegate, PurchaseViewDelegate> {
    Animal *animal;
    PurchaseViewController *purchase;
    
    CCAutoScalingSprite *circle;
    CCAutoScalingSprite *title;
    CCAutoScalingSprite *background;
    CCAutoScalingSprite *playbuy;
    CCAutoScalingSprite *back;
    
    FactFrame *heightFrame;
    FactFrame *weightFrame;
    FactFrame *foodFrame;
    FactFrame *speedFrame;
    FactFrame *photoFrame;
    FactFrame *locFrame;
}

+(CCScene *) sceneWithAnimalKey: (NSString *) animal;

-(id) initWithAnimalKey: (NSString *) anml;
-(id) initWithAnimal: (Animal *) anml;

-(void) productRetrievalStarted;
-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data;
-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data;

-(BOOL) cancelClicked: (BOOL) buying;
-(void) purchaseFinished: (BOOL) success;

@end
