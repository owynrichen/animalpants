//
//  StoryLayer.m
//  FootGame
//
//  Created by Owyn Richen on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GoodbyeLayer.h"
#import "AnimalViewLayer.h"
#import "SoundManager.h"
#import "LocalizationManager.h"
#import "AudioCueRepository.h"
#import "AnalyticsPublisher.h"
#import "MBProgressHUD.h"
#import "AnimalSelectLayer.h"

@interface GoodbyeLayer()

-(void) nextScene;

@end

@implementation GoodbyeLayer

+(CCBaseScene *) scene
{
	// 'scene' is an autorelease object.
	CCBaseScene *scene = [CCBaseScene node];
	
	// 'layer' is an autorelease object.
	GoodbyeLayer *layer = [GoodbyeLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

+(ContentManifest *) myManifest {
    ContentManifest *mfest = [[[ContentManifest alloc] initWithImages:
                                        [NSArray arrayWithObjects:
                                         @"outro-background1.png",
                                         @"outro-background2.png",
                                         @"outro-background3.png",
                                         @"outro-midground1.png",
                                         @"outro-midground2.png",
                                         @"outro-midground3.png",
                                         @"outro-foreground1.png",
                                         @"outro-foreground2.png",
                                         @"outro-foreground3.png",
                                         @"jeep-side-animals.png",
                                         @"jeep-wheel-side1.png",
                                         @"jeep_front.png",
                                         nil]
                                    audio:
                                        [NSArray arrayWithObjects:
                                         [[LocalizationManager sharedManager] getLocalizedFilename:@"outro.mp3"],
                                         @"honk.mp3",
                                        nil]] autorelease];
    
    
    return mfest;
}

-(id) init {
    self = [super init];
    
    background = [CCLayer node];
    CCAutoScalingSprite *bg1 = [CCAutoScalingSprite spriteWithFile:@"outro-background1.jpg"];
    bg1.anchorPoint = ccp(0,0);
    bg1.position = ccpToRatio(0, 0);
    [background addChild:bg1];
    
    CCAutoScalingSprite *bg2 = [CCAutoScalingSprite spriteWithFile:@"outro-background2.jpg"];
    bg2.anchorPoint = ccp(0,0);
    bg2.position = ccpToRatio(1024, 0);
    [background addChild:bg2];
    
    CCAutoScalingSprite *bg3 = [CCAutoScalingSprite spriteWithFile:@"outro-background3.jpg"];
    bg3.anchorPoint = ccp(0,0);
    bg3.position = ccpToRatio(2048, 0);
    [background addChild:bg3];
    
    background.contentSize = CGSizeMake(1024 * 3, 768);
    background.anchorPoint = ccp(0,0);
    background.position = ccp(0,0);
    [self addChild:background z:0];
    
    midground = [CCLayer node];
    CCAutoScalingSprite *mg1 = [CCAutoScalingSprite spriteWithFile:@"outro-midground1.png"];
    mg1.anchorPoint = ccp(0,0);
    mg1.position = ccpToRatio(0, 0);
    [midground addChild:mg1];
    
    CCAutoScalingSprite *mg2 = [CCAutoScalingSprite spriteWithFile:@"outro-midground2.png"];
    mg2.anchorPoint = ccp(0,0);
    mg2.position = ccpToRatio(1024, 0);
    [midground addChild:mg2];
    
    CCAutoScalingSprite *mg3 = [CCAutoScalingSprite spriteWithFile:@"outro-midground3.png"];
    mg3.anchorPoint = ccp(0,0);
    mg3.position = ccpToRatio(2048, 0);
    [midground addChild:mg3];
    
    midground.contentSize = CGSizeMake(1024 * 3, 768);
    midground.anchorPoint = ccp(0,0);
    midground.position = ccp(0,0);
    [self addChild:midground z: 2];
    
    foreground = [CCLayer node];
    CCAutoScalingSprite *fg1 = [CCAutoScalingSprite spriteWithFile:@"outro-foreground1.png"];
    fg1.anchorPoint = ccp(0,0);
    fg1.position = ccpToRatio(0, 0);
    [foreground addChild:fg1];
    
    CCAutoScalingSprite *fg2 = [CCAutoScalingSprite spriteWithFile:@"outro-foreground2.png"];
    fg2.anchorPoint = ccp(0,0);
    fg2.position = ccpToRatio(1024, 0);
    [foreground addChild:fg2];
    
    CCAutoScalingSprite *fg3 = [CCAutoScalingSprite spriteWithFile:@"outro-foreground3.png"];
    fg3.anchorPoint = ccp(0,0);
    fg3.position = ccpToRatio(2048, 0);
    [foreground addChild:fg3];
    
    foreground.contentSize = CGSizeMake(1024 * 3, 768);
    foreground.anchorPoint = ccp(0,0);
    foreground.position = ccp(0,0);
    [self addChild:foreground z: 4];
    
    jeep = [CCAutoScalingSprite spriteWithFile:@"jeep-side-animals.png"];
    jeep.position = ccpToRatio(-jeep.contentSize.width * 0.2, 243);
    jeep.scale = 0.2;
    jeep.anchorPoint = ccp(0,0);
    
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
    
    [self addChild:jeep z: 1];
    
    CGSize bubbleRect = CGSizeMake(950 * positionScaleForCurrentDevice(kDimensionY), 240 * positionScaleForCurrentDevice(kDimensionY));
    
    outro = [[[NarrationNode alloc] initWithSize: bubbleRect] autorelease];
    outro.position = ccpToRatio(50, 480);
    outro.zOrder = 50;
    [self addChild:outro];
    
    __block GoodbyeLayer *pointer = self;
    
    skip = [LongPressButton buttonWithBlock:^(CCNode *sender) {
        [pointer nextScene];
    }];
    
    skip.position = ccpToRatio(950, 80);
    skip.zOrder = 50;
    [self addChild:skip];
    
#ifdef TESTING
    __block FeedbackPrompt *pPrompt = prompt;
    CircleButton *bugs = [CircleButton buttonWithFile:@"bugs.png"];
    bugs.scale = 0.5;
    bugs.anchorPoint = ccp(0,0);
    bugs.position = ccpToRatio(50, 768 - 100);
    
    [bugs addEvent:@"touch" withBlock:^(CCNode *sender) {
        [[SoundManager sharedManager] playSound:@"glock__g1.mp3"];
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:0.7]];
    }];
    [bugs addEvent:@"touchupoutside" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:0.5]];
    }];
    [bugs addEvent:@"touchup" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:0.5]];
        if (pPrompt == nil)
            pPrompt = [[FeedbackPrompt alloc] init];
        [pPrompt showFeedbackDialog];
    }];
    [self addChild: bugs];
