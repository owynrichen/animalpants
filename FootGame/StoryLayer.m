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
#import "AudioCueRepository.h"

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
    
    CGRect bubbleRect = CGRectMake(0, 0, 900 * positionScaleForCurrentDevice(kDimensionY), 240 * positionScaleForCurrentDevice(kDimensionY));
    
    story1 = [[[SpeechBubble alloc] initWithStoryKey:@"story1" typingInterval:0.04 rect: bubbleRect point:ccp(0,0)] autorelease];
    story1.position = ccpToRatio(100, 480);
    [self addChild:story1];
    
    return self;
}

-(void) onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    
    [girl1 runAction:[CCJumpBy actionWithDuration:30.0 position:ccp(0,0) height:20 * positionScaleForCurrentDevice(kDimensionY) jumps:50]];
    
    AudioCues *cues = [[AudioCueRepository sharedRepository] getCues:[[LocalizationManager sharedManager] getLocalizedFilename:@"story1.mp3"]];
    
    [story1 startWithCues: cues finishBlock:^(CCNode *node) {
        // TODO: set this up to go away on a timer or a touch
        [girl1 stopAllActions];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[AnimalViewLayer scene] backwards:false]];
    } touchBlock:^(CCNode *node, BOOL finished) {}];
}

@end
