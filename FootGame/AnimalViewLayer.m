//
//  AnimalViewLayer.m
//  FootGame
//
//  Created by Owyn Richen on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnimalViewLayer.h"
#import "PartRepository.h"


@implementation AnimalViewLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	AnimalViewLayer *layer = [AnimalViewLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init {
    self = [super init];
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:YES];
    return self;
}

-(void) onEnter {
    animal = [[PartRepository sharedRepository] getRandomAnimal];
    animal.body.position = ccp(500, 500);
    
    [self addChild:animal.body];
    
    feet = [[PartRepository sharedRepository] getRandomFeet:4 includingAnimalFeet:animal];
    
    for(int i = 0; i < [feet count]; i++) {
        AnimalPart *foot = [feet objectAtIndex:i];
        foot.position = ccp(150 + (200 * i), 350);
        [self addChild:foot];
    }
}

-(void) onExit {
    [self removeChild:animal.body cleanup:NO];
    for(int i = 0; i < [feet count]; i++) {
        AnimalPart *foot = [feet objectAtIndex:i];
        [self removeChild:foot cleanup:NO];
    }
}

-(void) draw {
    [super draw];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint pnt = [[CCDirector sharedDirector] convertToGL: [touch locationInView:[touch view]]];
    
    for(int i = 0; i < [feet count]; i++) {
        AnimalPart *foot = [feet objectAtIndex:i];
        if ([foot hitTest:pnt]) {
            foot.touch = touch;
            foot.position = pnt;
            break;
        }
    }
        
    return YES;
}
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint pnt = [[CCDirector sharedDirector] convertToGL: [touch locationInView:[touch view]]];
    for(int i = 0; i < [feet count]; i++) {
        AnimalPart *foot = [feet objectAtIndex:i];
        if (touch == foot.touch) {
            AnchorPointPair *pair = [foot getClosestAnchorWithinDistance:30 withAnimalPart:animal.body];
            
            if (pair != nil) {
                foot.position = [animal.body convertToWorldSpace: pair.second.point];
            } else {
                foot.position = pnt;
            }
        }
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    for(int i = 0; i < [feet count]; i++) {
        AnimalPart *foot = [feet objectAtIndex:i];
        if (touch == foot.touch) {
            foot.touch = nil;
        }
    }
}

@end
