//
//  AnimalViewLayer.m
//  FootGame
//
//  Created by Owyn Richen on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainMenuLayer.h"
#import "AnimalViewLayer.h"
#import "AnimalPartRepository.h"
#import "EnvironmentRepository.h"
#import "SoundManager.h"
#import "CCAutoScaling.h"
#import "FadeGrid3D.h"
#import "AudioCueRepository.h"
#import "LocalizationManager.h"
#import "AnalyticsPublisher.h"
#import "PremiumContentStore.h"
#import "GoodbyeLayer.h"
#import "StoryLayer.h"
#import "AnimalFactsLayer.h"

#define SNAP_DISTANCE 50
#define CORRECT_SNAP_DISTANCE 100
#define ROTATE_DISTANCE 300

// #define DRAW_PHYSICS 1
// #define DRAW_FOOT_ANCHORS 1

@implementation CCDrawLayer
+(id) layerWithBlock: (void(^)(void)) block {
    return [[[CCDrawLayer alloc] initWithBlock:block] autorelease];
}
-(id) initWithBlock: (void(^)(void)) blck {
    self = [super init];
    
    blk = [blck copy];
    
    return self;
}

-(void) dealloc {
    blk = nil;
    [super dealloc];
}

-(void) draw {
    blk();
    [super draw];
}
@end

@interface AnimalViewLayer ()

-(AnimalPart *) getCorrectFoot;
-(void) drawAttention: (ccTime) dtime;
-(CGPoint) startPositionForFoot: (int) index;

-(void) setupLevel;
-(void) teardownLevel;
-(void) quitToMainMenu;
-(void) openFactPage;
-(void) setupPhysics;
-(void) teardownPhysics;
-(void) createBoundary;

-(void) startNarration: (ccTime) dtime;
-(void) startNarration: (ccTime) dtime forLang: (NSString *) lang;
-(void) stopNarration;
-(void) startLevel;

-(void) drawPhysics;
-(void) drawFootAnchors;
@end

@implementation AnimalViewLayer

+(CCScene *) scene
{
	return [AnimalViewLayer sceneWithAnimalKey:nil];
}

+(CCScene *) sceneWithAnimalKey: (NSString *) animal {
    Animal *anml;
    
    if (animal == nil) {
        anml = [[AnimalPartRepository sharedRepository] getFirstAnimal];
    } else {
        anml = [[AnimalPartRepository sharedRepository] getAnimalByKey:animal];
    }
    
    return [AnimalViewLayer sceneWithAnimal:anml];
}

+(CCScene *) sceneWithAnimal: (Animal *) animal {
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
    NSAssert(animal != nil, @"animal cannot be nil");
	
	// 'layer' is an autorelease object.
	AnimalViewLayer *layer = [[[AnimalViewLayer alloc] initWithAnimal:animal] autorelease];
    
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

+(ContentManifest *) manifestWithAnimalKey: (NSString *) animal {
    return [AnimalViewLayer manifestWithAnimal:[[AnimalPartRepository sharedRepository] getAnimalByKey:animal]];
}

+(ContentManifest *) manifestWithAnimal: (Animal *) animal {
    ContentManifest *mfest = [[[ContentManifest alloc] init] autorelease];
    
    [mfest addManifest:animal.manifest];
    [mfest addManifest:[[EnvironmentRepository sharedRepository] getEnvironment:animal.environment].manifest];
    
    return mfest;
}

-(id) initWithAnimalKey: (NSString *) anml {
    self = [self initWithAnimal:[[AnimalPartRepository sharedRepository] getAnimalByKey:anml]];
    
    return self;
}

-(id) initWithAnimal: (Animal *) anml {
    self = [super init];
    isTouchEnabled_ = YES;
    
    animal = [anml retain];
    
    return self;
}

-(id) init {
    self = [self initWithAnimal:animal = [[AnimalPartRepository sharedRepository] getNextAnimal]];
    
    return self;
}

-(void) onEnter {
    victory = NO;
    
#if USE_PHYSICS_ENGINE
    [self setupPhysics];
#endif
    [self setupLevel];
    [super onEnter];
}

-(void) onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    
    if ([[PremiumContentStore instance] ownsProductId:animal.productId]) {
        [self startLevel];
    } else {
        [[CCDirector sharedDirector] pause];
        [[SoundManager sharedManager] playSound:locfile(@"upsell.mp3")];
        [[InAppPurchaseManager instance] getProducts:self withData:nil];
        apEvent(@"story", @"freemium", @"complete");
    }
}

