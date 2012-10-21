//
//  StoryLayer.m
//  FootGame
//
//  Created by Owyn Richen on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StoryLayer.h"
#import "AnimalViewLayer.h"
#import "SoundManager.h"
#import "LocalizationManager.h"

@implementation StoryLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	StoryLayer *layer = [StoryLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) init {
    self = [super init];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    background = [CCAutoScalingSprite spriteWithFile:@"tropical.png"];
    background.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
    [self addChild:background];
    
    girl1 = [CCAutoScalingSprite spriteWithFile:@"girl1.png"];
    girl1.position = ccpToRatio(700, 150);
    [self addChild:girl1];
    
    girl2 = [CCAutoScalingSprite spriteWithFile:@"girl2.png"];
    girl2.position = ccpToRatio(850, 150);
    [self addChild:girl2];
    
    CGRect bubbleRect = CGRectMake(0, 0, 900 * positionScaleForCurrentDevice(kDimensionY), 140 * positionScaleForCurrentDevice(kDimensionY));
    
    story1 = [[[SpeechBubble alloc] initWithStoryKey:@"story1" typingInterval:0.04 rect: bubbleRect point:ccp(0,0)] autorelease];
    story1.position = ccpToRatio(100, 580);
    [self addChild:story1];
    
    story2 = [[[SpeechBubble alloc] initWithStoryKey:@"story2" typingInterval:0.04 rect: bubbleRect point:ccp(0,0)] autorelease];
    story2.position = ccpToRatio(100, 440);
    [self addChild:story2];
    
    story3 = [[[SpeechBubble alloc] initWithStoryKey:@"story3" typingInterval:0.04 rect: bubbleRect point:ccp(0,0)] autorelease];
    story3.position = ccpToRatio(100, 300);
    [self addChild:story3];
    
    return self;
}

-(void) onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    
    [girl1 runAction:[CCJumpBy actionWithDuration:30.0 position:ccp(0,0) height:20 * positionScaleForCurrentDevice(kDimensionY) jumps:50]];
    [[SoundManager sharedManager] playSound:[[LocalizationManager sharedManager] getLocalizedFilename:@"story1.mp3"]];
    
    [story1 startWithFinishBlock:^(CCNode *node) {
        // TODO: set this up to go away on a timer or a touch
        [girl1 stopAllActions];
        [girl2 runAction:[CCJumpBy actionWithDuration:30.0 position:ccp(0,0) height:20 * positionScaleForCurrentDevice(kDimensionY) jumps:50]];
        [[SoundManager sharedManager] playSound:[[LocalizationManager sharedManager] getLocalizedFilename:@"story2.mp3"]];
        
        [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0], [CCCallBlockN actionWithBlock:^(CCNode *node) {
            
            [story2 startWithFinishBlock:^(CCNode *node) {
                [girl2 stopAllActions];
                [[SoundManager sharedManager] playSound:[[LocalizationManager sharedManager] getLocalizedFilename:@"story3.mp3"]];
                
                [story3 startWithFinishBlock:^(CCNode *node) {
                    [girl1 runAction:[CCJumpBy actionWithDuration:30.0 position:ccp(0,0) height:20 * positionScaleForCurrentDevice(kDimensionY) jumps:50]];
                    
                    [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0], [CCCallBlockN actionWithBlock:^(CCNode *node) {
                        [girl1 stopAllActions];
                        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[AnimalViewLayer scene] backwards:false]];
                    }], nil]];
                } touchBlock:^(CCNode *node, BOOL finished) {}];
            } touchBlock:^(CCNode *node, BOOL finished) {}];
        }], nil]];
    } touchBlock:^(CCNode *node, BOOL finished) {}];
}

@end
