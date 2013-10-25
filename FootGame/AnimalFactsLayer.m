//
//  AnimalFactsLayer.m
//  FootGame
//
//  Created by Owyn Richen on 2/7/13.
//
//

#import "AnimalFactsLayer.h"
#import "AnimalPartRepository.h"
#import "AnimalSelectLayer.h"
#import "AnimalViewLayer.h"
#import "LocalizationManager.h"
#import "InAppPurchaseManager.h"
#import "FadeGrid3D.h"
#import "SoundManager.h"
#import "EnvironmentRepository.h"

@interface AnimalFactsLayer()

-(void) startPurchase: (NSString *) productId;
-(void) blurFadeLayer: (BOOL) blur withDuration: (GLfloat) duration;
-(void) enableTouches: (BOOL) on;
-(NSString *) genderStringForAnimalKey: (NSString *) key formatKey: (NSString *) formatPrefix replacement: (NSString *) replacement;
@end

@implementation AnimalFactsLayer

+(CCScene *) sceneWithAnimalKey: (NSString *) animal {
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	AnimalFactsLayer *layer;
    
    if (animal == nil) {
        layer = [AnimalFactsLayer node];
    } else {
        layer = [[[AnimalFactsLayer alloc] initWithAnimalKey:animal] autorelease];
    }
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

+(ContentManifest *) manifestWithAnimalKey: (NSString *) animal {
    return [AnimalFactsLayer manifestWithAnimal:[[AnimalPartRepository sharedRepository] getAnimalByKey:animal]];
}

+(ContentManifest *) manifestWithAnimal: (Animal *) animal {
    ContentManifest *mfest = [[[ContentManifest alloc] init] autorelease];
    
    [mfest addManifest:animal.manifest];
    // TODO: 
    
    return mfest;
}

-(id) initWithAnimalKey: (NSString *) anml {
    Animal *a = [[AnimalPartRepository sharedRepository] getAnimalByKey:anml];
    self = [self initWithAnimal:a];
    
    return self;
}

-(id) initWithAnimal: (Animal *) anml {
    self = [super init];
    
    animal = [anml retain];
    __block AnimalFactsLayer *pointer = self;
    __block Animal *pAnimal = animal;
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    fadeLayer = [CCLayer node];
    [self addChild:fadeLayer];
    
    popup = [FactDetailPopup popup];
    popup.position = ccpToRatio(512, 300);

    background = [CCAutoScalingSprite spriteWithFile:@"tropical.png"];
    background.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
    [fadeLayer addChild:background];
    
    back = [CCAutoScalingSprite spriteWithFile:@"rightarrow.png"];
    back.scaleX = -0.4 * fontScaleForCurrentDevice();
    back.scaleY = 0.4 * fontScaleForCurrentDevice();
    back.anchorPoint = ccp(0,0);
    back.position = ccpToRatio(130, winSize.height - 100);
    [back addEvent:@"touch" withBlock:^(CCNode * sender) {
        [[SoundManager sharedManager] playSound:@"glock__g1.mp3"];
        [sender runAction:[CCScaleTo actionWithDuration:0.1 scaleX:-0.6 scaleY:0.6]];
    }];
    
    [back addEvent:@"touchupoutside" withBlock:^(CCNode *sender) {
        [sender runAction:[CCScaleTo actionWithDuration:0.1 scaleX:-0.4 scaleY:0.4]];
    }];
    
    [back addEvent:@"touchup" withBlock:^(CCNode *sender) {
        [pointer doWhenLoadComplete:locstr(@"loading", @"strings", @"") blk: ^{
            [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[AnimalSelectLayer scene] backwards:true]];
        }];
    }];
    [fadeLayer addChild:back];
    
    NSString *circleName = [NSString stringWithFormat:@"circle-%@-happy.png", [animal.key lowercaseString]];
    circle = [CCAutoScalingSprite spriteWithFile:circleName];
    circle.anchorPoint = ccp(0,0);
    circle.position = ccpToRatio(500, winSize.height + title.contentSize.height);
    [fadeLayer addChild:circle];
    
    title = [CCNode node];
    
    NSString *nameKey = [NSString stringWithFormat:@"%@_name", [animal.key lowercaseString]];
    NSString *kindKey = [NSString stringWithFormat:@"menu_%@", [animal.key lowercaseString]];
    NSString *animalName = [self genderStringForAnimalKey:animal.key formatKey:@"name_the_kind" replacement:locstr(nameKey, @"strings", @"")];
    NSString *animalKind = [self genderStringForAnimalKey:animal.key formatKey:@"kind" replacement:locstr(kindKey, @"strings", @"")];
    
    CCLabelTTFWithExtrude *name = [CCLabelTTFWithExtrude labelWithString:animalName fontName:@"Rather Loud" fontSize:70 * fontScaleForCurrentDevice()];
    [name setColor: ccc3(206, 216, 47)];
    [name setExtrudeColor: ccc3(130, 141, 55)];
    name.extrudeDepth = 10 * fontScaleForCurrentDevice();
    [name drawExtrude];
    name.position = ccpToRatio(0,name.contentSize.height * 1.1);
    [title addChild:name];
    
    CCLabelTTFWithExtrude *kind = [CCLabelTTFWithExtrude labelWithString:animalKind fontName:@"Rather Loud" fontSize:180 * fontScaleForCurrentDevice()];
    [kind setColor: ccc3(206, 216, 47)];
    [kind setExtrudeColor: ccc3(130, 141, 55)];
    kind.extrudeDepth = 10 * fontScaleForCurrentDevice();
    [kind drawExtrude];
    kind.position = ccpToRatio(0, 0);
    [title addChild:kind];
    
    title.rotation = -8.0;
    title.position = ccpToRatio(550,winSize.height + title.contentSize.height);
    [fadeLayer addChild:title];

    heightFrame = [FactFrame factFrameWithAnimal:animal frameType:kHeightFactFrame];
    // heightFrame.anchorPoint = ccp(0,0);
    heightFrame.position = ccpToRatio(50 + (heightFrame.contentSize.width / 2), 38 + (heightFrame.contentSize.height / 2));
    heightFrame.userData = popup;
    heightFrame.scale = 0.01;
    [fadeLayer addChild:heightFrame];
    
    [heightFrame addEvent:@"touch" withBlock:^(CCNode * sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:1.2]];
    }];
    
    [heightFrame addEvent:@"touchupoutside" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
    }];
    
    [heightFrame addEvent:@"touchup" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
        
        FactDetailPopup *p = (FactDetailPopup *) sender.parent.userData;
        [p showFact:kHeightFactFrame forAnimal:pAnimal withOpenBlock:^(CCNode<CCRGBAProtocol> *popup) {
            [pointer enableTouches:NO];
            [pointer blurFadeLayer:YES withDuration:0.5];
        } closeBlock:^(CCNode<CCRGBAProtocol> *popup) {
            [pointer enableTouches:YES];
            [pointer blurFadeLayer:NO withDuration:0.1];
        }];
    }];
    
    weightFrame = [FactFrame factFrameWithAnimal:animal frameType:kWeightFactFrame];
    // weightFrame.anchorPoint = ccp(0,0);
    weightFrame.position = ccpToRatio(365 + (weightFrame.contentSize.width / 2), 253 + (weightFrame.contentSize.height / 2));
    weightFrame.userData = popup;
    weightFrame.scale = 0.01;
    [fadeLayer addChild:weightFrame];
    
    [weightFrame addEvent:@"touch" withBlock:^(CCNode * sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:1.2]];
    }];
    
    [weightFrame addEvent:@"touchupoutside" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
    }];
    
    [weightFrame addEvent:@"touchup" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
        
        FactDetailPopup *p = (FactDetailPopup *) sender.parent.userData;
        [p showFact:kWeightFactFrame forAnimal:pAnimal withOpenBlock:^(CCNode<CCRGBAProtocol> *popup) {
            [pointer enableTouches:NO];
            [pointer blurFadeLayer:YES withDuration:0.5];
        } closeBlock:^(CCNode<CCRGBAProtocol> *popup) {
            [pointer enableTouches:YES];
            [pointer blurFadeLayer:NO withDuration:0.1];
        }];
    }];
    
    locFrame = [FactFrame factFrameWithAnimal:animal frameType:kEarthFactFrame];
    // locFrame.anchorPoint = ccp(0,0);
    locFrame.position = ccpToRatio(780 + (locFrame.contentSize.width / 2), 320 + (locFrame.contentSize.height / 2));
    locFrame.userData = popup;
    locFrame.scale = 0.01;
    [fadeLayer addChild:locFrame];
    
    [locFrame addEvent:@"touch" withBlock:^(CCNode * sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:1.2]];
    }];
    
    [locFrame addEvent:@"touchupoutside" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
    }];
    
    [locFrame addEvent:@"touchup" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
        
        FactDetailPopup *p = (FactDetailPopup *) sender.parent.userData;
        [p showFact:kEarthFactFrame forAnimal:pAnimal withOpenBlock:^(CCNode<CCRGBAProtocol> *popup) {
            [pointer enableTouches:NO];
            [pointer blurFadeLayer:YES withDuration:0.5];
        } closeBlock:^(CCNode<CCRGBAProtocol> *popup) {
            [pointer enableTouches:YES];
            [pointer blurFadeLayer:NO withDuration:0.1];
        }];
    }];
    
    foodFrame = [FactFrame factFrameWithAnimal:animal frameType:kFoodFactFrame];
    // foodFrame.anchorPoint = ccp(0,0);
    foodFrame.position = ccpToRatio(375 + (foodFrame.contentSize.width / 2), 38 + (foodFrame.contentSize.height / 2));
    foodFrame.userData = popup;
    foodFrame.scale = 0.01;
    [fadeLayer addChild:foodFrame];
    
    [foodFrame addEvent:@"touch" withBlock:^(CCNode * sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:1.2]];
    }];
    
    [foodFrame addEvent:@"touchupoutside" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
    }];
    
    [foodFrame addEvent:@"touchup" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
        
        FactDetailPopup *p = (FactDetailPopup *) sender.parent.userData;
        [p showFact:kFoodFactFrame forAnimal:pAnimal withOpenBlock:^(CCNode<CCRGBAProtocol> *popup) {
            [pointer enableTouches:NO];
            [pointer blurFadeLayer:YES withDuration:0.5];
        } closeBlock:^(CCNode<CCRGBAProtocol> *popup) {
            [pointer enableTouches:YES];
            [pointer blurFadeLayer:NO withDuration:0.1];
        }];
    }];
    
    speedFrame = [FactFrame factFrameWithAnimal:animal frameType:kSpeedFactFrame];
    // speedFrame.anchorPoint = ccp(0,0);
    speedFrame.position = ccpToRatio(578 + (speedFrame.contentSize.width / 2), 38 + (speedFrame.contentSize.height / 2));
    speedFrame.userData = popup;
    speedFrame.scale = 0.01;
    [fadeLayer addChild:speedFrame];
    
    [speedFrame addEvent:@"touch" withBlock:^(CCNode * sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:1.2]];
    }];
    
    [speedFrame addEvent:@"touchupoutside" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
    }];
    
    [speedFrame addEvent:@"touchup" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
        
        FactDetailPopup *p = (FactDetailPopup *) sender.parent.userData;
        [p showFact:kSpeedFactFrame forAnimal:pAnimal withOpenBlock:^(CCNode<CCRGBAProtocol> *popup) {
            [pointer enableTouches:NO];
            [pointer blurFadeLayer:YES withDuration:0.5];
        } closeBlock:^(CCNode<CCRGBAProtocol> *popup) {
            [pointer enableTouches:YES];
            [pointer blurFadeLayer:NO withDuration:0.1];
        }];
    }];
    
    photoFrame = [FactFrame factFrameWithAnimal:animal frameType:kFaceFactFrame];
    // photoFrame.anchorPoint = ccp(0,0);
    photoFrame.position = ccpToRatio(780 + (photoFrame.contentSize.width / 2), 38 + (photoFrame.contentSize.height / 2));
    photoFrame.userData = popup;
    photoFrame.scale = 0.01;
    [fadeLayer addChild:photoFrame];
    
    [photoFrame addEvent:@"touch" withBlock:^(CCNode * sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:1.2]];
    }];
    
    [photoFrame addEvent:@"touchupoutside" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
    }];
    
    [photoFrame addEvent:@"touchup" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
        
        FactDetailPopup *p = (FactDetailPopup *) sender.parent.userData;
        [p showFact:kFaceFactFrame forAnimal:pAnimal withOpenBlock:^(CCNode<CCRGBAProtocol> *popup) {
            [pointer enableTouches:NO];
            [pointer blurFadeLayer:YES withDuration:0.5];
        } closeBlock:^(CCNode<CCRGBAProtocol> *popup) {
            [pointer enableTouches:YES];
            [pointer blurFadeLayer:NO withDuration:0.1];
        }];
    }];
    
    playbuy = [CCAutoScalingSprite spriteWithFile:@"buy-button.png"];
    // playbuy.anchorPoint = ccp(0,0);
    playbuy.position = ccpToRatio(50 + (playbuy.contentSize.width / 2), 360 + (playbuy.contentSize.height / 2));
    playbuy.userData = animal.key;
    playbuy.opacity = 0;
    NSString *playbuytxt = [NSString stringWithFormat:locstr(@"play_button",@"strings",@""), [animal localizedName]];
    CCLabelTTF *playbuylabel = [CCLabelTTF labelWithString:playbuytxt fontName:@"Rather Loud" fontSize:44 * fontScaleForCurrentDevice() dimensions:CGSizeMake(playbuy.contentSize.width * 0.9, playbuy.contentSize.height * 0.9) hAlignment:kCCTextAlignmentCenter vAlignment:kCCVerticalTextAlignmentCenter];
    playbuylabel.color = ccWHITE;
    playbuylabel.position = ccp(playbuylabel.contentSize.width / 2, playbuylabel.contentSize.height / 2);
    playbuylabel.opacity = 0;
    [playbuy addChild:playbuylabel];
    
    [playbuy addEvent:@"touch" withBlock:^(CCNode * sender) {
        [sender runAction:[CCScaleTo actionWithDuration:0.1 scale:1.2]];
    }];
    
    [playbuy addEvent:@"touchupoutside" withBlock:^(CCNode *sender) {
        [sender runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
    }];
    
    [playbuy addEvent:@"touchup" withBlock:^(CCNode *sender) {
        [sender runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
        Animal *anml = [[AnimalPartRepository sharedRepository] getAnimalByKey:(NSString *) sender.userData];
        
        if ([[PremiumContentStore instance] ownsProductId:anml.productId]) {
            [pointer doWhenLoadComplete:locstr(@"loading", @"strings", @"") blk: ^{
               [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[AnimalViewLayer sceneWithAnimalKey: anml.key] backwards:false]];
            }];
        } else {
            NSLog(@"%@", anml.productId);
            [pointer startPurchase:anml.productId];
        }
    }];
    
    [fadeLayer addChild:playbuy];
    
    [self addChild:popup];
    
#ifdef TESTING
    CircleButton *bugs = [CircleButton buttonWithFile:@"bugs.png"];
    bugs.scale = 0.5;
    bugs.anchorPoint = ccp(0,0);
    bugs.position = ccpToRatio(1024 - 100, 768 - 100);
    
    [bugs addEvent:@"touch" withBlock:^(CCNode *sender) {
        [[SoundManager sharedManager] playSound:@"glock__g1.mp3"];
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:0.7]];
    }];
    [bugs addEvent:@"touchupoutside" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:0.5]];
    }];
    [bugs addEvent:@"touchup" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:0.5]];
        if (prompt == nil)
            prompt = [[FeedbackPrompt alloc] init];
        [prompt showFeedbackDialog];
    }];
    [self addChild: bugs];