-(void) onExit {
    [super onExit];
    [self teardownLevel];
#if USE_PHYSICS_ENGINE
    [self teardownPhysics];
#endif
}

-(void) setupPhysics {
    physicsSpace = cpSpaceNew();
    cpSpaceSetIterations(physicsSpace, 60);
	cpSpaceSetGravity(physicsSpace, cpv(0, -100));
	cpSpaceSetSleepTimeThreshold(physicsSpace, 0.5f);
    [self createBoundary];
    [self scheduleUpdate];
}

-(void) teardownPhysics {
    cpSpaceFree(physicsSpace);
    [self unscheduleUpdate];
}

- (void)createBoundary {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGPoint lowerLeft = ccp(0, 0);
    CGPoint lowerRight = ccp(winSize.width, 0);
    CGPoint upperLeft = ccp(0, winSize.height);
    CGPoint upperRight = ccp(winSize.width, winSize.height);
    
    cpBody *groundBody = cpSpaceGetStaticBody(physicsSpace);
    
    float radius = 3.0f;
    cpShape *groundShape = cpSegmentShapeNew(groundBody, lowerLeft, lowerRight, radius);
    groundShape->e = 1.0f; // elasticity
    groundShape->u = 1.0f; // friction
    groundShape->collision_type = 0;
    cpSpaceAddStaticShape(physicsSpace, groundShape);
    
    cpShape *leftShape = cpSegmentShapeNew(groundBody, lowerLeft, upperLeft, radius);
    leftShape->e = 1.0f; // elasticity
    leftShape->u = 1.0f; // friction
    leftShape->collision_type = 0;
    cpSpaceAddStaticShape(physicsSpace, leftShape);
    
    cpShape *rightShape = cpSegmentShapeNew(groundBody, lowerRight, upperRight, radius);
    rightShape->e = 1.0f; // elasticity
    rightShape->u = 1.0f; // friction
    rightShape->collision_type = 0;
    cpSpaceAddStaticShape(physicsSpace, rightShape);

    cpShape *topShape = cpSegmentShapeNew(groundBody, upperLeft, upperRight, radius);
    topShape->e = 1.0f; // elasticity
    topShape->u = 1.0f; // friction
    topShape->collision_type = 0;
    cpSpaceAddStaticShape(physicsSpace, topShape);
}

