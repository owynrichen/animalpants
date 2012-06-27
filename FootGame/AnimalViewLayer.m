//
//  AnimalViewLayer.m
//  FootGame
//
//  Created by Owyn Richen on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnimalViewLayer.h"
#import "PartRepository.h"
#import "SoundManager.h"

#define SNAP_DISTANCE 30
#define ROTATE_DISTANCE 300

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
    background = [CCSprite spriteWithFile:@"savannah.png"];
    // downscale for non-retina
    background.scale = 0.5 * CC_CONTENT_SCALE_FACTOR();
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    background.position = ccp(winSize.width / 2, winSize.height / 2);
    
    [self addChild:background];
    
    next = [CCSprite spriteWithFile:@"arrow.png"];
    next.scale = 0.4;
    next.position = ccp(920, 90);
    next.visible = false;
    
    [self addChild:next];
    
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:YES];
    return self;
}

-(void) onEnter {
    animal = [[PartRepository sharedRepository] getRandomAnimal];
    
    name = [CCLabelTTF labelWithString:animal.name fontName:@"Marker Felt" fontSize:100];
    name.anchorPoint = ccp(0,0);
    name.position = ccp(50, 650);
    name.opacity = 200;
    name.color = ccBLACK;
    [self addChild:name];
    
    feet = [[PartRepository sharedRepository] getRandomFeet:4 includingAnimalFeet:animal];
    
    for(int i = 0; i < [feet count]; i++) {
        AnimalPart *foot = [feet objectAtIndex:i];
        foot.position = ccp(150 + (220 * i), 200);
        [self addChild:foot];
    }
    
    body = [animal.body copyWithZone:nil];
    body.position = ccp(500, 270);
    
    [self addChild:body];
    
    [super onEnter];
}

-(void) onExit {
    [self removeChild:animal.body cleanup:YES];
    for(int i = 0; i < [feet count]; i++) {
        AnimalPart *foot = [feet objectAtIndex:i];
        [self removeChild:foot cleanup:YES];
    }
    [self removeChild:name cleanup:YES];
    [self removeChild:background cleanup:YES];
    [super onExit];
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
            [[SoundManager sharedManager] playSound:@"glock__c2.wav"];
            break;
        }
    }
    
    if (next.visible && CGRectContainsPoint([next boundingBox], pnt)) {
        nextTouched = YES;
    } else {
        nextTouched = NO;
    }
        
    return YES;
}
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint pnt = [[CCDirector sharedDirector] convertToGL: [touch locationInView:[touch view]]];
    for(int i = 0; i < [feet count]; i++) {
        AnimalPart *foot = [feet objectAtIndex:i];
        if (touch == foot.touch) {
            AnchorPointPair *pair = [foot getClosestAnchorWithinDistance:ROTATE_DISTANCE withAnimalPart:body];
            
            if (pair != nil && pair.distance <= SNAP_DISTANCE) { // SNAP IN PLACE
                [foot runAction:[CCRotateTo actionWithDuration:0.1 angle:pair.second.orientation]];
                // foot.rotation = pair.second.orientation;
                foot.position = [body convertToWorldSpace: pair.second.point];
            } else if (pair != nil) {  // ROTATE BUT DON'T SNAP
                float rot = pair.first.orientation + ((pair.second.orientation - pair.first.orientation) * (1 / (pair.distance - SNAP_DISTANCE)));
                // NSLog(@"%f", rot);
                [foot runAction:[CCRotateTo actionWithDuration:0.1 angle:rot]];
                // foot.rotation = rot;
                foot.position = pnt;
            } else { // LEAVE AS-IS
                [foot runAction:[CCRotateTo actionWithDuration:0.1 angle:pair.first.orientation]];
                //foot.rotation = pair.first.orientation;
                foot.position = pnt;
            }
            
            // NSLog(@"%f: %f, %@: %f", pair.distance, foot.rotation, pair.second.name, pair.second.orientation);
        }
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL footTouched = NO;
    
    for(int i = 0; i < [feet count]; i++) {
        AnimalPart *foot = [feet objectAtIndex:i];
        if (touch == foot.touch) {
            foot.touch = nil;
            footTouched = YES;
        }
    }
    
    if (footTouched) {
        if ([self testVictory]) {
            name.color = ccBLUE;
            [[SoundManager sharedManager] playSound:animal.successSound];
            next.visible = true;
            next.position = ccp(920, 90);
            [next runAction:[CCRepeatForever actionWithAction:[CCJumpBy actionWithDuration:2 position:ccp(0,0) height:30 jumps:2]]];
        // TODO: play sound, do something flashy, setup a button to choose the next animal
        } else {
            name.color = ccBLACK;
            [next stopAllActions];
            next.visible = false;
        }
    } else if (nextTouched) {
        [next stopAllActions];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[AnimalViewLayer scene] backwards:false]];
    }
}

-(BOOL) testVictory {
    CGPoint fpntWS;
    
    for(int i = 0; i < [animal.body.fixPoints count]; i++) {
        AnchorPoint* pnt = (AnchorPoint *) [body.fixPoints objectAtIndex: i];
        
        NSRange range = [pnt.name rangeOfString: @"Foot"];
        if (range.location != NSNotFound) {
            fpntWS = [body convertToWorldSpace:pnt.point];
        }
    }
    
    for(int i = 0; i < [feet count]; i++) {
        AnimalPart *foot = (AnimalPart *) [feet objectAtIndex:i];
        AnchorPoint *fpnt = (AnchorPoint *) [foot.fixPoints objectAtIndex:0];
        CGPoint test = [foot convertToWorldSpace:fpnt.point];
        NSLog(@"Testing foot: %@, %f, %f", foot.imageName, test.x, test.y);
        
        if ([foot.imageName isEqualToString:animal.foot.imageName]) {
            NSLog(@"'%@' == '%@'. %f, %f - %f, %f - Distance: %f", foot.imageName, animal.foot.imageName, test.x, test.y, fpntWS.x, fpntWS.y, ccpDistance(test, fpntWS));
            if (ccpDistance(test, fpntWS) != 0)
                return NO;
        }
    }
    
    return YES;
}

-(void) dealloc {
    [super dealloc];
}

@end
