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
    animal.frontFoot.position = ccp(350, 350);
    animal.backFoot.position = ccp(650, 350);
    
    [self addChild:animal.body];
    [self addChild:animal.frontFoot];
    [self addChild:animal.backFoot];
}

-(void) onExit {
    [self removeChild:animal.body cleanup:NO];
    [self removeChild:animal.frontFoot cleanup:NO];
    [self removeChild:animal.backFoot cleanup:NO];
}

-(void) draw {
    [super draw];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint pnt = [[CCDirector sharedDirector] convertToGL: [touch locationInView:[touch view]]];
    if ([animal.frontFoot hitTest:pnt]) {
        animal.frontFoot.touch = touch;
        animal.frontFoot.position = pnt;
    }
    
    if ([animal.backFoot hitTest:pnt]) {
        animal.backFoot.touch = touch;
        animal.backFoot.position = pnt;
    }
    
    return YES;
}
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint pnt = [[CCDirector sharedDirector] convertToGL: [touch locationInView:[touch view]]];
    if (touch == animal.frontFoot.touch) {
        AnchorPointPair *pair = [animal.frontFoot getClosestAnchorWithinDistance:30 withAnimalPart:animal.body];
        
        // TODO: figure out how best to "unsnap", also do the math to get the anchor and the origin to match
        if (pair != nil) {
            animal.frontFoot.position = [animal.body convertToWorldSpace: pair.second.point];
        } else {
            animal.frontFoot.position = pnt;
        }
    }
    
    if (touch == animal.backFoot.touch) {
        AnchorPointPair *pair = [animal.backFoot getClosestAnchorWithinDistance:30 withAnimalPart:animal.body];
        
        // TODO: figure out how best to "unsnap", also do the math to get the anchor and the origin to match
        if (pair != nil) {
            animal.backFoot.position = [animal.body convertToWorldSpace: pair.second.point];
        } else {
            animal.backFoot.position = pnt;
        }
    }
}
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if (touch == animal.frontFoot.touch) {
        animal.frontFoot.touch = nil;
    }
    
    if (touch == animal.backFoot.touch) {
        animal.backFoot.touch = nil;
    }
}

@end