-(void) setupLevel {
    gameLayer = [CCLayer node];
    [self addChild:gameLayer];
    
    hudLayer = [CCLayer node];
    [self addChild:hudLayer];
    
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:NO];
    
    environment = [[EnvironmentRepository sharedRepository] getEnvironment:animal.environment];
    background = [environment getLayerwithSpace:physicsSpace];
    
    [gameLayer addChild:background];
    
    feet = [[[AnimalPartRepository sharedRepository] getRandomFeet:3 includingAnimalFeet:animal] retain];
    
    for(int i = 0; i < [feet count]; i++) {
        AnimalPart *foot = [feet objectAtIndex:i];
        foot.position = [self startPositionForFoot:i];
        [gameLayer addChild:foot];
    }
    
    body = [animal.body copyWithZone:nil];
    body.position = background.animalPosition;
    
    [gameLayer addChild:body];
    
    next = [CCSprite spriteWithFile:@"rightarrow.png"];
    next.scale = 0.4 * fontScaleForCurrentDevice();
    next.position = ccpToRatio(920, 90);
    next.visible = false;
    
    [gameLayer addChild:next];
    
    prev = [CCSprite spriteWithFile:@"rightarrow.png"];
    prev.scale = -0.4 * fontScaleForCurrentDevice();
    prev.position = ccpToRatio(100, 90);
    prev.visible = false;
    
    [gameLayer addChild:prev];
    
    [[[CCDirector sharedDirector] scheduler] scheduleSelector:@selector(drawAttention:) forTarget:self interval:10 paused:NO repeat:10 delay:5];
    
    streak = [CCMotionStreak streakWithFade:1 minSeg:10 width:50 color:ccWHITE textureFilename:@"rainbow.png"];
    streak.fastMode = NO;
    [gameLayer addChild:streak];
    
    [self blurGameLayer:YES withDuration:0.1];
    
    narration = [[NarrationNode alloc] initWithSize:CGSizeMake(800 * positionScaleForCurrentDevice(kDimensionY), 150 * positionScaleForCurrentDevice(kDimensionY))];
    narration.position = ccpToRatio(50, 580);
    [self addChild:narration];

    [[SoundManager sharedManager] fadeOutBackground];
    [[SoundManager sharedManager] playBackground:environment.bgMusic];
    
    NSString *alog = [NSString stringWithFormat: @"Game View %@", animal.key];
    apView(alog);
    
    Animal *nextAnimal = [[AnimalPartRepository sharedRepository] peekNextAnimal];
    
    if (nextAnimal != nil) {
        manifestToLoad = [[AnimalViewLayer manifestWithAnimal:nextAnimal] retain];
    } else {
        manifestToLoad = [[GoodbyeLayer myManifest] retain];
    }
    
    __block AnimalViewLayer *pointer = self;
    
    skip = [LongPressButton buttonWithBlock:^(CCNode *sender) {
        apEvent(animal.key, @"skip", @"complete");
        [pointer stopNarration];
    }];
    skip.scale = 0.8;
    
    skip.position = ccpToRatio(950, 80);
    [self addChild:skip];
    skip.visible = NO;

    langMenuButton = [EarFlagCircleButton buttonWithLanguageCode:[[LocalizationManager sharedManager] getAppPreferredLocale]];
    langMenuButton.scale = 0.8;
    [langMenuButton addEvent:@"touch" withBlock:^(CCNode *sender) {
        [[SoundManager sharedManager] playSound:@"glock__g1.mp3"];
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
    }];
    [langMenuButton addEvent:@"touchupoutside" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:0.8]];
    }];
    [langMenuButton addEvent:@"touchup" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:0.8]];
        [langMenu showWithOpenBlock:^(CCNode<CCRGBAProtocol> *popup) {
            [pointer blurGameLayer:YES withDuration:0.2];
        } closeBlock:^(CCNode<CCRGBAProtocol> *popup) {
            [pointer blurGameLayer:NO withDuration:0.2];
        } analyticsKey:@"In Game Languages Menu"];
    }];
    langMenuButton.position = ccpToRatio(950, 620);
    [self addChild:langMenuButton];
    
    settingsMenuButton = [CircleButton buttonWithFile:@"gear.png"];
    settingsMenuButton.scale = 0.5;
    [settingsMenuButton addEvent:@"touch" withBlock:^(CCNode *sender) {
        [[SoundManager sharedManager] playSound:@"glock__g1.mp3"];
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:0.7]];
    }];
    [settingsMenuButton addEvent:@"touchupoutside" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:0.5]];
    }];
    [settingsMenuButton addEvent:@"touchup" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:0.5]];
        [settingsMenu showWithOpenBlock:^(CCNode<CCRGBAProtocol> *popup) {
            [pointer blurGameLayer:YES withDuration:0.2];
        } closeBlock:^(CCNode<CCRGBAProtocol> *popup) {
            [pointer blurGameLayer:NO withDuration:0.2];
        } analyticsKey:@"In Game Settings Menu"];
    }];
    settingsMenuButton.position = ccpToRatio(950, 700);
    [self addChild:settingsMenuButton];
    
    
    langMenu = [InGameLanguageMenuPopup inGameLanguageMenuWithNarrateInLanguageBlock:^(NSString *lang) {
        [pointer blurGameLayer:YES withDuration:0.25];
        [pointer startNarration:0 forLang:lang];
    }];
    langMenu.position = ccpToRatio(512, 300);
    
    settingsMenu = [InGameSettingsMenuPopup inGameSettingsMenuPopupWithGoHomeBlock:^{
        [pointer doWhenLoadComplete:locstr(@"loading", @"strings", @"") blk:^{
            [pointer quitToMainMenu];
        }]; }
        factPageBlock:^(NSString *key) {
            [pointer doWhenLoadComplete:locstr(@"loading", @"strings", @"") blk:^{
                [pointer openFactPage];
            }];
        } forAnimalKey: animal.key];
        
    
   
    settingsMenu.position = ccpToRatio(512, 300);
    
    [self addChild:langMenu];
    [self addChild:settingsMenu];
    
