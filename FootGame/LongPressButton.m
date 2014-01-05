//
//  LongPressButton.m
//  FootGame
//
//  Created by Owyn Richen on 5/9/13.
//
//

#import "LongPressButton.h"
#import "CCParticleSystem+Extras.h"

@interface LongPressButton()

-(CCFiniteTimeAction *) startAnimation: (float) delay;

@end

@implementation LongPressButton

@synthesize delay;
@synthesize block;
@synthesize startTime;
@synthesize autoClickStarted;
@synthesize clockHand;

+(LongPressButton *) buttonWithBlock: (LongPressBlock) blk {
    // TODO: animate this better
    CCAutoScalingSprite *hand = [CCAutoScalingSprite spriteWithFile:@"clockhand.png" space:nil];
    hand.position = ccpToRatio(39,38);
    CCAutoScalingSprite *clock = [CCAutoScalingSprite spriteWithFile:@"clock.png" space:nil];
    
    [clock addChild:hand];
    
    LongPressButton *btn = [LongPressButton buttonWithNode:clock];
    
    btn.delay = 1.0;
    btn.baseScale = 1.0;
    btn.autoClickStarted = NO;
    btn.clockHand = hand;
    __block LongPressButton *b = btn;

    [btn addEvent:@"touch" withBlock:^(CCNode *sender) {
        if (!b.visible || b.autoClickStarted)
            return;
        
        
        [b.clockHand runAction:[b startAnimation:b.delay]];
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:b.baseScale * 1.2]];
        btn.startTime = [[NSDate date] timeIntervalSince1970];
    }];
    
    [btn addEvent:@"touchupoutside" withBlock:^(CCNode *sender) {
        if (!b.visible || b.autoClickStarted)
            return;
        
        [b.clockHand stopAllActions];
        b.clockHand.rotation = 0;
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:b.baseScale * 1.0]];
    }];

    if (blk != nil)
        btn.block = [blk copy];
    
    [btn addEvent:@"touchup" withBlock:^(CCNode *sender) {
        if (!b.visible || b.autoClickStarted)
            return;
        
        [b.clockHand stopAllActions];
        b.clockHand.rotation = 0;
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:b.baseScale * 1.0]];
        
        double endTime = [[NSDate date] timeIntervalSince1970];
        
        if (b.block != nil && endTime - btn.startTime > btn.delay && b.visible)
            b.block(sender);
        
    }];

    return btn;
}

-(void) autoClickAfter: (float) d {
    autoClickStarted = YES;
    [clockHand stopAllActions];
    clockHand.rotation = 0;
    __block LongPressButton *b = self;
    [clockHand runAction:[CCSequence actions:
                          [self startAnimation:d],
                          [CCDelayTime actionWithDuration:0.5],
                          [CCCallBlockN actionWithBlock:^(CCNode *node) {
        b.block(node);
    }], nil]];
}

-(void) setScale:(float)scale {
    _baseScale = scale;
    [super setScale:scale];
}

-(void) dealloc {
    self.block = nil;
    [super dealloc];
}

-(CCFiniteTimeAction *) startAnimation:(float)d {
    CCCallBlockN *start = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        CCParticleSystemQuad *emitter = [CCParticleSystemQuad particleWithFile:@"ExplodingRing.plist"];
        emitter.position = ccpToRatio(39,38);
        emitter.scale = 1.0;
        [node addChild:emitter z:1 tag:1];
        if (emitter.duration > -1) {
            [emitter cleanupWhenDone];
        }
    }];
    
    CCSequence *seq = [CCSequence actions:[CCRotateBy actionWithDuration:d angle:360], start, nil];
    return seq;
}

-(void) setColor:(ccColor3B)color {
    [super setColor:color];
    [clockHand setColor:color];
}

-(ccColor3B) color {
    return back.color;
}

-(GLubyte) opacity {
    return back.opacity;
}

-(void) setOpacity: (GLubyte) opacity {
    [super setOpacity:opacity];
    clockHand.opacity = opacity;
}

@end