#endif
    
    return self;
}

-(void) dealloc {
#ifdef TESTING
    if (prompt != nil)
        [prompt release];
#endif
    
    [super dealloc];
}

-(void) onEnter {
    apView(@"Goodbye View");
    [super onEnter];
}

-(void) onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    
    AudioCues *cues = [[AudioCueRepository sharedRepository] getCues:[[LocalizationManager sharedManager] getLocalizedFilename:@"outro.mp3"]];
    
    ccTime t = cues.totalRuntime * 1.2;
    
    [background runAction:[CCMoveTo actionWithDuration:t position:ccpToRatio(- (1024 * 2), 0)]];
    [midground runAction:[CCMoveTo actionWithDuration:t position:ccpToRatio(- (1024 * 2), 0)]];
    [foreground runAction:[CCMoveTo actionWithDuration:t position:ccpToRatio(- (1024 * 2), 0)]];
    
    __block GoodbyeLayer *pointer = self;
    __block LongPressButton *sPointer = skip;
    __block NarrationNode *nPointer = outro;

    CCSequence *jeepSeq = [CCSequence actions:[CCMoveTo actionWithDuration:t * 0.40 position:ccpToRatio(750, 240)],
                           [CCDelayTime actionWithDuration:t * 0.40],
                           [CCCallBlockN actionWithBlock:^(CCNode *node) {
        CCTexture2D *front = [[CCTextureCache sharedTextureCache] addImage:@"jeep_front.png"];
        [jeep setTexture:front];
        [jeep setTextureRect:CGRectMake(0,0,front.contentSize.width,front.contentSize.height) rotated:NO untrimmedSize:front.contentSize];
        jeep.zOrder = 3;
        jeep.scale = 0.3;
        
        [jeep removeAllChildrenWithCleanup:YES];
        [jeep runAction:[CCScaleTo actionWithDuration:t * 0.20 scale:1.0]];
        [jeep runAction:[CCSequence actions:[CCMoveTo actionWithDuration:t * 0.20 position:ccpToRatio(200, 50)],
                         [CCCallBlockN actionWithBlock:^(CCNode *node) {
            [[SoundManager sharedManager] playSound:@"honk.mp3"];
            [jeep runAction:[CCRepeatForever actionWithAction:
                             [CCSequence actions:
                              [CCTintTo actionWithDuration:0.2 red:192 green:192 blue:192],
                              [CCTintTo actionWithDuration:0.2 red:255 green:255 blue:255], nil]]];
            
            [nPointer runAction:[CCFadeOut actionWithDuration:2.0]];
            
            [jeep addEvent:@"touch" withBlock:^(CCNode *sender) {
                [[SoundManager sharedManager] playSound:locfile(@"animals.mp3")];
                [sender runAction:[CCScaleTo actionWithDuration:0.1 scale:1.2]];
            }];
            [jeep addEvent:@"touchupoutside" withBlock:^(CCNode *sender) {
                [sender runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
            }];
            [jeep addEvent:@"touchup" withBlock:^(CCNode *sender) {
                [pointer doWhenLoadComplete:locstr(@"loading", @"strings", @"") blk:^{
                    [pointer nextScene];
                }];
            }];
        }], nil]];

    }], nil];
    
    [jeep runAction:jeepSeq];
    
    truckSound = [[SoundManager sharedManager] playSound:@"truck_engine.mp3" withVol:0.2];
    [[SoundManager sharedManager] setMusicVolumeTemporarily:0.2];
    
    [outro startWithCues: cues finishBlock:^(CCNode *node) { [sPointer autoClickAfter:10.0]; }];
}

-(void) onExitTransitionDidStart {
    [[SoundManager sharedManager] resetMusicVolume];
    [[SoundManager sharedManager] stopSound:truckSound];
    
    [super onExitTransitionDidStart];
}

-(void) nextScene {
    [outro stop];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[AnimalSelectLayer scene] backwards:false]];
}

@end
