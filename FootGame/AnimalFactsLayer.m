//
//  AnimalFactsLayer.m
//  FootGame
//
//  Created by Owyn Richen on 2/7/13.
//
//

#import "AnimalFactsLayer.h"
#import "AnimalPartRepository.h"
#import "MBProgressHUD.h"
#import "AnimalSelectLayer.h"
#import "AnimalViewLayer.h"
#import "LocalizationManager.h"
#import "InAppPurchaseManager.h"

@interface AnimalFactsLayer()

-(void) startPurchase: (NSString *) productId;

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

-(id) initWithAnimalKey: (NSString *) anml {
    Animal *a = [[AnimalPartRepository sharedRepository] getAnimalByKey:anml];
    self = [self initWithAnimal:a];
    
    return self;
}

-(id) initWithAnimal: (Animal *) anml {
    self = [super init];
    
    animal = [anml retain];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];

    background = [CCAutoScalingSprite spriteWithFile:@"tropical.png"];
    background.position = ccp(winSize.width * 0.5, winSize.height * 0.5);
    [self addChild:background];
    
    back = [CCAutoScalingSprite spriteWithFile:@"arrow.png"];
    back.scaleX = -0.4 * fontScaleForCurrentDevice();
    back.scaleY = 0.4 * fontScaleForCurrentDevice();
    back.anchorPoint = ccp(0,0);
    back.position = ccpToRatio(130, winSize.height - 100);
    [back addEvent:@"touchup" withBlock:^(CCNode *sender) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[CCDirector sharedDirector].view animated:YES];
        hud.labelText = locstr(@"loading", @"strings", @"");
        
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[AnimalSelectLayer scene] backwards:true]];
    }];
    [self addChild:back];
    
    NSString *circleName = [NSString stringWithFormat:@"circle-%@-happy.png", [animal.key lowercaseString]];
    circle = [CCAutoScalingSprite spriteWithFile:circleName];
    circle.anchorPoint = ccp(0,0);
    circle.position = ccpToRatio(500, winSize.height + title.contentSize.height);
    [self addChild:circle];
    
    NSString *titleName = [NSString stringWithFormat:@"%@-name.en.png", [animal.key lowercaseString]];
    title = [CCAutoScalingSprite spriteWithFile:titleName];
    title.position = ccpToRatio(550,winSize.height + title.contentSize.height);
    [self addChild:title];

    heightFrame = [FactFrame factFrameWithAnimal:animal frameType:kHeightFactFrame];
    heightFrame.anchorPoint = ccp(0,0);
    heightFrame.position = ccpToRatio(50, 38);
    [self addChild:heightFrame];
    
    weightFrame = [FactFrame factFrameWithAnimal:animal frameType:kWeightFactFrame];
    weightFrame.anchorPoint = ccp(0,0);
    weightFrame.position = ccpToRatio(365, 253);
    [self addChild:weightFrame];
    
    locFrame = [FactFrame factFrameWithAnimal:animal frameType:kEarthFactFrame];
    locFrame.anchorPoint = ccp(0,0);
    locFrame.position = ccpToRatio(780, 320);
    [self addChild:locFrame];
    
    foodFrame = [FactFrame factFrameWithAnimal:animal frameType:kFoodFactFrame];
    foodFrame.anchorPoint = ccp(0,0);
    foodFrame.position = ccpToRatio(375, 38);
    [self addChild:foodFrame];
    
    speedFrame = [FactFrame factFrameWithAnimal:animal frameType:kSpeedFactFrame];
    speedFrame.anchorPoint = ccp(0,0);
    speedFrame.position = ccpToRatio(578, 38);
    [self addChild:speedFrame];
    
    photoFrame = [FactFrame factFrameWithAnimal:animal frameType:kFaceFactFrame];
    photoFrame.anchorPoint = ccp(0,0);
    photoFrame.position = ccpToRatio(780, 38);
    [self addChild:photoFrame];
    
    playbuy = [CCAutoScalingSprite spriteWithFile:@"buy-button.png"];
    playbuy.anchorPoint = ccp(0,0);
    playbuy.position = ccpToRatio(50, 360);
    playbuy.userData = animal.key;
    
    [playbuy addEvent:@"touchup" withBlock:^(CCNode *sender) {
        NSLog(@"touchup");
        Animal *anml = [[AnimalPartRepository sharedRepository] getAnimalByKey:(NSString *) sender.userData];
        
        if ([[PremiumContentStore instance] ownsProductId:anml.productId]) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[CCDirector sharedDirector].view animated:YES];
            hud.labelText = locstr(@"loading", @"strings", @"");
            
            [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[AnimalViewLayer sceneWithAnimalKey: anml.key] backwards:false]];
        } else {
            AnimalFactsLayer *me = (AnimalFactsLayer *) sender.parent;
            NSLog(@"%@", anml.productId);
            [me startPurchase:anml.productId];
        }
    }];
    
    [self addChild:playbuy];
    
    return self;
}

-(void) startPurchase:(NSString *)productId {
    NSLog(@"Animal %@ isn't owned", productId);
    [[InAppPurchaseManager instance] getProducts:self withData:productId];
}

-(void) dealloc {
    if (animal != nil)
        [animal release];
    
    [super dealloc];
}


-(void) onEnter {
    [super onEnter];
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
//    photoFrame.anchorPoint = ccp(1.0,1.0);
//    CCRotateTo *rot = [CCRotateTo actionWithDuration:2.0 angle:20];
//    CCRotateTo *rrot = [CCRotateTo actionWithDuration:2.0 angle:-20];
//    [photoFrame runAction:[CCRepeatForever actionWithAction:[CCSequence actions:rot, rrot, nil]]];
}

-(void) onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    CCScaleBy *titleScale = [CCScaleBy actionWithDuration:0.5 scale:1.025];
    CCRepeatForever *bfscale = [CCRepeatForever actionWithAction:[CCSequence actions:titleScale, [titleScale reverse], nil]];
    
    // TODO: make this bounce?
    [title runAction:bfscale];
    [title runAction:[CCMoveTo actionWithDuration:0.50 position:ccpToRatio(550, 620)]];
    [circle runAction:[CCMoveTo actionWithDuration:0.50 position:ccpToRatio(500, 620)]];
}

-(void) productRetrievalStarted {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[CCDirector sharedDirector].view animated:YES];
    hud.labelText = locstr(@"get_products", @"strings", @"");
    apEvent(@"facts", @"freemium", @"product start");
}

-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data {
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    
    if (purchase != nil)
        [purchase release];
    
    purchase = [PurchaseViewController handleProductsRetrievedWithDelegate:self products:products withProductId:animal.productId upsell:PREMIUM_PRODUCT_ID];
    apEvent(@"facts", @"freemium", @"product success");
}

-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data {
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    
    [PurchaseViewController handleProductsRetrievedFail];
    apEvent(@"facts", @"freemium", @"product error");
}

-(BOOL) cancelClicked: (BOOL) buying {
    [[CCDirector sharedDirector] resume];
    apEvent(@"facts", @"freemium", @"cancel click");
    [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[AnimalSelectLayer scene] backwards:true]];
    [purchase.view removeFromSuperview];
    return NO;
}

-(void) purchaseFinished: (BOOL) success {
    if (success) {
        [[CCDirector sharedDirector] resume];
        apEvent(@"facts", @"freemium", @"purchase complete");
        [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[AnimalViewLayer sceneWithAnimalKey:animal.key] backwards:false]];
        [purchase.view removeFromSuperview];
    } else {
        apEvent(@"facts", @"freemium", @"purchase fail");
    }
}

@end
