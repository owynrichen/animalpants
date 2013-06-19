//
//  LongPressButton.m
//  FootGame
//
//  Created by Owyn Richen on 5/9/13.
//
//

#import "LongPressButton.h"
#import "CCParticleSystem+Extras.h"

@implementation LongPressButton

@synthesize delay;
@synthesize block;
@synthesize startTime;

+(LongPressButton *) buttonWithBlock: (LongPressBlock) blk {
    // TODO: animate this better
    __block CCAutoScalingSprite *clockHand = [CCAutoScalingSprite spriteWithFile:@"clockhand.png" space:nil];
    clockHand.position = ccpToRatio(39,38);
    CCAutoScalingSprite *clock = [CCAutoScalingSprite spriteWithFile:@"clock.png" space:nil];
    
    [clock addChild:clockHand];
    
    LongPressButton *btn = [LongPressButton buttonWithNode:clock];
    
    btn.delay = 1.0;
    btn.baseScale = 1.0;
    __block LongPressButton *b = btn;

    [btn addEvent:@"touch" withBlock:^(CCNode *sender) {
        if (!b.visible)
            return;
        
        CCCallBlockN *start = [CCCallBlockN actionWithBlock:^(CCNode *node) {
            CCParticleSystemQuad *emitter = [CCParticleSystemQuad particleWithFile:@"ExplodingRing.plist"];
            emitter.position = ccpToRatio(39,38);
            emitter.scale = 1.0;
            [node addChild:emitter z:1 tag:1];
            if (emitter.duration > -1) {
                [emitter cleanupWhenDone];
            }
        }];
        
        CCSequence *seq = [CCSequence actions:[CCRotateBy actionWithDuration:b.delay angle:360], start, nil];
        [clockHand runAction:seq];
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:b.baseScale * 1.2]];
        btn.startTime = [[NSDate date] timeIntervalSince1970];
    }];
    
    [btn addEvent:@"touchupoutside" withBlock:^(CCNode *sender) {
        if (!b.visible)
            return;
        
        [clockHand stopAllActions];
        clockHand.rotation = 0;
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:b.baseScale * 1.0]];
    }];

    if (blk != nil)
        btn.block = [blk copy];
    
    [btn addEvent:@"touchup" withBlock:^(CCNode *sender) {
        if (!b.visible)
            return;
        
        [clockHand stopAllActions];
        clockHand.rotation = 0;
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:b.baseScale * 1.0]];
        
        double endTime = [[NSDate date] timeIntervalSince1970];
        
        if (b.block != nil && endTime - btn.startTime > 1.0 && b.visible)
            b.block(sender);
        
    }];

    return btn;
}

-(void) setScale:(float)scale {
    _baseScale = scale;
    [super setScale:scale];
}

-(void) dealloc {
    self.block = nil;
    [super dealloc];
}

@end