#if DRAW_PHYSICS || DRAW_FOOT_ANCHORS
    drawLayer = [CCDrawLayer layerWithBlock:^{
#if USE_PHYSICS_ENGINE && DRAW_PHYSICS
        [self drawPhysics];
#endif
        
        CHECK_GL_ERROR_DEBUG();
        
#if DRAW_FOOT_ANCHORS
        [self drawFootAnchors];
#endif
    }];
    [drawLayer setContentSize:self.contentSize];
    drawLayer.position = ccp(0,0);
    
    [self addChild:drawLayer];
#endif
}

-(void) teardownLevel {
    [self removeChild:animal.body cleanup:YES];
    for(int i = 0; i < [feet count]; i++) {
        AnimalPart *foot = [feet objectAtIndex:i];
        [self removeChild:foot cleanup:YES];
    }
    [self removeChild:background cleanup:YES];
    [feet release];
    
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
}

-(void) startLevel {
    [self startNarration:0.0];
}

-(void) update:(ccTime)delta {
    cpSpaceStep(physicsSpace, delta);
    [super update:delta];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint pnt = [[CCDirector sharedDirector] convertToGL: [touch locationInView:[touch view]]];
    nextTouched = NO;
    bodyTouched = NO;
    
#if USE_PHYSICS_ENGINE
    physicsMouse = cpMouseNew(physicsSpace);
    cpMouseGrab(physicsMouse, pnt, false);
#endif
    
    for(int i = 0; i < [feet count]; i++) {
        AnimalPart *foot = [feet objectAtIndex:i];
        if ([foot hitTest:pnt]) {
            foot.touch = touch;
            foot.position = pnt;
            [[SoundManager sharedManager] playSound:@"glock__c2.mp3"];

            [streak setPosition:pnt];
            return YES;
        }
    }
    
    if (next.visible && CGRectContainsPoint([next boundingBox], pnt)) {
        nextTouched = YES;
        return YES;
    }
    
    if (prev.visible && CGRectContainsPoint([prev boundingBox], pnt)) {
        prevTouched = YES;
        return YES;
    }
    
// TURNING OFF BODY MOVEMENT
//    if ([body hitTest:pnt]) {
//        [streak setPosition:pnt];
//        bodyTouched = YES;
//        return YES;
//    }
    
    return NO;
}
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint pnt = [[CCDirector sharedDirector] convertToGL: [touch locationInView:[touch view]]];
    
#if USE_PHYSICS_ENGINE
    cpMouseMove(physicsMouse, pnt);