#endif
    
    manifestToLoad = [[AnimalViewLayer manifestWithAnimalKey:anml.key] retain];
    
    return self;
}

-(NSString *) genderStringForAnimalKey: (NSString *) key formatKey: (NSString *) formatPrefix replacement: (NSString *) replacement {
    NSString *genderKey = [NSString stringWithFormat: @"%@_word_gender", [key lowercaseString]];
    NSString *gender = locstr(genderKey, @"strings", @"");
    
    NSString *formatKey = formatPrefix;
    
    if (![gender isEqualToString:@""]) {
        formatKey = [NSString stringWithFormat:@"%@_%@", formatPrefix, gender];
    }
    
    return [NSString stringWithFormat: locstr(formatKey, @"strings", @""), replacement];
}

-(void) startPurchase:(NSString *)productId {
    NSLog(@"Animal %@ isn't owned", productId);
    [[InAppPurchaseManager instance] getProducts:self withData:productId];
}

-(void) dealloc {
#ifdef TESTING
    if (prompt != nil)
        [prompt release];
#endif
    if (animal != nil)
        [animal release];
    
    [super dealloc];
}


-(void) onEnter {
    [super onEnter];
    NSString *alog = [NSString stringWithFormat: @"Fact View %@", animal.key];
    apView(alog);
}

