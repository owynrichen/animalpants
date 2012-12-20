//
//  AnimalViewLayer.h
//  FootGame
//
//  Created by Owyn Richen on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Animal.h"
#import "Environment.h"
#import "EnvironmentLayer.h"
#import "SpeechBubble.h"
#import "PurchaseViewController.h"

@interface AnimalViewLayer : CCLayer<CCTargetedTouchDelegate, ProductRetrievalDelegate, PurchaseViewDelegate> {
    Animal *animal;
    AnimalPart *body;
    NSArray *feet;
    Environment *environment;
    EnvironmentLayer *background;
    CCSprite *next;
    CCAutoScalingSprite *name;
    
    CCMotionStreak *streak;
    
    CCAutoScalingSprite *kid;
    SpeechBubble *bubble;
    CCLayer *gameLayer;
    CCLayer *hudLayer;
    
    CCAutoScalingSprite *head1;
    CCAutoScalingSprite *head2;
    
    BOOL nextTouched;
    BOOL bodyTouched;
    BOOL head1Touched;
    BOOL head2Touched;
    BOOL victory;
    
    PurchaseViewController *purchase;
}

// returns a CCScene that contains the AnimalViewLayer as the only child
+(CCScene *) scene;
+(CCScene *) sceneWithAnimalKey: (NSString *) animal;

-(id) initWithAnimalKey: (NSString *) animal;
-(id) initWithAnimal: (Animal *) animal;
-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event;
-(BOOL) testVictory;
-(void) blurGameLayer: (BOOL) blur withDuration: (GLfloat) duration;

-(void) productRetrievalStarted;
-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data;
-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data;

-(BOOL) cancelClicked: (BOOL) buying;
-(void) purchaseFinished: (BOOL) success;

@end
