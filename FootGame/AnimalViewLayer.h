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
#import "PurchaseViewController.h"
#import "ContentManifest.h"
#import "EarFlagCircleButton.h"
#import "LongPressButton.h"
#import "InGameLanguageMenuPopup.h"
#import "InGameSettingsMenuPopup.h"
#import "NarrationNode.h"
#import "chipmunk.h"
#import "cpMouse.h"


@interface CCDrawLayer : CCLayer {
     void (^blk)(void);
}

+(id) layerWithBlock: (void (^)(void)) block;
-(id) initWithBlock: (void (^)(void)) block;

@end

@interface AnimalViewLayer : CCPreloadingLayer<CCTargetedTouchDelegate, ProductRetrievalDelegate, PurchaseViewDelegate> {
    Animal *animal;
    AnimalPart *body;
    NSArray *feet;
    Environment *environment;
    EnvironmentLayer *background;
    CCSprite *next;
    CCSprite *prev;
    LongPressButton *skip;
    EarFlagCircleButton *langMenuButton;
    CircleButton *settingsMenuButton;
    InGameLanguageMenuPopup *langMenu;
    InGameSettingsMenuPopup *settingsMenu;
    NarrationNode *narration;
    cpSpace *physicsSpace;
    cpMouse *physicsMouse;
    CCDrawLayer *drawLayer;
    
    CCMotionStreak *streak;

    CCLayer *gameLayer;
    CCLayer *hudLayer;
    
    BOOL nextTouched;
    BOOL prevTouched;
    BOOL bodyTouched;
    BOOL head1Touched;
    BOOL head2Touched;
    BOOL victory;
    
    PurchaseViewController *purchase;
}

// returns a CCScene that contains the AnimalViewLayer as the only child
+(CCScene *) scene;
+(CCScene *) sceneWithAnimalKey: (NSString *) animal;
+(CCScene *) sceneWithAnimal: (Animal *) animal;

+(ContentManifest *) manifestWithAnimalKey: (NSString *) animal;
+(ContentManifest *) manifestWithAnimal: (Animal *) animal;

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
-(BOOL) purchaseFinished: (BOOL) success;

@end
