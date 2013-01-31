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
#import "MBProgressHUD.h"

#define SNAP_DISTANCE 50
#define CORRECT_SNAP_DISTANCE 100
#define ROTATE_DISTANCE 300

@interface AnimalViewLayer ()
-(AnimalPart *) getCorrectFoot;
-(void) drawAttention: (ccTime) dtime;
-(void) moveKids: (ccTime) dtime;
-(CGPoint) startPositionForFoot: (int) index;
-(void) startLevel;
@end

@implementation AnimalViewLayer

+(CCScene *) scene
{
	return [AnimalViewLayer sceneWithAnimalKey:nil];
}

+(CCScene *) sceneWithAnimalKey: (NSString *) animal {
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	AnimalViewLayer *layer;
    
    if (animal == nil) {
        layer = [AnimalViewLayer node];
    } else {
        layer = [[[AnimalViewLayer alloc] initWithAnimalKey:animal] autorelease];
    }
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id) initWithAnimalKey: (NSString *) anml {
    self = [self initWithAnimal:[[AnimalPartRepository sharedRepository] getAnimalByKey:anml]];
    
    return self;
}

-(id) initWithAnimal: (Animal *) anml {
    self = [super init];
    
    animal = [anml retain];
    
    return self;
}

-(id) init {
    self = [self initWithAnimal:animal = [[AnimalPartRepository sharedRepository] getRandomAnimal]];
    
    return self;
}

-(void) onEnter {
    victory = NO;
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    gameLayer = [CCLayer node];
    [self addChild:gameLayer];
    
    hudLayer = [CCLayer node];
    [self addChild:hudLayer];
    
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:NO];
    
    environment = [[EnvironmentRepository sharedRepository] getEnvironment:animal.environment];
    background = [environment getLayer];
    
    [gameLayer addChild:background];
    
    name = [CCAutoScalingSprite spriteWithFile:animal.word];
    // name.anchorPoint = ccp(0,0);
    name.position = ccp(0-name.contentSize.width, winSize.height * 0.5);
    name.opacity = 200;
    name.scale *= 0.4;
    name.color = ccWHITE;
    
    [self addChild:name];
    
    feet = [[[AnimalPartRepository sharedRepository] getRandomFeet:3 includingAnimalFeet:animal] retain];
    
    for(int i = 0; i < [feet count]; i++) {
        AnimalPart *foot = [feet objectAtIndex:i];
        foot.position = [self startPositionForFoot:i];
        [gameLayer addChild:foot];
    }

    body = [animal.body copyWithZone:nil];
    body.position = background.animalPosition;
    
    [gameLayer addChild:body];
    
    next = [CCSprite spriteWithFile:@"arrow.png"];
    next.scale = 0.4 * fontScaleForCurrentDevice();
    next.position = ccpToRatio(920, 90);
    next.visible = false;
    
    [gameLayer addChild:next];
    
    [[[CCDirector sharedDirector] scheduler] scheduleSelector:@selector(drawAttention:) forTarget:self interval:10 paused:NO repeat:10 delay:5];
    
    
    streak = [CCMotionStreak streakWithFade:1 minSeg:10 width:50 color:ccWHITE textureFilename:@"rainbow.png"];
    streak.fastMode = NO;
    [gameLayer addChild:streak];
    
    [self blurGameLayer:YES withDuration:2.0];
    
    kid = [CCAutoScalingSprite spriteWithFile:@"girl1.png"];
    kid.anchorPoint = ccp(0,0);
    kid.position = ccpToRatio(background.kidPosition.x, 0.0 - kid.contentSize.height);
    [hudLayer addChild:kid];
    
    head1 = [CCAutoScalingSprite spriteWithFile:@"girl1_head.png"];
    head1.position = ccpToRatio(800, 690);
    [hudLayer addChild:head1];
    
    head2 = [CCAutoScalingSprite spriteWithFile:@"girl2_head.png"];
    head2.position = ccpToRatio(930, 690);
    [hudLayer addChild:head2];
    
