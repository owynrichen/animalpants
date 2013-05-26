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
#import "AnalyticsPublisher.h"
#import "AnimalPartRepository.h"

@interface StoryLayer()

-(void) nextScene;

@end

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

static ContentManifest *__manifest;
static NSString *__sync = @"sync";

+(ContentManifest *) myManifest {
    if (__manifest == nil) {
        @synchronized(__sync) {
            if (__manifest == nil) {
                __manifest = [[ContentManifest alloc] initWithImages:
                              [NSArray arrayWithObjects:
                               @"intro-background1.jpg",
                               @"intro-background2.jpg",
                               @"intro-background3.jpg",
                               @"jeep-back.png"
                               @"jeep-side.png",
                               @"intro-bggrass1.png",
                               @"intro-bggrass2.png",
                               @"intro-bggrass3.png",
                               @"jeep-wheel-side1.png",
                               nil] audio:
                              [NSArray arrayWithObjects:
                               @"story1.en.mp3",
                               @"story1.es.mp3",
                               @"story1.fr.mp3",
                               @"story1.de.mp3",
                               nil]];
            }
        }
    }
    
    return [[__manifest copy] autorelease];
}

-(id) init {
    self = [super init];
    
    background = [CCLayer node];
    CCAutoScalingSprite *bg1 = [CCAutoScalingSprite spriteWithFile:@"intro-background1.jpg"];
    bg1.anchorPoint = ccp(0,0);
    bg1.position = ccpToRatio(0, 0);
    [background addChild:bg1];
    
    CCAutoScalingSprite *bg2 = [CCAutoScalingSprite spriteWithFile:@"intro-background2.jpg"];
    bg2.anchorPoint = ccp(0,0);
    bg2.position = ccpToRatio(1024, 0);
    [background addChild:bg2];
    
    CCAutoScalingSprite *bg3 = [CCAutoScalingSprite spriteWithFile:@"intro-background3.jpg"];
    bg3.anchorPoint = ccp(0,0);
    bg3.position = ccpToRatio(2048, 0);
    [background addChild:bg3];
    
    background.contentSize = CGSizeMake(1024 * 3, 768);
    background.anchorPoint = ccp(0,0);
    background.position = ccp(0,0);
    [self addChild:background];
    
    [[CCTextureCache sharedTextureCache] addImage:@"jeep-back.png"];
    jeep = [CCAutoScalingSprite spriteWithFile:@"jeep-side.png"];
    jeep.position = ccpToRatio(-jeep.contentSize.width, 250);
    [self addChild:jeep];
    
    foreground = [CCLayer node];
    CCAutoScalingSprite *fg1 = [CCAutoScalingSprite spriteWithFile:@"intro-bggrass1.png"];
    fg1.anchorPoint = ccp(0,0);
    fg1.position = ccpToRatio(0, 0);
    [foreground addChild:fg1];
    
    CCAutoScalingSprite *fg2 = [CCAutoScalingSprite spriteWithFile:@"intro-bggrass2.png"];
    fg2.anchorPoint = ccp(0,0);
    fg2.position = ccpToRatio(1024, 0);
    [foreground addChild:fg2];
    
    CCAutoScalingSprite *fg3 = [CCAutoScalingSprite spriteWithFile:@"intro-bggrass3.png"];
    fg3.anchorPoint = ccp(0,0);
    fg3.position = ccpToRatio(2048, 0);
    [foreground addChild:fg3];
    
    foreground.contentSize = CGSizeMake(1024 * 3, 768);
    foreground.anchorPoint = ccp(0,0);
    foreground.position = ccp(0,0);
    [self addChild:foreground];
    
    CCAutoScalingSprite *frontWheel = [CCAutoScalingSprite spriteWithFile:@"jeep-wheel-side1.png"];
    frontWheel.position = ccpToRatio(750, 111);
    [jeep addChild:frontWheel];
    [frontWheel runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:1.0 angle:360]]];
    [frontWheel resumeSchedulerAndActions];
    CCAutoScalingSprite *backWheel = [CCAutoScalingSprite spriteWithFile:@"jeep-wheel-side1.png"];
    backWheel.position = ccpToRatio(384, 111);
    [jeep addChild:backWheel];
    [backWheel runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:1.0 angle:360]]];
    [backWheel resumeSchedulerAndActions];
    
    CGSize bubbleRect = CGSizeMake(950 * positionScaleForCurrentDevice(kDimensionY), 240 * positionScaleForCurrentDevice(kDimensionY));
    
    story1 = [[[NarrationNode alloc] initWithSize: bubbleRect] autorelease];
    story1.position = ccpToRatio(50, 550);
    [self addChild:story1];
    
    __block StoryLayer *pointer = self;
    
    skip = [LongPressButton buttonWithBlock:^(CCNode *sender) {
        [pointer nextScene];
    }];
    
    skip.position = ccpToRatio(950, 80);
    skip.scale = 0.8;
    [self addChild:skip];
    
    return self;
}

-(void) onEnter {
    apView(@"Story View");
    
    [[AnimalPartRepository sharedRepository] resetAnimals:NO];
    
    manifestToLoad = [[ContentManifest alloc] initWithManifests:[AnimalViewLayer manifestWithAnimal:[[AnimalPartRepository sharedRepository] peekNextAnimal]], nil];

    [super onEnter];
}

-(void) onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    
    AudioCues *cues = [[AudioCueRepository sharedRepository] getCues:[[LocalizationManager sharedManager] getLocalizedFilename:@"story1.mp3"]];
    
    ccTime t = cues.totalRuntime * 1.2;
    
    [background runAction:[CCMoveTo actionWithDuration:t position:ccpToRatio(- (1024 * 2), 0)]];
    [foreground runAction:[CCMoveTo actionWithDuration:t position:ccpToRatio(- (1024 * 2), 0)]];
    
    __block StoryLayer *pointer = self;
    
    CCSequence *jeepSeq = [CCSequence actions:[CCMoveTo actionWithDuration:t * 0.10 position:ccpToRatio(400, 280)],
                           [CCDelayTime actionWithDuration:t * 0.70],
                           [CCCallBlockN actionWithBlock:^(CCNode *node) {
                                CCTexture2D *back = [[CCTextureCache sharedTextureCache] addImage:@"jeep-back.png"];
                                [jeep setTexture:back];
                                [jeep setTextureRect:CGRectMake(0,0,back.contentSize.width,back.contentSize.height) rotated:NO untrimmedSize:back.contentSize];
                                jeep.scale = 2.0;
                                [jeep removeAllChildrenWithCleanup:YES];
                                [jeep runAction:[CCScaleTo actionWithDuration:t * 0.20 scale:0.3]];
                                [jeep runAction:[CCSequence actions:[CCMoveTo actionWithDuration:t * 0.20 position:ccpToRatio(1200, 380)], [CCCallBlockN actionWithBlock:^(CCNode *node) {
                                    [pointer nextScene];
                                }], nil]];
                            }],
                           nil];
    
    [jeep runAction:jeepSeq];
    
    [[SoundManager sharedManager] setMusicVolume:0.4];
    
    [story1 startWithCues: cues finishBlock:^(CCNode *node) {}];
}

-(void) onExitTransitionDidStart {
    [[SoundManager sharedManager] setMusicVolume:0.6];
    
    [super onExitTransitionDidStart];
}

-(void) nextScene {
    [story1 stop];
    
    [self doWhenLoadComplete:locstr(@"loading", @"strings", @"") blk:^{
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[AnimalViewLayer scene] backwards:false]];
    }];
}

@end