#endif
    
    for(int i = 0; i < [feet count]; i++) {
        AnimalPart *foot = [feet objectAtIndex:i];
        if (touch == foot.touch) {
            [streak setPosition:pnt];
            
            AnchorPointPair *pair = [foot getClosestAnchorWithinDistance:ROTATE_DISTANCE withAnimalPart:body];
            
            int distance = SNAP_DISTANCE;
            if (foot == [self getCorrectFoot]) {
                distance = CORRECT_SNAP_DISTANCE;
            }
            
            if (pair != nil && pair.distance <= distance) { // SNAP IN PLACE
                [foot runAction:[CCRotateTo actionWithDuration:0.1 angle:pair.second.orientation]];
                // foot.rotation = pair.second.orientation;
                foot.position = [body convertToWorldSpace: pair.second.point];
            } else if (pair != nil) {  // ROTATE BUT DON'T SNAP
                float rot = pair.first.orientation + ((pair.second.orientation - pair.first.orientation) * (1 / (pair.distance - distance)));
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
    
    if (bodyTouched) {
        // TODO: play a sound
        [body setPosition:pnt];
        [streak setPosition:pnt];
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    BOOL footTouched = NO;
    
#if USE_PHYSICS_ENGINE
    cpMouseRelease(physicsMouse);
    cpMouseDestroy(physicsMouse);
    physicsMouse = NULL;
#endif
    
    for(int i = 0; i < [feet count]; i++) {
        AnimalPart *foot = [feet objectAtIndex:i];
        if (touch == foot.touch) {
            foot.touch = nil;
            footTouched = YES;
        }
    }
    
    if (bodyTouched) {
        footTouched = YES;
        
        // TODO: other fun stuff
    }
    
    if (footTouched) {
        if ([self testVictory]) {
            [body setState:kAnimalStateHappy];
            [[SoundManager sharedManager] fadeOutBackground];
            [[SoundManager sharedManager] playBackground:@"level_complete.mp3"];
            victory = YES;
            
            [[SoundManager sharedManager] playSound:animal.successSound];
            next.visible = true;
            next.position = ccpToRatio(920, 90);
            [next runAction:[CCRepeatForever actionWithAction:[CCJumpBy actionWithDuration:2 position:ccpToRatio(0,0) height:30 jumps:2]]];
            
            prev.visible = true;
            prev.position = ccpToRatio(100, 90);
            [prev runAction:[CCRepeatForever actionWithAction:[CCJumpBy actionWithDuration:2 position:ccpToRatio(0,0) height:30 jumps:2]]];
            
            AnimalPart *correctFoot = [self getCorrectFoot];
            for (int i = 0; i < [feet count]; i++) {
                AnimalPart *foot = (AnimalPart *) [feet objectAtIndex:i];
                if (![foot.imageName isEqualToString:correctFoot.imageName]) {
                    foot.visible = NO;
                }
            }
        } else {
            [body setState:kAnimalStateNormal];
            if (victory) {
                [[SoundManager sharedManager] fadeOutBackground];
                [[SoundManager sharedManager] playBackground:environment.bgMusic];
            }
            
            victory = NO;
            
            [next stopAllActions];
            next.visible = false;
            
            [prev stopAllActions];
            prev.visible = false;
            
            // TODO: play bad noise
            
            for(int i = 0; i < [feet count]; i++) {
                AnimalPart *foot = [feet objectAtIndex:i];
                foot.visible = YES;
                CGPoint correctPos = [self startPositionForFoot:i];
                if (foot.position.x != correctPos.x || foot.position.y != correctPos.y) {
                    [foot runAction:[CCMoveTo actionWithDuration:0.5 position: correctPos]];
                }
            }
        }
    } else if (nextTouched) {
        [next stopAllActions];
        
        Animal *nextAnimal = [[AnimalPartRepository sharedRepository] getNextAnimal];
        CCScene *nextScene;
        
        if (nextAnimal != nil) {
            nextScene = [AnimalViewLayer sceneWithAnimal:nextAnimal];
        } else {
            nextScene = [GoodbyeLayer scene];
        }
        
        [self doWhenLoadComplete:locstr(@"loading", @"strings", @"") blk:^{
            [narration stop];
            
            [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:nextScene backwards:false]];
        }];
    } else if (prevTouched) {
        [prev stopAllActions];
        
        Animal *prevAnimal = [[AnimalPartRepository sharedRepository] getPreviousAnimal];
        CCScene *prevScene;
        
        if (prevAnimal != nil) {
            prevScene = [AnimalViewLayer sceneWithAnimal:prevAnimal];
        } else {
            prevScene = [StoryLayer scene];
        }
        
        [self doWhenLoadComplete:locstr(@"loading", @"strings", @"") blk:^{
            [narration stop];
            
            [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:prevScene backwards:true]];
        }];
    }
}

-(AnimalPart *) getCorrectFoot {
    for(int i = 0; i < [feet count]; i++) {
        AnimalPart *foot = (AnimalPart *) [feet objectAtIndex:i];
        if ([foot.imageName isEqualToString:animal.foot.imageName]) {
            return foot;
        }
    }
    
    return nil;
}

-(void) drawAttention: (ccTime) dtime {
    AnimalPart *foot = [self getCorrectFoot];
    
    [foot getAttention];
}

-(void) startNarration:(ccTime)dtime {
    [self startNarration:dtime forLang:[[LocalizationManager sharedManager] getAppPreferredLocale]];
}

-(void) startNarration:(ccTime)dtime forLang:(NSString *)lang {
    __block AnimalViewLayer *pointer = self;
    __block NarrationNode *pBubble = narration;
    __block EnvironmentLayer *pBackground = background;
    
    CCCallBlockN *scaleBlock = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [pBubble clear];
        pBubble.scale = 1.0;
    }];
    
    CCCallBlockN *startText = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        NSString *file = [NSString stringWithFormat:@"%@_story.mp3", pBackground.storyKey];
        AudioCues *cues = [[AudioCueRepository sharedRepository] getCues:[[LocalizationManager sharedManager] getLocalizedFilename:file withLocale:lang]];
        
        if (cues != nil) {
            if ([[SoundManager sharedManager] getMusicVolume] >= 0.1) {
                [[SoundManager sharedManager] setMusicVolumeTemporarily:0.2];
            }
            [pBubble startForLanguage:lang cues:cues finishBlock:^(CCNode *node) {
                [pointer stopNarration];
            }];
        }
    }];

    CCSequence *bubseq = [CCSequence actions:scaleBlock, [CCDelayTime actionWithDuration:0.25], startText, nil];
    [narration runAction:bubseq];
    [[[CCDirector sharedDirector] scheduler] unscheduleSelector:@selector(startNarration:) forTarget:self];
    skip.visible = YES;
}