//
//    // TODO: this is all fucking wrong
//    
    CGPoint bubbleTop = ccpToRatio(50, 580);
    CGRect bubbleRect = CGRectMake(0, 0, 900 * positionScaleForCurrentDevice(kDimensionY), 140 * positionScaleForCurrentDevice(kDimensionY));
    CGPoint bubblePoint = ccpToRatio(background.kidPosition.x, background.kidPosition.y + (kid.contentSize.height * autoScaleForCurrentDevice()));
    
    bubble = [[[SpeechBubble alloc] initWithStoryKey:background.storyKey typingInterval:0.08 rect: bubbleRect point:bubblePoint] autorelease];
    bubble.anchorPoint = ccp(0,0);
    bubble.position = bubbleTop;
    bubble.scale = 0.0;
    [self addChild:bubble];
    
    [[[CCDirector sharedDirector] scheduler] scheduleSelector:@selector(moveKids:) forTarget:self interval:0.5 paused:NO];
    
    [super onEnter];
    [[SoundManager sharedManager] fadeOutBackground];
    [[SoundManager sharedManager] playBackground:environment.bgMusic];
    
    NSString *alog = [NSString stringWithFormat: @"Game View %@", animal.key];
    apView(alog);
}

-(void) startLevel {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    [name runAction:[CCSequence actions:
                     [CCMoveTo actionWithDuration:0.3 position:ccp(winSize.width * 0.5, winSize.height * 0.5)],
                     [CCDelayTime actionWithDuration:2.0],
                     [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [name runAction:[CCFadeOut actionWithDuration:0.25]];
    }],
    nil]];
}

-(void) onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    
    if ([[PremiumContentStore instance] ownsProductId:animal.productId]) {
        [self startLevel];
    } else {
        [[CCDirector sharedDirector] pause];
        [[InAppPurchaseManager instance] getProducts:self withData:nil];
        apEvent(@"story", @"freemium", @"complete");
    }
}

-(void) onExit {
    [self removeChild:animal.body cleanup:YES];
    for(int i = 0; i < [feet count]; i++) {
        AnimalPart *foot = [feet objectAtIndex:i];
        [self removeChild:foot cleanup:YES];
    }
    [self removeChild:name cleanup:YES];
    [self removeChild:background cleanup:YES];
    [feet release];
    
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    
    [super onExit];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint pnt = [[CCDirector sharedDirector] convertToGL: [touch locationInView:[touch view]]];
    nextTouched = NO;
    bodyTouched = NO;
    
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
    
    if (head1.visible && CGRectContainsPoint([head1 boundingBox], pnt)) {
        head1Touched = YES;
    }
    
    if (head2.visible && CGRectContainsPoint([head2 boundingBox], pnt)) {
        head2Touched = YES;
    }
    
    if ([body hitTest:pnt]) {
        [streak setPosition:pnt];
        bodyTouched = YES;
        return YES;
    }
        
    return YES;
}
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint pnt = [[CCDirector sharedDirector] convertToGL: [touch locationInView:[touch view]]];
    
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
            name.color = ccBLUE;

            [body setState:kAnimalStateHappy];
            [[SoundManager sharedManager] fadeOutBackground];
            [[SoundManager sharedManager] playBackground:@"level_complete.mp3"];
            victory = YES;
            
            [[SoundManager sharedManager] playSound:animal.successSound];
            next.visible = true;
            next.position = ccpToRatio(920, 90);
            [next runAction:[CCRepeatForever actionWithAction:[CCJumpBy actionWithDuration:2 position:ccpToRatio(0,0) height:30 jumps:2]]];
            
            AnimalPart *correctFoot = [self getCorrectFoot];
            for (int i = 0; i < [feet count]; i++) {
                AnimalPart *foot = (AnimalPart *) [feet objectAtIndex:i];
                if (![foot.imageName isEqualToString:correctFoot.imageName]) {
                    foot.visible = NO;
                }
            }
        } else {
            name.color = ccWHITE;
            
            [body setState:kAnimalStateNormal];
            if (victory) {
                [[SoundManager sharedManager] fadeOutBackground];
                [[SoundManager sharedManager] playBackground:environment.bgMusic];
            }
            
            victory = NO;
            
            [next stopAllActions];
            next.visible = false;
            
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
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[AnimalViewLayer scene] backwards:false]];
    } else if (head1Touched) {
        head1Touched = NO;
        [self blurGameLayer:YES withDuration:0.25];
        [self moveKids:0];
    } else if (head2Touched) {
        head2Touched = NO;
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[MainMenuLayer scene] backwards:true]];
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