-(void) onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    
    Environment *environment = [[EnvironmentRepository sharedRepository] getEnvironment:animal.environment];
    [[SoundManager sharedManager] playBackground:environment.bgMusic];
    
    CCScaleBy *titleScale = [CCScaleBy actionWithDuration:0.5 scale:1.025];
    CCRepeatForever *bfscale = [CCRepeatForever actionWithAction:[CCSequence actions:titleScale, [titleScale reverse], nil]];
    
    // TODO: make this bounce?
    [title runAction:bfscale];
    [title runAction:[CCMoveTo actionWithDuration:0.50 position:ccpToRatio(550, 620)]];
    [circle runAction:[CCMoveTo actionWithDuration:0.50 position:ccpToRatio(500, 580)]];
    
    [playbuy runAction:[CCFadeIn actionWithDuration:0.2]];
    [((CCNode *)[playbuy.children objectAtIndex:0]) runAction:[CCFadeIn actionWithDuration:0.2]];
    
#define DELAY_TIME 0.15
#define SCALE_TIME 0.2
    
    FactFrame *frames[6] = {
        heightFrame,
        weightFrame,
        locFrame,
        photoFrame,
        foodFrame,
        speedFrame
    };
    
    for (int i = 0; i < 6; i++) {
        int n = (arc4random() % (6 - i)) + i;
        FactFrame *tmp = frames[n];
        frames[n] = frames[i];
        frames[i] = tmp;
        float delayTime = DELAY_TIME * (i + 1);
        [frames[i] runAction:[CCSequence actions:[CCDelayTime actionWithDuration:delayTime], [CCScaleTo actionWithDuration:SCALE_TIME scale:1.0], nil]];
    }
}