-(void) stopNarration {
    [narration runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.25 scale:0.0],
                        [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [narration stopAllActions];
    }],
    nil]];
    
    [self blurGameLayer:NO withDuration:0.25];
    [narration stop];
    [[SoundManager sharedManager] resetMusicVolume];
    skip.visible = NO;
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
    
    AnimalPart *foot = [self getCorrectFoot];

    if (foot == nil)
        return NO;
    
    AnchorPoint *fpnt = (AnchorPoint *) [foot.fixPoints objectAtIndex:0];
    CGPoint test = [foot convertToWorldSpace:fpnt.point];
    
    if (ccpDistance(test, fpntWS) != 0)
        return NO;

    return YES;
}

-(void) dealloc {
    if (animal != nil)
        [animal release];
    
    [super dealloc];
}

-(void) blurGameLayer: (BOOL) blur withDuration: (GLfloat) duration {
    [gameLayer stopAllActions];
    if (blur) {
        FadeGridAction *blur = [FadeGridAction actionWithDuration:duration sigmaStart:0.0 sigmaEnd:1.0 desaturateStart:0.0 desaturateEnd:0.7];
        [gameLayer runAction:blur];
    } else {
        FadeGridAction *blur = [FadeGridAction actionWithDuration:duration sigmaStart:1.0 sigmaEnd:0.0 desaturateStart:0.7 desaturateEnd:0.0];
        [gameLayer runAction:blur];
    }
}

-(CGPoint) startPositionForFoot: (int) index {
    AnimalPart *foot = [feet objectAtIndex:index];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    if (positionScaleForCurrentDevice(kDimensionY) < 1) {
        winSize.width = (positionScaleForCurrentDevice(kDimensionY) * 2.0) * winSize.width;
    }
    
    float offset = 0.0;
    float ratio = 0.5;
    
    switch(index) {
        case 0:
            offset = foot.anchorPoint.x * (foot.contentSize.width / CC_CONTENT_SCALE_FACTOR());
            ratio = 0.1;
            break;
        case 1:
            break;
        case 2:
            offset = -(1.0 - foot.anchorPoint.x) * (foot.contentSize.width / CC_CONTENT_SCALE_FACTOR());
            ratio = 0.9;
            break;
        default:
            return ccp(winSize.width * 0.5, winSize.height * 0.5);
            break;
    }
    
    CGPoint point = ccp(winSize.width * ratio + offset, winSize.height * 0.2);
    return point;
}

-(void) productRetrievalStarted {
    apEvent(@"story", @"freemium", @"product start");
}

-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data {
    if (purchase != nil)
        [purchase release];
    
    purchase = [PurchaseViewController handleProductsRetrievedWithDelegate:self products:products withProductId:animal.productId upsell:PREMIUM_PRODUCT_ID];
    apEvent(@"story", @"freemium", @"product success");
    [self blurGameLayer:YES withDuration:0.5];
}

-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data {
    [PurchaseViewController handleProductsRetrievedFail];
    apEvent(@"story", @"freemium", @"product error");
    [self quitToMainMenu];
}

-(BOOL) cancelClicked: (BOOL) buying {
    apEvent(@"story", @"freemium", @"cancel click");
    if (!buying) {
        [self quitToMainMenu];
        return YES;
    }
    return NO;
}

-(BOOL) purchaseFinished: (BOOL) success {
    if (success) {
        [[CCDirector sharedDirector] resume];
        apEvent(@"story", @"freemium", @"purchase complete");
        [self startLevel];
        [purchase.view removeFromSuperview];
        [self blurGameLayer:NO withDuration:0.1];
        return YES;
    } else {
        apEvent(@"story", @"freemium", @"purchase fail");
        return NO;
    }
}