//-(void) draw {
//    [super draw];
//    
//    int count = [feet count];
//    for (int i = 0; i < count; i++) {
//        CGPoint pnt = [self startPositionForFoot:i];
//        ccDrawColor4B(255, 0, 0, 255);
//        ccPointSize(8 * CC_CONTENT_SCALE_FACTOR());
//        // NSLog(@"%f,%f -> %f, %f", pnt.point.x, pnt.point.y, glpnt.x, glpnt.y);
//        ccDrawPoint(pnt);
//    }
//}

-(void) drawAttention: (ccTime) dtime {
    AnimalPart *foot = [self getCorrectFoot];
    
    [foot getAttention];
}

-(void) moveKids:(ccTime)dtime {
    CGPoint point = ccpToRatio(background.kidPosition.x, background.kidPosition.y);
    
    CCMoveTo *move = [CCMoveTo actionWithDuration:0.5 position:point];
    CCCallBlockN *scaleBlock = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [bubble runAction:[CCScaleTo actionWithDuration:0.2 scale:1.0]];
    }];
    
    void (^touchBlock)(CCNode *node, BOOL finished) = ^(CCNode *node, BOOL finished) {

        [bubble runAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.25 scale:0.0],
                           [CCCallBlockN actionWithBlock:^(CCNode *node) {
                                [bubble stopAllActions];
                            }],
                            nil]];
        [kid runAction:[CCSequence actions:[CCMoveTo actionWithDuration:0.25 position:ccpToRatio(kid.position.x, -1000)], nil]];
        [self blurGameLayer:NO withDuration:0.25];
    };
    
    CCCallBlockN *startText = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        NSString *file = [NSString stringWithFormat:@"%@_story.mp3", background.storyKey];
        AudioCues *cues = [[AudioCueRepository sharedRepository] getCues:[[LocalizationManager sharedManager] getLocalizedFilename:file]];
        
        void (^callback)(CCNode *node) =  ^(CCNode *node) {
            [bubble runAction:[CCSequence actions:[CCDelayTime actionWithDuration:5.0], [CCCallBlockN actionWithBlock:^(CCNode *node) {
                [bubble ccTouchEnded:nil withEvent:nil];
            }], nil]];
        };
        
        if (cues != nil) {
            [bubble startWithCues:cues finishBlock:callback touchBlock:touchBlock];
        } else {
            [bubble startWithFinishBlock:callback touchBlock:touchBlock];
        }
    }];

    CCSequence *seq = [CCSequence actions:move, scaleBlock, startText, nil];
    [kid runAction:seq];
    [[[CCDirector sharedDirector] scheduler] unscheduleSelector:@selector(moveKids:) forTarget:self];
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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[CCDirector sharedDirector].view animated:YES];
    hud.labelText = locstr(@"get_products", @"strings", @"");
    apEvent(@"story", @"freemium", @"product start");
}

-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data {
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    
    if (purchase != nil)
        [purchase release];
    
    purchase = [PurchaseViewController handleProductsRetrievedWithDelegate:self products:products withProductId:animal.productId upsell:PREMIUM_PRODUCT_ID];
    apEvent(@"story", @"freemium", @"product success");
}

-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data {
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    
    [PurchaseViewController handleProductsRetrievedFail];
    apEvent(@"story", @"freemium", @"product error");
}

-(BOOL) cancelClicked: (BOOL) buying {
    [[CCDirector sharedDirector] resume];
    apEvent(@"story", @"freemium", @"cancel click");
    [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[MainMenuLayer scene] backwards:true]];
    [purchase.view removeFromSuperview];
    return NO;
}

-(void) purchaseFinished: (BOOL) success {
    if (success) {
        [[CCDirector sharedDirector] resume];
        apEvent(@"story", @"freemium", @"purchase complete");
        [self startLevel];
        [purchase.view removeFromSuperview];
    } else {
        apEvent(@"story", @"freemium", @"purchase fail");
    }
}

@end