-(void) productRetrievalStarted {
    apEvent(@"facts", @"freemium", @"product start");
    [self enableTouches:NO];
}

-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data {
    if (purchase != nil)
        [purchase release];
    
    purchase = [PurchaseViewController handleProductsRetrievedWithDelegate:self products:products withProductId:animal.productId upsell:PREMIUM_PRODUCT_ID];
    apEvent(@"facts", @"freemium", @"product success");
    [self blurFadeLayer:YES withDuration:0.5];
}

-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data {
    [PurchaseViewController handleProductsRetrievedFail];
    apEvent(@"facts", @"freemium", @"product error");
    [self blurFadeLayer:NO withDuration:0.1];
    [self enableTouches:YES];
}

-(BOOL) cancelClicked: (BOOL) buying {
    [[CCDirector sharedDirector] resume];
    apEvent(@"facts", @"freemium", @"cancel click");
    [self blurFadeLayer:NO withDuration:0.1];
    [self enableTouches:YES];
    
    if (!buying) {
        [purchase.view removeFromSuperview];
        return YES;
    } else {
        return NO;
    }
}

-(BOOL) purchaseFinished: (BOOL) success {
    if (success) {
        [[CCDirector sharedDirector] resume];
        [self blurFadeLayer:NO withDuration:0.1];
        apEvent(@"facts", @"freemium", @"purchase complete");
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[AnimalViewLayer sceneWithAnimalKey:animal.key] backwards:false]];
        [purchase.view removeFromSuperview];
        return YES;
    } else {
        apEvent(@"facts", @"freemium", @"purchase fail");
        return NO;
    }
    [self enableTouches:YES];
}



-(void) blurFadeLayer: (BOOL) blur withDuration: (GLfloat) duration {
    if (blur) {
        FadeGridAction *blur = [FadeGridAction actionWithDuration:duration sigmaStart:0.0 sigmaEnd:1.0 desaturateStart:0.0 desaturateEnd:0.7];
        [fadeLayer runAction:blur];
    } else {
        FadeGridAction *blur = [FadeGridAction actionWithDuration:duration sigmaStart:1.0 sigmaEnd:0.0 desaturateStart:0.7 desaturateEnd:0.0];
        [fadeLayer runAction:blur];
    }
}

-(void) enableTouches: (BOOL) on {
    [heightFrame enableTouches:on];
    [weightFrame enableTouches:on];
    [locFrame enableTouches:on];
    [foodFrame enableTouches:on];
    [speedFrame enableTouches:on];
    [photoFrame enableTouches:on];
    [back enableTouches:on];
    [playbuy enableTouches:on];
}

@end
