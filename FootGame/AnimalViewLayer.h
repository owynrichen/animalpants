//
//  AnimalViewLayer.h
//  FootGame
//
//  Created by Owyn Richen on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Animal.h"

@interface AnimalViewLayer : CCLayer<CCTargetedTouchDelegate> {
    Animal *animal;
    AnimalPart *body;
    NSArray *feet;
    CCSprite *background;
    CCSprite *next;
    CCLabelTTF *name;
    
    BOOL nextTouched;
}

// returns a CCScene that contains the AnimalViewLayer as the only child
+(CCScene *) scene;

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event;
- (BOOL) testVictory;

@end