-(void) drawPhysics {
    glLineWidth( 1.0f );
    if (physicsMouse != NULL) {
        ccDrawColor4B(255, 100, 0, 180);
        CGPoint c = physicsMouse->body->p;
        ccDrawCircle(c, 8, 0, 8, NO);
    }
    
    ccDrawColor4B(0,255,255,180);
    
    cpSpaceEachShape_b(physicsSpace, ^(cpShape *shape) {
        cpBB bb = shape->bb;
        CGPoint bl = ccp(bb.l,bb.b);
        CGPoint tr = ccp(bb.r,bb.t);
        ccDrawRect(bl,tr);
    });
    
    cpSpaceEachConstraint_b(physicsSpace, ^(cpConstraint *constraint) {
        cpBody *body_a = constraint->a;
        cpBody *body_b = constraint->b;
        
        const cpConstraintClass *klass = constraint->klass_private;
        if(klass == cpPinJointGetClass()){
            cpPinJoint *joint = (cpPinJoint *)constraint;
            
            cpVect a = cpvadd(body_a->p, cpvrotate(joint->anchr1, body_a->rot));
            cpVect b = cpvadd(body_b->p, cpvrotate(joint->anchr2, body_b->rot));
            
            // glPointSize(5.0f);
            ccPointSize(5.0f);
            ccDrawPoint(a);
            ccDrawPoint(b);
            ccDrawLine(a, b);
            
        } else if(klass == cpSlideJointGetClass()){
            cpSlideJoint *joint = (cpSlideJoint *)constraint;
            
            cpVect a = cpvadd(body_a->p, cpvrotate(joint->anchr1, body_a->rot));
            cpVect b = cpvadd(body_b->p, cpvrotate(joint->anchr2, body_b->rot));
            
            // glPointSize(5.0f);
            ccPointSize(5.0f);
            ccDrawPoint(a);
            ccDrawPoint(b);
            ccDrawLine(a, b);
            
        } else if(klass == cpPivotJointGetClass()){
            cpPivotJoint *joint = (cpPivotJoint *)constraint;
            
            cpVect a = cpvadd(body_a->p, cpvrotate(joint->anchr1, body_a->rot));
            cpVect b = cpvadd(body_b->p, cpvrotate(joint->anchr2, body_b->rot));
            
            // glPointSize(10.0f);
            ccPointSize(10.0f);
            ccDrawPoint(a);
            ccDrawPoint(b);
        } else if(klass == cpGrooveJointGetClass()){
            cpGrooveJoint *joint = (cpGrooveJoint *)constraint;
            
            cpVect a = cpvadd(body_a->p, cpvrotate(joint->grv_a, body_a->rot));
            cpVect b = cpvadd(body_a->p, cpvrotate(joint->grv_b, body_a->rot));
            cpVect c = cpvadd(body_b->p, cpvrotate(joint->anchr2, body_b->rot));
            
            // glPointSize(5.0f);
            ccPointSize(5.0f);
            ccDrawPoint(c);
            ccDrawLine(a, b);
        } else if(klass == cpDampedSpringGetClass()){
           // drawSpring((cpDampedSpring *)constraint, body_a, body_b);
        } else {
            //		printf("Cannot draw constraint\n");
        }
    });
}

-(void) drawFootAnchors {
    int count = [feet count];
    for (int i = 0; i < count; i++) {
        CGPoint pnt = [self startPositionForFoot:i];
        ccDrawColor4B(255, 0, 0, 255);
        ccPointSize(8 * CC_CONTENT_SCALE_FACTOR());
        ccDrawPoint(pnt);
    }
}

-(void) quitToMainMenu {
    [[CCDirector sharedDirector] resume];
    [self blurGameLayer:NO withDuration:0.1];
    
    [narration stop];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[MainMenuLayer scene] backwards:true]];

    if (purchase != nil)
        [purchase.view removeFromSuperview];
}

-(void) openFactPage {
    [[CCDirector sharedDirector] resume];
    [self blurGameLayer:NO withDuration:0.1];
    
    [narration stop];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[AnimalFactsLayer sceneWithAnimalKey:animal.key] backwards:true]];
}

@end
